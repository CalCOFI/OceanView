
import 'package:flutter/material.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:provider/provider.dart';

class ObservationList extends StatefulWidget {
  const ObservationList({Key? key}) : super(key: key);

  @override
  _ObservationListState createState() => _ObservationListState();
}

class _ObservationListState extends State<ObservationList> {
  @override
  Widget build(BuildContext context) {

    final observations = Provider.of<List<Observation>?>(context) ?? [];

    observations.forEach((observation){
      print('documentID: ${observation.documentID}');
      print('uid: ${observation.uid}');
      print('length: ${observation.length}');
      print('weight: ${observation.weight}');
    });

    return Container();
  }
}
