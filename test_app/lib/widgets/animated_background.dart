import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Фон с изображением карты мира и светящимися линиями
class AnimatedBackground extends StatelessWidget {
  final bool isConnected;

  const AnimatedBackground({
    super.key,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Изображение фона
          Image.asset(
            'assets/images/new_phone.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Если изображение не найдено, показываем темный фон
              return Container(
                color: AppColors.darkBackground,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
