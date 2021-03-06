import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/shared/constants.dart';

import 'local_store.dart';

/*
  Class for accessing data in Firebase including fetch observations,
  add single observation, add multiple observations in a batch
 */

class DatabaseService {
  String uid;
  Observation? observation;
  DatabaseService({required this.uid, this.observation});

  // collection reference
  final CollectionReference observationCollection =
  FirebaseFirestore.instance.collection('observations');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create map from observation
  Map<String, dynamic> _getMapFromObs(Observation observation) {
    Map<String, dynamic> obsMap = Map<String, dynamic>();

    // Check for each field in observation
    obsMap['uid'] = observation.uid ?? uid;
    obsMap['name'] = observation.name ?? 'None';
    obsMap['latinName'] = observation.latinName ?? 'None';
    obsMap['length'] = observation.length ?? 0.0;
    obsMap['weight'] = observation.weight ?? 0.0;
    obsMap['time'] = observation.time ?? 'None';
    if (observation.location != null) {
      obsMap['location'] = GeoPoint(
          observation.location!.latitude, observation.location!.longitude);
    }
    obsMap['status'] = observation.status ?? STATUS;
    obsMap['confidentiality'] = observation.confidentiality ?? CONFIDENTIALITY;
    obsMap['confidence'] = observation.confidence ?? CONFIDENCE;
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

    if (messages[0] == TaskState.success) {
      observation.uid = uid;
      observation.url = messages[1];

      Map<String, dynamic> obsMap = _getMapFromObs(observation);

      // Upload observation to CloudStore
      await observationCollection.add(obsMap);
    }

    return messages[0];
  }

  // Batched write multiple observations
  Future<List<TaskState>> batchedWriteObservations(
      List<Observation> observations) async {
    final WriteBatch writeBatch = FirebaseFirestore.instance.batch();
    List<dynamic> messages;
    List<TaskState> states = [];
    File file;
    DocumentReference documentReference;

    // Loop over each observations
    for (int i = 0; i < observations.length; i++) {
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

  // Update existing observation
  Future<String> updateObservation(Observation observation) async {

    Map<String, dynamic> obsMap = _getMapFromObs(observation);
    String state = 'fail';

    // Update existing observation on CloudStore
    await observationCollection
        .doc(observation.documentID)
        .update(obsMap)
        .then((_) => state='success')
        .catchError((error) => state='fail');;

    return state;
  }


  // Delete observation
  Future<String> deleteObservation(Observation observation) async {
    String state = 'Null';

    await observationCollection
        .doc(observation.documentID)
        .delete()
        .then((value) => state = 'Observation deleted')
        .catchError((error) => state = 'Unable to delete observation');

    return state;
  }


  // observation list from snapshots
  List<Observation> _observationsFromSnapshots(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Observation(
        documentID: doc.id,
        uid: doc.data()['uid'],
        name: doc.data()['name'],
        latinName: doc.data()['latinName'] ?? 'Unknown',
        length: doc.data()['length'],
        weight: doc.data()['weight'],
        time: (doc.data()['time'] != null)
            ? DateTime.fromMillisecondsSinceEpoch(
            doc.data()['time'].seconds * 1000)
            : 'None',
        location: (doc.data()['location']!=null)?
        LatLng(doc.data()['location'].latitude, doc.data()['location'].longitude):
        LatLng(0,0),
        status: doc.data()['status'] ?? STATUS,
        confidentiality: doc.data()['confidentiality'] ?? CONFIDENTIALITY,
        confidence: doc.data()['confidence'] ?? CONFIDENCE,
        url: doc.data()['url'],
      );
    }).toList();
  }

  // Query current users' observations
  Stream<List<Observation>> get meObs {
    return observationCollection.where('uid', isEqualTo: this.uid)
        .snapshots().map(_observationsFromSnapshots);
  }

  // Query related observations for statistics
  Stream<List<Observation>> get statisticsObs {
    return observationCollection
        .where('name', isEqualTo: this.observation!.name)
        .where('confidentiality', isEqualTo: CONFIDENTIALITY)
        .snapshots().map(_observationsFromSnapshots);
  }
}
