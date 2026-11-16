import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_code.dart';
import 'package:tic_tac_toe_app/features/game/presentation/creation/player_name_field.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

/// Creates an online game, or joins one with its code, typed or pasted with the invitation around it.
class GameCreateOnlineDialog extends StatefulWidget {
  const GameCreateOnlineDialog({super.key});

  @override
  State<GameCreateOnlineDialog> createState() => _GameCreateOnlineDialogState();
}

class _GameCreateOnlineDialogState extends State<GameCreateOnlineDialog> {
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _isCreate = true;

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocus.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;

    final name = _nameController.text.trim();
    if (_isCreate) {
      Navigator.of(context).pop(GameCreateInput.createOnline(hostName: name));
    } else if (GameCode.tryParse(_codeController.text) case final code?) {
      Navigator.of(context).pop(GameCreateInput.joinOnline(code: code, guestName: name));
    }
  }

  Future<void> _pasteCode(BuildContext context) async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    if (!context.mounted) return;

    switch (GameCode.tryParse(clipboard?.text ?? '')) {
      case final code?:
        _codeController.text = code.value;
      case null:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(I18n.of(context).noGameCodeInClipboard)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    return AlertDialog(
      // Title, fields and actions scroll together when the keyboard leaves little room, as in landscape.
      scrollable: true,
      title: Text(i18n.onlineGame),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(i18n.create)),
                ButtonSegment(value: false, label: Text(i18n.join)),
              ],
              selected: {_isCreate},
              onSelectionChanged: (selection) => setState(() => _isCreate = selection.first),
            ),
            const SizedBox(height: Dimens.standardSpacing),
            PlayerNameField(
              controller: _nameController,
              label: i18n.playerFirstName,
              mark: _isCreate ? CellMark.X : CellMark.O,
              textInputAction: _isCreate ? TextInputAction.done : TextInputAction.next,
              onSubmitted: _isCreate ? () => _submit(context) : _codeFocus.requestFocus,
            ),
            if (!_isCreate) ...[
              const SizedBox(height: Dimens.halfSpacing),
              TextFormField(
                controller: _codeController,
                focusNode: _codeFocus,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: i18n.gameCode,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    tooltip: i18n.paste,
                    onPressed: () => _pasteCode(context),
                  ),
                ),
                validator:
                    (value) => switch (value?.trim() ?? '') {
                      '' => i18n.pleaseEnterGameCode,
                      final text when GameCode.tryParse(text) == null => i18n.invalidGameCode(GameCode.length),
                      _ => null,
                    },
                onFieldSubmitted: (_) => _submit(context),
              ),
            ],
          ],
        ),
      ),
      actions: [FilledButton(onPressed: () => _submit(context), child: Text(_isCreate ? i18n.createGame : i18n.join))],
    );
  }
}
