import 'package:flutter_test/flutter_test.dart';
import 'package:cowboycavead/main.dart';

void main() {
  testWidgets(
      'Navigation flow smoke test: Dashboard -> Level Select -> GamePlayScreen with HUD & Controls',
      (WidgetTester tester) async {
    // Build CowboyCaveApp and trigger a frame
    await tester.pumpWidget(const CowboyCaveApp());
    await tester.pump();

    // Verify Dashboard screen is rendered
    expect(find.text('COWBOY CAVE'), findsOneWidget);
    expect(find.text('PLAY GAME'), findsOneWidget);
    expect(find.text('EXIT'), findsOneWidget);

    // Tap PLAY GAME to navigate to Level Select
    await tester.tap(find.text('PLAY GAME'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Level Selection screen
    expect(find.text('SELECT STAGE'), findsOneWidget);
    expect(find.text('LVL 1'), findsOneWidget);
    expect(find.text('LVL 2'), findsOneWidget);

    // Tap Level 1 to launch GamePlayScreen
    await tester.tap(find.text('LVL 1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify GamePlayScreen and HUD elements
    expect(find.text('STAGE 1'), findsOneWidget);
    expect(find.text('LIFE '), findsOneWidget);
    expect(find.text('PTS '), findsOneWidget);

    // Verify On-Screen Touch Control Buttons
    expect(find.text('LEFT'), findsOneWidget);
    expect(find.text('RIGHT'), findsOneWidget);
    expect(find.text('JUMP'), findsOneWidget);
    expect(find.text('SHOOT'), findsOneWidget);
  });
}
