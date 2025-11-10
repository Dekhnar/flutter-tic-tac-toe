import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
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
      true => GameCreateInput.offlineVsAi(fromLabel: fromName),
      false => GameCreateInput.offline(fromLabel: fromName, toLabel: toName),
    });
  }

  String? _requiredNameValidator(BuildContext context, String? value) {
    return (value?.trim() ?? '').isEmpty ? I18n.of(context).pleaseEnterFirstName : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isVsAi ? I18n.of(context).versusAiOffline : I18n.of(context).offline1v1),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fromNameController,
                focusNode: _fromFocusNode,
                textInputAction: _isVsAi ? TextInputAction.done : TextInputAction.next,
                decoration: InputDecoration(labelText: I18n.of(context).playerOneFirstName, prefixText: 'X: '),
                validator: (v) => _requiredNameValidator(context, v),
                onFieldSubmitted: (_) {
                  if (_isVsAi) {
                    _handleSubmit(context);
                  } else {
                    _toFocusNode.requestFocus();
                  }
                },
                maxLength: 20,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
              ),
              if (!_isVsAi) const SizedBox(height: Dimens.halfSpacing),
              if (!_isVsAi)
                TextFormField(
                  controller: _toNameController,
                  focusNode: _toFocusNode,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(labelText: I18n.of(context).playerTwoFirstName, prefixText: 'O: '),
                  validator: (v) => _requiredNameValidator(context, v),
                  onFieldSubmitted: (_) => _handleSubmit(context),
                  maxLength: 20,
                  inputFormatters: [LengthLimitingTextInputFormatter(20)],
                ),
            ],
          ),
        ),
      ),
      actions: [FilledButton(onPressed: () => _handleSubmit(context), child: Text(I18n.of(context).start))],
    );
  }
}