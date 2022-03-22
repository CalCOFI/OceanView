import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocean_view/models/observation.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocean_view/screens/upload/upload_stopwatch.dart';
import 'package:ocean_view/screens/observation_page.dart';
import 'package:ocean_view/screens/upload/upload_timeline.dart';
import 'package:ocean_view/src/extract_exif.dart';

class UploadSession extends StatefulWidget {
  @override
  _UploadSessionState createState() => _UploadSessionState();
}

class _UploadSessionState extends State<UploadSession> {
  XFile? _imageFile = null;
  DateTime _startTime = DateTime.now();
  List<dynamic> result = []; // observation and image
  List<Observation> observationList = [];
  List<Image> imageList = [];
  bool isRecording = false;

  // Use startCallback in stopwatch to begin
  startCallback() {
    setState(() {
      isRecording = true;
    });
  }

  // Use stopCallback in stopwatch to navigate to timeline
  stopCallback(DateTime startTime, Duration elapsedTime) {
    print('Elapsed: ' + elapsedTime.toString());

    observationList.forEach((observation) {
      observation.stopwatchStart = _startTime;
    });

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UploadTimeline(
                observationList: observationList, imageList: imageList)));
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    _imageFile = await _picker.pickImage(source: source);

    if (_imageFile == null) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recording Session'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          UploadStopwatch(
              startCallback: startCallback, stopCallback: stopCallback),
          Expanded(
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20),
                itemCount: imageList.length + 1,
                itemBuilder: (BuildContext ctx, index) {
                  return (isRecording)
                      ? (index == imageList.length)
                          ? IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () async {
                                await _pickImage(ImageSource.camera);

                                // Extract exif data from image file
                                PhotoMeta photoMeta =
                                    await extractLocationAndTime(
                                        _imageFile! as File);

                                if (_imageFile != null) {
                                  // Get observation from ObservationPage
                                  result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ObservationPage(
                                              file: _imageFile!,
                                              mode: 'session',
                                              photoMeta: photoMeta,
                                              index: observationList.length)));
                                  setState(() {
                                    observationList.add(result[0]);
                                    imageList.add(result[1]);
                                  });

                                  // Add observation to local directory

                                }
                              })
                          : IconButton(
                              icon: imageList[index],
                              onPressed: () => print('Touch ${index}'),
                            )
                      : IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            print('Press start');
                          },
                        );
                }),
          ),
        ],
      ),
    );
  }
}
