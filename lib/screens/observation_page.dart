import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_view/src/extract_exif.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:ocean_view/services/local_store.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/screens/upload/upload_classification.dart';
import 'package:ocean_view/services/database.dart';

// Define a custom Form widget.
class ObservationPage extends StatefulWidget {
  final File file;
  final String mode;
  Observation? observation;
  int? index;    // Index for observation in session
  ObservationPage({required this.file, required this.mode, this.observation, this.index});

  @override
  _ObservationPageState createState() => _ObservationPageState(this.file, this.mode, this.observation, this.index);
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _ObservationPageState extends State<ObservationPage> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final _nameController = TextEditingController();
  String statusValue = 'Observe';
  String _imageListText = "What did you see?";

  // From previous widget
  late Image _image;
  late File _imageFile;
  late String mode;           // single, session, me
  late String buttonName;     // Upload, Add    , Edit
  Observation? observation;
  DateTime? selectedDate;
  int index = 0;

  _ObservationPageState (File file, String mode, Observation? observation, int? index) {
    this._imageFile = file;
    this._image = new Image.file(
      file,
      width: 250,
      height: 180,
      fit: BoxFit.contain,
    );
    this.mode = mode;
    this.observation = (observation!=null)? observation:Observation();
    try {
      switch (this.mode) {
        case 'single': {
          this.buttonName = 'Upload';
        }
        break;
        case 'session': {
          this.buttonName = 'Add';
        }
        break;
        case 'me': {
          this.buttonName = 'Edit';
        }
        break;
        default: {
          throw new FormatException('Undefined mode');
        }
      }
    } catch (e) {
      print(e.toString());
    }

    this.index = (index==null)? 0 : index;
    if (this.observation!.time==null) {
      selectedDate = DateTime.now();
      this.observation!.time = selectedDate;
    } else {
      selectedDate = this.observation!.time;
    }

  }

  // Select date
  Future<Null> _selectDate(BuildContext context) async {
    /*
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate!,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        this.observation!.time = selectedDate;
      });
    }
     */
    final DateTime? picked = await DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        minTime: DateTime(2000, 1, 1),
        maxTime: DateTime.now(), onChanged: (date) {
          print('change $date');
        }, onConfirm: (date) {
          print('confirm $date');
        }, currentTime: selectedDate!, locale: LocaleType.en);
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        this.observation!.time = selectedDate;
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User?>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Observation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
          child: Column(

            children: <Widget>[

              Padding(
                  padding: EdgeInsets.all(8),
                  child: _image
              ),
              Divider(
                color: Colors.black,
              ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              //   child: Card(
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       children: <Widget>[
              //         ListTile(
              //           leading: Icon(Icons.question_answer),
              //           title: Text(_imageListText),
              //           subtitle: Text('><'),
              //         ),
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.end,
              //           children: <Widget>[
              //             TextButton(
              //                 child: const Text('See suggestions'),
              //                 onPressed: () {
              //                   _navigateAndDisplaySelection(context);
              //                 }
              //             ),
              //             const SizedBox(width: 8),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.all(4),
                child: Row(
                  children: [
                    const Text('Name:'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        onChanged: (String value) => this.observation!.name=value,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _navigateAndDisplaySelection(context);
                        print(this.observation!.name);
                      },
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4),
                child: Row(
                    children: <Widget>[
                      const Text('Length: '),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          onChanged: (String value) => this.observation!.length=double.parse(value),
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
                padding: EdgeInsets.all(4),
                child: Row(
                    children: <Widget>[
                      const Text('Weight: '),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          textAlign: TextAlign.center,
                          onChanged: (String value) => this.observation!.weight=double.parse(value),
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
                padding: EdgeInsets.all(4),
                child: Row(
                    children: <Widget>[
                      const Text("Time: "),
                      const SizedBox(width: 10.0,),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                              "${DateFormat('yyyy-MM-dd kk:mm').format(selectedDate!.toLocal())}"
                          ),
                        )
                      ),
                      const SizedBox(width: 10.0),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: Icon(Icons.date_range),
                      ),
                    ]
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(4),
                  child: Row(
                    children: [
                      const Text("Status: "),
                      const SizedBox(width: 10.0,),
                      Container(
                        alignment: Alignment.center,
                        child: DropdownButton<String>(
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
                              this.observation!.status = statusValue;
                            });
                          },
                          items: <String>['Observe', 'Release', 'Catch']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      )
                    ],
                  )
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: Text(this.buttonName),
                onPressed: () async {

                  if (this.mode == 'single') {

                    TaskState state = await DatabaseService(uid: user!.uid).addObservation(this.observation!, widget.file);

                    if (state == TaskState.success){
                      final snackBar = SnackBar(content: Text('Success'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      print('Error from image repo ${state.toString()}');
                      throw ('This file is not an image');
                    }

                    // Back to previous page
                    Navigator.pop(context);

                  } else if (this.mode == 'session') {
                    print('Stopwatch: ${this.observation!.stopwatchStart}');
                    print('Add');

                    // Add image to local directory
                    await LocalStoreService().saveImage(context, _imageFile, '$index.png');

                    // Add observation to local directory
                    await LocalStoreService().saveObservation(this.observation!, '$index.txt');

                    Navigator.pop(context, [this.observation, this._image]);
                  } else {
                    print('Edit');
                  }

                },
              ),
            ],
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
      _nameController.text = result;
    });
  }

}