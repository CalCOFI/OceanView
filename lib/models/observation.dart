import 'package:cloud_firestore/cloud_firestore.dart';

class Observation {

  String? documentID;
  String? uid;
  String? name;
  double? length;
  double? weight;
  dynamic time;
  String? status;
  String? url;

  Observation( {this.documentID, this.uid, this.name, this.length, this.weight, this.time, this.status, this.url} );

}