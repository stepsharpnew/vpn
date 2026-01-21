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
    this.borderWidth = 1.0,
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
                color: _getAnimatedColor().withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 0,
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
    // Золотой цвет: HSL примерно (45-50, 0.8-1.0, 0.5-0.6)
    final hue = 45 + (math.sin(value * math.pi * 2) * 10); // От 35 до 55 (золотой диапазон)
    final saturation = 0.85 + (math.sin(value * math.pi * 2 + math.pi / 2) * 0.15); // 0.7-1.0
    final lightness = 0.55 + (math.sin(value * math.pi * 2) * 0.1); // 0.45-0.65
    
    return HSLColor.fromAHSL(
      1.0,
      hue.clamp(35.0, 55.0),
      saturation.clamp(0.7, 1.0),
      lightness.clamp(0.45, 0.65),
    ).toColor();
  }
}
