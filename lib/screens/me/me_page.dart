import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/services/database.dart';
import 'package:ocean_view/shared/constants.dart';
import 'package:ocean_view/shared/custom_widgets.dart';
import 'package:provider/provider.dart';

import 'observation_list.dart';

/*
  A wrapper widget fetching user's observations from Firebase
  and show the ObservationList
 */
class MePage extends StatelessWidget {
  const MePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return StreamProvider<List<Observation>?>.value(
      value: DatabaseService(uid: user!.uid).meObs,
      initialData: null,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Me Page: ${user.displayName}'),
          centerTitle: true,
          backgroundColor: themeMap['scaffold_appBar_color'],
          elevation: 0.0,
        ),
        //Run ObservationList() from observation_list.dart
        body: Container(
          decoration: blueBoxDecoration,
          child: Stack(children: [
            CustomPainterWidgets.buildTopShape(),
            ObservationList()
          ]),
        ),
      ),
    );
  }
}
