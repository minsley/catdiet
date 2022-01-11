import 'dart:io';
import 'dart:ui';

import 'package:catdiet/gaugeChart.dart';
import 'package:catdiet/profile_row.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis/vision/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

// final _googleSignIn = GoogleSignIn(
//   scopes: <String>[SheetsApi.spreadsheetsScope],
// );

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _credStorageKey = "CatDietServiceCredentials";
  AuthClient? _client;
  CatData? _data;

  @override
  void initState() {
    super.initState();
    _handleSignIn()
        .then((value) => _handleGetSheet());
  }

  Future<void> _handleSignIn() async {
    try {
      _client = await obtainAuthenticatedClient();
    } catch (error) {
      print(error);
    }
  }

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
        // User canceled the picker
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


  Future<void> _handleGetSheet() async {
    assert(_client != null, 'Authenticated client missing!');

    final SheetsApi sheetsApi = SheetsApi(_client!);
    final Spreadsheet sheet = await sheetsApi.spreadsheets.get(
        '10491Rx3qiDDSK4kRvSXOR9VWNVumRQImyeYnq7Q89-s',
        includeGridData: true,
        ranges: [
          '\'Nutrition History\'!F30:G31', // [[B lo, K lo],[B hi, K hi]]
          '\'Nutrition History\'!A3:C40', // [[Date, B, K],[Date2, B, K],...]
          '\'Food List\'!A2:U100',
        ]
    );

    final String? sheetString = json.encode(sheet);

    var data = CatData.parse(sheet);

    setState(() {
      if (sheetString != null) {
        _data = data;
      } else {
        // _sheetText = 'No sheet to display.';
      }
    });
  }

  Widget _buildBody() {
    if (_data != null) {
      return Center(
        child: Stack(children: [
          Container(
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(top: 10, right: 10),
            child: IconButton(icon: const Icon(Icons.refresh), onPressed: _handleGetSheet,)
          ),
          Container(
            margin: const EdgeInsets.all(50),
            child: Column(children: [
              ProfileRow(_data!.cats[0]),
              Container(height: 30),
              ProfileRow(_data!.cats[1])
            ]),
          ),
          Container(
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.only(bottom: 20, right: 20),
            child: FloatingActionButton.extended(
              label: Row(children: [
                const Icon(Icons.add_circle_rounded, size: 40),
                Container(width: 10),
                const Text("Add Meal", style: TextStyle(fontSize: 20)),
              ]),
              onPressed: null,
            )
          )
        ]),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}

class Datum {
  final DateTime date;
  final int value;

  Datum(this.date, this.value);
}
