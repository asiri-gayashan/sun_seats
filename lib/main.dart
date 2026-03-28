import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLanguageState()),
      ],
      child: const ShadeSeatApp(),
    ),
  );
}

class AppLanguageState extends ChangeNotifier {
  Locale _appLocale = const Locale('en');

  Locale get appLocale => _appLocale;

  void changeLanguage(Locale type) {
    if (_appLocale == type) {
      return;
    }
    _appLocale = type;
    notifyListeners();
  }
}

class ShadeSeatApp extends StatelessWidget {
  const ShadeSeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguageState>(
      builder: (context, languageState, child) {
        return MaterialApp(
          title: 'ShadeSeat LK',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          locale: languageState.appLocale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ] + [AppLocalizations.delegate],
          supportedLocales: const [
            Locale('en'),
            Locale('si'),
            Locale('ta'),
          ],
          home: const TempHomeScreen(),
        );
      },
    );
  }
}

class TempHomeScreen extends StatelessWidget {
  const TempHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Phase 1 Setup Complete!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Text(l10n.startLocation, style: Theme.of(context).textTheme.bodyLarge),
            Text(l10n.endLocation, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<AppLanguageState>().changeLanguage(const Locale('en')),
                  child: const Text('EN'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.read<AppLanguageState>().changeLanguage(const Locale('si')),
                  child: const Text('සිංහල'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.read<AppLanguageState>().changeLanguage(const Locale('ta')),
                  child: const Text('தமிழ்'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
