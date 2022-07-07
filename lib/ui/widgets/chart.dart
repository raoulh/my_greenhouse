import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_greenhouse/models/models.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class LineChartWidget extends StatefulWidget {
  final String title;
  final void Function()? onMorePressed;

  const LineChartWidget({Key? key, required this.title, this.onMorePressed})
      : super(key: key);

  @override
  State<LineChartWidget> createState() => _LineChartState();
}

class _LineChartState extends State<LineChartWidget> {
  double _minX = 0;
  double _maxX = 0;
  double _minY = 2;
  double _maxY = 8;
  final int _divider = 1;

  double _zoomMin = 0, _zoomMax = 0;
  double _zoomStep = 0;
  double _prevMinX = 0;
  double _prevMaxX = 0;

  final GlobalKey _widgetKey = GlobalKey();
  Size _widgetSize = const Size(0, 0);

  List<FlSpot>? _values = const [];

  static const _maxZoomLevelMs = 6 * 60 * 60 * 1000; //max 6h zoom level

  final List<Color> _gradientColors = [
    const Color(0xff008033),
    const Color.fromARGB(61, 22, 160, 132),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_getWidgetInfo);
    _prepareDemoPHData();
  }

  void _getWidgetInfo(_) {
    final RenderBox renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox;
    _widgetSize = renderBox.size;
  }

  void _prepareDemoPHData() async {
    List<MeasValue>? data = await loadPHDataDay();

    data?.sort((a, b) {
      //sorting in ascending order
      return a.captureDate.compareTo(b.captureDate);
    });

    _zoomMin = data!.first.captureDate.millisecondsSinceEpoch.toDouble();
    _zoomMax = data.last.captureDate.millisecondsSinceEpoch.toDouble();

    //Load other ranges, and append them
    List<MeasValue>? dataW = await loadPHDataWeek();
    List<MeasValue>? dataM = await loadPHData3Months();

    data = [...data, ...dataW!, ...dataM!];
    data.sort((a, b) {
      //sorting in ascending order
      return a.captureDate.compareTo(b.captureDate);
    });

    double minY = 4;
    double maxY = 8;

    _values = data.map((mvalue) {
      if (mvalue.value < minY) {
        minY = mvalue.value - 0.5;
      }
      if (mvalue.value > maxY) {
        maxY = mvalue.value + 0.5;
      }

      return FlSpot(
        mvalue.captureDate.millisecondsSinceEpoch.toDouble(),
        mvalue.value,
      );
    }).toList();

    _minX = _zoomMin;
    _maxX = _zoomMax;
    _minY = (minY / _divider).floorToDouble() * _divider;
    _maxY = (maxY / _divider).ceilToDouble() * _divider;
    _zoomStep = (_zoomMax - _zoomMin) / 12;

    setState(() {});
  }

  void zoomIn() {
    setState(() {
      _zoomStep = (_maxX - _minX) / 12;
      var prevMinX = _minX;
      var prevMaxX = _maxX;
      _minX += _zoomStep;
      _maxX -= _zoomStep;

      if (_maxX - _minX < _maxZoomLevelMs) {
        _minX = prevMinX;
        _maxX = prevMaxX;
      }
    });
  }

  void zoomOut() {
    setState(() {
      _zoomStep = (_maxX - _minX) / 12;
      _minX -= _zoomStep;
      _maxX += _zoomStep;
    });
  }

  LineChartBarData _lineBarData() {
    return LineChartBarData(
      spots: _values,
      isCurved: false,
      color: const Color.fromARGB(255, 0, 114, 46),
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _gradientColors,
          stops: const [0, 1],
        ),
      ),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.w200,
      color: Colors.black,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 6,
      child: Text(value.toString(), style: style, textAlign: TextAlign.center),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final style = GoogleFonts.montserrat(
      fontSize: 10,
      fontWeight: FontWeight.w200,
      color: Colors.black,
    );

    var dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    String fmt = DateFormat(DateFormat.ABBR_MONTH_DAY, Intl.getCurrentLocale())
        .format(dt);

    return SideTitleWidget(
      angle: 55,
      space: 12,
      axisSide: meta.axisSide,
      child: Text(fmt, style: style),
    );
  }

  FlLine _drawingVerticalLine(double value) {
    return FlLine(
      color: Colors.grey[300],
      strokeWidth: 0.4,
    );
  }

  FlLine _drawingHorizontalLine(double value) {
    return FlLine(
      color: Colors.grey[600],
      strokeWidth: 0.4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            Row(
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    CupertinoIcons.zoom_out,
                    color: Colors.grey[700],
                    size: 25.0,
                  ),
                  onPressed: () => zoomOut(),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    CupertinoIcons.zoom_in,
                    color: Colors.grey[700],
                    size: 25.0,
                  ),
                  onPressed: () => zoomIn(),
                ),
                Visibility(
                  visible: widget.onMorePressed != null,
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    onPressed: widget.onMorePressed,
                    child: Icon(
                      CupertinoIcons.ellipsis_circle,
                      color: Colors.grey[700],
                      size: 25.0,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        AspectRatio(
          aspectRatio: 2,
          child: GestureDetector(
            onDoubleTap: () {
              setState(() {
                _minX = _zoomMin;
                _maxX = _zoomMax;
              });
            },
            onScaleStart: (ScaleStartDetails details) {
              _prevMinX = _minX;
              _prevMaxX = _maxX;
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              setState(() {
                _minX = _prevMinX / details.horizontalScale;
                _maxX = _prevMaxX / details.horizontalScale;

                if (_minX < _zoomMin) {
                  _minX = _zoomMin;
                }
                if (_maxX > _zoomMax) {
                  _maxX = _zoomMax;
                }
              });
            },
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              setState(() {
                double pixelWidth = _widgetSize.width -
                    28; //28 is the left labels reserved size
                double viewSize = _maxX - _minX;
                double horizDelta =
                    details.delta.dx.abs() * viewSize / pixelWidth;

                if (details.primaryDelta != null) {
                  if (details.primaryDelta!.isNegative) {
                    _minX += horizDelta;
                    _maxX += horizDelta;
                  } else {
                    _minX -= horizDelta;
                    _maxX -= horizDelta;
                  }
                }
              });
            },
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                    enabled: true,
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      // TODO : Utilize touch event here to perform any operation
                    },
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.green[900],
                      tooltipRoundedRadius: 10.0,
                      showOnTopOfTheChartBoxArea: true,
                      fitInsideHorizontally: true,
                      tooltipMargin: 0,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map(
                          (LineBarSpot touchedSpot) {
                            TextStyle textStyle = GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            );

                            //format datetime
                            var dt = DateTime.fromMillisecondsSinceEpoch(
                                touchedSpot.x.toInt());
                            String fmt =
                                '${DateFormat(DateFormat.ABBR_MONTH_DAY, Intl.getCurrentLocale()).format(dt)} ${DateFormat(DateFormat.HOUR24_MINUTE, Intl.getCurrentLocale()).format(dt)}';

                            return LineTooltipItem(
                              '${touchedSpot.y.toString()} \n',
                              textStyle,
                              children: [
                                TextSpan(
                                  text: fmt,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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
                            dashArray: [4, 2],
                          );
                          return TouchedSpotIndicatorData(
                            line,
                            FlDotData(show: true),
                          );
                        },
                      ).toList();
                    },
                    getTouchLineEnd: (_, __) => double.infinity),
                clipData: FlClipData.all(),
                lineBarsData: [_lineBarData()],
                minY: _minY,
                minX: _minX,
                maxY: _maxY,
                maxX: _maxX,
                borderData: FlBorderData(
                  border: const Border(
                    bottom: BorderSide(color: Colors.black26),
                    left: BorderSide(color: Colors.black26),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                  getDrawingVerticalLine: _drawingVerticalLine,
                  getDrawingHorizontalLine: _drawingHorizontalLine,
                ),
                titlesData: FlTitlesData(
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: _bottomTitleWidgets,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: _leftTitleWidgets,
                    ),
                  ),
                ),
              ),
              key: _widgetKey,
            ),
          ),
        ),
      ],
    );
  }
}
