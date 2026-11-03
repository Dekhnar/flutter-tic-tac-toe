import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      // Counts UTF-16 code units, as the server does: an emoji counts for two.
      buildCounter:
          (context, {required currentLength, required isFocused, maxLength}) =>
              Text('${controller.text.length}/${PlayerName.maxLength}'),
      inputFormatters: const [_ServerLengthLimit()],
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

/// Cuts a name to what the server accepts, at a whole character so that a flag is never left half typed. Text the
/// keyboard is still composing is left alone; the validator catches it.
final class _ServerLengthLimit extends TextInputFormatter {
  const _ServerLengthLimit();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.composing.isValid || !PlayerName.isTooLong(newValue.text)) return newValue;

    final kept = StringBuffer();
    for (final character in newValue.text.characters) {
      if (kept.length + character.length > PlayerName.maxLength) break;
      kept.write(character);
    }
    final text = kept.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
