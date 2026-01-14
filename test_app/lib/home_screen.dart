import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/constants/app_constants.dart';
import 'package:test_app/models/country.dart';
import 'package:test_app/models/vpn_config.dart';
import 'package:test_app/services/api_service.dart';
import 'package:test_app/services/storage_service.dart';
import 'package:test_app/widgets/app_drawer.dart';
import 'package:test_app/widgets/connect_button.dart';
import 'package:test_app/widgets/gradient_background.dart';
import 'package:test_app/widgets/menu_button.dart';
import 'package:test_app/widgets/vpn_lottie_animation.dart';
import 'package:test_app/widgets/vpn_status_card.dart';

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
  Country _selectedCountry = const Country(
    name: AppConstants.defaultCountry,
    flag: AppConstants.defaultCountryFlag,
  );

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка инициализации: $e')),
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
      // Используем название страны как локацию, или "all" если не выбрана
      final location = _selectedCountry.name.isNotEmpty ? _selectedCountry.name : 'all';
      
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Подключение установлено'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка подключения: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openMenu() {
    _scaffoldKey.currentState?.openEndDrawer();
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
                // Статус подключения
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: VpnStatusCard(
                    isConnected: _isConnected,
                    serverName: _selectedCountry.name,
                  ),
                ),
                const SizedBox(height: 32),
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
