/// Модель сессии AmneziaWG из ответа /sessions/connect
class AmneziaSession {
  final String clientIp;
  final String clientPrivateKey;
  final String clientPublicKey;
  final double createdAt;
  final String id;
  final String name;
  final bool obfuscationEnabled;
  final Map<String, dynamic> obfuscationParams;
  final String presharedKey;
  final String serverId;
  final String serverName;
  final String status;

  AmneziaSession({
    required this.clientIp,
    required this.clientPrivateKey,
    required this.clientPublicKey,
    required this.createdAt,
    required this.id,
    required this.name,
    required this.obfuscationEnabled,
    required this.obfuscationParams,
    required this.presharedKey,
    required this.serverId,
    required this.serverName,
    required this.status,
  });

  factory AmneziaSession.fromJson(Map<String, dynamic> json) {
    return AmneziaSession(
      clientIp: json['client_ip'] as String? ?? '',
      clientPrivateKey: json['client_private_key'] as String? ?? '',
      clientPublicKey: json['client_public_key'] as String? ?? '',
      createdAt: (json['created_at'] as num?)?.toDouble() ?? 0.0,
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      obfuscationEnabled: json['obfuscation_enabled'] as bool? ?? false,
      obfuscationParams: json['obfuscation_params'] as Map<String, dynamic>? ?? {},
      presharedKey: json['preshared_key'] as String? ?? '',
      serverId: json['server_id'] as String? ?? '',
      serverName: json['server_name'] as String? ?? '',
      status: json['status'] as String? ?? 'inactive',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_ip': clientIp,
      'client_private_key': clientPrivateKey,
      'client_public_key': clientPublicKey,
      'created_at': createdAt,
      'id': id,
      'name': name,
      'obfuscation_enabled': obfuscationEnabled,
      'obfuscation_params': obfuscationParams,
      'preshared_key': presharedKey,
      'server_id': serverId,
      'server_name': serverName,
      'status': status,
    };
  }
}
