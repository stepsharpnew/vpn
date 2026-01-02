import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Кнопка питания для подключения/отключения VPN с анимацией
class PowerButton extends StatefulWidget {
  final bool isConnected;
  final VoidCallback onTap;

  const PowerButton({
    super.key,
    required this.isConnected,
    required this.onTap,
  });

  @override
  State<PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<PowerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Фиксированный размер кнопки (не меняется)
    const buttonSize = 120.0;
    const iconSize = 60.0;
    
    // Параметры зависят от состояния подключения
    final shadowBlur = widget.isConnected ? 30.0 : 20.0;
    final shadowOffset = widget.isConnected ? 15.0 : 10.0;
    final waveCount = widget.isConnected ? 3 : 2;
    final waveMaxSize = widget.isConnected ? 180.0 : 140.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: waveMaxSize,
          height: waveMaxSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Волны вокруг кнопки
              ...List.generate(waveCount, (index) {
                final delay = index * 0.3;
                final animationValue = (_waveAnimation.value + delay) % 1.0;
                final waveSize = buttonSize + (waveMaxSize - buttonSize) * animationValue;
                final opacity = (1.0 - animationValue) * 0.3;

                return Positioned(
                  child: Container(
                    width: waveSize,
                    height: waveSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withOpacity(opacity),
                        width: 2,
                      ),
                    ),
                  ),
                );
              }),
              // Кнопка с тенью (без масштабирования)
              GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.isConnected
                            ? AppColors.connectedGreen.withOpacity(0.4)
                            : Colors.black.withOpacity(0.2),
                        blurRadius: shadowBlur,
                        offset: Offset(0, shadowOffset),
                        spreadRadius: widget.isConnected ? 5 : 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: shadowBlur * 0.7,
                        offset: Offset(0, shadowOffset * 0.5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.power_settings_new,
                    size: iconSize,
                    color: widget.isConnected
                        ? AppColors.connectedGreen
                        : AppColors.disconnectedGrey,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
