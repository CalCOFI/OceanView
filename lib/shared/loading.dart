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
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: topBarColor,
            title: Text(
              'Working...',
            ),
            centerTitle: true,
          ),
          body: Container(
              //Center(
              child: Stack(
            children: [
              Center(
                child: Text(
                  'Searching...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
              SpinKitChasingDots(
                color: Colors.blue.shade900,
                size: 50.0,
              )
            ],
          )),
        ));
  }
}
