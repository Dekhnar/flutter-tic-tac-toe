import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/index.dart';
import 'package:uuid/uuid.dart';

@RoutePage()
class GameCreateOnlineDialog extends StatefulWidget {
  const GameCreateOnlineDialog({super.key, Uuid uuid = const Uuid()}) : _uuid = uuid;

  final Uuid _uuid;

  @override
  State<GameCreateOnlineDialog> createState() => _GameCreateOnlineDialogState();
}

class _GameCreateOnlineDialogState extends State<GameCreateOnlineDialog> {
  late final TextEditingController _shareLinkCtrl;
  late final _shareLink = widget._uuid.v4();

  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _labelFocus = FocusNode();
  final _linkFocus = FocusNode();

  bool _isCreate = true;

  @override
  void initState() {
    super.initState();
    _shareLinkCtrl = TextEditingController(text: _shareLink);
    debugPrint(_shareLink);
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _shareLinkCtrl.dispose();
    _labelFocus.dispose();
    _linkFocus.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) return;

    final label = _labelCtrl.text.trim();
    final link = _shareLinkCtrl.text.trim();

    context.router.pop(switch (_isCreate) {
      true => GameCreateInput.createOnlineLobby(fromLabel: label, shareLink: link),
      false => GameCreateInput.joinOnlineLobby(toLabel: label, shareLink: link),
    });
  }

  void _switchForm(bool isCreate) {
    if (!isCreate) {
      _shareLinkCtrl.text = "";
    } else {
      _shareLinkCtrl.text = _shareLink;
    }
    setState(() => _isCreate = isCreate);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    return AlertDialog(
      title: Text(i18n.onlineGame),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text(i18n.create)),
                    ButtonSegment(value: false, label: Text(i18n.join)),
                  ],
                  selected: {_isCreate},
                  onSelectionChanged: (s) => _switchForm(s.first),
                ),
              ),
              TextFormField(
                controller: _labelCtrl,
                focusNode: _labelFocus,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: i18n.playerFirstName,
                  prefixText: '${_isCreate ? CellMark.X.name : CellMark.O.name}: ',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? i18n.pleaseEnterFirstName : null,
                onFieldSubmitted: (_) => _linkFocus.requestFocus(),
                maxLength: 20,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
              ),
              const SizedBox(height: Dimens.halfPadding),
              TextFormField(
                controller: _shareLinkCtrl,
                focusNode: _linkFocus,
                readOnly: _isCreate,
                decoration: InputDecoration(
                  labelText: _isCreate ? i18n.shareLinkToShare : i18n.shareLinkToPaste,
                  suffixIcon: switch (_isCreate) {
                    true => IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: i18n.copy,
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _shareLinkCtrl.text));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(i18n.linkCopied)));
                      },
                    ),
                    false => IconButton(
                      icon: const Icon(Icons.paste),
                      tooltip: i18n.paste,
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        final value = (data?.text ?? '').trim();
                        if (value.isEmpty) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(i18n.emptyClipboard)));
                          return;
                        }
                        _shareLinkCtrl.text = value;
                      },
                    ),
                  },
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? i18n.pleaseProvideLink : null,
              ),
            ],
          ),
        ),
      ),
      actions: [FilledButton(child: Text(_isCreate ? i18n.createGame : i18n.join), onPressed: () => _submit(context))],
    );
  }
}
