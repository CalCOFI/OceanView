import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/screens/me/me_statistics.dart';
import 'package:ocean_view/services/database.dart';
import 'package:ocean_view/shared/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uri_to_file/uri_to_file.dart';

import '../observation_page.dart';

/*
  A page showing one observation
 */
class MeObservation extends StatelessWidget {
  MeObservation({required this.observation});
  //Create an observation object to store the data passed from the onTap() function from
  //observation_list.dart
  final Observation observation;

  // From url to file
  Future<File> urlToFile(String imageUrl) async {
    var rng = new Random();

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
    http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);

    return file;
  }

  @override
  Widget build(BuildContext context) {
    //Create objects to store detailed information of the observation
    String speciesName = '';
    String scientificName = '';
    double length = 0.0;
    double weight = 0.0;
    dynamic time = [];
    String status = '';
    String confidentiality = '';
    String imageURL = '';
    String? confidence = 'High';

    //Assign values for all objects
    speciesName = observation.name!;
    scientificName = observation.latinName!;
    length = observation.length!;
    weight = observation.weight!;
    time = observation.time!;
    status = observation.status!;
    confidentiality = observation.confidentiality!;
    imageURL = observation.url!;
    confidence = (CONFIDENCE_MAP.containsKey(observation.confidence))
      ? CONFIDENCE_MAP[observation.confidence]
      : 'Unknown';

    print('documentID: ${observation.documentID}');

    // Get user info
    final user = Provider.of<User?>(context);
    print('uid: ${observation.uid}');
    print('length: ${observation.length}');
    print('weight: ${observation.weight}');
    print('Confidence: ${observation.confidence}');

    String _printLocation(LatLng position) {
      String lat = position.latitude.toStringAsFixed(2);
      String lng = position.longitude.toStringAsFixed(2);
      return "(${lat},${lng})";
    }

    //Return the information in an organized layout
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        centerTitle: true,
        backgroundColor: themeMap['scaffold_appBar_color'],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Edit',
              style: TextStyle(fontSize: 16),
            ),
            style: TextButton.styleFrom(
              primary: Colors.white,
            ),
            onPressed: () async {
              File _imageFile = await urlToFile(imageURL);
              Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context) =>
                      ObservationPage(
                        file: _imageFile,
                        mode:'me',
                        observation: observation,
                      )
              )
              );
            },
          ),
          TextButton(
            child: Text(
              'Delete',
              style: TextStyle(fontSize: 16),
            ),
            style: TextButton.styleFrom(
              primary: Colors.red,
            ),
            onPressed: () async {
              String state = await DatabaseService(uid: user!.uid).
              deleteObservation(this.observation);

              if (state == 'Observation deleted'){
                final snackBar = SnackBar(content: Text(state));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                throw (state);
              }

              // Back to previous page
              Navigator.pop(context, ['Delete']);
            },
          ),
        ],
      ),
      //Layout for all information
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: Center(
                child: Image(
                  image: NetworkImage(imageURL),
                  height: 250,
                  width: 180,
                ),
              ),
            ),
            Divider(
              color: Colors.black,
            ),
            Expanded(
              child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child: Column(
                    children: [
                      FieldWithValue(field: 'Common Name', value: speciesName),
                      SizedBox(height: 10.0),
                      FieldWithValue(field: 'Scientific Name',
                          value: scientificName),
                      SizedBox(height: 10.0),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:[
                            FieldWithValue(field: 'Length (feet)',
                                value: length.toStringAsFixed(2)),
                            FieldWithValue(field: 'Weight (lbs)',
                                value: weight.toStringAsFixed(2)),
                          ]
                      ),
                      SizedBox(height: 10.0),
                      FieldWithValue(field: 'Time', value: time.toString()),
                      SizedBox(height: 10.0),
                      FieldWithValue(field: 'Location',
                          value: _printLocation(observation.location!)),
                      SizedBox(height: 10.0),
                      FieldWithValue(field: 'Confidence Level', value: confidence!),
                      SizedBox(height: 10.0),
                      FieldWithValue(field: 'Confidentiality',
                          value: confidentiality),
                      SizedBox(height: 10.0),
                      FieldWithValue(field: 'Status', value: status),
                      SizedBox(height: 10.0),
                      (this.observation.confidentiality==CONFIDENTIALITY)
                          ?ElevatedButton(
                        child: Text('See statistics'),
                        onPressed: () {
                          // Go to page with statistics
                          Navigator.push(
                              context, MaterialPageRoute(
                            builder: (context) => MeStatistics(user: user!,
                                observation: this.observation),
                          )
                          );
                        },
                      )
                          : SizedBox(),
                    ],
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FieldWithValue extends StatelessWidget {
  // Widget that combines field and value
  final String field;
  final String value;

  FieldWithValue({required this.field, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(field,
            style: TextStyle(
              color: Colors.grey,
              letterSpacing: 2.0,
            )
        ),
        Text(value,
            style: TextStyle(
              color: Colors.black54,
              letterSpacing: 2.0,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            )
        ),
      ]
    );
  }
}
