import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Виджет отображения IP адреса
class IpAddressDisplay extends StatelessWidget {
  final String? ipAddress;

  const IpAddressDisplay({
    super.key,
    this.ipAddress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32, // Фиксированная высота для IP адреса (увеличена для избежания overflow)
      child: ipAddress == null
          ? const SizedBox.shrink() // Пустое место, если IP нет
          : Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.language,
                    color: AppColors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ipAddress!,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

