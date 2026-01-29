import 'dart:convert';
import 'package:test_app/models/amnezia_session.dart';
import 'package:test_app/services/storage_service.dart';
import 'package:test_app/services/vpn_platform_service.dart';
import 'package:test_app/services/amnezia_api_service.dart';
import 'package:test_app/services/api_service.dart';

/// Сервис для работы с VPN подключением AmneziaWG
class VpnService {
  /// Получить сохраненную сессию из secure storage
  static Future<AmneziaSession?> getSavedSession() async {
    final jsonStr = await StorageService.getLastConnectResponseJson();
    if (jsonStr == null || jsonStr.isEmpty) {
      return null;
    }
    
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AmneziaSession.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Создать WireGuard конфиг из данных сессии
  static String createWireGuardConfig(AmneziaSession session, String endpoint, String serverPublicKey, {String? dns}) {
    final buffer = StringBuffer();
    
    // Секция [Interface]
    buffer.writeln('[Interface]');
    buffer.writeln('PrivateKey = ${session.clientPrivateKey}');
    buffer.writeln('Address = ${session.clientIp}/32');
    if (dns != null && dns.isNotEmpty) {
      buffer.writeln('DNS = $dns');
    }
    
    // Применяем obfuscation параметры если включены
    if (session.obfuscationEnabled && session.obfuscationParams.isNotEmpty) {
      final params = session.obfuscationParams;
      buffer.writeln('# Obfuscation parameters');
      if (params.containsKey('Jc')) buffer.writeln('# Jc = ${params['Jc']}');
      if (params.containsKey('Jmin')) buffer.writeln('# Jmin = ${params['Jmin']}');
      if (params.containsKey('Jmax')) buffer.writeln('# Jmax = ${params['Jmax']}');
      if (params.containsKey('S1')) buffer.writeln('# S1 = ${params['S1']}');
      if (params.containsKey('S2')) buffer.writeln('# S2 = ${params['S2']}');
      if (params.containsKey('H1')) buffer.writeln('# H1 = ${params['H1']}');
      if (params.containsKey('H2')) buffer.writeln('# H2 = ${params['H2']}');
      if (params.containsKey('H3')) buffer.writeln('# H3 = ${params['H3']}');
      if (params.containsKey('H4')) buffer.writeln('# H4 = ${params['H4']}');
    }
    
    buffer.writeln('');
    
    // Секция [Peer]
    buffer.writeln('[Peer]');
    buffer.writeln('PublicKey = $serverPublicKey');
    buffer.writeln('Endpoint = $endpoint');
    buffer.writeln('AllowedIPs = 0.0.0.0/0');
    if (session.presharedKey.isNotEmpty) {
      buffer.writeln('PresharedKey = ${session.presharedKey}');
    }
    buffer.writeln('PersistentKeepalive = 25');
    
    return buffer.toString();
  }

  /// Получить полный WireGuard конфиг через Amnezia WebUI API
  /// serverWebUiAddress: адрес сервера с WebUI API (например, "192.168.1.100" или "vpn.example.com")
  /// session: сессия AmneziaWG с данными peer
  static Future<String> getWireGuardConfigFromApi(String serverWebUiAddress, AmneziaSession session) async {
    try {
      // Пробуем использовать client_public_key (основной вариант для Amnezia WebUI API)
      // Формат: /api/servers/{server_ip}/clients/{client_public_key}/config
      // Также пробуем id на случай если API использует его
      try {
        return await AmneziaApiService.getPeerConfig(
          serverWebUiAddress, 
          session.clientPublicKey,
          serverIpAddress: session.serverIp.isNotEmpty ? session.serverIp : null,
        );
      } catch (e) {
        // Если не получилось с client_public_key, пробуем с id
        return await AmneziaApiService.getPeerConfig(
          serverWebUiAddress, 
          session.id,
          serverIpAddress: session.serverIp.isNotEmpty ? session.serverIp : null,
        );
      }
    } catch (e) {
      throw Exception('Не удалось получить конфигурацию через Amnezia WebUI API: $e');
    }
  }

  /// Подключиться к VPN используя сохраненную сессию
  /// serverWebUiAddress: адрес сервера с WebUI API (опционально, если не указан - попробуем получить из сессии)
  static Future<bool> connect({String? serverWebUiAddress}) async {
    final session = await getSavedSession();
    if (session == null) {
      throw Exception('Нет сохраненной сессии. Сначала выполните подключение к серверу.');
    }

    try {
      String wireGuardConfig;
      
      // Пробуем получить конфиг через Amnezia WebUI API
      if (serverWebUiAddress != null && serverWebUiAddress.isNotEmpty) {
        // Используем переданный адрес и сессию (пробуем client_public_key и id)
        wireGuardConfig = await getWireGuardConfigFromApi(serverWebUiAddress, session);
      } else {
        // Пробуем извлечь адрес из server_name или использовать дефолтный
        // В реальности server_name может содержать IP или домен
        // Пока что требуем явное указание адреса
        throw Exception('Необходимо указать адрес сервера WebUI API. Используйте connect(serverWebUiAddress: "IP_АДРЕС")');
      }
      
      // Подключаемся к VPN используя полученный конфиг
      return await connectWithConfig(wireGuardConfig);
      
    } catch (e) {
      rethrow;
    }
  }

  /// Подключиться к VPN используя WireGuard конфиг
  static Future<bool> connectWithConfig(String wireGuardConfig) async {
    try {
      return await VpnPlatformService.connectVPN(wireGuardConfig);
    } catch (e) {
      throw Exception('Ошибка подключения VPN: $e');
    }
  }

  /// Отключиться от VPN
  static Future<bool> disconnect() async {
    try {
      return await VpnPlatformService.disconnectVPN();
    } catch (e) {
      throw Exception('Ошибка отключения VPN: $e');
    }
  }

  /// Проверить статус подключения
  static Future<bool> isConnected() async {
    try {
      return await VpnPlatformService.getVPNStatus();
    } catch (e) {
      return false;
    }
  }

  /// Очистить сохраненную сессию
  static Future<void> clearSession() async {
    await StorageService.clearLastConnectResponse();
  }
}
