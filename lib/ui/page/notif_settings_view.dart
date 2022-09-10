import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:my_greenhouse/models/greenhouse_response.dart';
import 'package:my_greenhouse/services/greenhouse_service.dart';
import 'package:my_greenhouse/ui/page/decimal_input_page_android.dart';
import 'package:my_greenhouse/ui/widgets/appbar.dart';
import 'package:my_greenhouse/ui/widgets/error_dialog.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_greenhouse/ui/page/decimal_input_page_ios.dart';

class NotifSettingsPage extends StatefulWidget {
  final NotifType notifType;
  const NotifSettingsPage({Key? key, required this.notifType})
      : super(key: key);

  @override
  State<NotifSettingsPage> createState() => _NotifSettingsPageState();
}

class _NotifSettingsPageState extends State<NotifSettingsPage> {
  late GreenhouseService grService;
  late Future<NotifSettingsResponse> currentValues;
  late NotifSettingsResponse nextValues;
  late NotifSettingsResponse oldValues;

  @override
  void initState() {
    super.initState();

    grService = Provider.of<GreenhouseService>(context, listen: false);
    _loadValues();
  }

  void _loadValues() {
    currentValues = grService.getNotifSettings(widget.notifType);
    currentValues.then((value) => nextValues = value);
  }

  void _sendValues() async {
    grService.setNotifSettings(nextValues).then((value) {
      setState(() {
        nextValues = value;
      });
    }).catchError((err) {
      setState(() {
        nextValues = NotifSettingsResponse.fromJson(oldValues.toJson());
      });
    });
  }

