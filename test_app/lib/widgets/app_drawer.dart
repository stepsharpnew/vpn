import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';

/// Боковое меню приложения
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                  AppColors.primaryBlue,
                  AppColors.primaryPurple,
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
              ],
            ),
          ),
        ],
      ),
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
        color: AppColors.primaryBlue,
      ),
      title: Text(
        title,
        style: const TextStyle(
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

