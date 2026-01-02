import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/constants/app_constants.dart';
import 'package:test_app/models/country.dart';
import 'package:test_app/widgets/connection_status.dart';
import 'package:test_app/widgets/country_list_bottom_sheet.dart';
import 'package:test_app/widgets/country_selector_button.dart';
import 'package:test_app/widgets/gradient_header.dart';
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
  Country _selectedCountry = const Country(
    name: AppConstants.defaultCountry,
    flag: AppConstants.defaultCountryFlag,
  );

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VPN')),
      body: Column(
        children: [
          // Верхняя часть с градиентом
          Expanded(
            flex: 1,
            child: GradientHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PowerButton(
                    isConnected: _isConnected,
                    onTap: _toggleConnection,
                  ),
                  const SizedBox(height: 24),
                  ConnectionStatus(isConnected: _isConnected),
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
                    SpeedDisplay(downloadSpeed: '10.2', uploadSpeed: '5.2'),
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
    );
  }
}
