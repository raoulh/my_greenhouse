import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 30),
        child: Column(
          children: [
            SvgPicture.asset(height: 100, 'assets/logo.svg'),
          ],
        ),
      ),
    );
  }
}
