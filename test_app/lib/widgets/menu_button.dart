import 'package:flutter/material.dart';

/// Кнопка бургер-меню в правом верхнем углу
class MenuButton extends StatelessWidget {
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.menu,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

