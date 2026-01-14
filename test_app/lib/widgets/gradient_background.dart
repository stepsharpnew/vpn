import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Градиентный фон с сине-фиолетовым градиентом
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A0E27), // Темно-синий
            const Color(0xFF1A0F3A), // Темно-фиолетовый
            const Color(0xFF1E1B4A), // Сине-фиолетовый
            const Color(0xFF2D1B5A), // Более яркий фиолетово-синий
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }
}
