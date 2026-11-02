import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'golden_test_utils/devices.dart';
import 'golden_test_utils/material_golden.dart';

class TicTacToeMaterialApp extends MaterialGolden {
  const TicTacToeMaterialApp({super.key, required super.child});
}

extension TicTacToeWidgetTester on WidgetTester {
  /// Pumps [screen] inside the app shell, on a phone-sized surface.
  Future<void> pumpScreen(Widget screen) async {
    view.physicalSize = GoldenScreen.iphone11.size;
    view.devicePixelRatio = 1;
    addTearDown(view.reset);

    await pumpWidget(TicTacToeMaterialApp(child: screen));
  }
}
