import 'package:flutter/material.dart';
import 'package:ocean_view/services/auth.dart';

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
        child: Text('This is Activity Page.'),
      ),
    );
  }
}
