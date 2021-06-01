import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pPath;
import 'package:provider/provider.dart';
import '../models/picture.dart';
import '../providers/pictures.dart';

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
    final appDir = await pPath.getApplicationDocumentsDirectory();
    final fileName = path.basename(_imageFile!.path);
    final savedImage = await _imageFile!.copy('${appDir.path}/$fileName');
    var _imageToStore = Picture(picName: savedImage);
    _storeImage() {
      Provider.of<Pictures>(context, listen: false).storeImage(_imageToStore);
    }
    _storeImage();
  }

  void _clear(){
    setState(()=> _imageFile=null);
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
                )
              ]
          )
      ),
      body:ListView(
        children: <Widget>[
          if(_imageFile != null) ...[
            Image.file(_imageFile!),

            Row(
              children: <Widget>[
                FlatButton(
                  child: Icon(Icons.refresh),
                  onPressed: _clear,
                ),
              ],
            ),
            Uploader(key: UniqueKey(), file:_imageFile!)
          ]
        ],
      ),
    );
  }

}

class Uploader extends StatefulWidget{
  final File file;
  Uploader({required Key key, required this.file}): super(key:key);
  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader>{
  final FirebaseStorage _storage =
  FirebaseStorage(storageBucket:'gs://ecoapp-f4145.appspot.com');
  StorageUploadTask? _uploadTask = null;

  void _startUpload(){
    String filePath = 'images/${DateTime.now()}.png';
    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
    });
  }

  @override
  Widget build(BuildContext context){
    if(_uploadTask !=null){
      return StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask!.events,
          builder: (context,snapshot){
            var event = snapshot?.data?.snapshot;
            double progressPercent = event!=null
                ? event.bytesTransferred/event.totalByteCount
                :0;
            return Column(
                children:[
                  if(_uploadTask!.isComplete)
                    Text('Completed'),
                  if (_uploadTask!.isPaused)
                    FlatButton(
                      child:Icon(Icons.play_arrow),
                      onPressed: _uploadTask!.resume,
                    ),
                  LinearProgressIndicator(value:progressPercent),
                  Text(
                      '${(progressPercent*100).toStringAsFixed(2)} %'
                  ),
                ]
            );
          }
      );

    }else{
      return FlatButton.icon(
        label: Text('Confirm Your Photo Upload!'),
        icon: Icon(Icons.cloud_upload),
        onPressed: _startUpload,
      );
    }
  }
}