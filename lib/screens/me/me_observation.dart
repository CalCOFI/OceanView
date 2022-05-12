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
    String confidence = 'High';

    //Assign values for all objects
    speciesName = observation.name!;
    scientificName = observation.latinName!;
    length = observation.length!;
    weight = observation.weight!;
    time = observation.time!;
    status = observation.status!;
    confidentiality = observation.confidentiality!;
    imageURL = observation.url!;
    switch (observation.confidence) {
      case (1):
        {
          confidence = 'Low';
        }
        break;
      case (2):
        {
          confidence = 'Medium';
        }
        break;
      case (3):
        {
          confidence = 'High';
        }
        break;
      default:
        {
          confidence = 'Unknown';
        }
        break;
    }

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
        backgroundColor: Colors.lightBlueAccent,
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
              Navigator.pop(context);
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
            Text('Common Name:',
                style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2.0,
                )),
            Text('$speciesName',
                style: TextStyle(
                  color: Colors.black54,
                  letterSpacing: 2.0,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 10.0),
            Text('Scientific Name:',
                style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2.0,
                )),
            Text('$scientificName',
                style: TextStyle(
                  color: Colors.black54,
                  letterSpacing: 2.0,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 10.0),
            Text('Confidence Level:',
                style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2.0,
                )),
            Text('$confidence',
                style: TextStyle(
                  color: Colors.black54,
                  letterSpacing: 2.0,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 10.0),
            Text('Length(feet):',
                style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2.0,
                )),
            Text('$length',
                style: TextStyle(
                  color: Colors.black54,
                  letterSpacing: 2.0,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 10.0),
            Text('Weight(lb):',
                style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2.0,
                )),
            Text('$weight',
                style: TextStyle(
                  color: Colors.black54,
                  letterSpacing: 2.0,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 10.0),
            Text('Time:',
                style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2.0,
                )),
            Text(time.toString(),
                style: TextStyle(
                  color: Colors.black54,
                  letterSpacing: 2.0,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 10.0),
            Text('Location: ',
                style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2.0,
                )),
            Text(_printLocation(observation.location!),
                style: TextStyle(
                  color: Colors.black54,
                  letterSpacing: 2.0,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:10.0),
            Text(
                'Confidentiality',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                '$confidentiality',
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height: 10.0),
            Text('Status',
                style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2.0,
                )),
            Text('$status',
                style: TextStyle(
                  color: Colors.black54,
                  letterSpacing: 2.0,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                )),
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
        ),
      ),
    );
  }
}
