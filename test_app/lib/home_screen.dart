import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/constants/app_constants.dart';
import 'package:test_app/models/country.dart';
import 'package:test_app/widgets/app_drawer.dart';
import 'package:test_app/widgets/connection_status.dart';
import 'package:test_app/widgets/country_list_bottom_sheet.dart';
import 'package:test_app/widgets/country_selector_button.dart';
import 'package:test_app/widgets/gradient_header.dart';
import 'package:test_app/widgets/gradient_title.dart';
import 'package:test_app/widgets/menu_button.dart';
import 'package:test_app/widgets/power_button.dart';
import 'package:test_app/widgets/section_header.dart';
import 'package:test_app/widgets/speed_display.dart';
import 'package:test_app/widgets/world_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnected = false;
  String? _ipAddress;
  Country _selectedCountry = const Country(
    name: AppConstants.defaultCountry,
    flag: AppConstants.defaultCountryFlag,
  );

  // Примерные значения скорости (можно заменить на реальные)
  String get _downloadSpeed => _isConnected ? '10.2' : '0.0';
  String get _uploadSpeed => _isConnected ? '5.2' : '0.0';

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
      if (_isConnected) {
        // Генерируем примерный IP адрес при подключении
        _ipAddress = _generateFakeIp();
      } else {
        // Очищаем IP при отключении
        _ipAddress = null;
      }
    });
  }

  /// Генерирует примерный IP адрес для демонстрации
  String _generateFakeIp() {
    // Генерируем случайный IP в диапазоне VPN серверов
    final random = DateTime.now().millisecondsSinceEpoch % 255;
    return '185.${100 + (random % 50)}.${50 + (random % 100)}.${100 + (random % 155)}';
  }

  void _onCountrySelected(Country country) {
    setState(() {
      _selectedCountry = country;
    });
  }

  void _showCountrySelector() {
    CountryListBottomSheet.show(
      context: context,
      countries: AppConstants.availableCountries,
      selectedCountry: _selectedCountry.name,
      onCountrySelected: _onCountrySelected,
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openMenu() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const AppDrawer(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Верхняя часть с градиентом
            Expanded(
              flex: 1,
              child: GradientHeader(
                child: Stack(
                  children: [
                    // Фиксированная структура, чтобы элементы не прыгали
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Заголовок VPN (фиксированная высота)
                        const SizedBox(height: 20),
                        const GradientTitle(),
                        const SizedBox(height: 40),
                        // Кнопка питания (фиксированная высота)
                        PowerButton(
                          isConnected: _isConnected,
                          onTap: _toggleConnection,
                        ),
                        const SizedBox(height: 24),
                        // Статус подключения (фиксированная высота)
                        ConnectionStatus(
                          isConnected: _isConnected,
                          ipAddress: _ipAddress,
                        ),
                        const SizedBox(height: 20), // Компенсация для фиксированной высоты
                      ],
                    ),
                    // Кнопка меню в правом верхнем углу
                    Positioned(
                      top: 20,
                      right: 20,
                      child: MenuButton(
                        onTap: _openMenu,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Нижняя часть с информацией
          Expanded(
            flex: 1,
            child: Container(
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpeedDisplay(
                      downloadSpeed: _downloadSpeed,
                      uploadSpeed: _uploadSpeed,
                    ),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Location:'),
                    const SizedBox(height: 16),
                    const WorldMap(),
                    const SizedBox(height: 32),
                    CountrySelectorButton(
                      countryName: _selectedCountry.name,
                      countryFlag: _selectedCountry.flag,
                      onTap: _showCountrySelector,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
