import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/design_system/components/data_display/animated_splash.dart';
import 'package:tic_tac_toe_app/design_system/foundations/assets.dart';

import '../../../shared/tic_tac_toe_widget_test_wrapper.dart';

void main() {
  const midAnimation = Duration(milliseconds: 100);
  const afterTheNextDelay = Duration(milliseconds: 200);

  testWidgets('the splash moves on once its animation ends', (tester) async {
    var movedOn = false;
    await tester.pumpScreen(BaseAnimatedSplash(imagePath: Assets.images.appIcon, next: () => movedOn = true));

    await tester.pumpAndSettle();
    await tester.pump(afterTheNextDelay);

    expect(movedOn, isTrue);
  });

  testWidgets('leaving the splash while it animates releases its animation cleanly', (tester) async {
    await tester.pumpScreen(BaseAnimatedSplash(imagePath: Assets.images.appIcon));
    await tester.pump(midAnimation);

    await tester.pumpWidget(const SizedBox.shrink());

    expect(tester.takeException(), isNull);
  });

  testWidgets('a splash that is gone no longer moves on', (tester) async {
    var movedOn = false;
    await tester.pumpScreen(BaseAnimatedSplash(imagePath: Assets.images.appIcon, next: () => movedOn = true));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(afterTheNextDelay);

    expect(movedOn, isFalse);
  });
}
