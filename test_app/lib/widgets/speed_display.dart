import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Виджет отображения скорости соединения
class SpeedDisplay extends StatelessWidget {
  final String downloadSpeed;
  final String uploadSpeed;

  const SpeedDisplay({
    super.key,
    required this.downloadSpeed,
    required this.uploadSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Speed:',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SpeedItem(
              icon: Icons.arrow_downward,
              label: 'Download',
              value: downloadSpeed,
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.textSecondary.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(horizontal: 24),
            ),
            _SpeedItem(
              icon: Icons.arrow_upward,
              label: 'Upload',
              value: uploadSpeed,
            ),
          ],
        ),
      ],
    );
  }
}

/// Элемент скорости (Download/Upload)
class _SpeedItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpeedItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Mbps',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