  void _showHelpDialog(context, String text) {
    if (!Platform.isIOS) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text(AppLocalizations.of(context).help),
            content: Text(text),
            actions: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context).close),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(AppLocalizations.of(context).help),
          content: Text(text),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(AppLocalizations.of(context).close),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: AppLocalizations.of(context).notifSettingsTitle,
        showSettings: false,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: currentValues,
        builder: (BuildContext context,
            AsyncSnapshot<NotifSettingsResponse> snapshot) {
          if (snapshot.hasData) {
            return _createSettingsWidget(snapshot.data!);
          } else if (snapshot.hasError) {
            return ErrorDialog(
                type: DialogTypes.error,
                message: snapshot.error.toString(),
                buttonText: AppLocalizations.of(context).tryAgain,
                buttonFn: () {
                  //Navigator.pop(context);
                  setState(() {
                    _loadValues();
                  });
                });
          }

          return _createLoadingWidget();
        },
      ),
    );
  }

  Widget _createSettingsWidget(NotifSettingsResponse res) {
    return SettingsList(
      //platform: DevicePlatform.android,
      lightTheme: SettingsThemeData(
        settingsListBackground: Platform.isAndroid ? Colors.white : null,
        titleTextColor: const Color(0xff2ea636),
      ),
      sections: [
        SettingsSection(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context).outOfRange.toUpperCase()),
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  CupertinoIcons.info,
                  color: Colors.grey[700],
                  size: 25.0,
                ),
                onPressed: () => _showHelpDialog(
                    context, AppLocalizations.of(context).helpOutOfRange),
              ),
            ],
          ),
          tiles: <SettingsTile>[
            SettingsTile.switchTile(
              onToggle: (value) {
                oldValues = NotifSettingsResponse.fromJson(nextValues.toJson());
                setState(() {
                  nextValues.rangeEnabled = value;
                });
                _sendValues();
              },
              initialValue: nextValues.rangeEnabled,
              //leading: Icon(Icons.),
              title: Text(AppLocalizations.of(context).enable),
            ),
            SettingsTile.navigation(
              title: Text(AppLocalizations.of(context).minimumValue),
              leading: const Icon(Icons.arrow_left_outlined),
              value: Text("${res.rangeMin} ${res.getUnit()}"),
              onPressed: (context) => _minValueEdit(context, res),
            ),
            SettingsTile.navigation(
              title: Text(AppLocalizations.of(context).maximumValue),
              leading: const Icon(Icons.arrow_right_outlined),
              value: Text("${res.rangeMax} ${res.getUnit()}"),
              onPressed: (context) => _maxValueEdit(context, res),
            ),
          ],
        ),
        SettingsSection(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context).changesTooFast.toUpperCase()),
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  CupertinoIcons.info,
                  color: Colors.grey[700],
                  size: 25.0,
                ),
                onPressed: () => _showHelpDialog(
                    context, AppLocalizations.of(context).helpChangesTooFast),
              ),
            ],
          ),
          tiles: [
            SettingsTile.switchTile(
              onToggle: (value) {
                oldValues = NotifSettingsResponse.fromJson(nextValues.toJson());
                setState(() {
                  nextValues.tooFastEnabled = value;
                });
                _sendValues();
              },
              initialValue: nextValues.tooFastEnabled,
              title: Text(AppLocalizations.of(context).enable),
            ),
          ],
        ),
        SettingsSection(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context).updateTime.toUpperCase()),
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  CupertinoIcons.info,
                  color: Colors.grey[700],
                  size: 25.0,
                ),
                onPressed: () => _showHelpDialog(
                    context, AppLocalizations.of(context).helpUpdateTime),
              ),
            ],
          ),
          tiles: [
            SettingsTile.switchTile(
              onToggle: (value) {
                oldValues = NotifSettingsResponse.fromJson(nextValues.toJson());
                setState(() {
                  nextValues.timeEnabled = value;
                });
                _sendValues();
              },
              initialValue: nextValues.timeEnabled,
              title: Text(AppLocalizations.of(context).enable),
            ),
            SettingsTile.navigation(
              title: Text(AppLocalizations.of(context).durationUpdateTime),
              leading: const Icon(Icons.history_rounded),
              value: Text(res.getFormatedTimeMin(context)),
              onPressed: (context) => _timeValueEdit(context, res),
            ),
          ],
        ),
      ],
    );
  }

  Widget _createLoadingWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SpinKitThreeBounce(
            color: Color(0xff2ea636),
            size: 30,
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
            child: Text(
              AppLocalizations.of(context).loadingDots,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: const Color.fromARGB(255, 58, 58, 58),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _minValueEdit(BuildContext context, res) {
    double min = 0, max = 0;
    String help = "";

    if (res.type == NotifType.pH) {
      min = 0;
      max = 10;
      help = AppLocalizations.of(context).helpRangePHMin;
    } else if (res.type == NotifType.waterTemp) {
      min = 0;
      max = 50;
      help = AppLocalizations.of(context).helpTempWaterMin;
    } else if (res.type == NotifType.airTemp) {
      min = 0;
      max = 50;
      help = AppLocalizations.of(context).helpTempAirMin;
    } else if (res.type == NotifType.humidity) {
      min = 0;
      max = 100;
      help = AppLocalizations.of(context).helpHumidityMin;
    }

    _promptDecimal(context, res.rangeMin, min, max, help, true, (newValue) {
      setState(() {
        nextValues.rangeMin = newValue.toDouble();
      });
      _sendValues();
    });
  }

  void _maxValueEdit(BuildContext context, res) {
    double min = 0, max = 0;
    String help = "";

    if (res.type == NotifType.pH) {
      min = 0;
      max = 10;
      help = AppLocalizations.of(context).helpRangePHMax;
    } else if (res.type == NotifType.waterTemp) {
      min = 0;
      max = 50;
      help = AppLocalizations.of(context).helpTempWaterMax;
    } else if (res.type == NotifType.airTemp) {
      min = 0;
      max = 50;
      help = AppLocalizations.of(context).helpTempAirMax;
    } else if (res.type == NotifType.humidity) {
      min = 0;
      max = 100;
      help = AppLocalizations.of(context).helpHumidityMax;
    }

    _promptDecimal(context, res.rangeMax, min, max, help, true, (newValue) {
      setState(() {
        nextValues.rangeMax = newValue.toDouble();
      });
      _sendValues();
    });
  }

  void _timeValueEdit(BuildContext context, res) {
    double min = 1, max = 100;
    String help = AppLocalizations.of(context).helpTimeout;

    _promptDecimal(
        context, res.timeMin.inHours.toDouble(), min, max, help, false,
        (newValue) {
      setState(() {
        nextValues.timeMin = Duration(hours: newValue.toInt());
      });
      _sendValues();
    });
  }

  void _promptDecimal(
      BuildContext context,
      double currentVal,
      double minVal,
      double maxVal,
      String help,
      bool hasDecimals,
      ValueChanged<num> onSubmit) {
    if (Platform.isAndroid) {
      //if (Platform.isIOS) {
      _promptAndroidDecimal(
          context, currentVal, minVal, maxVal, help, hasDecimals, onSubmit);
    } else {
      _promptIOSDecimal(
          context, currentVal, minVal, maxVal, help, hasDecimals, onSubmit);
    }
  }

  void _promptAndroidDecimal(
      BuildContext context,
      double currentVal,
      double minVal,
      double maxVal,
      String help,
      bool hasDecimals,
      ValueChanged<num> onSubmit) {
    showMaterialModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DecimalInputModalAndroid(
        currentValue: currentVal,
        minValue: minVal,
        maxValue: maxVal,
        help: help,
        onSubmit: onSubmit,
        hasDecimals: hasDecimals,
      ),
    );
  }

  void _promptIOSDecimal(
      BuildContext context,
      double currentVal,
      double minVal,
      double maxVal,
      String help,
      bool hasDecimals,
      ValueChanged<num> onSubmit) {
    showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DecimalInputModalIOS(
        currentValue: currentVal,
        minValue: minVal,
        maxValue: maxVal,
        help: help,
        onSubmit: onSubmit,
        hasDecimals: hasDecimals,
      ),
    );
  }
}
