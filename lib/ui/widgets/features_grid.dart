import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FeaturesGrid extends StatelessWidget {
  const FeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Text(
              'Why use SunSeat?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: isMobile ? 3.5 : 2.5,
              children: const [
                _FeatureCard(
                  title: 'No account needed',
                  icon: Icons.no_accounts,
                  desc: 'Use instantly without signing up.',
                ),
                _FeatureCard(
                  title: 'Sri Lanka routes',
                  icon: Icons.directions_bus,
                  desc: 'Optimised for long-distance travel.',
                ),
                _FeatureCard(
                  title: 'Works offline',
                  icon: Icons.wifi_off,
                  desc: 'Calculations run right on your phone.',
                ),
                _FeatureCard(
                  title: 'Sinhala & Tamil',
                  icon: Icons.translate,
                  desc: 'Fully translated into local languages.',
                ),
                _FeatureCard(
                  title: 'UV index warning',
                  icon: Icons.wb_sunny_rounded,
                  desc: 'Get alerts for extreme sun intensity.',
                ),
                _FeatureCard(
                  title: 'Free forever',
                  icon: Icons.money_off,
                  desc: 'No subscriptions, no hidden fees.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;

  const _FeatureCard({
    required this.title,
    required this.desc,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.midGray, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.midGray,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
