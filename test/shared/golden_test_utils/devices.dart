import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

final class Devices {
  static final portraitScreens = [...screensWithoutAccessibility, a11yScreen];

  static List<Device> screens({bool includeLandscapeMode = false, bool includeTabletLandscape = false}) {
    return [
      ...portraitScreens,
      if (includeTabletLandscape) Device.tabletLandscape,
      if (includeLandscapeMode)
        ...portraitScreens.map(
          (screen) => screen.copyWith(
            name: '${screen.name}_landscape',
            size: screen.size.flipped,
            safeArea: EdgeInsets.fromLTRB(
              screen.safeArea.top,
              screen.safeArea.right,
              screen.safeArea.bottom,
              screen.safeArea.left,
            ),
          ),
        ),
    ];
  }

  static final a11yScreen = Device.phone.copyWith(name: 'a11y', textScale: 2);

  static final semanticsScreen = Device.phone.copyWith(name: 'semantic');

  static final lightModeScreen = Device.iphone11.copyWith(name: 'light');

  static final screensWithoutAccessibility = [Device.iphone11];
}
