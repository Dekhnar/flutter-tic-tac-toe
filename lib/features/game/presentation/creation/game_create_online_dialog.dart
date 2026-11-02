import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/presentation/creation/player_name_field.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

/// Creates an online game, whose code the board then shows to share, or joins one with the code received.
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
    Navigator.of(context).pop(switch (_isCreate) {
      true => GameCreateInput.createOnlineLobby(hostName: name),
      false => GameCreateInput.joinOnlineLobby(
        gameId: GameId(_codeController.text.trim().toUpperCase()),
        guestName: name,
      ),
    });
  }

  Future<void> _pasteCode(BuildContext context) async {
    final code = (await Clipboard.getData(Clipboard.kTextPlain))?.text?.trim() ?? '';
    if (!context.mounted) return;

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(I18n.of(context).emptyClipboard)));
      return;
    }
    _codeController.text = code;
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
                validator: (value) => (value?.trim() ?? '').isEmpty ? i18n.pleaseEnterGameCode : null,
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
