import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_view/models/userstats.dart';
import 'package:ocean_view/shared/constants.dart';
import 'package:ocean_view/src/extract_exif.dart';
import 'package:ocean_view/src/aphia_parse.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:cross_file/cross_file.dart';

import 'package:ocean_view/services/local_store.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/screens/upload/upload_classification.dart';
import 'package:ocean_view/services/database.dart';

String namehelp =
    'If you think you have a clear, identifiable image of your observation, use image search.  Otherwise, you can type in your guess for a full or partial name and use text search.  This will perform a search of the World Register of Marine Species (https://www.marinespecies.org) database and display a list of possible matches.';

// Define the help dialog popup
Widget _buildPopupDialog(BuildContext context, String wtitle, String msg) {
  return new AlertDialog(
    title: Text(wtitle),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(msg),
      ],
    ),
    actions: <Widget>[
      new ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Close'),
      ),
    ],
  );
}

// Define a custom Form widget.

class ObservationPage extends StatefulWidget {
  final File file;
  final String mode;
  Observation? observation;
  PhotoMeta? photoMeta;
  int? index; // Index for observation in session
  ObservationPage(
      {required this.file,
      required this.mode,
      this.observation,
      this.photoMeta,
      this.index});

  @override
  _ObservationPageState createState() => _ObservationPageState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _ObservationPageState extends State<ObservationPage> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  late TextEditingController _nameController;
  late TextEditingController _latinNameController;

  // From previous widget
  late Image _image;
  late File _imageFile;
  late String mode; // single, session, me
  late String buttonName; // Upload, Add    , Update

  String _statusValue = STATUS;
  int _confidence = CONFIDENCE;
  String _confidentialityValue = CONFIDENTIALITY;
  String _imageListText = "What did you see?";
  Observation? observation;
  UserStats? uStats;
  DateTime? selectedDate;
  int index = 0;

