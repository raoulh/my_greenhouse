import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            SvgPicture.asset(height: 200, 'assets/no_internet.svg'),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
              child: Text(
                AppLocalizations.of(context).oopsNoInternet,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 58, 58, 58),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
              child: Text(
                AppLocalizations.of(context).noInternetDesc,
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
      ),
    );
  }
}
