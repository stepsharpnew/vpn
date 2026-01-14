import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  
  // Keys
  static const String _deviceIdKey = 'device_id';
  static const String _isVipKey = 'is_vip';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  /// Получить device_id или сгенерировать новый
  static Future<String> getDeviceId() async {
    String? deviceId = await _storage.read(key: _deviceIdKey);
    
    if (deviceId == null || deviceId.isEmpty) {
      // Генерируем новый UUID
      deviceId = await _generateDeviceId();
      await _storage.write(key: _deviceIdKey, value: deviceId);
    }
    
    return deviceId;
  }
  
  /// Генерация нового device_id
  static Future<String> _generateDeviceId() async {
    const uuid = Uuid();
    return uuid.v4();
  }
  
  /// Сохранить access token
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }
  
  /// Получить access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }
  
  /// Сохранить refresh token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }
  
  /// Получить refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  /// Удалить все токены (logout)
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
  
  /// Проверить, есть ли access token
  static Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
  
  /// Проверить, есть ли refresh token
  static Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty;
  }
  
  /// Получить is_vip или инициализировать как false
  static Future<bool> getIsVip() async {
    final isVipStr = await _storage.read(key: _isVipKey);
    if (isVipStr == null || isVipStr.isEmpty) {
      // Инициализируем как false при первом запуске
      await setIsVip(false);
      return false;
    }
    return isVipStr == 'true' || isVipStr == '1';
  }
  
  /// Сохранить is_vip
  static Future<void> setIsVip(bool isVip) async {
    await _storage.write(key: _isVipKey, value: isVip ? 'true' : 'false');
  }
}

