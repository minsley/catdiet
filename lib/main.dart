import 'dart:ui';

import 'package:catdiet/gaugeChart.dart';
import 'package:catdiet/profile_row.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis/vision/v1.dart';
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

void main() {
  runApp(const MyApp());
}

final _googleSignIn = GoogleSignIn(
  scopes: <String>[SheetsApi.spreadsheetsScope],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
// This is the theme of your application.
//
// Try running your application with "flutter run". You'll see the
// application has a blue toolbar. Then, without quitting the app, try
// changing the primarySwatch below to Colors.green and then invoke
// "hot reload" (press "r" in the console where you ran "flutter run",
// or simply save your changes to "hot reload" in a Flutter IDE).
// Notice that the counter didn't reset back to zero; the application
// is not restarted.
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

// This widget is the home page of your application. It is stateful, meaning
// that it has a State object (defined below) that contains fields that affect
// how it looks.

// This class is the configuration for the state. It holds the values (in this
// case the title) provided by the parent (in this case the App widget) and
// used by the build method of the State. Fields in a Widget subclass are
// always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  GoogleSignInAccount? _currentUser;
  String _sheetText = '';

  List<Food> _foods = [];
  CatProfile _kashi = CatProfile(Cat.Kashi, 0, 0, []);
  CatProfile _batman = CatProfile(Cat.Batman, 0, 0, []);

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetSheet();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Future<void> _handleGetSheet() async {
    setState(() {
      _sheetText = 'Loading contact info...';
    });

    // Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();

    assert(client != null, 'Authenticated client missing!');

    final SheetsApi sheetsApi = SheetsApi(client!);
    final Spreadsheet sheet = await sheetsApi.spreadsheets.get(
        '10491Rx3qiDDSK4kRvSXOR9VWNVumRQImyeYnq7Q89-s',
        includeGridData: true,
        ranges: [
          '\'Nutrition History\'!F30:G31', // [[B lo, K lo],[B hi, K hi]]
          '\'Nutrition History\'!A3:C40', // [[Date, B, K],[Date2, B, K],...]
          '\'Food List\'!A2:T100',
        ]
    );

    final String? sheetString = json.encode(sheet);

    var data = CatData.parse(sheet);
    _kashi = data.cats[0];
    _batman = data.cats[1];
    _foods = data.foods;

    setState(() {
      if (sheetString != null) {
        _sheetText = sheetString;
      } else {
        _sheetText = 'No sheet to display.';
      }
    });
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;

    // return Center(child: Expanded(child: Text(_sheetText)));

    if (user != null) {
      return Center(
        child: Stack(children: [
          Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(top: 10, right: 10),
              child: PopupMenuButton(
                  itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry>[
                    PopupMenuItem(
                        child: ListTile(
                            leading: GoogleUserCircleAvatar(
                              identity: user,
                            ),
                            title: Text(user.displayName ?? ''),
                            subtitle: Text(user.email)
                        )
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      child: const Text('Refresh'),
                      onTap: _handleGetSheet,
                    ),
                    PopupMenuItem(
                      child: const Text('Sign out', textAlign: TextAlign.center),
                      onTap: _handleSignOut,
                    )
                  ])),
          Container(
            margin: const EdgeInsets.all(50),
            child: Column(children: [
              ProfileRow(_kashi),
              Container(height: 30),
              ProfileRow(_batman)
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
              // child: ,
            )
          )
        ]),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('You are not currently signed in.'),
          ElevatedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
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
