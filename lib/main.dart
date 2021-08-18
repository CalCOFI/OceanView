import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:ocean_view/MapPage.dart';
import 'package:ocean_view/UploadPage.dart';
import 'package:ocean_view/ActivityPage.dart';
import 'package:ocean_view/MePage.dart';

import './providers/pictures.dart';
import 'notification_library.dart' as notification;

Future<void> main() async{
  notification.initializeNotification();

  // Initialize firebase
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MultiProvider(
      providers: [
        ChangeNotifierProvider<Pictures>(create: (_) => Pictures()),
      ],
      child: Container(
        child:MaterialApp(
          title: 'OceanView',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
          ),
          home: MyHomePage(title: 'OceanView Home Page', key: UniqueKey()),
        )
      )
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required Key key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 2;

  List<Widget> _widgetOptions = <Widget>[
    MapPage(key:UniqueKey()),
    UploadPage(key:UniqueKey()),
    ActivityPage(key:UniqueKey()),
    MePage(key:UniqueKey()),
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
