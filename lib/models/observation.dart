import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/*
  Implementation of observation containing information of
  species, photo and database
 */
class Observation {

  String? documentID;       // Document ID on Firebase
  String? uid;              // User ID who uploads this observation
  String? name;             // Species name on the photo
  double? length;           // Length of species
  double? weight;           // Weight of species
  dynamic time;             // Timestamp from the picture (None: not showing)
  LatLng? location;         // LatLng from picture (None: not showing)
  String? status;           // Observe / Release / Catch
  String? confidentiality;  // Share with scientists / Keep private
  String? url;              // Url of photo on Firebase, generated when uploading
  dynamic stopwatchStart;   // Timestamp of stopwatch start

  Observation( {this.documentID, this.uid, this.name,
    this.length, this.weight, this.time, this.location,
    this.status, this.url, this.stopwatchStart, this.confidentiality} );

}