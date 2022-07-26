import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorDialog extends StatelessWidget {
  final String message;
  final String buttonText;
  final void Function()? buttonFn;

  const ErrorDialog(
      {Key? key,
      required this.message,
      required this.buttonText,
      required this.buttonFn})
      : super(key: key);

  dialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(
          Radius.circular(18),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          SvgPicture.asset(height: 80, 'assets/error_bg.svg'),
          const SizedBox(height: 10.0),
          Text(
            "Error",
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: const Color(0xffff2a2a),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: const Color(0xff162d50),
            ),
          ),
          const Divider(
            color: Color.fromARGB(255, 206, 206, 206),
            height: 40,
            thickness: 1,
            indent: 15,
            endIndent: 15,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
                onPressed: buttonFn,
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text(buttonText.toUpperCase())),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}
