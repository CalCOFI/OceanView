import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocean_view/models/userstats.dart';
import 'package:ocean_view/services/database.dart';
import 'package:provider/provider.dart';

import 'package:ocean_view/screens/profile_page.dart';

/*
  A wrapper widget fetching user's observations from Firebase
  and show the ObservationList
 */
class UserPage extends StatelessWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return StreamProvider<UserStats>.value(
      value: DatabaseService(uid: user!.uid).meStats,
      initialData: UserStats(),
      child: Scaffold(
        backgroundColor: Colors.brown[50],
        //Run ProfilePage() from profile.dart
        body: ProfilePage(),
      ),
    );
  }
}
