import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Виджет статуса подключения VPN
class ConnectionStatus extends StatelessWidget {
  final bool isConnected;

  const ConnectionStatus({
    super.key,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Цветная точка статуса
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isConnected ? AppColors.connectedGreen : AppColors.disconnectedRed,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        // Текст статуса
        Text(
          isConnected ? 'Connected' : 'Disconnected',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

