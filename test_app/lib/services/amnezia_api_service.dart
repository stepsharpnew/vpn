import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_app/models/amnezia_session.dart';

/// Сервис для работы с AmneziaWG WebUI API напрямую
class AmneziaApiService {
  /// Получить WireGuard конфигурацию для peer через Amnezia WebUI API
  /// serverIp: IP адрес сервера (где запущен WebUI API, обычно на порту 5000)
  /// peerId: ID peer (client_public_key из сессии)
  static Future<String> getPeerConfig(String serverIp, String peerId) async {
    final url = Uri.parse('http://$serverIp:5000/api/peers/$peerId/config');
    
    final response = await http.get(url);
    
    if (response.statusCode != 200) {
      throw Exception('Ошибка получения конфигурации: ${response.statusCode} - ${response.body}');
    }
    
    return response.body;
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
