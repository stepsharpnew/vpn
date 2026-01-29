import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_app/models/amnezia_session.dart';

/// Сервис для работы с AmneziaWG WebUI API напрямую
class AmneziaApiService {
  /// Получить WireGuard конфигурацию для peer через Amnezia WebUI API
  /// serverIp: IP адрес сервера (где запущен WebUI API, обычно на порту 5000)
  /// peerId: ID peer - пробуем разные варианты (id, client_public_key)
  /// serverIpAddress: IP адрес сервера WireGuard (server_ip из backend, опционально)
  static Future<String> getPeerConfig(String serverIp, String peerId, {String? serverIpAddress}) async {
    // В Amnezia WebUI API для получения конфига используется client_public_key, а не id
    // Формат: /api/servers/{server_ip}/clients/{client_public_key}/config
    // Но также пробуем другие варианты
    
    final urls = <Uri>[];
    
    // Если есть server_ip, используем его (основной вариант)
    if (serverIpAddress != null && serverIpAddress.isNotEmpty) {
      // Основной вариант: /api/servers/{server_ip}/clients/{client_public_key}/config
      urls.add(Uri.parse('http://$serverIp:5000/api/servers/$serverIpAddress/clients/$peerId/config'));
    }
    
    // Альтернативные варианты
    urls.addAll([
      Uri.parse('http://$serverIp:5000/api/peers/$peerId/config'),
      Uri.parse('http://$serverIp:5000/api/clients/$peerId/config'),
      Uri.parse('http://$serverIp:5000/api/servers/awg0/clients/$peerId/config'),
      Uri.parse('http://$serverIp:5000/api/servers/awg0/peers/$peerId/config'),
    ]);
    
    Exception? lastError;
    String? lastResponseBody;
    
    for (final url in urls) {
      try {
        final response = await http.get(url);
        
        if (response.statusCode == 200) {
          return response.body;
        } else {
          lastError = Exception('HTTP ${response.statusCode}');
          lastResponseBody = response.body;
          // Пробуем следующий URL
          continue;
        }
      } catch (e) {
        lastError = Exception('Ошибка запроса: $e');
        continue;
      }
    }
    
    final errorMsg = 'Не удалось получить конфигурацию для peer ID: $peerId\n'
        'Пробовали URL: ${urls.map((u) => u.toString()).join(", ")}\n'
        'Последняя ошибка: ${lastError?.toString() ?? "неизвестно"}\n'
        'Ответ сервера: ${lastResponseBody ?? "нет"}';
    
    throw Exception(errorMsg);
  }

  /// Парсинг WireGuard конфига в структурированный формат
  static Map<String, dynamic> parseWireGuardConfig(String config) {
    final result = <String, dynamic>{};
    final lines = config.split('\n');
    
    String? currentSection;
    final sections = <String, Map<String, dynamic>>{};
    
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      
      if (line.startsWith('[') && line.endsWith(']')) {
        currentSection = line.substring(1, line.length - 1);
        sections[currentSection] = {};
        continue;
      }
      
      final parts = line.split('=');
      if (parts.length == 2) {
        final key = parts[0].trim();
        final value = parts[1].trim();
        
        if (currentSection != null) {
          sections[currentSection]![key] = value;
        } else {
          result[key] = value;
        }
      }
    }
    
    result['sections'] = sections;
    return result;
  }

  /// Получить данные сервера из конфига
  static Map<String, String> extractServerInfo(String config) {
    final parsed = parseWireGuardConfig(config);
    final peerSection = parsed['sections']?['Peer'] as Map<String, dynamic>? ?? {};
    
    return {
      'endpoint': peerSection['Endpoint'] as String? ?? '',
      'publicKey': peerSection['PublicKey'] as String? ?? '',
      'allowedIPs': peerSection['AllowedIPs'] as String? ?? '0.0.0.0/0',
    };
  }
}
