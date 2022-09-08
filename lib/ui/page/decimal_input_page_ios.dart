import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DecimalInputModalIOS extends StatefulWidget {
  final double currentValue;
  final double minValue;
  final double maxValue;
  final ValueChanged<double>? onSubmit;
  final String help;

  const DecimalInputModalIOS({
    Key? key,
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    this.onSubmit,
    required this.help,
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
                  decoration: _isValid
                      ? _kDefaultBorderDecoration
                      : _kErrorBorderDecoration,
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
