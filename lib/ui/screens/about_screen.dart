import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkText),
        title: const Text('About ShadeSeat LK', style: TextStyle(color: AppTheme.darkText, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.midGray, height: 0.5),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wb_sunny, color: AppTheme.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text('ShadeSeat LK', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('Version 1.0.0', style: TextStyle(color: AppTheme.midGray, fontSize: 14)),
              const SizedBox(height: 32),
              const Text(
                'ShadeSeat LK calculates the exact astronomical position of the sun during your journey to recommend which side of the vehicle will keep you in the shade.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppTheme.darkText, height: 1.5),
              ),
              const SizedBox(height: 48),
              const Text('Credits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkText)),
              const SizedBox(height: 16),
              const Text('• SunCalc algorithm by Vladimir Agafonkin\n• Map routing by Google Maps Platform', style: TextStyle(fontSize: 14, color: AppTheme.midGray, height: 1.5)),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: () {}, child: const Text('Privacy Policy', style: TextStyle(color: AppTheme.primaryBlue))),
                  const Text(' | ', style: TextStyle(color: AppTheme.midGray)),
                  TextButton(onPressed: () {}, child: const Text('Contact Us', style: TextStyle(color: AppTheme.primaryBlue))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
