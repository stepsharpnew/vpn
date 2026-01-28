import 'package:flutter/services.dart';

/// Platform channel сервис для работы с VPN на Android
class VpnPlatformService {
  static const MethodChannel _channel = MethodChannel('com.example.test_app/vpn');

  /// Подключиться к VPN используя WireGuard конфиг
  static Future<bool> connectVPN(String wireGuardConfig) async {
    try {
      final result = await _channel.invokeMethod<bool>('connectVPN', {
        'config': wireGuardConfig,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'VPN_PERMISSION_REQUIRED') {
        throw Exception('Требуется разрешение на VPN. Пожалуйста, предоставьте разрешение.');
      }
      throw Exception('Ошибка подключения VPN: ${e.message}');
    }
  }

  /// Отключиться от VPN
  static Future<bool> disconnectVPN() async {
    try {
      final result = await _channel.invokeMethod<bool>('disconnectVPN');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Ошибка отключения VPN: ${e.message}');
    }
  }

  /// Получить статус VPN подключения
  static Future<bool> getVPNStatus() async {
    try {
      final result = await _channel.invokeMethod<bool>('getVPNStatus');
      return result ?? false;
    } on PlatformException catch (e) {
      return false;
    }
  }
}
