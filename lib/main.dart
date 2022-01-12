import 'package:catdiet/add_meal_screen.dart';
import 'package:catdiet/cat_api.dart';
import 'package:catdiet/profile_row.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'CatData.dart';
import 'dart:ui' as ui;

final routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const ui.Color(0xFFF6F6F6)// const HSVColor.fromAHSV(1, 0, 0, 0.95).toColor(),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      navigatorObservers: [routeObserver]
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RouteAware {
  AuthClient? _client;
  CatData? _data;
  Spreadsheet? _sheet;
  final CatApi _api = CatApi();

  @override
  void initState() {
    super.initState();
    _handleSignIn()
        .then((value) => _handleGetSheet());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // view will appear
    if(_client  != null)  _handleGetSheet();
  }

  Future<void> _handleSignIn() async {
    try {
      _client = await _api.obtainAuthenticatedClient();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleGetSheet() async {

    var sheet = await _api.getSheet();
    var data = CatData.parse(sheet);

    setState(() {
      _sheet = sheet;
      _data = data;
    });
  }

  Widget _buildBody() {
    if (_data != null && _sheet != null) {
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
              onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddMealScreen(sheet: _sheet!, data: _data!))
                  );
              },
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
