import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/widgets/ip_address_display.dart';

/// Виджет статуса подключения VPN
class ConnectionStatus extends StatelessWidget {
  final bool isConnected;
  final String? ipAddress;

  const ConnectionStatus({
    super.key,
    required this.isConnected,
    this.ipAddress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64, // Фиксированная высота, чтобы кнопка не прыгала (увеличена для IP)
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
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
          ),
          // IP адрес (показывается только при подключении, но место всегда зарезервировано)
          IpAddressDisplay(ipAddress: ipAddress),
        ],
      ),
    );
  }
}

