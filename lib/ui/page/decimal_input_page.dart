import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DecimalInputModal extends StatefulWidget {
  final double currentValue;
  final double minValue;
  final double maxValue;

  const DecimalInputModal({
    Key? key,
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
  }) : super(key: key);

  @override
  State<DecimalInputModal> createState() => _DecimalInputModalState();
}

class _DecimalInputModalState extends State<DecimalInputModal> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller.text = widget.currentValue.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          //leading: Container(),
          middle: Text('Edit'),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, left: 50, right: 50),
                child: Text(AppLocalizations.of(context).helpOutOfRange),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(top: 50, left: 100, right: 100),
                child: CupertinoTextField(
                  controller: _controller,
                  maxLength: 10,
                  autofocus: true,
                  onSubmitted: (value) {},
                  enabled: true,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
