import 'package:flutter/material.dart';

import 'package:ocean_view/MapPage.dart';
import 'package:ocean_view/UploadPage.dart';
import 'package:ocean_view/ActivityPage.dart';
import 'package:ocean_view/MePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OceanView',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(title: 'OceanView Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MapPage(),
    UploadPage(),
    ActivityPage(),
    MePage(),
  ];

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'Me',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onNavBarTapped,
        selectedItemColor: Colors.amber[800],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
