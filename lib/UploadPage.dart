import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pPath;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:async/async.dart' hide Result;
import 'package:image_picker/image_picker.dart';

import 'package:ocean_view/src/prediction.dart';
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
      body:
        (_imageFile==null)
          ? SizedBox(width: 10,)
          : Uploader(key: UniqueKey(), file:_imageFile!)

      /*
      ListView(
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
       */
    );
  }
}

// Define a custom Form widget.
class Uploader extends StatefulWidget {
  final File file;
  Uploader({required Key key, required this.file}): super(key:key);

  @override
  _UploaderState createState() => _UploaderState(file);
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _UploaderState extends State<Uploader> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();
  Map<String,String> textDict = <String,String>{};
  String statusValue = 'Observe';
  String _imageListText = "What did you see?";
  late Image _image;

  // Firebase
  String userID = "abcdef";
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  UploadTask? _uploadTask;


  _UploaderState (File file) {
    this._image = new Image.file(
      file,
      width: 200,
      height: 100,
      fit: BoxFit.contain,
    );
  }
  /*
  final Image _image = Image.File(
    widget.file,
    width: 200,
    height: 100,
    fit: BoxFit.contain,
  );
   */

  DateTime selectedDate = DateTime.now();

  // Select date
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        this.textDict['time'] = selectedDate.toString();
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Retrieve Text Input'),
      ),
      body: SingleChildScrollView(
          child: Container(
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: _image
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.question_answer),
                            title: Text(_imageListText),
                            subtitle: Text('><'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                  child: const Text('See suggestions'),
                                  onPressed: () {
                                    _navigateAndDisplaySelection(context);
                                  }
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Row(
                        children: <Widget>[
                          const Text('Length: '),
                          Expanded(
                            child: TextField(
                              onSubmitted: (String value){textDict['length']=value;},
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text("inches"),
                        ]
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Row(
                        children: <Widget>[
                          const Text('Weight: '),
                          Expanded(
                            child: TextField(
                              onSubmitted: (String value){textDict['weight']=value;},
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text("lb"),
                        ]
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Row(
                        children: <Widget>[
                          const Text("Time: "),
                          const SizedBox(width: 10.0,),
                          Text("${selectedDate.toLocal()}".split(' ')[0]),
                          const SizedBox(width: 10.0),
                          ElevatedButton(
                            onPressed: () => _selectDate(context),
                            child: Icon(Icons.date_range),
                          ),
                        ]
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: Row(
                        children: [
                          const Text("Status: "),
                          DropdownButton<String>(
                            value: statusValue,
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.black26,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                statusValue = newValue!;
                                textDict['status'] = statusValue;
                              });
                            },
                            items: <String>['Observe', 'Release', 'Catch']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),)
                        ],
                      )
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      child: Text("Upload"),
                      onPressed: _pressUpload
                  ),
                ],
              )
          )
      ),
    );
  }

  // A method that launches the ImageClassification screen and awaits the result from
  // Navigator.pop.
  void _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          ImageClassification(key: UniqueKey(), imageFile: widget.file)),
    );

    // After the ImageClassification Screen returns a result, change text of TextButton
    setState((){
      _imageListText = result;
      textDict['name'] = result;
      print(_imageListText);
    });
  }


  _pressUpload() async {

    String filePath = 'images/${this.userID}/${DateTime.now()}.png';

    TaskSnapshot snapshot = await _storage.ref().child(filePath).putFile(widget.file);
    if(snapshot.state == TaskState.success) {
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      await _database.collection("observations").add({
        "user": this.userID,
        "name": this.textDict['name'] ?? "None",
        "length": this.textDict['length'] ?? "None",
        "weight": this.textDict['weight'] ?? "None",
        "time": this.textDict['time'] ?? "None",
        "status": this.textDict['status'] ?? "None",
        "url": downloadUrl
      });

      final snackBar = SnackBar(content: Text('Success'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print('Error from image repo ${snapshot.state.toString()}');
      throw ('This file is not an image');
    }
  }

}

class ImageClassification extends StatefulWidget {
  final File imageFile;
  const ImageClassification({required Key key, required this.imageFile}) : super(key:key);

  @override
  State<StatefulWidget> createState() => _ImageClassificationState();
}

class _ImageClassificationState extends State<ImageClassification>{

  var _imageFile;
  var _prediction;
  late List<Result> _results;

  Map<String,String> headers = {
    'x-rapidapi-key':'5b2f443d6cmsh9e04ef3014bde3dp176b6ajsnea7f884ff2e9',
    'x-rapidapi-host':'visionapi.p.rapidapi.com'
  };
  String apiUrl = "https://visionapi.p.rapidapi.com/v1/rapidapi/score_image";

  Future<void> getImage() async{
    _imageFile = widget.imageFile;
    var path = _imageFile.path;
    print('Path of imageFile: $path');
  }

  upload() async {
    await getImage();
    //var bytes = imageFile.openRead();
    //print(' --- Successfully read ---');
    // ignore: deprecated_member_use
    var stream = new http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
    //var stream = new http.ByteStream(imageFile.openRead());
    //stream.cast();
    var length = await _imageFile.length();
    print(length);

    var uri = Uri.parse(apiUrl);

    var request = new http.MultipartRequest("POST", uri);

    Map<String,String> mapContent = {"content-type":"mutipart/form-data"};
    request.headers.addAll(headers);
    request.headers.addAll(mapContent);
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: path.basename(_imageFile.path),contentType: MediaType.parse("multipart/form-data"));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);

    String jsonText = '';

    await response.stream.transform(utf8.decoder).listen((value) {
      //print(value);
      jsonText = value;
    });

    setState (() {
      _prediction = Prediction.fromJson(json.decode(jsonText));
      _results = _prediction.results;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context, "None"),
          ),
          title: Text("Species suggestions"),
        ),
        body:
        Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(onPressed: upload, child: Text('Search')),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _prediction==null? 0 : _prediction.results.length,
                  itemBuilder: (context, index) {
                    /*
                  return ListTile(
                    title: Text('${_prediction==null? 0: _prediction.results[index].taxon.preferredCommonName}'),
                  );
                  */
                    return _prediction==null? ListTile(title:Text("0")) : getCard(context, index);
                  },
                ),
              ]
          ),
        )
    );
  }

  getCard(BuildContext context, int position) {
    Result model = _results[position];
    return Card(
      child: new InkWell(
        onTap: (){
          print("Tap ${model.taxon.preferredCommonName}");
          Navigator.pop(context, model.taxon.preferredCommonName);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              model.taxon.preferredCommonName,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
      margin: EdgeInsets.all(5),
    );
  }
}