import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/journey_form_state.dart';
import 'core/providers/result_state.dart';
import 'core/providers/location_state.dart';
import 'ui/screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLanguageState()),
        ChangeNotifierProvider(create: (_) => JourneyFormState()),
        ChangeNotifierProvider(create: (_) => ResultState()),
        ChangeNotifierProvider(create: (_) => LocationState()),
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
          localizationsDelegates:
              const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ] +
              [AppLocalizations.delegate],
          supportedLocales: const [Locale('en'), Locale('si'), Locale('ta')],
          home: const HomeScreen(),
        );
      },
    );
  }
}
