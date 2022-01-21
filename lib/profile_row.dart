import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sfChart;
import 'CatData.dart';
import 'line_range_annotation.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:math';
import 'package:collection/collection.dart';

class ProfileRow extends StatelessWidget {
  final CatProfile profile;
  final intl.DateFormat _dateFormat = intl.DateFormat.Md('en_US');

  ProfileRow(this.profile, {Key? key}) : super(key: key);

  bool isTodaysRecord(DietRecord r) {
    var now = DateTime.now();
    return DateTime(r.datetime.year, r.datetime.month, r.datetime.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays == 0;
  }

  @override
  Widget build(BuildContext context) {
    var currentKcals = profile.records.lastWhereOrNull(isTodaysRecord)?.kcal ?? 0;

    return Expanded(child: Row(children: [
      Expanded(
        flex: 3,
        child: Stack(
            children: [
              // SfRadialGauge(
              //   // enableLoadingAnimation: true,
              //   // animationDuration: 2000,
              //     axes: <RadialAxis>[RadialAxis(
              //       minimum: 0,
              //       maximum: profile.targetHigh,
              //       radiusFactor: 1,
              //       showLabels: false,
              //       showTicks: false,
              //       axisLineStyle: const AxisLineStyle(
              //           cornerStyle: CornerStyle.bothCurve,
              //           thickness: 0.2,
              //           thicknessUnit: GaugeSizeUnit.factor
              //       ),
              //       pointers: <GaugePointer>[
              //         RangePointer(
              //           value: profile.records.last.kcal,
              //           cornerStyle: CornerStyle.bothCurve,
              //           width: 0.2,
              //           sizeUnit: GaugeSizeUnit.factor,
              //           // enableAnimation: true, // This breaks things for some reason
              //           // animationType: AnimationType.linear,
              //           color: HSLColor.lerp(
              //               HSLColor.fromColor(Colors.redAccent),
              //               HSLColor.fromColor(Colors.green),
              //               (profile.records.last.kcal/profile.targetHigh).clamp(0,1)
              //           )!.toColor(),
              //         ),
              //         MarkerPointer(
              //           value: profile.targetLow,
              //           markerType: MarkerType.rectangle,
              //           markerHeight: 3,
              //           markerWidth: 22,
              //           color: Colors.black38,
              //         )
              //       ],
              //       annotations: [
              //         GaugeAnnotation(
              //             widget: Container(
              //               margin: const EdgeInsets.only(left: 40, bottom: 20),
              //               decoration: const BoxDecoration(
              //                   image: DecorationImage(
              //                       image: ExactAssetImage("assets/cat1.png"),
              //                       scale: 1.3
              //                   )
              //               ),
              //             )
              //         ),
              //         GaugeAnnotation(
              //           widget: Text(
              //             profile.name.toString().substring(4),
              //             style: TextStyle(color: Colors.white, fontSize: 24),
              //           ),
              //           angle: 110,
              //           positionFactor: .1,
              //         ),
              //         GaugeAnnotation(
              //           widget: Text(
              //             profile.records.last.kcal.toStringAsFixed(0) + ' / ' + profile.targetLow.toStringAsFixed(0),
              //             style: TextStyle(color: Colors.black54),
              //           ),
              //           angle: 90,
              //           positionFactor: 0.3,
              //         )
              //       ],
              //     )]
              // )
              CircleAvatar(
                foregroundImage: AssetImage(profile.name == Cat.Kashi ? 'assets/k.png' : 'assets/b.png'),
                radius: 60,
                backgroundColor: Colors.transparent,
              ),
              sfChart.SfCircularChart(
                series: [sfChart.RadialBarSeries(
                  maximumValue: profile.targetHigh,
                  dataSource: [currentKcals],
                  xValueMapper: (datum, index) => index,
                  yValueMapper: (datum, index) => datum,
                  cornerStyle: sfChart.CornerStyle.bothCurve,
                  radius: '90',
                  innerRadius: '70',
                  pointColorMapper: (datum, index) => HSLColor.lerp(
                      HSLColor.fromColor(const Color(0xFFBF1406)),
                      HSLColor.fromColor(const Color(0xFF1A7341)),
                      (currentKcals/profile.targetHigh).clamp(0,1)
                  )!.toColor(),
                  // pointColorMapper: (datum, index) => Color.lerp(
                  //     Colors.redAccent,
                  //     Colors.green,
                  //     (profile.records.last.kcal/profile.targetHigh).clamp(0,1),
                  // ),
                )],
                annotations: [
                  sfChart.CircularChartAnnotation(
                      widget: Container(
                        margin: const EdgeInsets.only(top: 12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name.toString().substring(4),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                '${currentKcals.toInt()} / ${profile.targetLow.toInt()}',
                                style: const TextStyle(
                                  color: Color(0xFF555555),
                                  fontSize: 14,
                                ),
                              )
                            ]
                        ),
                      ),
                      radius: '120',
                  ),
                  sfChart.CircularChartAnnotation(
                      widget: const Icon(Icons.circle, color: Colors.black38, size: 15),
                      radius: '80',
                      angle: 360*profile.targetLow~/profile.targetHigh-90
                  ),
                  sfChart.CircularChartAnnotation(
                      widget: const Icon(Icons.circle, color: Colors.black38, size: 15),
                      radius: '80',
                      angle: 270
                  )
                ],
              ),
            ],
            alignment: Alignment.center,
          )
      ),
      Expanded(
          // child: LineRangeAnnotationChart(
          //   [
          //     charts.Series<Datum, DateTime>(
          //         id: 'Monthly Calories',
          //         domainFn: (Datum x, _) => x.date,
          //         measureFn: (Datum x, _) => x.value,
          //         measureLowerBoundFn: (a, b) => 0,
          //         measureUpperBoundFn: (a, b) => 400,
          //         colorFn: (a, b) =>
          //             charts.Color.fromHex(code: '#00D9E7'),
          //         areaColorFn: (a, b) => charts.Color.transparent,
          //         data: profile.records.map((e) => Datum(e.datetime, e.kcal.toInt())).toList()
          //     )
          //   ],
          //   animate: false,
          // ),
        flex: 5,
        child: sfChart.SfCartesianChart(
          plotAreaBorderWidth: 0,
          enableAxisAnimation: true,
          series: <sfChart.ChartSeries>[
            sfChart.SplineSeries<Datum, DateTime>(
              dataSource: profile.records.map((e) => Datum(e.datetime, e.kcal.toInt())).toList(),
              // Dash values for spline
              // dashArray: <double>[5, 5],
              xValueMapper: (Datum sales, _) => sales.date,
              yValueMapper: (Datum sales, _) => sales.value,
              color: const Color(0xFF00D9E7),
              width: 1,
              // markerSettings: const sfChart.MarkerSettings(
              //   isVisible: true
              // )
            )],
          primaryXAxis: sfChart.DateTimeAxis(
            isInversed: true,
            majorGridLines: const sfChart.MajorGridLines(width: 0),
            tickPosition: sfChart.TickPosition.inside,
            axisLine: const sfChart.AxisLine(
              color: Color(0xFF908E8E),
              width: 1
            ),
            dateFormat: _dateFormat
          ),
          primaryYAxis: sfChart.NumericAxis(
            minimum: profile.records.map((e)=>e.kcal).reduce(min) - 30,
            maximum: profile.records.map((e)=>e.kcal).reduce(max) + 30,
            decimalPlaces: 0,
            tickPosition: sfChart.TickPosition.inside,
            axisLine: const sfChart.AxisLine(
                color: Color(0xFF908E8E),
                width: 1
            ),
            majorGridLines: const sfChart.MajorGridLines(width: 0),
            plotBands: <sfChart.PlotBand>[
              sfChart.PlotBand(
                isVisible: true,
                start: profile.targetLow,
                end: profile.targetHigh,
                color: const Color(0xFF2DDB01), //const Color(0xFFE3F3DC),
                opacity: 0.12,
              ),
              sfChart.PlotBand(
                isVisible: true,
                start: profile.targetLow,
                end: profile.targetLow,
                color: const Color(0xFF000000),
                borderWidth: 0,//.1,
                text: profile.targetLow.toInt().toString(),
                horizontalTextAlignment: sfChart.TextAnchor.end,
                verticalTextAlignment: sfChart.TextAnchor.start,
                textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w300)
              ),
              sfChart.PlotBand(
                isVisible: true,
                start: profile.targetHigh,
                end: profile.targetHigh,
                color: const Color(0xFF000000),
                borderWidth: 0,//.1,
                text: profile.targetHigh.toInt().toString(),
                horizontalTextAlignment: sfChart.TextAnchor.end,
                verticalTextAlignment: sfChart.TextAnchor.end,
                textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w300)
              ),
            ],
        )),
      )
    ]));
  }
}