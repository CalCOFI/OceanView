import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocean_view/screens/upload/upload_classification.dart';
import 'package:ocean_view/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';


// Define a custom Form widget.
class UploadObservation extends StatefulWidget {
  final File file;
  UploadObservation({required this.file});

  @override
  _UploadObservationState createState() => _UploadObservationState(file);
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _UploadObservationState extends State<UploadObservation> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();
  Map<String,dynamic> observation = <String,dynamic>{};
  String statusValue = 'Observe';
  String _imageListText = "What did you see?";
  late Image _image;

  // Firebase
  String userID = "abcdef";
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  UploadTask? _uploadTask;


  _UploadObservationState (File file) {
    this._image = new Image.file(
      file,
      width: 200,
      height: 100,
      fit: BoxFit.contain,
    );
  }

  DateTime selectedDate = DateTime.now();

  // Select date
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        this.observation['time'] = Timestamp.fromDate(selectedDate);
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User?>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Retrieve Text Input'),
      ),
      body: SingleChildScrollView(
          child: Container(
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: _image
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.question_answer),
                            title: Text(_imageListText),
                            subtitle: Text('><'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                  child: const Text('See suggestions'),
                                  onPressed: () {
                                    _navigateAndDisplaySelection(context);
                                  }
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Row(
                        children: <Widget>[
                          const Text('Length: '),
                          Expanded(
                            child: TextField(
                              onSubmitted: (String value){observation['length']=double.parse(value);},
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text("inches"),
                        ]
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Row(
                        children: <Widget>[
                          const Text('Weight: '),
                          Expanded(
                            child: TextField(
                              onSubmitted: (String value){observation['weight']=double.parse(value);},
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text("lb"),
                        ]
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Row(
                        children: <Widget>[
                          const Text("Time: "),
                          const SizedBox(width: 10.0,),
                          Text("${selectedDate.toLocal()}".split(' ')[0]),
                          const SizedBox(width: 10.0),
                          ElevatedButton(
                            onPressed: () => _selectDate(context),
                            child: Icon(Icons.date_range),
                          ),
                        ]
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: Row(
                        children: [
                          const Text("Status: "),
                          DropdownButton<String>(
                            value: statusValue,
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.black26,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                statusValue = newValue!;
                                observation['status'] = statusValue;
                              });
                            },
                            items: <String>['Observe', 'Release', 'Catch']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),)
                        ],
                      )
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    child: Text("Upload"),
                    onPressed: () async {
                      String filePath = 'images/${user!.uid}/${DateTime.now()}.png';

                      TaskSnapshot snapshot = await _storage.ref().child(filePath).putFile(widget.file);
                      if(snapshot.state == TaskState.success) {
                        final String downloadUrl = await snapshot.ref.getDownloadURL();
                        this.observation['uid'] = user.uid;
                        this.observation['url'] = downloadUrl;

                        await DatabaseService(uid: user.uid).addObservation(this.observation);

                        final snackBar = SnackBar(content: Text('Success'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        print('Error from image repo ${snapshot.state.toString()}');
                        throw ('This file is not an image');
                      }
                    },
                  ),
                ],
              )
          )
      ),
    );
  }

  // A method that launches the UploadClassification screen and awaits the result from
  // Navigator.pop.
  void _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          UploadClassification(key: UniqueKey(), imageFile: widget.file)),
    );

    // After the UploadClassification Screen returns a result, change text of TextButton
    setState((){
      _imageListText = result;
      observation['name'] = result;
    });
  }
}