import 'package:flutter/material.dart';

/// Виджет кнопки подключения/отключения VPN
/// Это пример переиспользуемого виджета
class ConnectionButton extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onPressed;

  const ConnectionButton({
    super.key,
    required this.isConnected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(isConnected ? 'Отключить' : 'Подключить'),
    );
  }
}

