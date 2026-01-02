import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Кнопка питания для подключения/отключения VPN
class PowerButton extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onTap;

  const PowerButton({
    super.key,
    required this.isConnected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          Icons.power_settings_new,
          size: 60,
          color: isConnected ? AppColors.connectedGreen : AppColors.disconnectedGrey,
        ),
      ),
    );
  }
}

