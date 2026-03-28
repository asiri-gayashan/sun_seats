import 'package:flutter/material.dart';

import '../widgets/nav_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/footer_section.dart';
import '../widgets/journey_input_form.dart';
import '../widgets/result_panel.dart';
import '../widgets/features_grid.dart';
import '../widgets/faq_accordion.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: Column(
          children: [
            const NavBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const HeroSection(),
                    const SizedBox(height: 24),
                    _buildMainGrid(context),
                    const SizedBox(height: 80),
                    const FeaturesGrid(),
                    const SizedBox(height: 80),
                    const FaqAccordion(),
                    const SizedBox(height: 80),
                    const FooterSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildMainGrid(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: isMobile
            ? const Column(
                children: [
                  JourneyInputForm(),
                  SizedBox(height: 24),
                  ResultPanel(state: ResultPanelState.success), // Preview static state
                ],
              )
            : const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: JourneyInputForm()),
                  SizedBox(width: 24),
                  Expanded(child: ResultPanel(state: ResultPanelState.success)),
                ],
              ),
      ),
    );
  }
}


