import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DecimalInputModalAndroid extends StatefulWidget {
  final double currentValue;
  final double minValue;
  final double maxValue;
  final ValueChanged<double>? onSubmit;
  final String help;

  const DecimalInputModalAndroid({
    Key? key,
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    this.onSubmit,
    required this.help,
  }) : super(key: key);

  @override
  State<DecimalInputModalAndroid> createState() =>
      _DecimalInputModalAndroidState();
}

class _DecimalInputModalAndroidState extends State<DecimalInputModalAndroid> {
  final _controller = TextEditingController();
  var _isValid = true;
  double? _currentValue;

  @override
  void initState() {
    super.initState();

    _controller.text = widget.currentValue.toString();
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.currentValue.toString().length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 25),
              Container(
                margin: const EdgeInsets.only(top: 20, left: 50, right: 50),
                child: Text(widget.help),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(top: 50, left: 100, right: 100),
                child: TextField(
                  controller: _controller,
                  maxLength: 10,
                  autofocus: true,
                  onSubmitted: (value) {
                    if (!_isValid) {
                      return;
                    }
                    if (_currentValue != null && widget.onSubmit != null) {
                      widget.onSubmit!(_currentValue!);
                    }
                    Navigator.pop(context);
                  },
                  onChanged: (value) {
                    setState(() {
                      _isValid = _isValueValid(value);
                    });
                  },
                  enabled: true,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).editValueText,
                    errorText: _isValid
                        ? null
                        : AppLocalizations.of(context).editValueError,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValueValid(String value) {
    try {
      double v = double.parse(value);

      if (v < widget.minValue || v > widget.maxValue) {
        return false;
      }

      _currentValue = v;
    } on FormatException {
      return false;
    }

    return true;
  }
}
