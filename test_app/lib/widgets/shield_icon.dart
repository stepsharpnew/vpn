import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Большой щит в центре экрана
class ShieldIcon extends StatelessWidget {
  final bool isConnected;

  const ShieldIcon({
    super.key,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isConnected
              ? [
                  AppColors.neonBlue,
                  AppColors.neonPurple,
                ]
              : [
                  AppColors.neonBlue.withOpacity(0.6),
                  AppColors.neonPurple.withOpacity(0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isConnected ? AppColors.neonBlue : AppColors.neonBlue.withOpacity(0.3))
                .withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Внутренний градиент
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // Иконка щита
          Center(
            child: Icon(
              Icons.security,
              size: 70,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          // Обводка
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.neonBlue.withOpacity(0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}


