import 'package:flutter/material.dart';

class AloDocLogo extends StatelessWidget {
  final double height;

  const AloDocLogo({Key? key, this.height = 80}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_doc.png',
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          padding: const EdgeInsets.all(8),
          child: const Center(
            child: Text(
              'AloDoc',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D8B8B),
              ),
            ),
          ),
        );
      },
    );
  }
} 