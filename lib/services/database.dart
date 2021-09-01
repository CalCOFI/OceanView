import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocean_view/models/observation.dart';

class DatabaseService {

  String? uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference observationCollection = FirebaseFirestore.instance.collection('observations');

  Future updateObservation(Map<String, dynamic> observation) async {
    return await observationCollection.add(observation);
  }

  // get brews stream
  Stream<QuerySnapshot> get brews {
    return observationCollection.snapshots();
  }

}