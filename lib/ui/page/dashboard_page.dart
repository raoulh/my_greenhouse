import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_greenhouse/models/greenhouse_response.dart';
import 'package:my_greenhouse/services/failure.dart';
import 'package:my_greenhouse/services/greenhouse_service.dart';
import 'package:my_greenhouse/services/lifecycle_service.dart';
import 'package:my_greenhouse/services/myfood_service.dart';
import 'package:my_greenhouse/ui/page/notif_settings_view.dart';
import 'package:my_greenhouse/ui/widgets/appbar.dart';
import 'package:my_greenhouse/ui/widgets/chart.dart';
import 'package:my_greenhouse/ui/widgets/error_dialog.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late GreenhouseService grService;
  late MyfoodService mfService;
  late LifeCycleService lifecycleService;

  GreenhouseResponse resultData =
      GreenhouseResponse(error: true, username: "", meas: []);
  int currentProdUnit = 0;

  ChartResult phData = ChartResult([], 0, 0);
  ChartResult waterData = ChartResult([], 0, 0);
  ChartResult airData = ChartResult([], 0, 0);
  ChartResult humiData = ChartResult([], 0, 0);

  bool resetZoom = false;

  @override
  void initState() {
    super.initState();

    grService = Provider.of<GreenhouseService>(context, listen: false);
    mfService = Provider.of<MyfoodService>(context, listen: false);
    lifecycleService = Provider.of<LifeCycleService>(context, listen: false);

    _loadInitialData(true);

    grService.addListener(() {
      _loadInitialData(false);
    });

    //reload when app is resumed
    lifecycleService.addResumeObserver(_refreshData);
  }

  @override
  void dispose() {
    lifecycleService.removeResumeObserver(() {
      _loadInitialData(true);
    });
    super.dispose();
  }

  Future<void> _loadInitialData(bool notify) async {
    print("_loadInitialData");

    currentProdUnit = grService.currentProdUnitIndex;

    try {
      resetZoom = false;
      resultData = await grService.getCurrentData(notify);
      setState(() {});

      if (currentProdUnit >= resultData.meas.length) {
        return;
      }

      int prodUnit = resultData.meas[currentProdUnit].productUnitId;

      phData = await mfService.getPHData(prodUnit);
      setState(() {});
      waterData = await mfService.getWaterTempData(prodUnit);
      setState(() {});
      airData = await mfService.getAirTempData(prodUnit);
      setState(() {});
      humiData = await mfService.getHumidityData(prodUnit);
      setState(() {});
    } on Failure catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              type: DialogTypes.error,
              message: e.toString(),
              buttonText: AppLocalizations.of(context).tryAgain,
              buttonFn: () {
                Navigator.pop(context);
                _loadInitialData(true);
              },
            );
          });
    }
  }

  Future<bool> _refreshData() async {
    currentProdUnit = grService.currentProdUnitIndex;

    try {
      setState(() {
        resetZoom = true;
      });
      resultData = await grService.getRefreshedData();
      setState(() {});

      if (currentProdUnit >= resultData.meas.length) {
        return true;
      }

      int prodUnit = resultData.meas[currentProdUnit].productUnitId;

      phData = await mfService.getPHData(prodUnit);
      setState(() {});
      waterData = await mfService.getWaterTempData(prodUnit);
      setState(() {});
      airData = await mfService.getAirTempData(prodUnit);
      setState(() {});
      humiData = await mfService.getHumidityData(prodUnit);
      setState(() {});

      setState(() {
        resetZoom = false;
      });

      return true;
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              type: DialogTypes.error,
              message: e.toString(),
              buttonText: AppLocalizations.of(context).tryAgain,
              buttonFn: () {
                Navigator.pop(context);
                _refreshData();
              },
            );
          });
      return false;
    }
  }

  String _appBarTitle() {
    if (currentProdUnit < resultData.meas.length) {
      return resultData.meas[currentProdUnit].productUnitType;
    }
    return "N/A";
  }

  ProdMeas _phData() {
    if (currentProdUnit < resultData.meas.length) {
      return resultData.meas[currentProdUnit].ph;
    }
    return ProdMeas(currentValue: 0, hourAverageValue: 0, dayAverageValue: 0);
  }

  ProdMeas _waterTempData() {
    if (currentProdUnit < resultData.meas.length) {
      return resultData.meas[currentProdUnit].waterTemp;
    }
    return ProdMeas(currentValue: 0, hourAverageValue: 0, dayAverageValue: 0);
  }

  ProdMeas _airTempData() {
    if (currentProdUnit < resultData.meas.length) {
      return resultData.meas[currentProdUnit].airTemp;
    }
    return ProdMeas(currentValue: 0, hourAverageValue: 0, dayAverageValue: 0);
  }

  ProdMeas _humidityData() {
    if (currentProdUnit < resultData.meas.length) {
      return resultData.meas[currentProdUnit].humidity;
    }
    return ProdMeas(currentValue: 0, hourAverageValue: 0, dayAverageValue: 0);
  }

  ProdUnit? _selectedProdUnit() {
    if (currentProdUnit < resultData.meas.length) {
      return resultData.meas[currentProdUnit];
    }
    return null;
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    bool success = await _refreshData();

    if (!success) {
      _refreshController.refreshFailed();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: _appBarTitle(),
        showSettings: true,
      ),
      backgroundColor: Colors.white,
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: const WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: Platform.isIOS
              ? const BouncingScrollPhysics()
              : const ClampingScrollPhysics(),
          child: Column(
            children: [
              _SumarySection(
                resultData: _selectedProdUnit(),
              ),
              const SizedBox(height: 10),
              _ChartSection(
                title: AppLocalizations.of(context).evolutionPh,
                titleBox1: AppLocalizations.of(context).average1h,
                valueBox1: _phData().hourAverageValue.toString(),
                titleBox2: AppLocalizations.of(context).average24h,
                valueBox2: _phData().dayAverageValue.toString(),
                chartData: phData,
                resetZoom: resetZoom,
                onMorePressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotifSettingsPage(
                              notifType: NotifType.pH,
                            )),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ChartSection(
                title: AppLocalizations.of(context).waterTemp,
                titleBox1: AppLocalizations.of(context).average1h,
                valueBox1: _waterTempData().hourAverageValue.toString(),
                titleBox2: AppLocalizations.of(context).average24h,
                valueBox2: _waterTempData().dayAverageValue.toString(),
                chartData: waterData,
                resetZoom: resetZoom,
                onMorePressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotifSettingsPage(
                              notifType: NotifType.waterTemp,
                            )),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ChartSection(
                title: AppLocalizations.of(context).airTemp,
                titleBox1: AppLocalizations.of(context).average1h,
                valueBox1: _airTempData().hourAverageValue.toString(),
                titleBox2: AppLocalizations.of(context).average24h,
                valueBox2: _airTempData().dayAverageValue.toString(),
                chartData: airData,
                resetZoom: resetZoom,
                onMorePressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotifSettingsPage(
                              notifType: NotifType.airTemp,
                            )),
                  );
                },
              ),
              const SizedBox(height: 10),
              _ChartSection(
                title: AppLocalizations.of(context).humidity,
                titleBox1: AppLocalizations.of(context).average1h,
                valueBox1: _humidityData().hourAverageValue.toString(),
                titleBox2: AppLocalizations.of(context).average24h,
                valueBox2: _humidityData().dayAverageValue.toString(),
                chartData: humiData,
                resetZoom: resetZoom,
                onMorePressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotifSettingsPage(
                              notifType: NotifType.humidity,
                            )),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SumarySection extends StatelessWidget {
  final ProdUnit? resultData;

  const _SumarySection({required this.resultData});

  String _currentPH() {
    if (resultData != null && resultData?.ph != null) {
      return resultData!.ph.currentValue.toString();
    }
    return "-";
  }

  String _currentWaterTemp() {
    if (resultData != null && resultData?.waterTemp != null) {
      return resultData!.waterTemp.currentValue.toString();
    }
    return "-";
  }

  String _currentAirTemp() {
    if (resultData != null && resultData?.airTemp != null) {
      return resultData!.airTemp.currentValue.toString();
    }
    return "-";
  }

  String _currentPic() {
    if (resultData != null) {
      if (resultData!.productUnitType.contains("Family")) {
        return "assets/family.png";
      } else if (resultData!.productUnitType.contains("City")) {
        return "assets/city.png";
      }
    }
    return "assets/family.png";
  }

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
                  "${_currentPH()} pH",
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
                      "${_currentWaterTemp()}°",
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
                      "${_currentAirTemp()}°",
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
                    _currentPic(),
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
  final ChartResult chartData;
  final bool resetZoom;

  _ChartSection({
    required this.title,
    required this.titleBox1,
    required this.valueBox1,
    required this.titleBox2,
    required this.valueBox2,
    required this.chartData,
    this.onMorePressed,
    required this.resetZoom,
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
              chartData: chartData,
              resetZoom: resetZoom,
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
