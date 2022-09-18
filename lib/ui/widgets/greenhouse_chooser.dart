import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_greenhouse/services/greenhouse_service.dart';
import 'package:provider/provider.dart';

class GreenHouseChooser extends StatelessWidget {
  const GreenHouseChooser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _buildIOS(context) : _buildAndroid(context);
  }

  Widget _buildIOS(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: Provider.of<GreenhouseService>(context)
              .prodUnits
              .map((e) => ListTile(
                    title: e.prodRef == ""
                        ? Text(e.name)
                        : Text("${e.name} - ${e.prodRef}"),
                    leading: Provider.of<GreenhouseService>(context)
                                .currentProdUnitIndex ==
                            e.index
                        ? const Icon(CupertinoIcons.check_mark_circled_solid)
                        : const Icon(CupertinoIcons.circle),
                    onTap: () {
                      Provider.of<GreenhouseService>(context, listen: false)
                          .currentProdUnitIndex = e.index;
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: Provider.of<GreenhouseService>(context)
              .prodUnits
              .map((e) => ListTile(
                    title: e.prodRef == ""
                        ? Text(e.name)
                        : Text("${e.name} - ${e.prodRef}"),
                    leading: Provider.of<GreenhouseService>(context)
                                .currentProdUnitIndex ==
                            e.index
                        ? const Icon(Icons.radio_button_on)
                        : const Icon(Icons.radio_button_off),
                    onTap: () {
                      Provider.of<GreenhouseService>(context, listen: false)
                          .currentProdUnitIndex = e.index;
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
