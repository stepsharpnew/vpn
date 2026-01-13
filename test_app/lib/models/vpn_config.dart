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
    return VpnConfig(
      serverIp: json['server_ip'] as String,
      serverPort: json['server_port'] as int,
      username: json['username'] as String,
      password: json['password'] as String,
      dns: json['dns'] as String?,
      publicKey: json['public_key'] as String?,
      configData: json['config_data'] as Map<String, dynamic>?,
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

