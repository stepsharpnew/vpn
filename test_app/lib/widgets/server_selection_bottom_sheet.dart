import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/models/server.dart';

enum ServerSelectionState {
  disconnected,
  connecting,
  connected,
}

/// Выезжающая панель выбора сервера (2/3 экрана)
class ServerSelectionBottomSheet extends StatelessWidget {
  final List<Server> servers;
  final Server? selectedServer;
  final ServerSelectionState state;
  final Function(Server) onServerSelected;

  const ServerSelectionBottomSheet({
    super.key,
    required this.servers,
    this.selectedServer,
    required this.state,
    required this.onServerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = screenHeight * 2 / 3;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.neonBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Ручка для перетаскивания
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Заголовок
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Выберите сервер',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Индикатор состояния
                _buildStateIndicator(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Список серверов
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: servers.length,
              itemBuilder: (context, index) {
                final server = servers[index];
                final isSelected = selectedServer?.name == server.name;
                final isDisabled = state == ServerSelectionState.connecting;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isDisabled ? null : () => onServerSelected(server),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.neonBlue.withOpacity(0.2)
                              : AppColors.darkBackground.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.neonBlue
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Иконка или флаг
                            if (server.isAuto)
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.neonPurple.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.neonPurple,
                                  size: 20,
                                ),
                              )
                            else
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.neonBlue.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: AppColors.neonBlue,
                                  size: 20,
                                ),
                              ),
                            const SizedBox(width: 16),
                            // Название сервера
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    server.name,
                                    style: TextStyle(
                                      color: isDisabled
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (!server.isAuto && server.location.isNotEmpty)
                                    Text(
                                      server.location,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Индикатор выбора
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.neonBlue,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateIndicator() {
    Color color;
    String text;
    IconData icon;

    switch (state) {
      case ServerSelectionState.connecting:
        color = AppColors.neonBlue;
        text = 'Connecting';
        icon = Icons.sync;
        break;
      case ServerSelectionState.connected:
        color = AppColors.connectedGreen;
        text = 'Connected';
        icon = Icons.check_circle;
        break;
      case ServerSelectionState.disconnected:
        color = AppColors.disconnectedGrey;
        text = 'Disconnected';
        icon = Icons.circle;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state == ServerSelectionState.connecting)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          )
        else
          Icon(
            icon,
            size: 16,
            color: color,
          ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

