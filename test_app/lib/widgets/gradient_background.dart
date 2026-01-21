import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Градиентный фон с сине-фиолетовым градиентом и анимацией снега
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Градиентный фон
        Container(
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
        ),
        // Анимация снега на весь фон
        IgnorePointer(
          child: Lottie.asset(
            'assets/animatios/Snow Off white.json',
            fit: BoxFit.cover,
            repeat: true,
            animate: true,
            frameRate: FrameRate.max,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