  @override
  void initState() {
    super.initState();

    this._imageFile = widget.file;
    this._image = new Image.file(
      File(_imageFile.path),
      width: 250,
      height: 180,
      fit: BoxFit.contain,
    );
    this.mode = widget.mode;
    this.observation =
        (widget.observation != null) ? widget.observation : Observation();
    this._nameController = (this.observation!.name != null)
        ? TextEditingController(text: this.observation!.name)
        : TextEditingController(text: '');
    this._latinNameController = (this.observation!.latinName != null)
        ? TextEditingController(text: this.observation!.latinName)
        : TextEditingController(text: '');
    this.mode = mode;
    this.observation = (observation != null) ? observation : Observation();
    this.uStats = (uStats != null) ? uStats : UserStats();
    try {
      switch (this.mode) {
        case 'single':
          {
            this.buttonName = 'Upload';
          }
          break;
        case 'session':
          {
            this.buttonName = 'Add';
          }
          break;
        case 'me':
          {
            this.buttonName = 'Edit';
          }
          break;
        default:
          {
            throw new FormatException('Undefined mode');
          }
      }
    } catch (e) {
      print(e.toString());
    }
    this.index = ((widget.index == null) ? 0 : widget.index)!;

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
      _confidence = this.observation!.confidence!;
      _statusValue = this.observation!.status!;
      _confidentialityValue = this.observation!.confidentiality!;
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
    _latinNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final userSt = Provider.of<UserStats>(context);
    print('FFFFF FOUND USER ${userSt.name} FFFFF');
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
              Padding(padding: EdgeInsets.all(8), child: _image),
              Divider(
                color: Colors.black,
              ),
              Padding(
                padding: EdgeInsets.all(1),
                child: Row(
                  // Row for Name entry
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text('Name:'),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () => {
                                      _nameController.clear(),
                                      _latinNameController.clear()
                                    }),
                          ),
                          textAlign: TextAlign.center,
                          onChanged: (String value) => {
                                this.observation!.name = value,
                                _latinNameController.clear(),
                              }),
                    ),
                    IconButton(
                        iconSize: 20,
                        onPressed: () {
                          _navigateAndDisplaySelection(context);
                          print(this.observation!.name);
                        },
                        // icon: Icon(Icons.arrow_forward_ios),
                        icon: Icon(Icons.image_search)),
                    IconButton(
                        iconSize: 20,
                        onPressed: () {
                          _navigateAndTextSearch(context);
                        },
                        icon: Icon(Icons.search)),
                    IconButton(
                        iconSize: 20,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                _buildPopupDialog(
                                    context, 'Search Options', namehelp),
                          );
                        },
                        icon: Icon(Icons.help_rounded)),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(4),
                  child: Row(
                    // Row for Species entry
                    children: [
                      const Text('Species:'),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          // initialValue: (this.observation!.latinName==null)
                          //     ? ''
                          //     : this.observation!.latinName,
                          controller: _latinNameController,
                          textAlign: TextAlign.center,
                          enabled: false,
                          onChanged: (String value) =>
                              this.observation!.latinName = value,
                        ),
                      ),
                    ],
                  )),
              Padding(
                padding: EdgeInsets.all(4),
                child: Row(children: <Widget>[
                  // Row for Length entry
                  const Text('Length: '),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: (this.observation!.length == null)
                          ? ''
                          : this.observation!.length.toString(),
                      textAlign: TextAlign.center,
                      onChanged: (String value) =>
                          this.observation!.length = double.parse(value),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text("inches"),
                  SizedBox(width: 10),
                  const Text('Weight: '),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: (this.observation!.weight == null)
                          ? ''
                          : this.observation!.weight.toString(),
                      textAlign: TextAlign.center,
                      onChanged: (String value) =>
                          this.observation!.weight = double.parse(value),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text("lb"),
                ]),
              ),
              Padding(
                padding: EdgeInsets.all(4),
                child: Row(children: <Widget>[
                  //Row for Time entry
                  const Text("Time: "),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.center,
                    child: Text(
                        "${DateFormat('yyyy-MM-dd kk:mm').format(selectedDate!.toLocal())}"),
                  )),
                  const SizedBox(width: 10.0),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Icon(Icons.date_range),
                  ),
                ]),
              ),
              Padding(
                padding: EdgeInsets.all(4),
                child: Row(children: <Widget>[
                  // Row for Location entry
                  const Text('Location: '),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _printLocation(this.observation!.location!),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
              ),
              Divider(
                color: Colors.black,
              ),
              Padding(
                  padding: EdgeInsets.all(2),
                  child: Row(
                    children: [
                      SizedBox(width: 170, height: 2),
                      Text('Low', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 10, height: 2),
                      Text('Medium', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 10, height: 2),
                      Text('High', style: TextStyle(fontSize: 12))
                    ],
                  )),
              Padding(
                padding: EdgeInsets.all(2),
                child: Row(
                  children: [
                    const Text('Confidence level:'),
                    IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => _buildPopupDialog(
                                context,
                                'Confidence Level',
                                'Specify how confident you are in your identification of this species.  1 is least confident, 3 is most confident.'),
                          );
                        },
                        icon: Icon(Icons.help_rounded)),
                    Radio(
                      value: 1,
                      groupValue: _confidence,
                      onChanged: (val) {
                        setState(() {
                          _confidence = 1;
                          this.observation!.confidence = 1;
                        });
                      },
                    ),
                    //const Text('1'),
                    Radio(
                      value: 2,
                      groupValue: _confidence,
                      onChanged: (val) {
                        setState(() {
                          _confidence = 2;
                          this.observation!.confidence = 2;
                        });
                      },
                    ),
                    //const Text('2'),
                    Radio(
                      value: 3,
                      groupValue: _confidence,
                      onChanged: (val) {
                        setState(() {
                          _confidence = 3;
                          this.observation!.confidence = 3;
                        });
                      },
                    ),
                    //const Text('3'),
                  ],
                ),
              ),
              Divider(
                color: Colors.black,
              ),
              Padding(
                  padding: EdgeInsets.all(2),
                  child: Row(
                    // Row for Status Entry
                    children: [
                      const Text("Status: "),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Container(
                          alignment: Alignment.center,
                          child: DropdownButton<String>(
                            value: _statusValue,
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
                                _statusValue = newValue!;
                                this.observation!.status = _statusValue;
                              });
                            },
                            items: <String>['Observe', 'Release', 'Catch']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ))
                    ],
                  )),
              Divider(
                color: Colors.black,
              ),
              Padding(
                  padding: EdgeInsets.all(4),
                  child: Row(
                    children: [
                      const Text("Confidentiality: "),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Container(
                          alignment: Alignment.center,
                          child: DropdownButton<String>(
                            value: _confidentialityValue,
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
                                _confidentialityValue = newValue!;
                                this.observation!.confidentiality =
                                    _confidentialityValue;
                              });
                            },
                            items: <String>[
                              'Share with community',
                              'Keep private'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ))
                    ],
                  )),
              const SizedBox(height: 10),
              ElevatedButton(
                  child: Text(this.buttonName),
                  onPressed: () async {
                    this.observation!.name = _nameController.text;
                    this.observation!.latinName = _latinNameController.text;
                    if (this.mode == 'single') {
                      TaskState state = await DatabaseService(uid: user.uid)
                          .addObservation(
                              this.observation!, File(widget.file.path));

                      if (state == TaskState.success) {
                        userSt.numobs = userSt.numobs! + 1;
                        print('0000 NUMOBS IS ${userSt.numobs} 0000');
                        await DatabaseService(uid: user.uid)
                            .updateUserStats(userSt);
                        final snackBar = SnackBar(content: Text('Success'));
                        //userSt?.numobs = userSt.numobs! + 1;
                        //DatabaseService(uid: user.uid)
                        //.updateUserStats(userSt as UserStats);
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
                      await LocalStoreService().saveImage(
                          context, File(_imageFile.path), '$index.png');

                      // Add observation to local directory
                      await LocalStoreService()
                          .saveObservation(this.observation!, '$index.txt');

                      Navigator.pop(context, [this.observation, this._image]);
                    } else if (this.mode == 'me') {
                      print('Update');
                      String state = await DatabaseService(uid: user!.uid)
                          .updateObservation(this.observation!);

                      if (state == "success") {
                        final snackBar = SnackBar(content: Text('Success'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        print('Error from image repo ${state.toString()}');
                        throw ('This file is not an image');
                      }

                      // Back to previous page
                      Navigator.pop(context);
                    }
                  }),
            ],
          )),
    );
  }

  // A method that launches the UploadClassification screen and awaits the result from
  // Navigator.pop.
  void _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UploadClassification(
              key: UniqueKey(), imageFile: File(widget.file.path))),
    );

    // After the UploadClassification Screen returns a result, change text of TextButton
    if (result != null) {
      setState(() {
        _nameController.text = result.preferredCommonName;
        _latinNameController.text = result.name;
      });
    }
  }

  void _navigateAndTextSearch(BuildContext context) async {
    // Same as above, except it returns result of text search
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AphiaParseDemo(
            svalue: _nameController.text.toLowerCase(),
            which: Kingdoms.Animalia,
          ),
        ));
    setState(() {
      _nameController.text = result.vname;
      _latinNameController.text = result.scientificName;
    });
  }
}
