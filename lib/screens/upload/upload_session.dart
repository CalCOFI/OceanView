import 'dart:io';

import 'package:ocean_view/models/observation.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocean_view/screens/upload/upload_stopwatch.dart';
import 'package:ocean_view/screens/observation_page.dart';
import 'package:ocean_view/screens/upload/upload_timeline.dart';
import 'package:ocean_view/singletons/appdata.dart';

class UploadSession extends StatefulWidget {

  @override
  _UploadSessionState createState() => _UploadSessionState();
}

class _UploadSessionState extends State<UploadSession> {

  File? _imageFile = null;
  DateTime _startTime = DateTime.now();
  List<dynamic> result = [];
  List<Observation> observationList = [];
  List<Image> imageList = [];

  // Use stopCallback in stopwatch to navigate to timeline
  stopCallback (Duration elapsedTime) {
    print(elapsedTime.toString());

    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) =>
                UploadTimeline()
        )
    );
  }

  Future<void> _pickImage(ImageSource source) async{
    _imageFile = await ImagePicker.pickImage(source:source);

    if (_imageFile==null){
      return ;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recording Session'),
        backgroundColor: Colors.brown,
      ),
      body: 
        Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            UploadStopwatch(stopCallback: stopCallback),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20),
                itemCount: imageList.length+1,
                itemBuilder: (BuildContext ctx, index) {
                  return (index==imageList.length)
                    ? IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () async {

                          await _pickImage(ImageSource.camera);
                          if (_imageFile!=null) {
                            // Get observation from ObservationPage
                            result = await Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) =>
                                  ObservationPage(file: _imageFile!, mode:'session',
                                      index: observationList.length,
                                      stopwatchRecord: appData.getElapsedSeconds())
                              )
                            );
                            setState(() {
                              observationList.add(result[0]);
                              imageList.add(result[1]);
                            });

                            // Add observation to local directory

                          }
                        }
                      )
                    : IconButton(
                        icon: imageList[index],
                        onPressed: () => print('Touch ${index}'),
                      );
                }
              ),
            ),
          ],
        ),
      
    );
  }
}
