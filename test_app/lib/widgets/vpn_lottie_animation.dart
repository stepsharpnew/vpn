import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Виджет для отображения Lottie анимаций в зависимости от состояния VPN
class VpnLottieAnimation extends StatefulWidget {
  final VpnConnectionState state;
  final double? width;
  final double? height;

  const VpnLottieAnimation({
    super.key,
    required this.state,
    this.width,
    this.height,
  });

  @override
  State<VpnLottieAnimation> createState() => _VpnLottieAnimationState();
}

class _VpnLottieAnimationState extends State<VpnLottieAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  String? _currentAnimationPath;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _currentAnimationPath = _getAnimationPath(widget.state);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(VpnLottieAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      final newPath = _getAnimationPath(widget.state);
      if (newPath != _currentAnimationPath) {
        _fadeController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentAnimationPath = newPath;
            });
            _fadeController.forward();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _getAnimationPath(VpnConnectionState state) {
    switch (state) {
      case VpnConnectionState.disconnected:
        return 'assets/animatios/space boy developer.json';
      case VpnConnectionState.connecting:
        return 'assets/animatios/Space Purple.json';
      case VpnConnectionState.connected:
        return 'assets/animatios/world wide shipment, e-commerce platform, international commerce and shipping, e-commerce.json';
    }
  }

  bool _shouldRepeat(VpnConnectionState state) {
    // Все анимации бесконечные
    return true;
  }

  IconData _getIconForState(VpnConnectionState state) {
    switch (state) {
      case VpnConnectionState.disconnected:
        return Icons.cloud_off;
      case VpnConnectionState.connecting:
        return Icons.cloud_sync;
      case VpnConnectionState.connected:
        return Icons.cloud_done;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 300,
        child: _currentAnimationPath != null
            ? Lottie.asset(
                _currentAnimationPath!,
                key: ValueKey('${_currentAnimationPath}_${widget.state}'),
                fit: BoxFit.contain,
                repeat: _shouldRepeat(widget.state),
                animate: true,
                frameRate: FrameRate.max,
                options: LottieOptions(
                  enableMergePaths: true,
                ),
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Lottie error: $error');
                  debugPrint('Stack trace: $stackTrace');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconForState(widget.state),
                          size: 100,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ошибка загрузки анимации',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentAnimationPath ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Center(
                child: Icon(
                  _getIconForState(widget.state),
                  size: 100,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
      ),
    );
  }
}

/// Состояния подключения VPN
enum VpnConnectionState {
  disconnected,
  connecting,
  connected,
}
