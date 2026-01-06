import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Карточка статуса VPN с информацией о сервере
class VpnStatusCard extends StatelessWidget {
  final bool isConnected;
  final String serverName;

  const VpnStatusCard({
    super.key,
    required this.isConnected,
    this.serverName = 'Optimal Server',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected
              ? AppColors.connectedGreen.withOpacity(0.3)
              : AppColors.disconnectedGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Статус Connected/Not Connected
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppColors.connectedGreen
                      : AppColors.disconnectedGrey,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isConnected ? Icons.check : Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isConnected ? 'Connected' : 'Not Connected',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Информация о сервере
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                serverName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Auto',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

