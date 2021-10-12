import 'package:flutter/material.dart';
import 'package:ocean_view/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        child: Text('This is an activity.'),
        /*
        child: ElevatedButton(
          child: Text('Upload'),
          onPressed: () {
            WriteBatch writeBatch = FirebaseFirestore.instance.batch();
            final CollectionReference observationCollection = FirebaseFirestore.instance.collection('observations');
            DocumentReference documentReference;

            for (int i = 0; i<2; i++) {
              documentReference = observationCollection.doc();
              print(documentReference.id);
              writeBatch.set(documentReference, {
                'Name': 'Bill',
                'Age': i
              });
            }

            writeBatch.commit();
          },
        )
         */
      ),
    );
  }
}
