import 'package:flutter/material.dart';

/// A card that is a button as a whole: the card's clip keeps the ink within its shape.
class BaseCardButton extends StatelessWidget {
  const BaseCardButton({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: onTap, child: child));
  }
}
