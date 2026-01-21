import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/services/storage_service.dart';
import 'package:test_app/widgets/gradient_background.dart';

class TariffPlansScreen extends StatelessWidget {
  final VoidCallback? onVipActivated;

  const TariffPlansScreen({super.key, this.onVipActivated});

  static const _crownAnim = 'assets/animatios/Premium_CallerID.json';
  static const _goProAnim = 'assets/animatios/Pro Animation 3rd.json';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            const GradientBackground(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Тарифные планы',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.neonPurple.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: Lottie.asset(
                            _crownAnim,
                            repeat: true,
                            animate: true,
                            frameRate: FrameRate.max,
                            options: LottieOptions(enableMergePaths: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'VIP / Go Pro',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Быстрее, стабильнее, больше локаций. (Пока демо-экран)',
                                style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.22,
                      child: Lottie.asset(
                        _goProAnim,
                        repeat: true,
                        animate: true,
                        frameRate: FrameRate.max,
                        options: LottieOptions(enableMergePaths: true),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PlanCard(
                    title: 'VIP • 1 месяц',
                    price: '4.99 \$',
                    subtitle: 'Все локации • Приоритетная скорость',
                    accent: AppColors.neonPurple,
                  ),
                  const SizedBox(height: 12),
                  _PlanCard(
                    title: 'VIP • 12 месяцев',
                    price: '39.99 \$',
                    subtitle: 'Лучшая цена • Все возможности VIP',
                    accent: AppColors.neonBlue,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Пока демо: активируем VIP флаг локально
                        await StorageService.setIsVip(true);
                        onVipActivated?.call();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('VIP активирован (демо)')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Продолжить (демо)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final Color accent;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.35), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withOpacity(0.5), width: 1),
            ),
            child: Icon(Icons.stars, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.95),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

