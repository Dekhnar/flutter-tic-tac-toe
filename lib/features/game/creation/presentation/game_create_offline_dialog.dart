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

  final TextEditingController _hostNameController = TextEditingController();
  final TextEditingController _guestNameController = TextEditingController();

  final FocusNode _hostFocusNode = FocusNode();
  final FocusNode _guestFocusNode = FocusNode();

  bool get _isVsAi => widget.vsAi;

  @override
  void dispose() {
    _hostNameController.dispose();
    _guestNameController.dispose();
    _hostFocusNode.dispose();
    _guestFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;

    final hostName = _hostNameController.text.trim();
    final guestName = _guestNameController.text.trim();

    context.router.pop(switch (_isVsAi) {
      true => GameCreateInput.offlineVsAi(hostName: hostName),
      false => GameCreateInput.offline(guestName: guestName, hostName: hostName),
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
              controller: _hostNameController,
              focusNode: _hostFocusNode,
              label: I18n.of(context).playerOneFirstName,
              mark: CellMark.X,
              textInputAction: _isVsAi ? TextInputAction.done : TextInputAction.next,
              onSubmitted: _isVsAi ? () => _handleSubmit(context) : _guestFocusNode.requestFocus,
            ),
            if (!_isVsAi) ...[
              const SizedBox(height: Dimens.halfSpacing),
              PlayerNameField(
                controller: _guestNameController,
                focusNode: _guestFocusNode,
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
