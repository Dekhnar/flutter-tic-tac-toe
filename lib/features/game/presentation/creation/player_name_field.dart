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
      // The server measures names in UTF-16 code units, an emoji counting for two: so do the counter and the limit.
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

/// Keeps a name within what the server accepts, cutting at a whole character: a flag is never left half typed. A name
/// still being composed by the keyboard is left alone, the validator catching what it would leave too long.
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
