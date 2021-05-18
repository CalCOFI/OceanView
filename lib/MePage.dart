import 'package:flutter/material.dart';

class MePage extends StatefulWidget {
  const MePage({Key key}) : super(key: key);

  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Me Page'),
      ),
      body: Center(
        child: Text('This is Me Page.'),
      ),
    );
  }
}
