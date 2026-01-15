import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Большая кнопка Connect/Disconnect
class ConnectButton extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onTap;

  const ConnectButton({
    super.key,
    required this.isConnected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isConnected
                  ? [
                      AppColors.neonPurple.withOpacity(0.7),
                      AppColors.neonMagenta.withOpacity(0.7),
                    ]
                  : [
                      AppColors.neonBlue,
                      AppColors.neonPurple,
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isConnected
                        ? AppColors.neonMagenta
                        : AppColors.neonBlue)
                    .withOpacity(isConnected ? 0.3 : 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              isConnected ? 'Disconnect' : 'Connect',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

