import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:ocean_view/screens/upload/upload_observation.dart';
import 'package:ocean_view/screens/upload/upload_session.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pPath;
import 'package:provider/provider.dart';

import 'package:image_picker/image_picker.dart';

import '../../../models/picture.dart';
import '../../../providers/pictures.dart';
import '../observation_page.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({required Key key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>{
  File? _imageFile = null;

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
  Widget build(BuildContext context){
    return Scaffold(
      body:
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Single Observation'),
              IconButton(
                  icon: Icon(Icons.photo_camera),
                  onPressed:() async {
                    await _pickImage(ImageSource.camera);
                    if (_imageFile != null) {
                      Navigator.push(
                          context, MaterialPageRoute(
                          builder: (context) =>
                              ObservationPage(file: _imageFile!, mode:'single')
                      )
                      );
                    }
                  }
              ),
              IconButton(
                  icon:Icon(Icons.photo_library),
                  onPressed: () async {
                    await _pickImage(ImageSource.gallery);
                    if (_imageFile != null) {
                      Navigator.push(
                          context, MaterialPageRoute(
                          builder: (context) =>
                              ObservationPage(file: _imageFile!, mode:'single')
                      )
                      );
                    }
                  }
              ),
              Text('Record Session'),
              IconButton(
                icon: Icon(Icons.not_started_outlined),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) => UploadSession()
                )
                ),
              ),
            ],
          )
    );
  }
}