import 'package:flutter/material.dart';

import 'package:ocean_view/screens/map/map_page.dart';
import 'package:ocean_view/screens/upload/upload_page.dart';
import 'package:ocean_view/screens/activity_page.dart';
import 'package:ocean_view/screens/me/me_page.dart';
import 'package:ocean_view/screens/me/user_page.dart';
import 'package:ocean_view/services/auth.dart';
import 'package:ocean_view/shared/constants.dart';

import '../authenticate/verify.dart';

/*
  Root widget for managing navigating through different pages
 */
class Home extends StatefulWidget {
  Home({required Key key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 2;
  late bool isEmailVerified;

  List<Widget> _widgetOptions = <Widget>[
    MapPage(key: UniqueKey()),
    UploadPage(key: UniqueKey()),
    ActivityPage(key: UniqueKey()),
    UserPage(key: UniqueKey()),
    MePage(key: UniqueKey()),
  ];

  @override
  void initState() {
    super.initState();
    isEmailVerified = AuthService().currentUser!.emailVerified;
  }

  void verifyEmail() {
    setState(() {
      isEmailVerified = true;
    });
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (!isEmailVerified)
        ? VerifyScreen(verifyEmail: verifyEmail)
        : Scaffold(
          body: _widgetOptions[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: bottomBarColor, //Colors.teal.shade100,
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
                icon: Icon(Icons.account_circle),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.verified_user),
                label: 'Me',
              ),
            ],
            currentIndex: _currentIndex,
            onTap: _onNavBarTapped,
            selectedItemColor: Colors.blue.shade900,
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
