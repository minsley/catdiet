/// Line chart with range annotations example.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class LineRangeAnnotationChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  LineRangeAnnotationChart(this.seriesList, {required this.animate});

  /// Creates a [LineChart] with sample data and range annotations.
  ///
  /// The second annotation extends beyond the range of the series data,
  /// demonstrating the effect of the [Charts.RangeAnnotation.extendAxis] flag.
  /// This can be set to false to disable range extension.
  factory LineRangeAnnotationChart.withSampleData() {
    return LineRangeAnnotationChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    // return charts.LineChart(List.from(seriesList), animate: animate, behaviors: [
    //   charts.RangeAnnotation([
    //     charts.RangeAnnotationSegment(
    //         190, 220, charts.RangeAnnotationAxisType.measure,
    //         labelPosition: charts.AnnotationLabelPosition.outside,
    //         startLabel: '190',
    //         endLabel: '220',
    //         color: charts.Color.fromHex(code: '#DFF4DA'))
    //   ]),
    // ]);
    return charts.TimeSeriesChart(List.from(seriesList), animate: animate, behaviors: [
      charts.RangeAnnotation([
        charts.RangeAnnotationSegment(
            190, 220, charts.RangeAnnotationAxisType.measure,
            labelPosition: charts.AnnotationLabelPosition.outside,
            startLabel: '190',
            endLabel: '220',
            color: charts.Color.fromHex(code: '#DFF4DA'))
      ]),
    ],
    primaryMeasureAxis: const charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(desiredTickCount: 2), showAxisLine: true
    ),
    domainAxis: const charts.DateTimeAxisSpec(
        tickProviderSpec: charts.AutoDateTimeTickProviderSpec(),
      // tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec()
    ));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<Datum, DateTime>> _createSampleData() {
    final data = [
      Datum(DateTime.now(), 5),
      Datum(DateTime.now().subtract(Duration(days: 1)), 25),
      Datum(DateTime.now().subtract(Duration(days: 2)), 100),
      Datum(DateTime.now().subtract(Duration(days: 3)), 75),
    ];

    return [
      charts.Series<Datum, DateTime>(
        id: 'Sales',
        domainFn: (Datum datum, _) => datum.date,
        measureFn: (Datum datum, _) => datum.value,
        data: data,
      )
    ];
  }
}

/// Sample linear data type.
class Datum {
  final DateTime date;
  final int value;

  Datum(this.date, this.value);
}