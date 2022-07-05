
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:image_stack/image_stack.dart';

import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/screens/me/me_observation.dart';

import '../../shared/constants.dart';


/*
  A page showing user's past observations with only images organized
  in two columns
 */
class ObservationList extends StatefulWidget {

  @override
  _ObservationListState createState() => _ObservationListState();
}

class _ObservationListState extends State<ObservationList> {

  List<Observation> extractSingleObs(List<Observation> observations) {
    List<Observation> listSingleObs = [];
    if (observations.length == 0)
      return [];

    // Extract single observation from observations whose stopwatchStart is None
    for (Observation observation in observations) {
      if (observation.stopwatchStart.toString() == STOPWATCHSTART){
        listSingleObs.add(observation);
      }
    }

    return listSingleObs;
  }

  List<List<Observation>> extractCollections(List<Observation> observations) {

    Map<Timestamp, List<Observation>> mapCollections = {};
    if (observations.length == 0)
      return [];

    // Extract collection from observations whose stopwatchStart is not None
    for (Observation observation in observations) {
      if (observation.stopwatchStart.toString() != STOPWATCHSTART) {
        Timestamp startTime = observation.stopwatchStart;
        if (!mapCollections.containsKey(startTime))
          mapCollections[startTime] = [observation];
        else
          mapCollections[startTime]!.add(observation);
      }
    }

    // Sort list of collections according to stopwatchStart
    List<Timestamp> listStartTime = mapCollections.keys.toList();
    List<List<Observation>> listCollections = [];
    listStartTime.sort();
    for (Timestamp startTime in listStartTime) {
      listCollections.add(mapCollections[startTime]!);
    }

    return listCollections;
  }

  @override
  Widget build(BuildContext context) {
    //pull all observation data from firebase of the user
    //and stored the observation data in observations
    final observations = Provider.of<List<Observation>?>(context) ?? [];
    List<Observation> listSingleObs = extractSingleObs(observations);
    List<List<Observation>> listCollections = extractCollections(observations);
    // CustomScrollView
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Single Observation')
          ),
          const SliverPadding(padding: EdgeInsets.symmetric(vertical: 5)),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10
            ),
            delegate: SliverChildBuilderDelegate(
              (cxt, index) {
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
                                MeObservation(observation: listSingleObs[index]),
                              settings: RouteSettings(
                                arguments: listSingleObs[index],
                              ),
                            ),
                          );
                        },
                        //Image Widget which displays the image
                        child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(listSingleObs[index].url!),
                                )
                            )
                        )
                    )
                );
              },
              childCount: listSingleObs.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.symmetric(vertical: 5)),
          SliverAppBar(
            title: Text('Collections')
          ),
          const SliverPadding(padding: EdgeInsets.symmetric(vertical: 5)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (cxt, index) {
                List<String> images = [];
                List<Observation> collection = listCollections[index];
                for (Observation observation in collection) {
                  images.add(observation.url!);
                };
                DateTime startTime = collection[0].stopwatchStart.toDate();
                return Container(
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('yyyy-MM-dd, HH:mm').format(startTime)),
                        GestureDetector(
                            onTap: () {
                              print('Press $index stack');
                            },
                            //Image Widget which displays the image
                            child: ImageStack(
                              imageList: images,
                              totalCount: collection.length,
                              imageRadius: 50,
                              imageCount: 3,
                              imageBorderWidth: 3,
                            )
                        ),
                      ],
                    )
                );
              },
              childCount: listCollections.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.symmetric(vertical: 5)),
        ],
      ),
    );
  }
}
