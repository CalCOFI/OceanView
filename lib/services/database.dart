import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocean_view/models/observation.dart';

class DatabaseService {

  String? uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference observationCollection = FirebaseFirestore.instance.collection('observations');

  Future updateObservation(Map<String, dynamic> observation) async {
    // Check for each field in observation
    observation['uid'] = observation['uid'] ?? 'None';
    observation['name'] = observation['name'] ?? 'None';
    observation['length'] = observation['length'] ?? 0.0;
    observation['weight'] = observation['name'] ?? 0.0;
    observation['time'] = observation['time'] ?? 'None';
    observation['status'] = observation['status'] ?? 'Observe';
    observation['url'] = observation['url'] ?? 'None';

    return await observationCollection.add(observation);
  }

}