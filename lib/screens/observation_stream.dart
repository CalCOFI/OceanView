import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/models/userstats.dart';
import 'package:ocean_view/screens/observation_page.dart';
import 'package:ocean_view/services/database.dart';
import 'package:provider/provider.dart';
import 'package:ocean_view/src/extract_exif.dart';

/*
  A wrapper widget fetching user's observations from Firebase
  and show the ObservationList
 */
class ObservationStream extends StatelessWidget {
  final File file;
  final String mode;

  Observation? observation;
  PhotoMeta? photoMeta;
  int? index; // Index for observation in session
  ObservationStream(
      {required this.file,
      required this.mode,
      this.observation,
      this.photoMeta,
      this.index});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    index = this.mode == 'single' ? 0 : this.index;
    return StreamProvider<UserStats>.value(
      value: DatabaseService(uid: user!.uid).meStats,
      initialData: UserStats(),
      child: Scaffold(
        backgroundColor: Colors.brown[50],
        //Run ObservationPage() from observation_page.dart
        body: ObservationPage(
          file: file,
          mode: this.mode,
          observation: observation,
          photoMeta: photoMeta,
          index: index,
        ),
      ),
    );
  }
}
