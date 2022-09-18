import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:my_greenhouse/services/greenhouse_service.dart';
import 'package:my_greenhouse/ui/page/settings_page.dart';
import 'package:my_greenhouse/ui/widgets/greenhouse_chooser.dart';
import 'package:provider/provider.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showSettings;

  const MainAppBar({Key? key, required this.title, required this.showSettings})
      : super(key: key);

  @override
  State<MainAppBar> createState() => _MainAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _MainAppBarState extends State<MainAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 4,
      leading: Visibility(
        visible: !widget.showSettings,
        child: CupertinoButton(
          child: const Icon(
            CupertinoIcons.back,
            color: Color(0xff2ea636),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Visibility(
          visible: widget.showSettings,
          child: CupertinoButton(
            child: const Icon(
              CupertinoIcons.gear,
              color: Color(0xff2ea636),
              size: 20,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
        ),
      ],
      centerTitle: true,
      title: Row(
        mainAxisAlignment:
            Provider.of<GreenhouseService>(context).hasMultiProdUnit &&
                    widget.showSettings
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
        children: [
          Visibility(
            visible: Provider.of<GreenhouseService>(context).hasMultiProdUnit &&
                widget.showSettings,
            child: CupertinoButton(
              child: const Icon(
                CupertinoIcons.chevron_up_chevron_down,
                color: Color(0xff2ea636),
                size: 20,
              ),
              onPressed: () => _promptMultiProdUnits(),
            ),
          ),
          Text(
            widget.title,
            style: GoogleFonts.montserrat(
              color: const Color(0xff2ea636),
              fontSize: 22,
              fontWeight: FontWeight.w200,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  void _promptMultiProdUnits() {
    if (Platform.isAndroid) {
      showMaterialModalBottomSheet(
        expand: false,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => const GreenHouseChooser(),
      );
    } else {
      showCupertinoModalBottomSheet(
        expand: false,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => const GreenHouseChooser(),
      );
    }
  }
}
