// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:sun_seats/main.dart';
import 'package:sun_seats/core/providers/journey_form_state.dart';
import 'package:sun_seats/core/providers/result_state.dart';
import 'package:sun_seats/core/providers/location_state.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => JourneyFormState()),
          ChangeNotifierProvider(create: (_) => ResultState()),
          ChangeNotifierProvider(create: (_) => LocationState()),
        ],
        child: const SunSeatApp(),
      ),
    );

    await tester.pumpAndSettle();
  });
}
