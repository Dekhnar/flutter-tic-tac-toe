import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/design_system/components/lists/right_side_slider.dart';

import '../../../shared/tic_tac_toe_widget_test_wrapper.dart';

void main() {
  final modes = [
    for (final mode in ['Online', 'Local', 'Solo', 'Tournament'])
      SliderItem(title: mode, description: '$mode description', value: mode),
  ];

  Future<void> swipeUp(WidgetTester tester) async {
    await tester.drag(find.byType(RightSideSlider), const Offset(0, -60));
    await tester.pumpAndSettle();
  }

  testWidgets('every mode becomes reachable when there are more than three', (tester) async {
    await tester.pumpScreen(RightSideSlider(items: modes, ctaLabel: 'Play'));

    expect(find.text('Tournament'), findsNothing);

    await swipeUp(tester);

    expect(find.text('Tournament'), findsOneWidget);
  });

  testWidgets('swiping past the last mode comes back to the first one', (tester) async {
    await tester.pumpScreen(RightSideSlider(items: modes, ctaLabel: 'Play'));

    for (var swipe = 0; swipe < modes.length; swipe++) {
      await swipeUp(tester);
    }

    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Local'), findsOneWidget);
    expect(find.text('Solo'), findsOneWidget);
  });
}
