import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_greenhouse/ui/page/settings_page.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSettings;

  const MainAppBar({Key? key, required this.title, required this.showSettings})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 4,
      leading: Visibility(
        visible: !showSettings,
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
          visible: showSettings,
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
      title: Text(
        title,
        style: GoogleFonts.montserrat(
          color: const Color(0xff2ea636),
          fontSize: 22,
          fontWeight: FontWeight.w200,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
