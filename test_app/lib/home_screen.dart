import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/models/server.dart';
import 'package:test_app/services/api_service.dart';
import 'package:test_app/services/storage_service.dart';
import 'package:test_app/widgets/app_drawer.dart';
import 'package:test_app/widgets/connect_button.dart';
import 'package:test_app/widgets/gradient_background.dart';
import 'package:test_app/widgets/menu_button.dart';
import 'package:test_app/widgets/server_selection_bottom_sheet.dart';
import 'package:test_app/widgets/top_notification.dart';
import 'package:test_app/widgets/vpn_lottie_animation.dart';
import 'package:test_app/tariff_plans_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnected = false;
  bool _isLoading = false;
  String? _deviceId;
  Server _selectedServer = Server.auto;
  List<Server> _availableServers = [Server.vipOffer, Server.auto];
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Инициализируем device_id и is_vip при первом запуске
      final deviceId = await StorageService.getDeviceId();
      final isVip = await StorageService.getIsVip(); // Инициализирует is_vip как false, если еще не установлен
      setState(() {
        _deviceId = deviceId;
        _isVip = isVip;
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
      setState(() {
        if (_isVip) {
          // Если VIP - все сервера с позолоченными рамками
          _availableServers = [
            Server.auto,
            ...locations.map((location) => Server(
                  name: location,
                  location: location,
                )),
          ];
        } else {
          // Если не VIP - VIP плашка сверху, затем auto, затем остальные сервера
          _availableServers = [
            Server.vipOffer,
            Server.auto,
            ...locations.map((location) => Server(
                  name: location,
                  location: location,
                )),
          ];
        }
      });
    } catch (e) {
      // Если не удалось загрузить, оставляем только Auto
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
      });
      return;
    }

    // Подключение
    setState(() {
      _isLoading = true;
    });

    try {
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
      
      await ApiService.getVpnConfig(location: location);

      // Здесь должна быть логика подключения к VPN серверу
      // Пока просто сохраняем конфигурацию
      setState(() {
        _isConnected = true;
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
    final parentContext = context;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ServerSelectionBottomSheet(
          servers: _availableServers,
          selectedServer: _selectedServer,
          state: _getServerSelectionState(),
          isVip: _isVip,
          onServerSelected: (server) {
            if (server.isVipOffer) {
              Navigator.pop(context);
              Navigator.of(parentContext).push(
                MaterialPageRoute(
                  builder: (_) => TariffPlansScreen(
                    onVipActivated: () async {
                      final isVip = await StorageService.getIsVip();
                      if (mounted) {
                        setState(() {
                          _isVip = isVip;
                        });
                        await _loadServers(); // Перезагружаем список серверов
                      }
                    },
                  ),
                ),
              );
              return;
            }

            setState(() => _selectedServer = server);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.darkBackground,
      endDrawer: AppDrawer(
        onVipStatusChanged: () async {
          final isVip = await StorageService.getIsVip();
          if (mounted) {
            setState(() {
              _isVip = isVip;
            });
            await _loadServers(); // Перезагружаем список серверов
          }
        },
      ),
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
                                // Иконка сервера
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _selectedServer.isAuto
                                        ? AppColors.neonPurple.withOpacity(0.3)
                                        : AppColors.neonBlue.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _selectedServer.isAuto
                                        ? Icons.auto_awesome
                                        : Icons.location_on,
                                    color: _selectedServer.isAuto
                                        ? AppColors.neonPurple
                                        : AppColors.neonBlue,
                                    size: 20,
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
                                    if (!_selectedServer.isAuto && _selectedServer.location.isNotEmpty)
                                      Text(
                                        _selectedServer.location,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            if (_isVip)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: AppColors.neonPurple.withOpacity(0.25),
                                  border: Border.all(
                                    color: AppColors.neonPurple.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'VIP',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
