import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocean_view/models/observation.dart';

class DatabaseService {

  String? uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference observationCollection = FirebaseFirestore.instance.collection('observations');

  // Add new observations
  /*
  Future addObservation(Map<String, dynamic> observation) async {
    // Check for each field in observation
    observation['uid'] = observation['uid'] ?? 'None';
    observation['name'] = observation['name'] ?? 'None';
    observation['length'] = observation['length'] ?? 0.0;
    observation['weight'] = observation['weight'] ?? 0.0;
    observation['time'] = observation['time'] ?? 'None';
    observation['status'] = observation['status'] ?? 'Observe';
    observation['url'] = observation['url'] ?? 'None';

    return await observationCollection.add(observation);
  }
   */
  Future addObservation(Observation observation) async {

    Map<String, dynamic> obsMap = Map<String, dynamic>();
    // Check for each field in observation
    obsMap['uid'] = observation.uid ?? 'None';
    obsMap['name'] = observation.name ?? 'None';
    obsMap['length'] = observation.length ?? 0.0;
    obsMap['weight'] = observation.weight ?? 0.0;
    obsMap['time'] = observation.time ?? 'None';
    obsMap['status'] = observation.status ?? 'Observe';
    obsMap['url'] = observation.url ?? 'None';
    obsMap['session'] = observation.session ?? '0';

    return await observationCollection.add(obsMap);
  }

  // observation list from snapshots
  List<Observation> _observationsFromSnapshots (QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      return Observation (
        documentID: doc.id,
        uid: doc.data()['uid'],
        name: doc.data()['name'],
        length: doc.data()['length'],
        weight: doc.data()['weight'],
        time: doc.data()['time'],
        status: doc.data()['status'],
        url: doc.data()['url'],
        session: doc.data()['session'],
      );
    }).toList();
  }

  // get observations stream
  Stream<List<Observation>> get observations {
    return observationCollection.where('uid', isEqualTo: this.uid)
        .snapshots().map(_observationsFromSnapshots);
  }
}