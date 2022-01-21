

import 'package:flutter/foundation.dart';
import 'package:googleapis/sheets/v4.dart';

class CatData {

  final List<CatProfile> cats;
  final List<Food> foods;

  CatData(this.cats, this.foods);

  factory CatData.parse(Spreadsheet sheet) {
    return CatData(
      [
        CatProfile(
            Cat.Kashi,
            sheet.sheets?.first.data?.first.rowData?.first.values?.last.effectiveValue?.numberValue ?? 0,
            sheet.sheets?.first.data?.first.rowData?.last.values?.last.effectiveValue?.numberValue ?? 0,
            sheet.sheets?.first.data?.last.rowData
                ?.where((r) => r.values?.length == 3 && r.values?.first.effectiveValue != null)
                .map((r) => DietRecord(
                Cat.Kashi,
                parseSerialDatetime(r, 0),
                parseDouble(r, 2)))
                .toList() ?? []),
        CatProfile(
            Cat.Batman,
            sheet.sheets?.first.data?.first.rowData?.first.values?.first.effectiveValue?.numberValue ?? 0,
            sheet.sheets?.first.data?.first.rowData?.last.values?.first.effectiveValue?.numberValue ?? 0,
            sheet.sheets?.first.data?.last.rowData
                ?.where((r) => r.values?.length == 3 && r.values?.first.effectiveValue != null)
                .map((r) => DietRecord(
                Cat.Batman,
                parseSerialDatetime(r, 0),
                parseDouble(r, 1)))
                .toList() ?? [])
      ],
      sheet.sheets?.last.data?.first.rowData
        ?.where((r) => parseString(r, 0).isNotEmpty)
        .map((r) => Food(
          parseString(r, 0),  // brand
          parseString(r, 1),  // line
          parseString(r, 2),  // variety,
          parseString(r, 3),  // mainIngredient,
          parseString(r, 4),  // shape,
          parseFoodType(r, 5),  // type,
          parseDouble(r, 6),  // packageOz,
          parseDouble(r, 7),  // packageKcal,
          parseDouble(r, 8),  // kcalPerKg,
          parseCurrency(r, 9),  // packageCost,
          parseDouble(r, 10),  // kcalPerOz,
          parseCurrency(r, 11),  // costPerOz,
          parseCurrency(r, 12),  // costPer100Kcal,
          parseString(r, 13),  // foodNotes,
          parseString(r, 14),  // feedingNotes,
          parseString(r, 15),  // fullIngredients,
          parseUri(r, 18),  // canPicUri,
          parseUri(r, 19),  // foodPicUri
          parseBool(r, 20), // isInStock
          parseDouble(r, 21), // servingsPerPackage
          parseString(r, 22), // servingUnit
      )).toList() ?? []
    );
  }

  static String parseString(RowData r, int i) {
    if(r.values == null || r.values!.length < i+1) return '';
    return r.values?[i].effectiveValue?.stringValue ?? '';
  }

  static double parseDouble(RowData r, int i) {
    if(r.values == null || r.values!.length < i+1) return -1;
    return r.values?[i].effectiveValue?.numberValue ?? -1;
  }

  static double parseCurrency(RowData r, int i) {
    if(r.values == null || r.values!.length < i+1) return -1;
    return double.parse(r.values?[i].effectiveValue?.stringValue?.substring(1) ?? '0');
  }

  static Uri? parseUri(RowData r, int i) {
    if(r.values == null || r.values!.length < i+1) return null;
    return Uri.tryParse(r.values?[i].effectiveValue?.stringValue ?? '');
  }

  static FoodType parseFoodType(RowData r, int i) {
    if(r.values == null || r.values!.length < i+1) return FoodType.treat;
    return FoodType.values.firstWhere((e) => describeEnum(e) == (r.values?[i].effectiveValue?.stringValue?.toLowerCase() ?? 'treat'));
  }

  static DateTime parseSerialDatetime(RowData r, int i) {
    var dt = DateTime(1900, 1, 1);
    if(r.values == null || r.values!.length < i+1) return dt;
    return dt.add(Duration(days: (r.values?.first.effectiveValue?.numberValue?.toInt() ?? 2)-2));
  }

  static bool parseBool(RowData r, int i) {
    if(r.values == null || r.values!.length < i+1) return false;
    return r.values?[i].effectiveValue?.boolValue ?? false;
  }
}

enum Cat{
  Kashi,
  Batman
}

class CatProfile {
  final Cat name;
  final double targetLow;
  final double targetHigh;
  final List<DietRecord> records;

  CatProfile(this.name, this.targetLow, this.targetHigh, this.records);
}

class DietRecord {
  final Cat cat;
  final DateTime datetime;
  final double kcal;

  DietRecord(this.cat, this.datetime, this.kcal);
}

enum FoodType{
  dry,
  wet,
  treat
}

class Food {
  final String brand;
  final String line;
  final String variety;
  final String mainIngredients;
  final String shape;
  final FoodType type;
  final double packageOz;
  final double packageKcal;
  final double kcalPerKg;
  final double packageCost;
  final double kcalPerOz;
  final double costPerOz;
  final double costPer100Kcal;
  final String foodNotes;
  final String feedingNotes;
  final String fullIngredients;
  final Uri? canPicUri;
  final Uri? foodPicUri;
  final bool isInStock;
  final double servingsPerPackage;
  final String servingUnit;

  Food(this.brand, this.line, this.variety, this.mainIngredients, this.shape, this.type, this.packageOz, this.packageKcal, this.packageCost, this.kcalPerKg, this.kcalPerOz, this.costPerOz, this.costPer100Kcal, this.foodNotes, this.feedingNotes, this.fullIngredients, this.canPicUri, this.foodPicUri, this.isInStock, this.servingsPerPackage, this.servingUnit);
}