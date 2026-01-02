import 'package:flutter/material.dart';

/// Заголовок приложения в градиентном стиле
class GradientTitle extends StatelessWidget {
  const GradientTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'VPN',
      style: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }
}

