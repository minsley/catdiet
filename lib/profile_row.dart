import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'CatData.dart';
import 'line_range_annotation.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

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
                  )]
              )
            ],
            alignment: Alignment.center,
          )),
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