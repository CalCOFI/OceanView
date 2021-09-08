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

class UploadSession extends StatefulWidget {

  @override
  _UploadSessionState createState() => _UploadSessionState();
}

class _UploadSessionState extends State<UploadSession> {

  List a = [
    "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_960_720.jpg",
    "https://cdn.pixabay.com/photo/2016/05/05/02/37/sunset-1373171_960_720.jpg",
    "https://cdn.pixabay.com/photo/2017/02/01/22/02/mountain-landscape-2031539_960_720.jpg",
    "https://cdn.pixabay.com/photo/2014/09/14/18/04/dandelion-445228_960_720.jpg",
    "https://cdn.pixabay.com/photo/2016/08/09/21/54/yellowstone-national-park-1581879_960_720.jpg",
    "https://cdn.pixabay.com/photo/2016/07/11/15/43/pretty-woman-1509956_960_720.jpg",
    "https://cdn.pixabay.com/photo/2016/02/13/12/26/aurora-1197753_960_720.jpg",
    "https://cdn.pixabay.com/photo/2016/11/08/05/26/woman-1807533_960_720.jpg",
    "https://cdn.pixabay.com/photo/2013/11/28/10/03/autumn-219972_960_720.jpg",
    "https://cdn.pixabay.com/photo/2017/12/17/19/08/away-3024773_960_720.jpg",
    "https://cdn.pixabay.com/photo/2017/12/17/19/08/away-3024773_960_720.jpg",
    "https://cdn.pixabay.com/photo/2017/12/17/19/08/away-3024773_960_720.jpg",
  ];

  File? _imageFile = null;

  Future<void> _pickImage(ImageSource source) async{
    File selected = await ImagePicker.pickImage(source:source);

    _imageFile = selected;

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
                itemCount: a.length+1,
                itemBuilder: (BuildContext ctx, index) {
                  return (index==a.length)
                    ? IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () async {
                          await _pickImage(ImageSource.camera);
                          print(_imageFile);
                          if (_imageFile!=null) {
                            Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) =>
                                  UploadObservation(file: _imageFile!)
                              )
                            );
                          }
                        }
                      )
                    : IconButton(
                        icon: Image.network(a[index]),
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
