import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/design_system/components/lists/right_side_slider.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';

import '../../../shared/golden_test_utils/material_golden.dart';
import '../../../shared/tic_tac_toe_widget_test_wrapper.dart';

void main() {
  final modes = [
    for (final mode in ['Online', 'Local', 'Solo', 'Tournament'])
      SliderItem(title: mode, description: '$mode description', value: mode),
  ];

  Widget slider(List<SliderItem<String>> items, {ValueChanged<String>? onSelected}) =>
      RightSideSlider<String>(ctaLabel: 'Play', items: items, onSelected: onSelected ?? (_) {});

  Future<void> swipeUp(WidgetTester tester, {double distance = 60}) async {
    await tester.drag(find.byType(RightSideSlider<String>), Offset(0, -distance));
    await tester.pumpAndSettle();
  }

  testWidgets('every mode becomes reachable when there are more than three', (tester) async {
    await tester.pumpScreen(slider(modes));

    expect(find.text('Tournament'), findsNothing);

    await swipeUp(tester);

    expect(find.text('Tournament'), findsOneWidget);
  });

  testWidgets('swiping past the last mode comes back to the first one', (tester) async {
    await tester.pumpScreen(slider(modes));

    for (var swipe = 0; swipe < modes.length; swipe++) {
      await swipeUp(tester);
    }

    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Local'), findsOneWidget);
    expect(find.text('Solo'), findsOneWidget);
  });

  testWidgets('a short slow drag does not turn the modes', (tester) async {
    await tester.pumpScreen(slider(modes));

    await tester.timedDrag(find.byType(RightSideSlider<String>), const Offset(0, -20), const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Tournament'), findsNothing);
  });

  testWidgets('tapping a mode selects it', (tester) async {
    String? selected;
    await tester.pumpScreen(slider(modes, onSelected: (mode) => selected = mode));

    await tester.tap(find.text('Solo'));

    expect(selected, 'Solo');
  });

  testWidgets('no mode shows nothing, and fewer modes than before still show', (tester) async {
    await tester.pumpScreen(slider(const []));
    expect(find.text('Play'), findsNothing);

    await tester.pumpScreen(slider(modes));
    await swipeUp(tester);
    await swipeUp(tester);
    await tester.pumpScreen(slider(modes.take(1).toList()));

    expect(tester.takeException(), isNull);
    expect(find.text('Online'), findsWidgets);
  });

  screenTestGolden(
    'The game modes, the middle one highlighted',
    fileName: 'right_side_slider',
    builder:
        () => Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Dimens.sliderWidth),
            child: slider(modes.take(3).toList()),
          ),
        ),
  );
}
