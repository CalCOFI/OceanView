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
  String? session;   // 0: single observation, DateTime.now(): session observation

  Observation( {this.documentID, this.uid, this.name,
    this.length, this.weight, this.time, this.status,
    this.url, this.session} );

}