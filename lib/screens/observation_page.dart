import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_view/shared/constants.dart';
import 'package:ocean_view/src/extract_exif.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:ocean_view/services/local_store.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/screens/upload/upload_classification.dart';
import 'package:ocean_view/services/database.dart';

/*
  Page for editing all the information of one specific observation

  It loads the meta data of the image (shot time, location) when building the widget.
  Image classification button navigates to the page for recommending species name
  by utilizing VisionAPI.
  Other information, such as size and status can be typed or selected based on
  data formats.
 */

class ObservationPage extends StatefulWidget {
  final File file;
  final String mode;
  Observation? observation;
  PhotoMeta? photoMeta;
  int? index;    // Index for observation in session
  ObservationPage({required this.file, required this.mode, this.observation, this.photoMeta, this.index});

  @override
  _ObservationPageState createState() => _ObservationPageState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _ObservationPageState extends State<ObservationPage> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  late TextEditingController _nameController;

  // From previous widget
  late Image _image;
  late File _imageFile;
  late String mode;           // single, session, me
  late String buttonName;     // Upload, Add    , Update
  String statusValue = STATUS;
  String confidentialityValue = CONFIDENTIALITY;
  Observation? observation;
  DateTime? selectedDate;
  int index = 0;


  @override
  void initState() {
    super.initState();

    this._imageFile = widget.file;
    this._image = new Image.file(
      widget.file,
      width: 250,
      height: 100,
      fit: BoxFit.contain,
    );
    this.mode = widget.mode;
    this.observation = (widget.observation!=null)? widget.observation:Observation();
    this._nameController = (this.observation!.name!=null)
      ? TextEditingController(text: this.observation!.name)
      : TextEditingController(text: '');
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
    this.index = ((widget.index==null)? 0 : widget.index)!;

    // Only load meta data when adding observation
    if (this.mode == 'single' || this.mode == 'session') {
      if (widget.photoMeta!.time == 0) {
        selectedDate = DateTime.now();
        this.observation!.time = selectedDate;
      } else {
        selectedDate = widget.photoMeta!.time;
        this.observation!.time = selectedDate;
      }

      if (widget.photoMeta!.location == 0) {
        this.observation!.location = LatLng(0, 0);
      } else {
        this.observation!.location = widget.photoMeta!.location.getLatLng();
      }

    } else {
      selectedDate = this.observation!.time;
      statusValue = this.observation!.status!;
      confidentialityValue = this.observation!.confidentiality!;
    }
  }

  // Select date
  Future<Null> _selectDate(BuildContext context) async {
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

  // print location
  String _printLocation(LatLng position) {
    String lat = position.latitude.toStringAsFixed(2);
    String lng = position.longitude.toStringAsFixed(2);
    return "(${lat},${lng})";
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
                          initialValue: (this.observation!.length==null)
                              ? ''
                              : this.observation!.length.toString(),
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
                        child: TextFormField(
                          initialValue: (this.observation!.weight == null)
                            ? ''
                            : this.observation!.weight.toString(),
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
                    children: <Widget>[
                      const Text('Location: '),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _printLocation(this.observation!.location!),
                          textAlign: TextAlign.center,
                        ),
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
              Padding(
                  padding: EdgeInsets.all(4),
                  child: Row(
                    children: [
                      const Text("Confidentiality: "),
                      const SizedBox(width: 10.0,),
                      Container(
                          alignment: Alignment.center,
                          child: DropdownButton<String>(
                            value: confidentialityValue,
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
                                confidentialityValue = newValue!;
                                this.observation!.confidentiality =
                                    confidentialityValue;
                              });
                            },
                            items: <String>['Share with scientists', 'Keep private']
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
                  } else if (this.mode == 'me') {
                    print('Update');

                    String state = await DatabaseService(uid: user!.uid).updateObservation(this.observation!);

                    if (state == "success"){
                      final snackBar = SnackBar(content: Text('Success'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      print('Error from image repo ${state.toString()}');
                      throw ('This file is not an image');
                    }

                    // Back to previous page
                    Navigator.pop(context);
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