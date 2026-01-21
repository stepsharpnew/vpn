import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/services/api_service.dart';
import 'package:test_app/services/storage_service.dart';
import 'package:test_app/widgets/top_notification.dart';

/// Боковое меню приложения
class AppDrawer extends StatefulWidget {
  final VoidCallback? onVipStatusChanged;

  const AppDrawer({super.key, this.onVipStatusChanged});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isVip = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVipStatus();
  }

  Future<void> _loadVipStatus() async {
    final isVip = await StorageService.getIsVip();
    setState(() {
      _isVip = isVip;
    });
  }

  Future<void> _toggleVip() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isVip) {
        await ApiService.disableVip();
        setState(() {
          _isVip = false;
        });
        if (mounted) {
          TopNotification.show(
            context: context,
            message: 'VIP статус деактивирован',
            type: NotificationType.success,
          );
          widget.onVipStatusChanged?.call();
        }
      } else {
        await ApiService.enableVip();
        setState(() {
          _isVip = true;
        });
        if (mounted) {
          TopNotification.show(
            context: context,
            message: 'VIP статус активирован',
            type: NotificationType.success,
          );
          widget.onVipStatusChanged?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        TopNotification.show(
          context: context,
          message: 'Ошибка: $e',
          type: NotificationType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.darkSurface,
      child: Column(
        children: [
          // Заголовок с аватаром
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.neonBlue,
                  AppColors.neonPurple,
                ],
              ),
            ),
            child: Column(
              children: [
                // Аватар пользователя
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Пользователь',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'user@example.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Список пунктов меню
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Переключатель VIP
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isVip
                        ? AppColors.neonPurple.withOpacity(0.2)
                        : AppColors.darkBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isVip
                          ? AppColors.neonPurple
                          : AppColors.textSecondary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.diamond,
                            color: _isVip ? AppColors.neonPurple : AppColors.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isVip ? 'VIP активирован' : 'VIP неактивен',
                            style: TextStyle(
                              color: _isVip ? AppColors.neonPurple : AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonPurple),
                          ),
                        )
                      else
                        Switch(
                          value: _isVip,
                          onChanged: (_) => _toggleVip(),
                          activeColor: AppColors.neonPurple,
                        ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.textSecondary, height: 1),
                _DrawerItem(
                  icon: Icons.settings,
                  title: 'Настройки',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Переход на экран настроек
                  },
                ),
                _DrawerItem(
                  icon: Icons.diamond,
                  title: 'Тарифные планы',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Переход на экран тарифов
                  },
                ),
                _DrawerItem(
                  icon: Icons.help_outline,
                  title: 'FAQ и поддержка',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Переход на экран поддержки
                  },
                ),
                _DrawerItem(
                  icon: Icons.star_outline,
                  title: 'Оцените приложение',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Открыть страницу в магазине
                  },
                ),
                _DrawerItem(
                  icon: Icons.share,
                  title: 'Поделиться',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Поделиться приложением
                  },
                ),
                _DrawerItem(
                  icon: Icons.info_outline,
                  title: 'О программе',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Показать информацию о приложении
                  },
                ),
                const Divider(color: AppColors.textSecondary, height: 1),
                _DrawerItem(
                  icon: Icons.phone_android,
                  title: 'Показать Device ID',
                  onTap: () {
                    Navigator.pop(context);
                    _showDeviceId(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeviceId(BuildContext context) async {
    final deviceId = await StorageService.getDeviceId();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: const Text(
            'Device ID',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SelectableText(
            deviceId,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: deviceId));
                if (context.mounted) {
                  Navigator.pop(context);
                  TopNotification.show(
                    context: context,
                    message: 'Device ID скопирован в буфер обмена',
                    type: NotificationType.success,
                  );
                }
              },
              child: const Text(
                'Скопировать',
                style: TextStyle(color: AppColors.neonBlue),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Закрыть',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Элемент меню
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.neonBlue,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}

