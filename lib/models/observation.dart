import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Observation {
  String? documentID;
  String? uid;
  String? name;
  String? latinName;
  double? length;
  double? weight;
  dynamic time; // None: not showing / Timestamp from the picture
  LatLng? location; // None: not showing / LatLng from picture
  String? status;
  String? url;
  int? confidence;

  // stopwatch time
  dynamic stopwatchStart; // Record timestamp of stopwatch start

  Observation(
      {this.documentID,
      this.uid,
      this.name,
      this.latinName,
      this.length,
      this.weight,
      this.time,
      this.location,
      this.status,
      this.url,
      this.confidence,
      this.stopwatchStart});
}
