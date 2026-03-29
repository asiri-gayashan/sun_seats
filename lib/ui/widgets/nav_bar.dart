import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart'; // Temporary for AppLanguageState
import '../../core/theme/app_theme.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(bottom: BorderSide(color: AppTheme.midGray, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wb_sunny,
                  color: AppTheme.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ShadeSeat LK',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: AppTheme.darkText,
                ),
              ),
            ],
          ),
          const _LanguageSelector(),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final languageState = context.watch<AppLanguageState>();
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      // Mobile uses a dropdown or a simple toggle menu to save space
      return PopupMenuButton<Locale>(
        initialValue: languageState.appLocale,
        onSelected: (locale) => languageState.changeLanguage(locale),
        icon: const Icon(Icons.language, color: AppTheme.primaryBlue),
        itemBuilder: (context) => const [
          PopupMenuItem(value: Locale('en'), child: Text('English (EN)')),
          PopupMenuItem(value: Locale('si'), child: Text('සිංහල (SI)')),
          PopupMenuItem(value: Locale('ta'), child: Text('தமிழ் (TA)')),
        ],
      );
    }

    // Web uses pill buttons
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LanguagePillButton(
          locale: const Locale('en'),
          text: 'EN',
          isSelected: languageState.appLocale.languageCode == 'en',
        ),
        const SizedBox(width: 4),
        _LanguagePillButton(
          locale: const Locale('si'),
          text: 'සිං',
          isSelected: languageState.appLocale.languageCode == 'si',
        ),
        const SizedBox(width: 4),
        _LanguagePillButton(
          locale: const Locale('ta'),
          text: 'த',
          isSelected: languageState.appLocale.languageCode == 'ta',
        ),
      ],
    );
  }
}

class _LanguagePillButton extends StatelessWidget {
  final Locale locale;
  final String text;
  final bool isSelected;

  const _LanguagePillButton({
    required this.locale,
    required this.text,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<AppLanguageState>().changeLanguage(locale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightGreen : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.midGray,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.primaryGreen : AppTheme.darkText,
          ),
        ),
      ),
    );
  }
}
