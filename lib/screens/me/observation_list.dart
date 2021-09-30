
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
    //pull all observation data from firebase of the user
    //and stored the observation data in observations
    final observations = Provider.of<List<Observation>?>(context) ?? [];
    //Create an String object to store image url of each observation
    String imageURL = '';
    int index = 0;
    //A function that runs through observations which contains
    // all observation of the user
    observations.forEach((observation) {
      print('$index');
      imageURL = observation.url!;
      index += 1;
      print('$imageURL');
    });
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // A child Widget that show the images in a grid view
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
              //A widget that contains the onTap() function which passes the observation
              //data to MeObservation() when clicking an image
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MeObservation(observation: observations[index]),
                      settings: RouteSettings(
                        arguments: observations[index],
                      ),
                    ),
                  );
                },
                //Image Widget which displays the image
                child: Image(
                  image: NetworkImage(observations[index].url!),
                  height: 250,
                  width: 180,
                ),
              )
          );
        },


      ),
    );
  }
}
