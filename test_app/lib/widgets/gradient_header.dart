import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Верхняя часть экрана с градиентом
class GradientHeader extends StatelessWidget {
  final Widget child;

  const GradientHeader({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryPurple,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Center(child: child),
    );
  }
}

