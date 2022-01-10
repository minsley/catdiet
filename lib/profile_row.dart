import 'dart:ui';

import 'package:catdiet/gaugeChart.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'CatData.dart';
import 'barChart.dart';
import 'gaugeChart.dart';
import 'line_range_annotation.dart';
import 'package:flutter/foundation.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'barChart.dart';

class ProfileRow extends StatelessWidget {
  final CatProfile profile;

  ProfileRow(this.profile, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Row(children: [
      Expanded(
          flex: 2,
          child: Stack(
            children: [
              // Container(
              //   child: Image.asset('assets/cat1.png'),
              //   padding: EdgeInsets.only(bottom: 20, left: 20),
              //   height: 150,
              //   width: 150,
              // ),
              // Container(
              //   child: Text('Kashi', style: TextStyle(color: Colors.white, fontSize: 24)),
              // ),
              // SfCircularChart(
              //     series: <CircularSeries>[
              //       // Renders radial bar chart
              //       RadialBarSeries<int, String>(
              //         dataSource: [_kashi.records.last.kcal.toInt()],
              //         xValueMapper: (data, _) => '',
              //         yValueMapper: (data, _) => data,
              //         pointColorMapper: (data, _) => HSLColor.lerp(HSLColor.fromColor(Colors.red), HSLColor.fromColor(Colors.green), _kashi.records.last.kcal/_kashi.targetHigh)!.toColor(),
              //         radius: '100%',
              //         innerRadius: '80%',
              //         maximumValue: _kashi.targetHigh,
              //         cornerStyle: CornerStyle.bothCurve,
              //       )
              //     ]
              // ),
              SfRadialGauge(
                // enableLoadingAnimation: true,
                // animationDuration: 2000,
                  axes: <RadialAxis>[RadialAxis(
                    minimum: 0,
                    maximum: profile.targetHigh,
                    radiusFactor: 1,
                    showLabels: false,
                    showTicks: false,
                    axisLineStyle: const AxisLineStyle(
                        cornerStyle: CornerStyle.bothCurve,
                        thickness: 0.2,
                        thicknessUnit: GaugeSizeUnit.factor
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: profile.records.last.kcal,
                        cornerStyle: CornerStyle.bothCurve,
                        width: 0.2,
                        sizeUnit: GaugeSizeUnit.factor,
                        // enableAnimation: true, // This breaks things for some reason
                        // animationType: AnimationType.linear,
                        color: HSLColor.lerp(
                            HSLColor.fromColor(Colors.redAccent),
                            HSLColor.fromColor(Colors.green),
                            (profile.records.last.kcal/profile.targetHigh).clamp(0,1)
                        )!.toColor(),
                      ),
                      MarkerPointer(
                        value: profile.targetLow,
                        markerType: MarkerType.rectangle,
                        markerHeight: 3,
                        markerWidth: 22,
                        color: Colors.black38,
                      )
                    ],
                    annotations: [
                      GaugeAnnotation(
                          widget: Container(
                            margin: const EdgeInsets.only(left: 40, bottom: 20),
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: ExactAssetImage("assets/cat1.png"),
                                    scale: 1.3
                                )
                            ),
                          )
                      ),
                      GaugeAnnotation(
                        widget: Text(
                          profile.name.toString().substring(4),
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                        angle: 110,
                        positionFactor: .1,
                      ),
                      GaugeAnnotation(
                        widget: Text(
                          profile.records.last.kcal.toStringAsFixed(0) + ' / ' + profile.targetLow.toStringAsFixed(0),
                          style: TextStyle(color: Colors.black54),
                        ),
                        angle: 90,
                        positionFactor: 0.3,
                      )
                    ],
                    // ranges: <GaugeRange>[GaugeRange(
                    //   startValue: 0,
                    //   endValue: _kashi.records.last.kcal,
                    //   color: HSLColor.lerp(
                    //       HSLColor.fromColor(Colors.red),
                    //       HSLColor.fromColor(Colors.green),
                    //       (_kashi.records.last.kcal/_kashi.targetHigh).clamp(0,1)
                    //   )!.toColor()
                    // )],
                  )]
              )
            ],
            alignment: Alignment.center,
          )),
      // Expanded(
      //   child: StackedBarChart([
      //     charts.Series<int, String>(
      //       id: 'Daily Calories',
      //       domainFn: (a, b) => '',
      //       measureFn: (x, _) => x,
      //       data: [profile.records.last.kcal.toInt()],
      //       fillColorFn: (a, b) => charts.Color.fromHex(code: '#24B400'),
      //       measureUpperBoundFn: (datum, index) => 400,
      //       measureLowerBoundFn: (datum, index) => 0,
      //
      //     ),
      //   ], animate: false,),
      // ),
      Expanded(
          child: LineRangeAnnotationChart(
            [
              charts.Series<Datum, DateTime>(
                  id: 'Monthly Calories',
                  domainFn: (Datum x, _) => x.date,
                  measureFn: (Datum x, _) => x.value,
                  measureLowerBoundFn: (a, b) => 0,
                  measureUpperBoundFn: (a, b) => 400,
                  colorFn: (a, b) =>
                      charts.Color.fromHex(code: '#00D9E7'),
                  areaColorFn: (a, b) => charts.Color.transparent,
                  data: profile.records.map((e) => Datum(e.datetime, e.kcal.toInt())).toList()
              )
            ],
            animate: false,
          ),
          flex: 3
      )
    ]));
  }
}