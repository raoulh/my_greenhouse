import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_greenhouse/ui/widgets/decimal_input_formater.dart';

class DecimalInputModalIOS extends StatefulWidget {
  final double currentValue;
  final double minValue;
  final double maxValue;
  final ValueChanged<num>? onSubmit;
  final String help;
  final bool? hasDecimals;

  const DecimalInputModalIOS({
    Key? key,
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    this.onSubmit,
    required this.help,
    this.hasDecimals,
  }) : super(key: key);

  @override
  State<DecimalInputModalIOS> createState() => _DecimalInputModalIOSState();
}

const BorderSide _kErrorBorder = BorderSide(
  color: Color(0x99FF0000),
  width: 0.0,
);

const BorderSide _kDefaultRoundedBorderSide = BorderSide(
  color: CupertinoDynamicColor.withBrightness(
    color: Color(0x33000000),
    darkColor: Color(0x33FFFFFF),
  ),
  width: 0.0,
);

const Border _kDefaultRoundedBorder = Border(
  top: _kDefaultRoundedBorderSide,
  bottom: _kDefaultRoundedBorderSide,
  left: _kDefaultRoundedBorderSide,
  right: _kDefaultRoundedBorderSide,
);

const BoxDecoration _kDefaultBorderDecoration = BoxDecoration(
  color: CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white,
    darkColor: CupertinoColors.black,
  ),
  border: _kDefaultRoundedBorder,
  borderRadius: BorderRadius.all(Radius.circular(5.0)),
);

const BoxDecoration _kErrorBorderDecoration = BoxDecoration(
  color: CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white,
    darkColor: CupertinoColors.black,
  ),
  border: Border(
    top: _kErrorBorder,
    bottom: _kErrorBorder,
    left: _kErrorBorder,
    right: _kErrorBorder,
  ),
  borderRadius: BorderRadius.all(Radius.circular(5.0)),
);

class _DecimalInputModalIOSState extends State<DecimalInputModalIOS> {
  final _controller = TextEditingController();
  var _isValid = true;
  num? _currentValue;
  late final bool _hasDecimals;

  @override
  void initState() {
    super.initState();

    if (widget.hasDecimals != null) {
      _hasDecimals = widget.hasDecimals!;
    } else {
      _hasDecimals = false;
    }

    num val;
    if (_hasDecimals) {
      val = widget.currentValue;
    } else {
      val = widget.currentValue.toInt();
    }

    _controller.text = val.toString();
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
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
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          //leading: Container(),
          middle: Text(AppLocalizations.of(context).edit),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, left: 50, right: 50),
                child: Text(widget.help),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(top: 50, left: 100, right: 100),
                child: CupertinoTextField(
                  controller: _controller,
                  maxLength: 10,
                  autofocus: true,
                  onSubmitted: (value) => _submitValue(value),
                  onChanged: (value) {
                    setState(() {
                      _isValid = _isValueValid(value);
                    });
                  },
                  enabled: true,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _isValid
                      ? _kDefaultBorderDecoration
                      : _kErrorBorderDecoration,
                  inputFormatters: [
                    DecimalTextInputFormatter(),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              CupertinoButton.filled(
                onPressed: () => _submitValue(_controller.text),
                child: Text(AppLocalizations.of(context).save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitValue(value) {
    if (!_isValid) {
      return;
    }

    if (_currentValue != null && widget.onSubmit != null) {
      widget.onSubmit!(_currentValue!);
    }

    Navigator.pop(context);
  }

  bool _isValueValid(String value) {
    try {
      if (_hasDecimals) {
        double v = double.parse(value);

        if (v < widget.minValue || v > widget.maxValue) {
          return false;
        }

        _currentValue = v;
      } else {
        int v = int.parse(value);

        if (v < widget.minValue || v > widget.maxValue) {
          return false;
        }

        _currentValue = v;
      }
    } on FormatException {
      return false;
    }

    return true;
  }
}
