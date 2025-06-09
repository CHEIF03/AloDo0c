import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class TawkChatWidget extends StatefulWidget {
  const TawkChatWidget({Key? key}) : super(key: key);

  @override
  State<TawkChatWidget> createState() => _TawkChatWidgetState();
}

class _TawkChatWidgetState extends State<TawkChatWidget> {
  final String _iframeElementId = 'tawk-chat-iframe';
  
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Create a div to hold the Tawk.to script
      final hostElement = html.DivElement()
        ..id = 'tawk-chat-container'
        ..style.position = 'fixed'
        ..style.bottom = '120px'  // Increased significantly to avoid bottom nav
        ..style.right = '20px'
        ..style.zIndex = '1000'
        ..style.marginBottom = '60px'; // Additional margin from bottom

      // Initialize Tawk_API before loading the script
      final initScript = html.ScriptElement()
        ..text = '''
          var Tawk_API = Tawk_API || {};
          Tawk_API.onLoad = function() {
            console.log('Tawk widget loaded');
            Tawk_API.hideWidget();
            setTimeout(function() {
              Tawk_API.showWidget();
              // Force the widget to be higher up
              var iframe = document.getElementById('tawk-chat-container');
              if (iframe) {
                iframe.style.bottom = '120px';
                iframe.style.marginBottom = '60px';
              }
            }, 1000);
          };
          Tawk_API.onChatMaximized = function() {
            console.log('Chat window maximized');
            // Ensure chat window doesn't go below safe area
            var iframe = document.getElementById('tawk-chat-container');
            if (iframe) {
              iframe.style.bottom = '120px';
            }
          };
          Tawk_API.onChatMinimized = function() {
            console.log('Chat window minimized');
          };
          Tawk_API.customStyle = {
            visibility: {
              desktop: {
                position: 'br',
                xOffset: '20',
                yOffset: '180'  // Significantly increased offset from bottom
              },
              mobile: {
                position: 'br',
                xOffset: '20',
                yOffset: '180'  // Significantly increased offset from bottom
              }
            },
            zIndex: 1000
          };
        ''';

      // Add the Tawk.to script
      final script = html.ScriptElement()
        ..async = true
        ..src = 'https://embed.tawk.to/6846faf7f5d578190ca9f989/1itak8m8r'
        ..charset = 'UTF-8'
        ..setAttribute('crossorigin', '*');

      // Add scripts to the document
      html.document.body!.children.add(hostElement);
      html.document.head!.children.add(initScript);
      html.document.head!.children.add(script);

      // Register the view factory
      ui.platformViewRegistry.registerViewFactory(
        _iframeElementId,
        (int viewId) => hostElement,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    // For non-web platforms, show a button to open in browser
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://www.tawk.to/wp-content/uploads/2020/04/tawk-stickerr.png',
            width: 48,
            height: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chat disponible sur le web',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final Uri url = Uri.parse('https://tawk.to/chat/6846faf7f5d578190ca9f989/1itak8m8r');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D8B8B),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Ouvrir dans le navigateur'),
          ),
        ],
      ),
    );
  }
}