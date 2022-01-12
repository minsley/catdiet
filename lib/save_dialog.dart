import 'dart:ui';

import 'package:catdiet/CatData.dart';
import 'package:catdiet/cat_api.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart' as gsheet;
import 'package:intl/intl.dart' as intl;

class SaveDialog extends AlertDialog {

  final gsheet.Spreadsheet sheet;
  final CatData data;
  final List<Food> foods;
  final List<int> selectedFoods;
  final double k_split;
  final double b_split;

  final CatApi _api = CatApi();
  final List<MealRecord> _records = [];
  final intl.NumberFormat _format = intl.NumberFormat('#.#');

  SaveDialog({Key? key, required this.sheet, required this.data, required this.foods, required this.selectedFoods, required this.k_split, required this.b_split}) : super(key: key) {
    for(int i=0; i<selectedFoods.length; i++) {
      var food = foods[selectedFoods[i]];
      _records.add(MealRecord(Cat.Kashi, food.variety, food.packageOz / food.servingsPerPackage * k_split, food.packageKcal / food.servingsPerPackage * k_split));
      _records.add(MealRecord(Cat.Batman, food.variety, food.packageOz / food.servingsPerPackage * b_split, food.packageKcal / food.servingsPerPackage * b_split));
    }
  }

  Future<void> addToSheet() async {
    await _api.logMeal(_records);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Save to Google Sheets?'),
        content: Container(
          height: 250, width: 400,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(
                  label: Text(
                    'Name',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Food',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Oz',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'kcal',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
              rows: List<DataRow>.generate(_records.length, (i) => DataRow(
                  cells: [
                    DataCell(Text(_records[i].cat.name)),
                    DataCell(Text(_records[i].foodVarietyName)),
                    DataCell(Text(_format.format(_records[i].oz))),
                    DataCell(Text(_records[i].kcal.toInt().toString())),
                  ]
              ))
            )

            // rows: const <DataRow>[
            //   DataRow(
            //     cells: <DataCell>[
            //       DataCell(Text('Sarah')),
            //       DataCell(Text('19')),
            //       DataCell(Text('Student')),
            //       DataCell(Text('Boob')),
            //     ],
            //   ),
            //   DataRow(
            //     cells: <DataCell>[
            //       DataCell(Text('Janine')),
            //       DataCell(Text('43')),
            //       DataCell(Text('Professor')),
            //       DataCell(Text('Boob')),
            //     ],
            //   ),
            //   DataRow(
            //     cells: <DataCell>[
            //       DataCell(Text('William')),
            //       DataCell(Text('27')),
            //       DataCell(Text('Associate Professor')),
            //       DataCell(Text('Boob')),
            //     ],
            //   ),
            // ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('SAVE'),
            onPressed: () => {
              addToSheet()
                  .then((value) => Navigator.popUntil(context, ModalRoute.withName('/')))
            },
          ),
          TextButton(
            child: const Text('CANCEL'),
            // onPressed: () => ,
            onPressed: () => Navigator.pop(context),
          )
        ]);
  }
}