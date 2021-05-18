import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Page'),
      ),
      body: Center(
        child: Text('This is Activity Page.'),
      ),
    );
  }
}
