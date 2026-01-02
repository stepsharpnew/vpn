import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Кнопка выбора страны
class CountrySelectorButton extends StatelessWidget {
  final String countryName;
  final String countryFlag;
  final VoidCallback onTap;

  const CountrySelectorButton({
    super.key,
    required this.countryName,
    required this.countryFlag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.primaryBlue,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              countryFlag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(
              countryName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

