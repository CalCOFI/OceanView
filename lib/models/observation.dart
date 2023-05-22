import 'package:google_maps_flutter/google_maps_flutter.dart';

/*
  Implementation of observation containing information of
  species, photo and database
 */
class Observation {
  String? documentID; // Document ID on Firebase
  String? uid; // User ID who uploads this observation
  String? name; // Species name on the photo
  String? latinName; // Scientific name of species
  double? length; // Length of species
  double? weight; // Weight of species
  dynamic time; // Datetime from the picture (None: not showing)
  LatLng? location; // LatLng from picture (None: not showing)
  String? status; // Observe / Release / Catch
  String? confidentiality; // Share with scientists / Keep private
  int? confidence; // 1-3
  String? url; // Url of photo on Firebase, generated when uploading
  dynamic stopwatchStart; // Datetime of stopwatch start

  Observation(
      {this.documentID,
      this.uid,
      this.name,
      this.latinName,
      this.length,
      this.weight,
      this.time,
      this.location,
      this.confidence,
      this.status,
      this.url,
      this.stopwatchStart,
      this.confidentiality});

  // Getter of observation
  Map<String, dynamic> get map {
    return {
      'length': length,
      'weight': weight,
    };
  }
}
