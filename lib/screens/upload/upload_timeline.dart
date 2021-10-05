import 'package:flutter/material.dart';

class UploadTimeline extends StatefulWidget {


  @override
  _UploadTimelineState createState() => _UploadTimelineState();
}

class _UploadTimelineState extends State<UploadTimeline> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('timeline')),
      body: ElevatedButton(
        onPressed: () {
          // Pop to the main page
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: Text('back'),
      )
    );
  }
}
