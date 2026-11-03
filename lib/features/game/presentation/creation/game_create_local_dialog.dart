import 'package:flutter/material.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/presentation/creation/player_name_field.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

/// Names the players of a game on this device: both of them, or only the host against the AI.
class GameCreateLocalDialog extends StatefulWidget {
  const GameCreateLocalDialog({super.key, this.vsAi = false});

  final bool vsAi;

  @override
  State<GameCreateLocalDialog> createState() => _GameCreateLocalDialogState();
}

class _GameCreateLocalDialogState extends State<GameCreateLocalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _guestFocus = FocusNode();
  final _guestNameController = TextEditingController();
  final _hostNameController = TextEditingController();

  @override
  void dispose() {
    _guestFocus.dispose();
    _guestNameController.dispose();
    _hostNameController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;

    final hostName = _hostNameController.text.trim();
    Navigator.of(context).pop(switch (widget.vsAi) {
      true => GameCreateInput.localVsAi(hostName: hostName),
      false => GameCreateInput.local(guestName: _guestNameController.text.trim(), hostName: hostName),
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    final vsAi = widget.vsAi;

    return AlertDialog(
      // Title, fields and actions scroll together when the keyboard leaves little room, as in landscape.
      scrollable: true,
      title: Text(vsAi ? i18n.soloVsAi : i18n.local1v1),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: Dimens.halfSpacing,
          children: [
            PlayerNameField(
              controller: _hostNameController,
              label: i18n.playerOneFirstName,
              mark: CellMark.X,
              textInputAction: vsAi ? TextInputAction.done : TextInputAction.next,
              onSubmitted: vsAi ? () => _submit(context) : _guestFocus.requestFocus,
            ),
            if (!vsAi)
              PlayerNameField(
                controller: _guestNameController,
                focusNode: _guestFocus,
                label: i18n.playerTwoFirstName,
                mark: CellMark.O,
                textInputAction: TextInputAction.done,
                onSubmitted: () => _submit(context),
              ),
          ],
        ),
      ),
      actions: [FilledButton(onPressed: () => _submit(context), child: Text(i18n.start))],
    );
  }
}
