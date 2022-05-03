import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ocean_view/shared/loading.dart';
import 'package:ocean_view/src/prediction.dart';
import 'package:path/path.dart' as path;

/*
  A page sends the image to VisionAPI and shows ten suggestions from VisionAPI
 */

class UploadClassification extends StatefulWidget {
  final File imageFile;
  const UploadClassification({required Key key, required this.imageFile})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _UploadClassificationState();
}

class _UploadClassificationState extends State<UploadClassification> {
  var _prediction;
  late List<Result> _results;
  bool loading = true;

  Map<String, String> headers = {
    'x-rapidapi-key': '5b2f443d6cmsh9e04ef3014bde3dp176b6ajsnea7f884ff2e9',
    'x-rapidapi-host': 'visionapi.p.rapidapi.com'
  };
  String apiUrl = "https://visionapi.p.rapidapi.com/v1/rapidapi/score_image";

  // Send request to VisionAPI
  uploadToVisionAPI() async {
    var stream = new http.ByteStream(widget.imageFile.openRead().cast());
    var length = await widget.imageFile.length();
    print(length);

    var uri = Uri.parse(apiUrl);

    var request = new http.MultipartRequest("POST", uri);

    Map<String, String> mapContent = {"content-type": "mutipart/form-data"};
    request.headers.addAll(headers);
    request.headers.addAll(mapContent);
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: path.basename(widget.imageFile.path),
        contentType: MediaType.parse("multipart/form-data"));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);

    String jsonText = '';

    await response.stream.transform(utf8.decoder).listen((value) {
      jsonText = value;
    });

    setState(() {
      _prediction = Prediction.fromJson(json.decode(jsonText));
      _results = _prediction.results;
      loading = false;
    });
  }

  // Run once when this widget is added to widget tree
  @override
  void initState() {
    super.initState();

    uploadToVisionAPI();
  }

  getCard(BuildContext context, int position) {
    Result model = _results[position];
    String commonName = model.taxon.preferredCommonName ?? 'None';
    String scientificName = model.taxon.name ?? 'None';
    return Card(
      child: new InkWell(
          onTap: () {
            print("Tap ${commonName}");
            Navigator.pop(context, model.taxon);
          },
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(commonName + ' (' + scientificName + ')'),
          )
          /*
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              model.taxon.preferredCommonName,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),

         */
          ),
      margin: EdgeInsets.all(5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context, null),
              ),
              title: Text("Species suggestions"),
            ),
            body: Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(40),
                      child: Image.asset(
                        'assets/images/iNaturalist.png',
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    (_prediction == null)
                        ? Text(
                            'Cannot find corresponding species',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: _prediction.results.length,
                            itemBuilder: (context, index) {
                              return getCard(context, index);
                            },
                          ),
                  ]),
            ));
  }
}
