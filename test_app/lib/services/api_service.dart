import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_app/constants/app_constants.dart';
import 'package:test_app/models/vpn_config.dart';
import 'package:test_app/services/storage_service.dart';

class ApiService {
  static const String baseUrl = AppConstants.apiBaseUrl;
  
  /// Получение VPN конфигурации (новый эндпоинт)
  /// location: название локации или "all" для любой локации
  static Future<VpnConfig> connectRequest(String deviceId, {String location = 'all', String? accessToken, bool? isVip}) async {
    final url = Uri.parse('$baseUrl/sessions/connect').replace(queryParameters: {'location': location});
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Device_id': deviceId,
    };
    
    // Добавляем is_vip в заголовок, если передан
    if (isVip != null) {
      headers['Is_Vip'] = isVip ? 'true' : 'false';
    }
    
    // Если есть access token, добавляем его для VIP пользователей
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    
    final response = await http.post(
      url,
      headers: headers,
    );
    
    if (response.statusCode == 403) {
      throw Exception('Устройство заблокировано');
    }
    
    if (response.statusCode == 401) {
      throw Exception('Ошибка авторизации');
    }
    
    if (response.statusCode != 200) {
      throw Exception('Ошибка подключения: ${response.statusCode} - ${response.body}');
    }
    
    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    return VpnConfig.fromJson(jsonData);
  }
  
  /// Получение VPN конфигурации для авторизованных пользователей
  static Future<VpnConfig> getVpnConfig({String location = 'all'}) async {
    String? accessToken = await StorageService.getAccessToken();
    String? deviceId = await StorageService.getDeviceId();
    bool isVip = await StorageService.getIsVip();
    
    if (deviceId == null || deviceId.isEmpty) {
      throw Exception('Нет device ID');
    }
    
    if (accessToken == null) {
      // Если нет токена, используем guest flow
      return connectRequest(deviceId, location: location, isVip: isVip);
    }
    
    try {
      return await connectRequest(deviceId, location: location, accessToken: accessToken, isVip: isVip);
    } catch (e) {
      // Если ошибка авторизации, пробуем обновить токен
      if (e.toString().contains('401') || e.toString().contains('авторизации')) {
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          // Повторяем запрос с новым токеном
          accessToken = await StorageService.getAccessToken();
          return await connectRequest(deviceId, location: location, accessToken: accessToken, isVip: isVip);
        } else {
          throw Exception('Не удалось обновить токен');
        }
      }
      rethrow;
    }
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
    
    // Получаем device_id для заголовка
    String deviceId = await StorageService.getDeviceId();
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Device_id': deviceId,
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Ошибка авторизации: ${response.statusCode} - ${response.body}');
    }
    
    // Ответ приходит как JSON объект
    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = jsonData['access_token'] as String;
    
    // В новом API refresh_token не возвращается, только access_token
    await StorageService.saveAccessToken(accessToken);
    
    return {
      'access_token': accessToken,
    };
  }
  
  /// Получение списка доступных локаций серверов
  static Future<List<String>> getServerLocations() async {
    final url = Uri.parse('$baseUrl/servers/get_all_locations_servers');
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
    );
    
    if (response.statusCode != 200) {
      throw Exception('Ошибка получения списка серверов: ${response.statusCode} - ${response.body}');
    }
    
    // Отладочная информация
    print('Response body: ${response.body}');
    
    final jsonData = jsonDecode(response.body);
    print('Parsed JSON: $jsonData');
    print('JSON type: ${jsonData.runtimeType}');
    
    if (jsonData is! List) {
      throw Exception('Ожидался массив, получен: ${jsonData.runtimeType}');
    }
    
    // Преобразуем каждый элемент в строку
    final locations = jsonData.map((item) {
      if (item is String) {
        return item.trim();
      }
      return item.toString().trim();
    }).where((location) => location.isNotEmpty).toList();
    
    print('Parsed locations: $locations');
    
    return locations;
  }
}

