import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class CustomDialogRoute extends CustomRoute {
  CustomDialogRoute({
    required super.page,
    super.path,
    super.initial,
    List<AutoRoute> super.children = const [],
    Color barrierColor = const Color(0x8A000000),
    bool barrierDismissible = true,
    super.fullscreenDialog = true,
    super.opaque = false,
  }) : super(
         customRouteBuilder: <T>(context, child, settings) {
           return DialogRoute<T>(
             context: context,
             settings: settings,
             barrierColor: barrierColor,
             barrierDismissible: barrierDismissible,
             builder: (_) => child,
           );
         },
       );
}
