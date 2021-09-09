import 'dart:io';

import 'package:flutter/material.dart';
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
    File selected = await ImagePicker.pickImage(source:source);

    setState((){
      _imageFile = selected;
    });

    if (selected==null){
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
      bottomNavigationBar: BottomAppBar(
          child:Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.photo_camera),
                  onPressed:() => _pickImage(ImageSource.camera),
                ),
                IconButton(
                  icon:Icon(Icons.photo_library),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                IconButton(
                  icon: Icon(Icons.not_started_outlined),
                  onPressed: () => Navigator.push(
                    context, MaterialPageRoute(
                      builder: (context) => UploadSession()
                    )
                  ),
                ),
              ]
          )
      ),
      body:
        (_imageFile==null)
          ? SizedBox(width: 10,)
          //: UploadObservation(file:_imageFile!)
          : ObservationPage(file:_imageFile!, mode: 'Single')
    );
  }
}