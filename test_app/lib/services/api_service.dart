import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_app/constants/app_constants.dart';
import 'package:test_app/models/vpn_config.dart';
import 'package:test_app/services/storage_service.dart';

class ApiService {
  static const String baseUrl = AppConstants.apiBaseUrl;
  
  /// Guest flow: запрос на подключение
  static Future<VpnConfig> connectRequest(String deviceId) async {
    final url = Uri.parse('$baseUrl/connect/request');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'device_id': deviceId}),
    );
    
    if (response.statusCode == 403) {
      throw Exception('Устройство заблокировано');
    }
    
    if (response.statusCode != 200) {
      throw Exception('Ошибка подключения: ${response.statusCode}');
    }
    
    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    return VpnConfig.fromJson(jsonData);
  }
  
  /// Registered/VIP flow: получение VPN конфигурации
  static Future<VpnConfig> getVpnConfig() async {
    final url = Uri.parse('$baseUrl/users/me/vpn-config');
    
    String? accessToken = await StorageService.getAccessToken();
    
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Нет access token');
    }
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    
    if (response.statusCode == 401) {
      // Токен истек, пробуем обновить
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        // Повторяем запрос с новым токеном
        accessToken = await StorageService.getAccessToken();
        final retryResponse = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );
        
        if (retryResponse.statusCode != 200) {
          throw Exception('Ошибка получения конфигурации: ${retryResponse.statusCode}');
        }
        
        final jsonData = jsonDecode(retryResponse.body) as Map<String, dynamic>;
        return VpnConfig.fromJson(jsonData);
      } else {
        throw Exception('Не удалось обновить токен');
      }
    }
    
    if (response.statusCode != 200) {
      throw Exception('Ошибка получения конфигурации: ${response.statusCode}');
    }
    
    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    return VpnConfig.fromJson(jsonData);
  }
  
  /// Обновление access token
  static Future<bool> refreshAccessToken() async {
    final url = Uri.parse('$baseUrl/auth/refresh');
    
    String? refreshToken = await StorageService.getRefreshToken();
    
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    
    if (response.statusCode != 200) {
      return false;
    }
    
    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    final newAccessToken = jsonData['access_token'] as String;
    
    await StorageService.saveAccessToken(newAccessToken);
    return true;
  }
  
  /// Логин пользователя
  static Future<Map<String, String>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Ошибка авторизации: ${response.statusCode}');
    }
    
    // Ответ приходит как JSON объект
    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = jsonData['access_token'] as String;
    final refreshToken = jsonData['refresh_token'] as String;
    
    await StorageService.saveAccessToken(accessToken);
    await StorageService.saveRefreshToken(refreshToken);
    
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}

