import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/models/userstats.dart';
import 'package:ocean_view/screens/timeline_page.dart';
import 'package:ocean_view/services/database.dart';
import 'package:provider/provider.dart';

/*
  A wrapper widget fetching user's observations from Firebase
  and show the ObservationList
 */
class TimelineStream extends StatelessWidget {
  final List<Observation> observationList;
  final List<Image> imageList;
  final String mode; // 'session' or 'me'

  TimelineStream(
      {required this.observationList,
      required this.imageList,
      required this.mode});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return StreamProvider<UserStats>.value(
      value: DatabaseService(uid: user!.uid).meStats,
      initialData: UserStats(),
      child: Scaffold(
        backgroundColor: Colors.brown[50],
        //Run ObservationPage() from observation_page.dart
        body: TimelinePage(
          observationList: observationList,
          imageList: imageList,
          mode: mode,
        ),
      ),
    );
  }
}
