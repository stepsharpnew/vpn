import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/constants/app_constants.dart';
import 'package:test_app/models/country.dart';
import 'package:test_app/models/vpn_config.dart';
import 'package:test_app/services/api_service.dart';
import 'package:test_app/services/storage_service.dart';
import 'package:test_app/widgets/animated_background.dart';
import 'package:test_app/widgets/app_drawer.dart';
import 'package:test_app/widgets/bottom_navigation.dart';
import 'package:test_app/widgets/connect_button.dart';
import 'package:test_app/widgets/menu_button.dart';
import 'package:test_app/widgets/vpn_status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnected = false;
  bool _isLoading = false;
  int _currentNavIndex = 0;
  String? _deviceId;
  VpnConfig? _currentVpnConfig;
  Country _selectedCountry = const Country(
    name: AppConstants.defaultCountry,
    flag: AppConstants.defaultCountryFlag,
  );

  @override
  void initState() {
    super.initState();
    _initializeDeviceId();
  }

  Future<void> _initializeDeviceId() async {
    try {
      final deviceId = await StorageService.getDeviceId();
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

      // Проверяем, есть ли access token
      final hasAccessToken = await StorageService.hasAccessToken();

      if (hasAccessToken) {
        // Registered/VIP flow
        try {
          vpnConfig = await ApiService.getVpnConfig();
        } catch (e) {
          // Если ошибка авторизации, пробуем обновить токен
          final hasRefresh = await StorageService.hasRefreshToken();
          if (hasRefresh) {
            final refreshed = await ApiService.refreshAccessToken();
            if (refreshed) {
              vpnConfig = await ApiService.getVpnConfig();
            } else {
              throw Exception('Не удалось обновить токен. Требуется повторная авторизация.');
            }
          } else {
            throw Exception('Требуется авторизация');
          }
        }
      } else {
        // Guest flow
        if (_deviceId == null) {
          await _initializeDeviceId();
        }
        vpnConfig = await ApiService.connectRequest(_deviceId!);
      }

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

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openMenu() {
    _scaffoldKey.currentState?.openEndDrawer();
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
            // Анимированный фон (не кликабельный)
            IgnorePointer(child: AnimatedBackground(isConnected: _isConnected)),
            // Основной контент
            Column(
              children: [
                // Картинка выше - занимает верхнюю часть
                Expanded(flex: 5, child: Container()),
                // Кнопка Connect под картинкой (опущена ниже)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _isLoading
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : ConnectButton(
                          isConnected: _isConnected,
                          onTap: _toggleConnection,
                        ),
                ),
                const SizedBox(height: 24),
                // Карточка статуса
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: VpnStatusCard(
                    isConnected: _isConnected,
                    serverName: _selectedCountry.name,
                  ),
                ),
                const Spacer(),
                // Нижняя навигация
                VpnBottomNavigation(
                  currentIndex: _currentNavIndex,
                  onTap: _onNavTap,
                ),
              ],
            ),
            // Кнопка меню в правом верхнем углу
            Positioned(top: 20, right: 20, child: MenuButton(onTap: _openMenu)),
          ],
        ),
      ),
    );
  }
}
