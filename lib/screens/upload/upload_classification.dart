import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:async/async.dart' hide Result;
import 'package:ocean_view/src/prediction.dart';
import 'package:path/path.dart' as path;

class UploadClassification extends StatefulWidget {
  final File imageFile;
  const UploadClassification({required Key key, required this.imageFile}) : super(key:key);

  @override
  State<StatefulWidget> createState() => _UploadClassificationState();
}

class _UploadClassificationState extends State<UploadClassification>{

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