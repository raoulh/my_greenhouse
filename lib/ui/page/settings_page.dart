import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_greenhouse/services/auth_service.dart';
import 'package:my_greenhouse/ui/widgets/error_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../widgets/appbar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    Future.delayed(const Duration(milliseconds: 600), () {
      Navigator.pushReplacementNamed(context, 'login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: "About",
        showSettings: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: Platform.isIOS
            ? const BouncingScrollPhysics()
            : const ClampingScrollPhysics(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xff046e0b),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(height: 100, 'assets/logo_alone.svg'),
              ),
              const SizedBox(height: 10),
              Text(
                "MyGreenhouse 1.0.0 (1)",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 0, 39, 49),
                ),
              ),
              Text(
                "Copyright (c) Raoul Hecky",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w200,
                  color: const Color.fromARGB(255, 65, 65, 65),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Licenses and code available here:",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                  color: const Color.fromARGB(255, 65, 65, 65),
                ),
              ),
              Linkify(
                onOpen: (LinkableElement link) async {
                  var fail = false;
                  try {
                    await launchUrlString(link.url);
                  } catch (e) {
                    fail = true;
                  }

                  if (fail) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                            message: "Oops... the URL couldn't be opened!",
                            buttonText: "Close",
                            buttonFn: () => Navigator.pop(context),
                          );
                        });
                  }
                },
                text: "https://github.com/raoulh/my_greenhouse",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                  color: const Color.fromARGB(255, 65, 65, 65),
                  decoration: TextDecoration.underline,
                ),
                //linkStyle: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
              if (Platform.isIOS)
                CupertinoButton.filled(
                  onPressed: () {
                    _logout(context);
                  },
                  child: const Text('Logout'),
                ),
              if (Platform.isAndroid)
                ElevatedButton(
                  //style: style,
                  onPressed: () {
                    _logout(context);
                  },
                  child: const Text('Logout'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
