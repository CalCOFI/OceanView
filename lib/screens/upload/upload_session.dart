import 'package:flutter/material.dart';
import 'package:ocean_view/screens/upload/stopwatch.dart';

class UploadSession extends StatefulWidget {

  @override
  _UploadSessionState createState() => _UploadSessionState();
}

class _UploadSessionState extends State<UploadSession> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recording Session'),
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: <Widget>[
          StopWatch(),
        ],
      )
    );
  }
}
