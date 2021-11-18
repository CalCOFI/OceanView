import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ocean_view/models/observation.dart';

import 'local_store.dart';

class DatabaseService {

  String uid;
  DatabaseService({required this.uid});

  // collection reference
  final CollectionReference observationCollection = FirebaseFirestore.instance.collection('observations');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create map from observation
  Map<String, dynamic> _getMapFromObs(Observation observation) {

    Map<String, dynamic> obsMap = Map<String, dynamic>();

    // Check for each field in observation
    obsMap['uid'] = observation.uid ?? uid;
    obsMap['name'] = observation.name ?? 'None';
    obsMap['length'] = observation.length ?? 0.0;
    obsMap['weight'] = observation.weight ?? 0.0;
    obsMap['time'] = observation.time ?? 'None';
    if (observation.location!=null) {
      obsMap['location'] = GeoPoint(
        observation.location!.latitude,
        observation.location!.longitude
      );
    }
    obsMap['status'] = observation.status ?? 'Observe';
    obsMap['url'] = observation.url ?? 'None';

    return obsMap;
  }

  // Upload image to Firebase Storage
  Future<List<dynamic>> _uploadImage(File file) async {

    String filePath = 'images/${uid}/${DateTime.now()}.png';

    // Upload image to Storage
    TaskSnapshot snapshot = await _storage.ref().child(filePath).putFile(file);
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    return [snapshot.state, downloadUrl];
  }

  // Add single new observation
  Future<TaskState> addObservation(Observation observation, File file) async {

    List<dynamic> messages = await _uploadImage(file);

    if(messages[0] == TaskState.success) {

      observation.uid = uid;
      observation.url = messages[1];

      Map<String, dynamic> obsMap = _getMapFromObs(observation);

      // Upload observation to CloudStore
      await observationCollection.add(obsMap);
    }

    return messages[0];
  }

  // Batched write multiple observations
  Future<List<TaskState>> batchedWriteObservations(List<Observation> observations) async {

    final WriteBatch writeBatch = FirebaseFirestore.instance.batch();
    List<dynamic> messages;
    List<TaskState> states = [];
    File file;
    DocumentReference documentReference;

    // Loop over each observations
    for (int i=0; i<observations.length; i++){

      // Upload image to storage
      file = await LocalStoreService().loadImage('$i.png');
      messages = await _uploadImage(file);

      // Only upload observation if image is successfully uploaded
      if (messages[0] == TaskState.success) {
        observations[i].uid = uid;
        observations[i].url = messages[1];

        documentReference = observationCollection.doc();
        writeBatch.set(documentReference, _getMapFromObs(observations[i]));
      }

      states.add(messages[0]);
    }

    // Batched write
    writeBatch.commit();

    return states;
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
        time: (doc.data()['time']!=null)?
          DateTime.fromMillisecondsSinceEpoch(doc.data()['time'].seconds*1000):
          'None',
        location: (doc.data()['location']!=null)?
          LatLng(doc.data()['location'].latitude, doc.data()['location'].longitude):
          LatLng(0,0),
        status: doc.data()['status'],
        url: doc.data()['url'],
      );
    }).toList();
  }

  // get observations stream
  Stream<List<Observation>> get observations {
    return observationCollection.where('uid', isEqualTo: this.uid)
        .snapshots().map(_observationsFromSnapshots);
  }
}