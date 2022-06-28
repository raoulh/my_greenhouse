import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:collection/collection.dart';

class PricePoint {
  final double x;
  final double y;

  PricePoint({required this.x, required this.y});
}

List<PricePoint> get pricePoints {
  final Random random = Random();
  final randomNumbers = <double>[];
  for (var i = 1; i <= 12; i++) {
    randomNumbers.add(random.nextDouble());
  }

  return randomNumbers
      .mapIndexed(
          (index, element) => PricePoint(x: index.toDouble(), y: element))
      .toList();
}

const _dashArray = [4, 2];

class LineChartWidget extends StatelessWidget {
  final List<PricePoint> points;
  final bool isPositiveChange;

  const LineChartWidget(this.points, this.isPositiveChange, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minY = points.map((point) => point.y).reduce(min);
    final maxY = points.map((point) => point.y).reduce(max);

    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
              enabled: true,
              touchCallback:
                  (FlTouchEvent event, LineTouchResponse? touchResponse) {
                // TODO : Utilize touch event here to perform any operation
              },
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.blue,
                tooltipRoundedRadius: 20.0,
                showOnTopOfTheChartBoxArea: true,
                fitInsideHorizontally: true,
                tooltipMargin: 0,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map(
                    (LineBarSpot touchedSpot) {
                      const textStyle = TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      );
                      return LineTooltipItem(
                        points[touchedSpot.spotIndex].y.toInt().toString(),
                        textStyle,
                      );
                    },
                  ).toList();
                },
              ),
              getTouchedSpotIndicator:
                  (LineChartBarData barData, List<int> indicators) {
                return indicators.map(
                  (int index) {
                    final line = FlLine(
                        color: Colors.grey,
                        strokeWidth: 1,
                        dashArray: _dashArray);
                    return TouchedSpotIndicatorData(
                      line,
                      FlDotData(show: false),
                    );
                  },
                ).toList();
              },
              getTouchLineEnd: (_, __) => double.infinity),
          lineBarsData: [
            LineChartBarData(
              spots: points.map((point) => FlSpot(point.x, point.y)).toList(),
              isCurved: false,
              color: isPositiveChange ? Colors.green : Colors.red,
              dotData: FlDotData(
                show: false,
              ),
            ),
          ],
          minY: minY,
          minX: 0,
          maxY: maxY,
          borderData: FlBorderData(
              border: const Border(bottom: BorderSide(), left: BorderSide())),
          gridData: FlGridData(show: false),
          // titlesData: FlTitlesData(
          //   bottomTitles: _bottomTitles,
          //   leftTitles: SideTitles(showTitles: false),
          //   topTitles: SideTitles(showTitles: false),
          //   rightTitles: SideTitles(showTitles: false),
          // ),
        ),
      ),
    );
  }
}
/*
SideTitles get _bottomTitles => SideTitles(
      showTitles: true,
      reservedSize: 22,
      margin: 10,
      interval: 1,
      getTextStyles: (context, value) => const TextStyle(
        color: Colors.blueGrey,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      getTitles: (value) {
        switch (value.toInt()) {
          case 1:
            return 'Jan';
          case 3:
            return 'Mar';
          case 5:
            return 'May';
          case 7:
            return 'Jul';
          case 9:
            return 'Sep';
          case 11:
            return 'Nov';
        }
        return '';
      },
    );
*/