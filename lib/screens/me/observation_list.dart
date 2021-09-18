
import 'package:flutter/material.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/screens/me/me_observation.dart';
import 'package:provider/provider.dart';

class ObservationList extends StatefulWidget {
  const ObservationList({Key? key}) : super(key: key);

  @override
  _ObservationListState createState() => _ObservationListState();
}

class _ObservationListState extends State<ObservationList> {
  @override
  Widget build(BuildContext context) {
   // Observation observation;
    final observations = Provider.of<List<Observation>?>(context) ?? [];
    String imageURL = '';
    int index = 0;
    observations.forEach((observation) {
      print('$index');
      imageURL = observation.url!;
      index+=1;
      print('$imageURL');
    });
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20),
        itemCount: observations.length,
        itemBuilder: (BuildContext ctx, index) {
          return Container(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder:(context) => MeObservation(observation:observations[index]),
                    settings: RouteSettings(
                    arguments: observations[index],
                  ),
                ),
                );
              }, // handle your image tap here
              child: Image(
                image:NetworkImage(observations[index].url!),
                height: 250,
                width: 180,
              ),
            )
          );
        },


      ),
    );
    /*
    //Create an object for each information
    String speciesName ='';
    double length =0.0;
    double weight =0.0;
    dynamic time = [];
    String status = '';
    String imageURL = '';

    observations.forEach((observation) {
      //Assign values for all objects
      speciesName = observation.name! ;
      length = observation.length!;
      weight = observation.weight!;
      time = observation.time!;
      status = observation.status! ;
      imageURL = observation.url!;
      print('documentID: ${observation.documentID}');
      print('uid: ${observation.uid}');
      print('length: ${observation.length}');
      print('weight: ${observation.weight}');
    });


    return Scaffold(
      //Layout for all information
      body: Padding(
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
                'Quantity: ',
                style: TextStyle(
                  color:Colors.grey,
                  letterSpacing: 2.0,
                )
            ),
            Text(
                '????',
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
                '$time',
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
                '?????',
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
          ],
        ),
      ),
    );
    */
  }
}


