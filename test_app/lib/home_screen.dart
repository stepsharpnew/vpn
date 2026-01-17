import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/models/server.dart';
import 'package:test_app/models/vpn_config.dart';
import 'package:test_app/services/api_service.dart';
import 'package:test_app/services/storage_service.dart';
import 'package:test_app/utils/country_flags.dart';
import 'package:test_app/widgets/app_drawer.dart';
import 'package:test_app/widgets/connect_button.dart';
import 'package:test_app/widgets/gradient_background.dart';
import 'package:test_app/widgets/menu_button.dart';
import 'package:test_app/widgets/server_selection_bottom_sheet.dart';
import 'package:test_app/widgets/top_notification.dart';
import 'package:test_app/widgets/vpn_lottie_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnected = false;
  bool _isLoading = false;
  String? _deviceId;
  VpnConfig? _currentVpnConfig;
  Server _selectedServer = Server.auto;
  List<Server> _availableServers = [Server.auto];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Инициализируем device_id и is_vip при первом запуске
      final deviceId = await StorageService.getDeviceId();
      await StorageService.getIsVip(); // Инициализирует is_vip как false, если еще не установлен
      setState(() {
        _deviceId = deviceId;
      });
      
      // Загружаем список серверов
      await _loadServers();
    } catch (e) {
      if (mounted) {
        TopNotification.show(
          context: context,
          message: 'Ошибка инициализации: $e',
          type: NotificationType.error,
        );
      }
    }
  }

  Future<void> _loadServers() async {
    try {
      final locations = await ApiService.getServerLocations();
      // Отладочная информация
      debugPrint('Загружено локаций: ${locations.length}');
      debugPrint('Локации: $locations');
      
      setState(() {
        _availableServers = [
          Server.auto,
          ...locations.map((location) {
            debugPrint('Создаю сервер для локации: $location');
            return Server(
              name: location,
              location: location,
            );
          }),
        ];
      });
      
      debugPrint('Всего серверов в списке: ${_availableServers.length}');
    } catch (e) {
      // Если не удалось загрузить, оставляем только Auto
      debugPrint('Ошибка загрузки серверов: $e');
      if (mounted) {
        TopNotification.show(
          context: context,
          message: 'Ошибка загрузки серверов: $e',
          type: NotificationType.error,
        );
      }
    }
  }

  Future<void> _toggleConnection() async {
    if (_isLoading) return;

    if (_isConnected) {
      // Отключение
      setState(() {
        _isConnected = false;
        _currentVpnConfig = null;
      });
      return;
    }

    // Подключение
    setState(() {
      _isLoading = true;
    });

    try {
      VpnConfig? vpnConfig;

      // Инициализируем device_id если нужно
      if (_deviceId == null) {
        await _initializeApp();
      }

      // Используем новый единый метод подключения
      // Он автоматически определяет, есть ли access token и использует его
      // Используем выбранный сервер, или "all" если выбран Auto
      final location = _selectedServer.isAuto ? 'all' : _selectedServer.location;
      
      // Добавляем задержку 2 секунды для имитации подключения
      await Future.delayed(const Duration(seconds: 2));
      
      vpnConfig = await ApiService.getVpnConfig(location: location);

      // Здесь должна быть логика подключения к VPN серверу
      // Пока просто сохраняем конфигурацию
      setState(() {
        _isConnected = true;
        _currentVpnConfig = vpnConfig;
        _isLoading = false;
      });

      if (mounted) {
        TopNotification.show(
          context: context,
          message: 'Вы успешно подключены',
          type: NotificationType.success,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        TopNotification.show(
          context: context,
          message: 'Ошибка подключения: $e',
          type: NotificationType.error,
        );
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openMenu() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _openServerSelection() {
    if (_isLoading) return; // Не открываем во время подключения
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ServerSelectionBottomSheet(
          servers: _availableServers,
          selectedServer: _selectedServer,
          state: _getServerSelectionState(),
          onServerSelected: (server) {
            setState(() {
              _selectedServer = server;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  ServerSelectionState _getServerSelectionState() {
    if (_isLoading) {
      return ServerSelectionState.connecting;
    } else if (_isConnected) {
      return ServerSelectionState.connected;
    } else {
      return ServerSelectionState.disconnected;
    }
  }

  VpnConnectionState get _connectionState {
    if (_isLoading) {
      return VpnConnectionState.connecting;
    } else if (_isConnected) {
      return VpnConnectionState.connected;
    } else {
      return VpnConnectionState.disconnected;
    }
  }

  Color _getPingColor(int ping) {
    if (ping < 50) {
      return AppColors.connectedGreen;
    } else if (ping < 100) {
      return AppColors.neonBlue;
    } else {
      return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.darkBackground,
      endDrawer: const AppDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Градиентный фон
            const GradientBackground(),
            // Основной контент
            Column(
              children: [
                const SizedBox(height: 40),
                // Lottie анимация в центре
                Expanded(
                  flex: 3,
                  child: Center(
                    child: VpnLottieAnimation(
                      state: _connectionState,
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.4,
                    ),
                  ),
                ),
                // Кнопка Connect/Disconnect
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _isLoading
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.neonBlue.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.neonBlue,
                              ),
                            ),
                          ),
                        )
                      : ConnectButton(
                          isConnected: _isConnected,
                          onTap: _toggleConnection,
                        ),
                ),
                const SizedBox(height: 24),
                // Кнопка выбора сервера
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _openServerSelection,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getServerSelectionState() == ServerSelectionState.connected
                                ? AppColors.connectedGreen.withOpacity(0.3)
                                : AppColors.disconnectedGrey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // Иконка или флаг сервера
                                if (_selectedServer.isAuto)
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.neonPurple.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      color: AppColors.neonPurple,
                                      size: 24,
                                    ),
                                  )
                                else
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.darkBackground.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        CountryFlags.getFlag(_selectedServer.name),
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 16),
                                // Название сервера
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedServer.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (!_selectedServer.isAuto)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.speed,
                                            size: 12,
                                            color: _getPingColor(_selectedServer.displayPing),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_selectedServer.displayPing} ms',
                                            style: TextStyle(
                                              color: _getPingColor(_selectedServer.displayPing),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            // Стрелка вниз
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
            // Кнопка меню в правом верхнем углу
            Positioned(
              top: 20,
              right: 20,
              child: MenuButton(onTap: _openMenu),
            ),
          ],
        ),
      ),
    );
  }
}
