import 'dart:io';

import 'package:ocean_view/models/observation.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocean_view/screens/observation_stream.dart';
import 'package:ocean_view/screens/upload/timeline_stream.dart';
import 'package:ocean_view/screens/upload/upload_stopwatch.dart';
import 'package:ocean_view/shared/constants.dart';
import 'package:ocean_view/shared/custom_widgets.dart';
import 'package:ocean_view/src/extract_exif.dart';

/*
  Root page for record session

  It shows the stopwatch on the top that user can start the record session or stop it.
  Start button triggers UploadStopwatch while stop button ends the session and goes to UploadTimeline
  Below are observations shown with images that organized in GradView.

  New observation can be added by pressing the plus button and goes to the path of
  single observation by camera.
 */
class UploadSession extends StatefulWidget {
  @override
  _UploadSessionState createState() => _UploadSessionState();
}

class _UploadSessionState extends State<UploadSession> {
  File? _imageFile = null;
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
            builder: (context) => TimelineStream(
                observationList: observationList,
                imageList: imageList,
                mode: 'session')));
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    XFile? tempFile = await _picker.pickImage(source: source);

    if (tempFile != null) {
      _imageFile = File(tempFile.path);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Recording Session'),
          elevation: 0.0,
          //backgroundColor: topBarColor,
          centerTitle: true,
          backgroundColor: themeMap['scaffold_appBar_color'],
        ),
        body: Container(
          decoration: blueBoxDecoration,
          child: Stack(
            children: [
              CustomPainterWidgets.buildTopShape(),
              Column(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(height: 80),
                  Text(
                    'Click record button (on the left) below to start adding observations to your session.  Recording will continue until you click the cancel button on the right.',
                    textAlign: TextAlign.center,
                  ),
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
                                      tooltip: 'Add an observation',
                                      iconSize: 48,
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
                                                  builder: (context) =>
                                                      ObservationStream(
                                                          file: _imageFile!,
                                                          mode: 'session',
                                                          photoMeta: photoMeta,
                                                          index: observationList
                                                              .length)));
                                          setState(() {
                                            observationList.add(result[0]);
                                            imageList.add(result[1]);
                                          });

                                          // Add observation to local directory

                                        }
                                      })
                                  : IconButton(
                                      tooltip:
                                          'Start recording to add an observation',
                                      iconSize: 48,
                                      icon: imageList[index],
                                      onPressed: () => print('Touch ${index}'),
                                    )
                              : IconButton(
                                  tooltip:
                                      'Start recording to add an observation',
                                  iconSize: 48,
                                  icon: Icon(Icons.cancel),
                                  onPressed: () {
                                    print('Press start');
                                  },
                                );
                        }),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
