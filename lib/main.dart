import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/journey_form_state.dart';
import 'core/providers/result_state.dart';
import 'core/providers/location_state.dart';
import 'ui/screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JourneyFormState()),
        ChangeNotifierProvider(create: (_) => ResultState()),
        ChangeNotifierProvider(create: (_) => LocationState()),
      ],
      child: const SunSeatApp(),
    ),
  );
}

class SunSeatApp extends StatelessWidget {
  const SunSeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SunSeat',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
