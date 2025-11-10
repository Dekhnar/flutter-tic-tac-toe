import 'package:flutter/material.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

class BaseLoadingRetryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BaseLoadingRetryButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(I18n.of(context).errorLoading),
        ElevatedButton(onPressed: onPressed, child: Text(I18n.of(context).retry)),
      ],
    ),
  );
}
