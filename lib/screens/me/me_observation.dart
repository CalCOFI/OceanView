import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ocean_view/models/observation.dart';

/*
  A page showing one observation
 */
class MeObservation extends StatelessWidget {
  const MeObservation({Key? key, required this.observation}) : super(key: key);
  //Create an observation object to store the data passed from the onTap() function from
  //observation_list.dart
  final Observation observation;

  @override
  Widget build(BuildContext context) {
    //Create objects to store detailed information of the observation
    String speciesName ='';
    double length =0.0;
    double weight =0.0;
    dynamic time = [];
    String status = '';
    String confidence = '';
    String imageURL = '';

    //Assign values for all objects
    speciesName = observation.name!;
    length = observation.length!;
    weight = observation.weight!;
    time = observation.time!;
    status = observation.status!;
    confidence = observation.confidence!;
    imageURL = observation.url!;
    print('documentID: ${observation.documentID}');
    print('uid: ${observation.uid}');
    print('length: ${observation.length}');
    print('weight: ${observation.weight}');

    String _printLocation(LatLng position) {
      String lat = position.latitude.toStringAsFixed(2);
      String lng = position.longitude.toStringAsFixed(2);
      return "(${lat},${lng})";
    }

    //Return the information in an organized layout
    return Scaffold(
      appBar: AppBar(
        title: Text('Observation Details'),
      ),
      //Layout for all information
      body:
      Padding(
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Container(
              margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: Center(
                child: Image(
                  image:NetworkImage(imageURL),
                  height: 250,
                  width: 180,
                ),
              ),
            ),
            Divider(

              color: Colors.black,
            ),
            Text(
                'Species Name:',
                style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                '$speciesName',
                style: TextStyle(
                  color: Colors.black54,
                  letterSpacing: 2.0,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:10.0),
            Text(
                'Length(feet):',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                '$length',
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:10.0),
            Text(
                'Weight(lb):',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                '$weight',
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:10.0),
            Text(
                'Time:',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                time.toString(),
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:10.0),
            Text(
                'Location: ',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                _printLocation(observation.location!),
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:10.0),
            Text(
                'Status',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                '$status',
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
            SizedBox(height:10.0),
            Text(
                'Confidence',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                '$confidence',
                style: TextStyle(
                  color:Colors.black54,
                  letterSpacing: 2.0,
                  fontSize:18.0,
                  fontWeight: FontWeight.bold,
                )
            ),
          ],
        ),
      ),
    );
  }

}
