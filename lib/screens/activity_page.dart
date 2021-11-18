import 'package:flutter/material.dart';
import 'package:ocean_view/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocean_view/src/mpa_regulation.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({required Key key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('OceanView'),
          centerTitle: true,
          backgroundColor: Colors.lightBlueAccent,
          elevation: 0.0,
          actions: <Widget>[
            TextButton.icon(
                onPressed: () async {
                  await _auth.signOut();
                },
                icon: Icon(Icons.person),
                label: Text('Log out')
            )
          ]
      ),
      body: Center(
        // child: Text('This is an activity.'),

        child: ElevatedButton(
          child: Text('Test'),
          onPressed: () async {
            Map<String, dynamic> regulations = await getMPARegulations();
            print(regulations['111']??'None');
          }
        )

      ),
    );
  }
}
