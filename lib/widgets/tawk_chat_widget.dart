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
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.position = 'fixed'
        ..style.bottom = '0'
        ..style.right = '0'
        ..id = 'tawk-chat-container';

      // Add the Tawk.to script
      final script = html.ScriptElement()
        ..text = '''
          var Tawk_API=Tawk_API||{}, Tawk_LoadStart=new Date();
          (function(){
            var s1=document.createElement("script"),s0=document.getElementsByTagName("script")[0];
            s1.async=true;
            s1.src='https://embed.tawk.to/6846faf7f5d578190ca9f989/1itak8m8r';
            s1.charset='UTF-8';
            s1.setAttribute('crossorigin','*');
            s0.parentNode.insertBefore(s1,s0);
          })();

          // Adjust the button position
          Tawk_API.customStyle = {
            visibility : {
              desktop: {
                position : 'br',
                xOffset: 20,
                yOffset: 100 // Increased offset from bottom
              },
              mobile: {
                position : 'br',
                xOffset: 20,
                yOffset: 100 // Increased offset from bottom
              }
            }
          };
        ''';

      hostElement.children.add(script);

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
      return SizedBox.expand(
        child: HtmlElementView(
          viewType: _iframeElementId,
        ),
      );
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