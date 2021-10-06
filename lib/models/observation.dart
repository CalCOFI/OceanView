import 'package:cloud_firestore/cloud_firestore.dart';

class Observation {

  String? documentID;
  String? uid;
  String? name;
  double? length;
  double? weight;
  dynamic time;     // None: not showing / Timestamp from the picture
  String? status;
  String? url;

  // stopwatch time
  dynamic stopwatchStart;      // Record timestamp of stopwatch start

  Observation( {this.documentID, this.uid, this.name,
    this.length, this.weight, this.time, this.status,
    this.url, this.stopwatchStart} );

}