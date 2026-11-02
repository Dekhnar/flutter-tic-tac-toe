import 'package:flutter/material.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_name.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

/// A player's first name, refused here when the server would refuse it.
class PlayerNameField extends StatelessWidget {
  const PlayerNameField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.label,
    required this.mark,
    this.onSubmitted,
    this.textInputAction,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final CellMark mark;
  final VoidCallback? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: label, prefixText: '${mark.name}: '),
      maxLength: PlayerName.maxLength,
      validator:
          (value) => switch (value?.trim() ?? '') {
            '' => i18n.pleaseEnterFirstName,
            final name when PlayerName.isTooLong(name) => i18n.nameTooLong(PlayerName.maxLength),
            _ => null,
          },
      onFieldSubmitted: (_) => onSubmitted?.call(),
    );
  }
}
