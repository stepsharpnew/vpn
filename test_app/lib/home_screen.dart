import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/constants/app_constants.dart';
import 'package:test_app/models/country.dart';
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
  int _currentNavIndex = 0;
  Country _selectedCountry = const Country(
    name: AppConstants.defaultCountry,
    flag: AppConstants.defaultCountryFlag,
  );

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
    });
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
                Expanded(flex: 2, child: Container()),
                // Кнопка Connect под картинкой
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConnectButton(
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
