import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Виджет карты мира с маркером локации
class WorldMap extends StatelessWidget {
  const WorldMap({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Изображение карты (placeholder)
          _buildMapPlaceholder(),
          // Маркер локации
          const Positioned(
            top: 40,
            child: Icon(
              Icons.location_on,
              color: AppColors.primaryBlue,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    // Placeholder (серый контейнер с иконкой карты)
    // Чтобы использовать реальное изображение:
    // 1. Добавьте world_map.png в папку assets/images/
    // 2. Замените этот метод на Image.asset с errorBuilder
    
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.map,
        size: 60,
        color: AppColors.textSecondary,
      ),
    );
  }
}

