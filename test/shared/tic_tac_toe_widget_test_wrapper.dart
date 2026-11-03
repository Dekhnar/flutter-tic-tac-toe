import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'golden_test_utils/devices.dart';
import 'golden_test_utils/material_golden.dart';

extension TicTacToeWidgetTester on WidgetTester {
  /// Shows [screen] on an iPhone 11-sized view, with the app's themes and localizations.
  Future<void> pumpScreen(Widget screen) async {
    view.physicalSize = GoldenScreen.iphone11.size;
    view.devicePixelRatio = 1;
    addTearDown(view.reset);

    await pumpWidget(MaterialGolden(child: screen));
  }
}
