import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../page/modal_with_navigator.dart';
import '../page/modal_fit.dart';

import '../widgets/appbar.dart';
import '../widgets/chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: "Family22 - Original",
        showSettings: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: Platform.isIOS
            ? const BouncingScrollPhysics()
            : const ClampingScrollPhysics(),
        child: Column(
          children: [
            _SumarySection(),
            const SizedBox(height: 10),
            _ChartSection(
              title: "Evolution du pH",
              titleBox1: "Moyenne 1h",
              valueBox1: "6.9 pH",
              titleBox2: "Moyenne 24h",
              valueBox2: "7 pH",
              onMorePressed: () {
                WidgetBuilder builder;
                if (Platform.isIOS) {
                  builder = (context) => ModalWithNavigator();
                } else {
                  builder = (context) => ModalFit();
                }

                showCupertinoModalBottomSheet(
                  expand: Platform.isIOS,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: builder,
                );
              },
            ),
            const SizedBox(height: 10),
            _ChartSection(
              title: "Température de l'eau",
              titleBox1: "Moyenne 1h",
              valueBox1: "22.5°",
              titleBox2: "Moyenne 24h",
              valueBox2: "18°",
            ),
            const SizedBox(height: 10),
            _ChartSection(
              title: "Température de l'air",
              titleBox1: "Moyenne 1h",
              valueBox1: "38°",
              titleBox2: "Moyenne 24h",
              valueBox2: "21.15°",
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SumarySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 10, 0),
            child: Column(
              children: [
                Text(
                  "6.9 pH",
                  style: GoogleFonts.montserrat(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff046e0b),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Text(
                      "27.6°",
                      style: GoogleFonts.montserrat(
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff004455),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const FaIcon(
                      FontAwesomeIcons.droplet,
                      color: Color(0xff004455),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "36.4°",
                      style: GoogleFonts.montserrat(
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff004455),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const FaIcon(
                      FontAwesomeIcons.wind,
                      color: Color(0xff004455),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 320,
                ),
                Positioned(
                  left: 0,
                  child: Image.asset(
                    'assets/family.png',
                    fit: BoxFit.cover,
                    height: 320,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  final String title;
  final String titleBox1;
  final String valueBox1;
  final String titleBox2;
  final String valueBox2;
  final void Function()? onMorePressed;

  _ChartSection({
    required this.title,
    required this.titleBox1,
    required this.valueBox1,
    required this.titleBox2,
    required this.valueBox2,
    this.onMorePressed,
  });

  final Random random = Random();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 30),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            height: 290,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  spreadRadius: 4,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: LineChartWidget(
              title: title,
              onMorePressed: onMorePressed,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.fromLTRB(60, 0, 60, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MiniBox(
                    title: titleBox1,
                    value: valueBox1,
                  ),
                  const SizedBox(width: 30),
                  _MiniBox(
                    title: titleBox2,
                    value: valueBox2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBox extends StatelessWidget {
  final String title;
  final String value;

  const _MiniBox({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w200,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 25,
                fontWeight: FontWeight.w400,
                color: const Color(0xff008033),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
