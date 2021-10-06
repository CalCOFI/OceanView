import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/services/local_store.dart';
import 'package:ocean_view/screens/observation_page.dart';

class UploadTimeline extends StatefulWidget {

  final List<Observation> observationList;
  final List<Image> imageList;

  UploadTimeline({required this.observationList, required this.imageList});

  @override
  _UploadTimelineState createState() => _UploadTimelineState();
}

class _UploadTimelineState extends State<UploadTimeline> {

  List<dynamic> result = [];  // observation and image

  String _getStringOfDuration(Duration duration) {
    String twoDigits (int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {

    // Screen size
    Size size = MediaQuery.of(context).size;

    Random random = new Random();
    widget.observationList.forEach((element)
    {
      print(element.stopwatchStart);
      print(element.time);
      print(element.length);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline'),
        centerTitle: true,
        actions: <Widget>[
          TextButton.icon(
            style: TextButton.styleFrom(
              primary: Colors.white
            ),
            icon: Icon(Icons.upload_sharp),
            label: Text('Upload'),
            onPressed: () {
              print('Upload');

              // pop to the main page
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body:
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.observationList.length,
          itemBuilder: (context, i){
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(40),
                  child: Row(
                    children: [
                      SizedBox(width: size.width * 0.1),
                      SizedBox(
                        child: Text(_getStringOfDuration(
                            (widget.observationList[i].time.difference(widget.observationList[i].stopwatchStart))
                        )),
                        width: size.width * 0.2,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            // Load image file in local storage
                            File imageFile = await LocalStoreService().loadImage('$i.png');
                            print('$imageFile');

                            // Modify the observation
                            result = await Navigator.push(
                                context, MaterialPageRoute(
                                builder: (context) =>
                                    ObservationPage(file: imageFile, mode:'session',
                                        observation: widget.observationList[i], index: i)
                              )
                            );
                          },
                          child: widget.imageList[i],
                        ),
                      ),
                    ],
                  )
                ),
                Positioned(   // Line
                  left: 50,
                  child: new Container(
                    height: size.height * 0.4,
                    width: 1.0,
                    color: Colors.grey.shade400,
                  ),
                ),
                Positioned(   // Dots
                  bottom: 40,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Container(
                      height: 20.0,
                      width: 20.0,
                      decoration: new BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        )
    /*
      ElevatedButton(
        onPressed: () {
          // Pop to the main page
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: Text('back'),
      )
       */
    );
    }
  }
