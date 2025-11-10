import 'package:flutter/material.dart';

class BaseCardButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsets padding;
  final ShapeBorder? shape;

  const BaseCardButton({super.key, this.shape, required this.child, this.onTap, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    final borderRadiusGeometry = switch (shape ?? CardTheme.of(context).shape) {
      RoundedRectangleBorder border => border.borderRadius,
      BeveledRectangleBorder border => border.borderRadius,
      ContinuousRectangleBorder border => border.borderRadius,
      OutlineInputBorder border => border.borderRadius,
      UnderlineInputBorder border => border.borderRadius,
      _ => null,
    };
    return BaseCard(
      shape: shape,
      child: InkWell(
        onTap: onTap,
        borderRadius: switch (borderRadiusGeometry) {
          BorderRadius borderRadius => borderRadius,
          _ => null,
        },
        customBorder: shape,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Clip clipBehavior;
  final ShapeBorder? shape;

  const BaseCard({
    super.key,
    this.shape,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    return Card(shape: shape, clipBehavior: clipBehavior, child: Padding(padding: padding, child: child));
  }
}
