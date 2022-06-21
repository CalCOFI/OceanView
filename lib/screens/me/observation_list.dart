
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:image_stack/image_stack.dart';

import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/screens/me/me_observation.dart';


/*
  A page showing user's past observations with only images organized
  in two columns
 */
class ObservationList extends StatefulWidget {

  @override
  _ObservationListState createState() => _ObservationListState();
}

class _ObservationListState extends State<ObservationList> {
  @override
  Widget build(BuildContext context) {
    //pull all observation data from firebase of the user
    //and stored the observation data in observations
    final observations = Provider.of<List<Observation>?>(context) ?? [];

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
                                  MeObservation(observation: observations[index]),
                              settings: RouteSettings(
                                arguments: observations[index],
                              ),
                            ),
                          );
                        },
                        //Image Widget which displays the image
                        child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(observations[index].url!),
                                )
                            )
                        )
                    )
                );
              },
              childCount: observations.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.symmetric(vertical: 5)),
          SliverAppBar(
            title: Text('Collections')
          ),
          const SliverPadding(padding: EdgeInsets.symmetric(vertical: 5)),
          // TODO: Add image stack for collections
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (cxt, index) {
                List<String> images = [];
                for (Observation observation in observations) {
                  images.add(observation.url!);
                };
                return Container(
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TODO: Add date and lasted time to this text
                        Text('Collection $index'),
                        // TODO: Only access collection here
                        GestureDetector(
                            onTap: () {
                              print('Press $index stack');
                            },
                            //Image Widget which displays the image
                            child: ImageStack(
                              imageList: images,
                              totalCount: observations.length,
                              imageRadius: 50,
                              imageCount: 3,
                              imageBorderWidth: 3,
                            )
                        ),
                      ],
                    )
                );
              },
              childCount: 1,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.symmetric(vertical: 5)),
        ],
      ),
    );
  }
}
