import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/models/userstats.dart';
import 'package:ocean_view/shared/constants.dart';

import 'local_store.dart';

/*
  Class for accessing data in Firebase including fetch observations,
  add single observation, add multiple observations in a batch
 */

class DatabaseService {
  String uid;
  Observation? observation;
  UserStats? stats;
  DatabaseService({required this.uid, this.observation, this.stats});

  // collection references
  final CollectionReference observationCollection =
      FirebaseFirestore.instance.collection('observations');
  final CollectionReference userstatsCollection =
      FirebaseFirestore.instance.collection('userstats');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create map from user stats
  Map<String, dynamic> _getMapFromUserStats(UserStats stats) {
    Map<String, dynamic> statMap = Map<String, dynamic>();
    statMap['uid'] = stats.uid ?? uid;
    statMap['name'] = stats.name ?? '';
    statMap['email'] = stats.email ?? '';
    statMap['share'] = stats.share ?? 'Y';
    statMap['numobs'] = stats.numobs ?? 0;
    statMap['firsttime'] = stats.firsttime ?? true;

    return statMap;
  }

  // Create map from observation
  Map<String, dynamic> _getMapFromObs(Observation observation) {
    Map<String, dynamic> obsMap = Map<String, dynamic>();

    // Check for each field in observation
    obsMap['uid'] = observation.uid ?? uid;
    obsMap['name'] = observation.name ?? NAME;
    obsMap['latinName'] = observation.latinName ?? LATINNAME;
    obsMap['length'] = observation.length ?? LENGTH;
    obsMap['weight'] = observation.weight ?? WEIGHT;
    obsMap['time'] = observation.time ?? TIME;
    if (observation.location != null) {
      obsMap['location'] = GeoPoint(
          observation.location!.latitude, observation.location!.longitude);
    } else {
      obsMap['location'] = GeoPoint(LATITUDE, LONGITUDE);
    }
    obsMap['status'] = observation.status ?? STATUS; //STATUS_MAP[STATUS];
    obsMap['confidentiality'] = observation.confidentiality ?? CONFIDENTIALITY;
    obsMap['confidence'] = observation.confidence ?? CONFIDENCE;
    obsMap['url'] = observation.url ?? URL;
    obsMap['imagePath'] = observation.imagePath ?? IMAGEPATH;
    obsMap['stopwatchStart'] = observation.stopwatchStart ?? STOPWATCHSTART;

    return obsMap;
  }

  Future<void> updateUserStats(UserStats stats) async {
    return await userstatsCollection.doc(uid).set(_getMapFromUserStats(stats));
  }

  // Upload image to Firebase Storage
  Future<List<dynamic>> _uploadImage(io.File file, String filePath) async {
    // Upload image to Storage
    TaskSnapshot snapshot = await _storage.ref().child(filePath).putFile(file);
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    return [snapshot.state, downloadUrl];
  }

  // Add single new observation
  Future<TaskState> addObservation(
      Observation observation, io.File file) async {
    String imagePath = 'images/${uid}/${DateTime.now()}.png';
    List<dynamic> messages = await _uploadImage(file, imagePath);

    if (messages[0] == TaskState.success) {
      observation.uid = uid;
      observation.url = messages[1];
      observation.imagePath = imagePath;

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
    io.File file;
    DocumentReference documentReference;

    // Loop over each observations
    for (int i = 0; i < observations.length; i++) {
      // Upload image to storage
      String imagePath = 'images/${uid}/${DateTime.now()}.png';
      file = await LocalStoreService().loadImage('$i.png');
      messages = await _uploadImage(file, imagePath);

      // Only upload observation if image is successfully uploaded
      if (messages[0] == TaskState.success) {
        observations[i].uid = uid;
        observations[i].url = messages[1];
        observations[i].imagePath = imagePath;

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
        .then((_) => state = 'success')
        .catchError((error) => state = 'fail');

    return state;
  }

  // Delete observation document and image
  Future<String> deleteObservation(Observation observation) async {
    String state = 'Null';

    // delete document
    await observationCollection
        .doc(observation.documentID)
        .delete()
        .then((value) => state = 'Document deleted')
        .catchError((error) => state = 'Unable to delete document');

    // delete corresponding image
    await _storage
        .ref()
        .child(observation.imagePath ?? IMAGEPATH)
        .delete()
        .then((value) => state = 'Image deleted')
        .catchError((error) => state = 'Unable to delete image');

    return state;
  }

  // observation list from snapshots
  List<Observation> _observationsFromSnapshots(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      print(doc.get('time').seconds);
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Observation(
        documentID: doc.id,
        uid: data['uid'],
        name: data['name'],
        latinName: data['latinName'] ?? LATINNAME,
        length: data['length'],
        weight: data['weight'],
        time: (data['time'] != null && data['time'] != TIME)
            ? DateTime.fromMillisecondsSinceEpoch(data['time'].seconds * 1000)
            : TIME,
        location: (data['location'] != null)
            ? LatLng(data['location'].latitude, data['location'].longitude)
            : LatLng(LATITUDE, LONGITUDE),
        status: data['status'] ?? STATUS,
        confidentiality: data['confidentiality'] ?? CONFIDENTIALITY,
        confidence: data['confidence'] ?? CONFIDENCE,
        url: data['url'] ?? URL,
        imagePath: data['imagePath'] ?? IMAGEPATH,
        stopwatchStart: (data['stopwatchStart'] != null &&
                data['stopwatchStart'] != STOPWATCHSTART)
            ? DateTime.fromMillisecondsSinceEpoch(
                data['stopwatchStart'].seconds * 1000)
            : STOPWATCHSTART,
      );
    }).toList();
  }

  UserStats _userstatsFromSnapshots(DocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map;
    return UserStats(
        documentID: snapshot.id,
        uid: data['uid'],
        name: data['name'],
        email: data['email'],
        share: data['share'],
        numobs: data['numobs'],
        firsttime: data['firsttime']);
  }

  // Query current users' observations
  Stream<List<Observation>> get meObs {
    return observationCollection
        .where('uid', isEqualTo: this.uid)
        .snapshots()
        .map(_observationsFromSnapshots);
  }

  Stream<UserStats> get meStats {
    return userstatsCollection
        .doc(uid)
        .snapshots()
        .map(_userstatsFromSnapshots);
  }

  // Query related observations for statistics
  Stream<List<Observation>> get statisticsObs {
    return observationCollection
        .where('name', isEqualTo: this.observation!.name)
        .where('confidentiality', isEqualTo: CONFIDENTIALITY)
        .snapshots()
        .map(_observationsFromSnapshots);
  }
}
