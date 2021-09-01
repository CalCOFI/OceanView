import 'package:cloud_firestore/cloud_firestore.dart';

class Observation {

  final String user;
  final String name;
  final double length;
  final double weight;
  final Timestamp time;
  final String status;
  final String url;

  Observation( {required this.user, required this.name, required this.length,
    required this.weight, required this.time, required this.status, required this.url} );

}