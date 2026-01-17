class VpnConfig {
  final String serverIp;
  final int serverPort;
  final String username;
  final String password;
  final String? dns;
  final String? publicKey;
  final Map<String, dynamic>? configData;

  VpnConfig({
    required this.serverIp,
    required this.serverPort,
    required this.username,
    required this.password,
    this.dns,
    this.publicKey,
    this.configData,
  });

  factory VpnConfig.fromJson(Map<String, dynamic> json) {
    // Поддержка как старого формата (server_ip, server_port), так и нового (ip_address, port)
    final serverIp = json['server_ip'] as String? ?? json['ip_address'] as String? ?? '';
    final serverPort = json['server_port'] as int? ?? 
                       (json['port'] != null ? int.tryParse(json['port'].toString()) : null) ?? 0;
    
    // username и password могут отсутствовать в новом API
    final username = json['username'] as String? ?? '';
    final password = json['password'] as String? ?? '';
    
    return VpnConfig(
      serverIp: serverIp,
      serverPort: serverPort,
      username: username,
      password: password,
      dns: json['dns'] as String?,
      publicKey: json['public_key'] as String?,
      configData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'server_ip': serverIp,
      'server_port': serverPort,
      'username': username,
      'password': password,
      'dns': dns,
      'public_key': publicKey,
      'config_data': configData,
    };
  }
}

