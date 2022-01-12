import 'dart:io';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart' as intl;

import 'CatData.dart';

class CatApi {

  final String _credStorageKey = "CatDietServiceCredentials";
  final String _sheetId = '10491Rx3qiDDSK4kRvSXOR9VWNVumRQImyeYnq7Q89-s';
  final intl.DateFormat _dateFormatter = intl.DateFormat.yMMMd('en_US');
  final intl.DateFormat _timeFormatter = intl.DateFormat.jms('en_US');

  Future<ServiceAccountCredentials> getCredentials() async {
    const storage = FlutterSecureStorage();

    String? credString = await storage.read(key: _credStorageKey);

    if(credString == null) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.length == 1) {
        File file = File(result.files.single.path!);
        credString = await file.readAsString();
        await storage.write(key: _credStorageKey, value: credString);
      } else {
        print("Uh oh. You need a credential file!");
      }
    }

    final accountCredentials = ServiceAccountCredentials.fromJson(credString);
    return accountCredentials;
  }

  Future<AuthClient> obtainAuthenticatedClient() async {
    var accountCredentials = await getCredentials();
    var scopes = ['https://www.googleapis.com/auth/spreadsheets'];

    AuthClient client = await clientViaServiceAccount(accountCredentials, scopes);

    return client; // Remember to close the client when you are finished with it.
  }

  Future<Spreadsheet> getSheet() async {
    var client = await obtainAuthenticatedClient();
    assert(client != null, 'Authenticated client missing!');

    final SheetsApi sheetsApi = SheetsApi(client);
    final Spreadsheet sheet = await sheetsApi.spreadsheets.get(
        _sheetId,
        includeGridData: true,
        ranges: [
          '\'Nutrition History\'!F30:G31', // [[B lo, K lo],[B hi, K hi]]
          '\'Nutrition History\'!A3:C40', // [[Date, B, K],[Date2, B, K],...]
          '\'Food List\'!A2:W100',
        ]
    );

    client.close();
    return sheet;
  }

  Future<void> logMeal(List<MealRecord> items) async {
    var client = await obtainAuthenticatedClient();
    assert(client != null, 'Authenticated client missing!');

    final SheetsApi sheetsApi = SheetsApi(client);
    var tempSheetId = '1528437937';
    var now = DateTime.now();

    try {
      var response = await sheetsApi.spreadsheets.values.append(
          ValueRange(values: items.map((x) => [
            // this is a row
            _dateFormatter.format(now),
            _timeFormatter.format(now),
            x.cat.toString().substring(4),
            x.foodVarietyName,
            x.oz
          ]).toList()),
          _sheetId,
          '\'Food Log\'!A1',
          insertDataOption: 'OVERWRITE',
          valueInputOption: 'USER_ENTERED');
    } catch(error) {
      print(error);
    }

    client.close();
    return;
  }
}

class MealRecord {
  final Cat cat;
  final String foodVarietyName;
  final double oz;
  final double kcal;

  MealRecord(this.cat, this.foodVarietyName, this.oz, this.kcal);
}