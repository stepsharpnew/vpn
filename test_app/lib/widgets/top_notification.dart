import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

enum NotificationType {
  success,
  error,
  info,
}

/// Красивое полупрозрачное уведомление сверху экрана
class TopNotification extends StatefulWidget {
  final String message;
  final NotificationType type;
  final Duration duration;
  final VoidCallback? onHide;

  const TopNotification({
    super.key,
    required this.message,
    this.type = NotificationType.success,
    this.duration = const Duration(seconds: 3),
    this.onHide,
  });

  /// Показать уведомление
  static void show({
    required BuildContext context,
    required String message,
    NotificationType type = NotificationType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => TopNotification(
        message: message,
        type: type,
        duration: duration,
        onHide: () {
          overlayEntry?.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  State<TopNotification> createState() => _TopNotificationState();
}

class _TopNotificationState extends State<TopNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Автоматически скрываем через указанное время с анимацией
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onHide?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.info:
        return Icons.info;
    }
  }

  Color _getIconColor() {
    switch (widget.type) {
      case NotificationType.success:
        return AppColors.connectedGreen;
      case NotificationType.error:
        return AppColors.disconnectedRed;
      case NotificationType.info:
        return AppColors.neonBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = MediaQuery.of(context).padding.top;

    return Positioned(
      top: safeAreaTop + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getIcon(),
                    color: _getIconColor(),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

