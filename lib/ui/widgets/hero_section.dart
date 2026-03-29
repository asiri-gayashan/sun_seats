import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Small pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.midGray, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Sri Lanka bus & train journeys',
                  style: TextStyle(fontSize: 12, color: AppTheme.darkText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // H1 Heading
          Text(
            'Ride the shady side',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: isMobile ? 22 : 26,
              color: AppTheme.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            'Enter your journey details and we’ll tell you exactly which\nside to sit on to avoid the sun.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme
                  .primaryBlue, // "secondary colour" per spec. Using primaryBlue or darkText with opacity. Let's use darkText lightly.
            ),
          ),
        ],
      ),
    );
  }
}
