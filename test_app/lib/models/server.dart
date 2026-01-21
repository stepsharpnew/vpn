/// Модель сервера для VPN
class Server {
  final String name;
  final String location;
  final bool isAuto;
  final bool isVipOffer;
  final int? ping; // Задержка в миллисекундах

  const Server({
    required this.name,
    required this.location,
    this.isAuto = false,
    this.isVipOffer = false,
    this.ping,
  });

  static const Server auto = Server(
    name: 'Auto',
    location: 'Auto',
    isAuto: true,
  );

  /// Псевдо-сервер: открывает экран тарифов/подписки
  static const Server vipOffer = Server(
    name: 'VIP / Go Pro',
    location: 'Тарифные планы',
    isVipOffer: true,
  );

  /// Генерирует случайную задержку для демонстрации (в реальном приложении это должно приходить с бекенда)
  int get displayPing {
    if (isAuto) return 0;
    if (isVipOffer) return 0;
    if (ping != null) return ping!;
    // Генерируем случайную задержку от 20 до 150 мс
    return 20 + (name.hashCode % 130);
  }
}

