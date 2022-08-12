import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ocean_view/shared/constants.dart';

/*
  Page for dynamic loading icon that would be used when signing in and
  waiting for results from VisionAPI
 */

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        //color: Colors.brown[100],
        decoration: blueBoxDecoration,
        child: Center(
            child: SpinKitChasingDots(
          color: Colors.blue.shade900,
          size: 50.0,
        )));
  }
}
