import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/screens/me/me_observation.dart';
import 'package:ocean_view/services/database.dart';
import 'package:provider/provider.dart';

import 'observation_list.dart';


class MePage extends StatelessWidget {
  const MePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User?>(context);

    return StreamProvider<List<Observation>?>.value (
      value: DatabaseService(uid: user!.uid).observations,
      initialData: null,
      child: Scaffold(
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          title: Text('Me: ${user!.uid}'),
          backgroundColor: Colors.brown[400],
          elevation: 0.0,
          
        ),
        body: ObservationList(),
      ),
    );
  }
}

