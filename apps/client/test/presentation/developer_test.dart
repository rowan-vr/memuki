import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memuki/presentation/developer/developer_screen.dart';
import 'package:memuki/presentation/developer/developer_tools_provider.dart';
import 'package:memuki/presentation/home/home_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('debug builds show the Developer destination', (tester) async {
    await tester.pumpApp();

    await tester.tap(find.text('Developer').first);
    await tester.pumpAndSettle();
    expect(find.byType(DeveloperScreen), findsOneWidget);
  });

  testWidgets('without developer tools the destination and routes are gone', (
    tester,
  ) async {
    await tester.pumpApp(
      overrides: [developerToolsProvider.overrideWithValue(false)],
    );
    expect(find.text('Developer'), findsNothing);

    GoRouter.of(tester.element(find.byType(HomeScreen)))
        .go('/developer/catalogue');
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(DeveloperScreen), findsNothing);
  });
}
