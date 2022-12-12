import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/screens/me/me_histogram.dart';
import 'package:ocean_view/services/database.dart';
import 'package:ocean_view/shared/constants.dart';
import 'package:ocean_view/shared/custom_widgets.dart';
import 'package:provider/provider.dart';

class MeStatistics extends StatefulWidget {
  final Observation observation;
  final User user;

  MeStatistics({required this.user, required this.observation});

  @override
  _MeStatisticsState createState() => _MeStatisticsState();
}

class _MeStatisticsState extends State<MeStatistics> {
  late Map<String, List<double>> mapValues;
  bool loading = true;

  // queryForStatistics() async {
  //   print(widget.observation.confidentiality);
  //   mapValues = await DatabaseService(uid:widget.user.uid)
  //       .queryStatistics(widget.observation);
  //   setState((){
  //     loading = false;
  //   });
  // }

  // @override
  // void initState(){
  //   super.initState();
  //
  //   // TODO: Query observations with certain restrictions
  //   setState(() {
  //     mapValues = DatabaseService(uid:widget.user.uid)
  //         .queryStatistics(widget.observation);
  //     loading = false;
  //   });
  // }

  // @override
  // Widget build(BuildContext context) {
  //   print('Name: ${widget.observation.name}');
  //   return loading? Loading(): Scaffold(
  //       appBar: AppBar(
  //         title: Text(widget.observation.name!),
  //       ),
  //       body: Column(
  //         children: [
  //           Text(mapValues.toString()),
  //           // TODO: Add two histograms
  //         ],
  //       )
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    print('In MeStatistics: ${widget.observation.name}');

    return StreamProvider<List<Observation>?>.value(
      value: DatabaseService(
              uid: widget.user!.uid, observation: widget.observation)
          .statisticsObs,
      initialData: null,
      child: Scaffold(
        //backgroundColor: Colors.brown[50],
        appBar: AppBar(
          title: Text(widget.observation.name!),
          centerTitle: true,
          backgroundColor: topBarColor,
          elevation: 0.0,
        ),
        body: Container(
          decoration: blueBoxDecoration,
          child: Stack(children: [
            CustomPainterWidgets.buildTopShape(),
            Column(
                // Add two histograms
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MeHistogram(field: 'length', curObs: widget.observation),
                  MeHistogram(field: 'weight', curObs: widget.observation),
                ]),
          ]),
        ),
      ),
    );
  }
}
