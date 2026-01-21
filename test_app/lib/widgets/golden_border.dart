import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:test_app/constants/app_colors.dart';

/// Виджет с позолоченной переливающейся рамкой
class GoldenBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final BorderRadius? borderRadius;

  const GoldenBorder({
    super.key,
    required this.child,
    this.borderWidth = 2.0,
    this.borderRadius,
  });

  @override
  State<GoldenBorder> createState() => _GoldenBorderState();
}

class _GoldenBorderState extends State<GoldenBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            border: Border.all(
              width: widget.borderWidth,
              color: _getAnimatedColor(),
            ),
            boxShadow: [
              BoxShadow(
                color: _getAnimatedColor().withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }

  Color _getAnimatedColor() {
    final value = _controller.value;
    // Создаем переливающийся эффект от золотого к желтому и обратно
    final hue = (value * 360 + 45) % 360; // От 45 (золотой) до 45+360
    final saturation = 0.8 + (math.sin(value * math.pi * 2) * 0.2);
    final lightness = 0.5 + (math.sin(value * math.pi * 2) * 0.1);
    
    return HSLColor.fromAHSL(
      1.0,
      hue,
      saturation.clamp(0.0, 1.0),
      lightness.clamp(0.0, 1.0),
    ).toColor();
  }
}
