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
  
  // API Configuration
  // Для Android эмулятора используйте: http://10.0.2.2:8000
  // Для iOS симулятора используйте: http://localhost:8000
  // Для реального устройства используйте IP адрес вашего компьютера в локальной сети
  // Например: http://192.168.1.100:8000 (замените на ваш IP)
  // Чтобы узнать IP: Windows - ipconfig, Mac/Linux - ifconfig
  static const String apiBaseUrl = 'http://10.0.2.2:8000'; // Android эмулятор
  // static const String apiBaseUrl = 'http://localhost:8000'; // iOS симулятор
  // static const String apiBaseUrl = 'http://192.168.1.100:8000'; // Реальное устройство (замените IP)
}

