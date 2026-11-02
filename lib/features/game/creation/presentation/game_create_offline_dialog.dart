import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/creation/presentation/player_name_field.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

@RoutePage()
class GameCreateOfflineDialog extends StatefulWidget {
  final bool vsAi;
  const GameCreateOfflineDialog({super.key, this.vsAi = false});

  @override
  State<GameCreateOfflineDialog> createState() => _GameCreateOfflineDialogState();
}

class _GameCreateOfflineDialogState extends State<GameCreateOfflineDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fromNameController = TextEditingController();
  final TextEditingController _toNameController = TextEditingController();

  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();

  bool get _isVsAi => widget.vsAi;

  @override
  void dispose() {
    _fromNameController.dispose();
    _toNameController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;

    final fromName = _fromNameController.text.trim();
    final toName = _toNameController.text.trim();

    context.router.pop(switch (_isVsAi) {
      true => GameCreateInput.offlineVsAi(hostName: fromName),
      false => GameCreateInput.offline(guestName: toName, hostName: fromName),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Title, fields and actions scroll together when the keyboard leaves little room, as in landscape.
      scrollable: true,
      title: Text(_isVsAi ? I18n.of(context).soloVsAi : I18n.of(context).local1v1),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlayerNameField(
              controller: _fromNameController,
              focusNode: _fromFocusNode,
              label: I18n.of(context).playerOneFirstName,
              mark: CellMark.X,
              textInputAction: _isVsAi ? TextInputAction.done : TextInputAction.next,
              onSubmitted: _isVsAi ? () => _handleSubmit(context) : _toFocusNode.requestFocus,
            ),
            if (!_isVsAi) ...[
              const SizedBox(height: Dimens.halfSpacing),
              PlayerNameField(
                controller: _toNameController,
                focusNode: _toFocusNode,
                label: I18n.of(context).playerTwoFirstName,
                mark: CellMark.O,
                textInputAction: TextInputAction.done,
                onSubmitted: () => _handleSubmit(context),
              ),
            ],
          ],
        ),
      ),
      actions: [FilledButton(onPressed: () => _handleSubmit(context), child: Text(I18n.of(context).start))],
    );
  }
}
