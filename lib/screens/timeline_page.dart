import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/screens/me/me_observation.dart';
import 'package:ocean_view/screens/observation_stream.dart';
import 'package:ocean_view/services/database.dart';
import 'package:ocean_view/services/local_store.dart';
import 'package:ocean_view/shared/constants.dart';
import 'package:ocean_view/models/userstats.dart';
import 'package:provider/provider.dart';

/*
  A page to show all the observations and their recording time in current recording session

  Upload button batched writes all the observations to Firebase.
 */

class TimelinePage extends StatefulWidget {
  final List<Observation> observationList;
  final List<Image> imageList;
  final String mode; // 'session' or 'me'

  TimelinePage(
      {required this.observationList,
      required this.imageList,
      required this.mode});

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  List<dynamic> result = []; // observation and image

  String _getStringOfDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userSt = Provider.of<UserStats>(context);
    // Screen size
    Size size = MediaQuery.of(context).size;

    widget.observationList.forEach((element) {
      print(element.stopwatchStart);
      print(element.time);
      print(element.length);
    });

    Future<bool> onWillPop() async {
      final shouldPop = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you want to leave without saving?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Timeline'),
          centerTitle: true,
          backgroundColor: themeMap['scaffold_appBar_color'],
          actions: (widget.mode == 'session')
              ? <Widget>[
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    icon: Icon(Icons.upload_sharp),
                    label: Text('Upload'),
                    onPressed: () async {
                      print('Upload');

                      // Batched write all the observations to Firebase
                      List<TaskState> states =
                          await DatabaseService(uid: user!.uid)
                              .batchedWriteObservations(widget.observationList);

                      String snackBarText = 'Upload:';
                      for (int i = 0; i < states.length; i++) {
                        snackBarText += ' $i,';
                      }
                      userSt.numobs = userSt.numobs! + states.length;
                      await DatabaseService(uid: user.uid)
                          .updateUserStats(userSt);
                      final snackBar = SnackBar(content: Text(snackBarText));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      // Delete images in local directory

                      // pop to the main page
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ]
              : null,
        ),
        body: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.observationList.length,
            itemBuilder: (context, i) {
              return Stack(children: [
                Positioned(
                  // Line
                  left: 49,
                  child: new Container(
                    height: size.height * 0.4,
                    width: 1.0,
                    color: Colors.grey.shade400,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(40),
                  child: Row(children: [
                    Container(
                      // Dot
                      height: 20,
                      width: 20,
                      decoration: new BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    SizedBox(
                      child: Text(_getStringOfDuration(
                          (widget.observationList[i].time.difference(
                              widget.observationList[i].stopwatchStart)))),
                      width: size.width * 0.15,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          // Load image file in local storage
                          File imageFile =
                              await LocalStoreService().loadImage('$i.png');
                          print('$imageFile');

                          print('Mode: ${widget.mode}');
                          // Modify the observation
                          result = (widget.mode == 'session')
                              ? await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ObservationStream(
                                          file: imageFile,
                                          mode: widget.mode,
                                          observation:
                                              widget.observationList[i],
                                          index: i)))
                              : await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MeObservation(
                                          observation:
                                              widget.observationList[i])));

                          print('result: $result');
                          // Remove observation if it is deleted
                          setState(() {
                            if (result != null &&
                                result[0] is String &&
                                result[0] == 'Delete') {
                              widget.observationList.removeAt(i);
                            }
                          });
                        },
                        child: widget.imageList[i],
                      ),
                    ),
                  ]),
                ),
              ]);
            } // End of ItemBuilder
            ),
      ),
    );
  }
}
