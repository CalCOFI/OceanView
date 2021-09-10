import 'dart:io';

import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/screens/upload/upload_observation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pPath;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocean_view/screens/upload/stopwatch.dart';
import 'package:provider/provider.dart';
import '../../../models/picture.dart';
import '../../../providers/pictures.dart';
import '../observation_page.dart';

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

  Future<void> _pickImage(ImageSource source) async{
    _imageFile = await ImagePicker.pickImage(source:source);

    if (_imageFile==null){
      return ;
    }

    final appDir = await pPath.getApplicationDocumentsDirectory();
    final fileName = path.basename(_imageFile!.path);
    final savedImage = await _imageFile!.copy('${appDir.path}/$fileName');
    var _imageToStore = Picture(picName: savedImage);
    _storeImage() {
      Provider.of<Pictures>(context, listen: false).storeImage(_imageToStore);
    }
    _storeImage();
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
            StopWatch(),
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
                          print(_imageFile);
                          if (_imageFile!=null) {
                            // Get observation from ObservationPage
                            result = await Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) =>
                                  ObservationPage(file: _imageFile!, mode:'session')
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
