import 'package:test_app/models/country.dart';

/// Константы приложения
class AppConstants {
  AppConstants._();

  static const List<Country> availableCountries = [
    Country(name: 'Germany', flag: '🇩🇪'),
    Country(name: 'United States', flag: '🇺🇸'),
    Country(name: 'United Kingdom', flag: '🇬🇧'),
    Country(name: 'France', flag: '🇫🇷'),
    Country(name: 'Japan', flag: '🇯🇵'),
    Country(name: 'Canada', flag: '🇨🇦'),
    Country(name: 'Australia', flag: '🇦🇺'),
    Country(name: 'Netherlands', flag: '🇳🇱'),
    Country(name: 'Switzerland', flag: '🇨🇭'),
    Country(name: 'Sweden', flag: '🇸🇪'),
  ];

  static const String defaultCountry = 'Germany';
  static const String defaultCountryFlag = '🇩🇪';
}

