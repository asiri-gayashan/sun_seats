import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FaqAccordion extends StatelessWidget {
  const FaqAccordion({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Text('Frequently Asked Questions', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            _buildExpansionTile('How does it know where the sun is?', 'We calculate the exact astronomical position of the sun based on your journey coordinates, date, and time using standard sun alignment formulas.'),
            _buildExpansionTile('How accurate is this?', 'The algorithm maps accurately to within 5 degrees of azimuth for the entire path, sampling hundreds of points along the road to determine the side with the most sun.'),
            _buildExpansionTile('What routes are supported?', 'Any mapped road or train line in Sri Lanka. As long as Google Maps can trace it, we can calculate the sun for it.'),
            _buildExpansionTile('Does it work for trains?', 'Yes, just select "Train" as your transit mode so the map routes via railways instead of highways.'),
            _buildExpansionTile('What about cloudy days?', 'Clouds will physically block the direct sun, but our calculation tells you where the UV source is, which is helpful to avoid glare even on overcast days.'),
            _buildExpansionTile('Is my location data saved?', 'No. Location is processed locally to find routes and is not retained continuously or uploaded to an advertising server.'),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String q, String a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.midGray, width: 0.5),
      ),
      child: ExpansionTile(
        title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.darkText)),
        iconColor: AppTheme.primaryGreen,
        collapsedIconColor: AppTheme.darkText,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(a, style: const TextStyle(fontSize: 13, color: AppTheme.darkText, height: 1.5), textAlign: TextAlign.left),
          ),
        ],
      ),
    );
  }
}
