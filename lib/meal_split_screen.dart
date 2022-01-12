import 'dart:ui';

import 'package:catdiet/CatData.dart';
import 'package:catdiet/main.dart';
import 'package:catdiet/save_dialog.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart' as gsheet;
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:intl/intl.dart' as intl;
import 'package:test/test.dart';

class MealSplitScreen extends StatefulWidget {
  const MealSplitScreen({Key? key, required this.sheet, required this.data, required this.foods, required this.selectedFoods}) : super(key: key);

  final gsheet.Spreadsheet sheet;
  final CatData data;
  final List<Food> foods;
  final List<int> selectedFoods;

  @override
  State<MealSplitScreen> createState() => MealSplitState();
}

class MealSplitState extends State<MealSplitScreen> {

  SfRangeValues _values = const SfRangeValues(-0.5, 0.5);
  final intl.NumberFormat _formatter = intl.NumberFormat('#%');

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: const Text('How much did they eat?'),
        ),
        body: Stack(children: [
          Container(
              padding: EdgeInsets.only(left: 50, right: 50),
              child: SfRangeSliderTheme(
                data: SfRangeSliderThemeData(
                  trackCornerRadius: 4,
                  activeTrackHeight: 50,
                  inactiveTrackHeight: 50,
                  activeTrackColor: Colors.deepPurple,
                  inactiveTrackColor: Colors.black12,
                  thumbRadius: 40,
                  thumbColor: Colors.pink,
                  tickOffset: Offset(0,-45),
                  tickSize: Size(2, 80),
                  minorTickSize: Size(2, 40),
                  activeTickColor: Colors.black54,
                  activeMinorTickColor: Colors.black38,
                  inactiveTickColor: Colors.black54,
                  inactiveMinorTickColor: Colors.black38,
                ),
                child: SfRangeSlider(
                  min: -1,
                  max: 1,
                  values: _values,
                  interval: .5,
                  showTicks: true,
                  showLabels: true,
                  enableTooltip: true,
                  shouldAlwaysShowTooltip: true,
                  minorTicksPerInterval: 4,
                  dragMode: SliderDragMode.both,
                  onChanged: (SfRangeValues values){
                    setState(() {
                      var newStart = ((values.start as double).clamp(-1, 0) *10).roundToDouble() / 10;
                      var newEnd = ((values.end as double).clamp(0, 1) *10).roundToDouble() / 10;
                      if(newEnd - newStart > 1){
                        if(newEnd != _values.end){
                          newStart = newEnd - 1;
                        } else {
                          newEnd = 1 + newStart;
                        }
                      }
                      _values = SfRangeValues(newStart, newEnd);
                    });
                  },
                  labelFormatterCallback: (actualValue, formattedText) => _formatter.format(actualValue.abs()),
                  tooltipTextFormatterCallback: (actualValue, formattedText) => _formatter.format(actualValue.abs()),
                  startThumbIcon: Center(child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: Image.asset(
                      'assets/k.png',
                      height: 70.0,
                      width: 70.0,
                      fit: BoxFit.scaleDown,
                    ),
                  )),
                  endThumbIcon: Center(child: ClipRRect(
                    borderRadius: BorderRadius.circular(40.0),
                    child: Image.asset(
                      'assets/b.png',
                      height: 70.0,
                      width: 70.0,
                      fit: BoxFit.scaleDown,
                    ),
                  )),
                )
              )
          ),
          Container(
              alignment: Alignment.bottomRight,
              margin: const EdgeInsets.only(bottom: 20, right: 20),
              child: FloatingActionButton.large(
                child: const Icon(Icons.check, size: 80,),
                backgroundColor: Colors.green,
                onPressed: () => showDialog(context: context, builder: (context) => SaveDialog(data: widget.data, sheet: widget.sheet, foods: widget.foods, selectedFoods: widget.selectedFoods, k_split: _values.start.abs(), b_split: _values.end,)),
              )
          )
        ])
    );
  }
}