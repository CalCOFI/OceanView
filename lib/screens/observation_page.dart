import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_view/models/userstats.dart';
import 'package:ocean_view/shared/constants.dart';
import 'package:ocean_view/shared/custom_widgets.dart';
import 'package:ocean_view/src/extract_exif.dart';
import 'package:ocean_view/src/aphia_parse.dart';
import 'package:provider/provider.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as DP;

import 'package:ocean_view/services/local_store.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/screens/upload/upload_classification.dart';
import 'package:ocean_view/services/database.dart';

String nameHelp =
    'If you think you have a clear, identifiable image of your observation, use image search.  Otherwise, you can type in your guess for a full or partial name and use text search.  This will perform a search of the World Register of Marine Species (https://www.marinespecies.org) database and display a list of possible matches.';

String confHelp =
    'You can change the confidentiality of your observations by navigating to your user profile page, clicking "Update Profile", and choosing Yes or No for the Share option.  Changes to this setting are not retroactive. Previously stored observations will retain the setting they were originally shared with.';

String snameHelp =
    'Please specify a common name for the observed species before saving your observation.  You may do this by using the image search, or by typing a guess into the "Name" field and doing a text search.  If you do not wish to do a search, or if your search returns no results, you may still save the observation with your guess; however, the species name will not be filled in, and the confidence level for your search will automatically be set to Null.';

String speciesHelp =
    'You have not specified the latin Species Name for your observation.  You may do this You may do this by using the image search, or by typing a guess into the "Name" field and doing a text search.  If you do not wish to do a search, or if your search returns no results, you may still save the observation with your guess; however, the species name will not be filled in, and the confidence level for your search will automatically be set to Null.  Do you wish to continue without searching?';

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

// dialog is shown when name is empty and upload button is pressed
Widget _twoOptionsDialog(BuildContext context, String wtitle, String msg,
    _ObservationPageState mystate) {
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
        child: const Text('No'),
      ),
      new ElevatedButton(
        onPressed: () {
          mystate._confidence = 0;
          mystate.doSave = true;
          Navigator.of(context).pop();
        },
        child: const Text('Yes'),
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
  ObservationPage({
    required this.file,
    required this.mode,
    this.observation,
    this.photoMeta,
    this.index,
  });

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

  int _statusValue = STATUS; // Now an integer
  int _confidence = CONFIDENCE;
  Observation? observation;
  UserStats? uStats;
  DateTime? selectedDate;
  int index = 0;
  bool doSave = true;

  Future<void> _loadMetaData() async {
    if (widget.photoMeta == null ||
        widget.photoMeta!.location.latLng == LatLng(0, 0)) {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        this.observation!.location =
            LatLng(position.latitude, position.longitude);
      });
    } else {
      this.observation!.location = widget.photoMeta!.location.getLatLng();
    }
  }

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
      if (widget.photoMeta == null || widget.photoMeta!.time == 0) {
        selectedDate = DateTime.now();
        this.observation!.time = selectedDate;
      } else {
        selectedDate = widget.photoMeta!.time;
        this.observation!.time = selectedDate;
      }
      _loadMetaData();
    } else {
      selectedDate = this.observation!.time;
      _confidence = this.observation!.confidence as int;
      _statusValue = this.observation!.status as int;
    }
  }

  // Select date
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await DP.DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        minTime: DateTime(2000, 1, 1),
        maxTime: DateTime.now(), onChanged: (date) {
      print('change $date');
    }, onConfirm: (date) {
      print('confirm $date');
    }, currentTime: selectedDate!, locale: DP.LocaleType.en);
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        this.observation!.time = selectedDate;
      });
    }
  }

  // print location
  String _printLocation(LatLng? position) {
    if (position == null) {
      return "(1,1)";
    } else {
      String lat = position.latitude.toStringAsFixed(6);
      String lng = position.longitude.toStringAsFixed(6);
      return "(${lat},${lng})";
    }
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
    this.observation!.confidentiality = (userSt.share == 'Y')
        ? CONFIDENTIALITY
        : CONFIDENTIALITY_MAP.keys.firstWhere(
            (s) => CONFIDENTIALITY_MAP[s] == 'Do not Share',
            orElse: () => 0);
    ;

    Future<bool> onWillPop() async {
      final shouldPop = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you want to leave without saving?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: topBarColor,
          title: Text('Observation'),
          centerTitle: true,
        ),
        body: Container(
          decoration: blueBoxDecoration,
          child: Stack(
            children: [
              CustomPainterWidgets.buildTopShape(),
              SingleChildScrollView(
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
                                  onFieldSubmitted: (String value) => {
                                        _nameController.text = value,
                                      },
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
                                        _buildPopupDialog(context,
                                            'Search Options', nameHelp),
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
                              onChanged: (String value) => this
                                  .observation!
                                  .length = double.parse(value),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
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
                              onChanged: (String value) => this
                                  .observation!
                                  .weight = double.parse(value),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
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
                              _printLocation(this.observation!.location),
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
                                    builder: (BuildContext context) =>
                                        _buildPopupDialog(
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
                                    value: STATUS_MAP[_statusValue],
                                    icon: const Icon(Icons.arrow_downward),
                                    iconSize: 24,
                                    elevation: 16,
                                    style: const TextStyle(
                                        color: Colors.deepPurple),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.black26,
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _statusValue = STATUS_MAP.keys
                                            .firstWhere(
                                                (s) =>
                                                    STATUS_MAP[s] == newValue,
                                                orElse: () => 0);
                                        //this.observation!.status = _statusValue;
                                        this.observation!.status = _statusValue;
                                      });
                                    },
                                    items: <String>[
                                      'Observed',
                                      'Released',
                                      'Caught'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
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
                              IconButton(
                                  iconSize: 20,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          _buildPopupDialog(
                                              context,
                                              'Confidentiality Options',
                                              confHelp),
                                    );
                                  },
                                  icon: Icon(Icons.help_rounded)),
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  CONFIDENTIALITY_MAP[
                                      this.observation!.confidentiality]!,
                                  style:
                                      const TextStyle(color: Colors.deepPurple),
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          child: Text(this.buttonName),
                          onPressed: () async {
                            this.doSave = true;
                            if (_nameController.text.isEmpty) {
                              this.doSave = false;
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _buildPopupDialog(
                                        context, 'Name missing', snameHelp),
                              );
                            } else if (_latinNameController.text.isEmpty) {
                              this.doSave = false;
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _twoOptionsDialog(
                                        context,
                                        'Species Name missing',
                                        speciesHelp,
                                        this),
                              );
                            }
                            if (this.doSave) {
                              this.observation!.name = _nameController.text;
                              this.observation!.latinName =
                                  _latinNameController.text;
                              this.observation!.confidence = this._confidence;
                              if (this.mode == 'single') {
                                TaskState state =
                                    await DatabaseService(uid: user.uid)
                                        .addObservation(this.observation!,
                                            File(widget.file.path));

                                if (state == TaskState.success) {
                                  userSt.numobs = userSt.numobs! + 1;
                                  await DatabaseService(uid: user.uid)
                                      .updateUserStats(userSt);
                                  final snackBar =
                                      SnackBar(content: Text('Success'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                } else {
                                  print(
                                      'Error from image repo ${state.toString()}');
                                  throw ('This file is not an image');
                                }

                                // Back to previous page
                                Navigator.pop(context);
                              } else if (this.mode == 'session') {
                                print(
                                    'Stopwatch: ${this.observation!.stopwatchStart}');
                                print('Add');

                                // Add image to local directory
                                await LocalStoreService().saveImage(context,
                                    File(_imageFile.path), '$index.png');

                                // Add observation to local directory
                                await LocalStoreService().saveObservation(
                                    this.observation!, '$index.txt');

                                Navigator.pop(
                                    context, [this.observation, this._image]);
                              } else if (this.mode == 'me') {
                                print('Update');
                                String state =
                                    await DatabaseService(uid: user.uid)
                                        .updateObservation(this.observation!);

                                if (state == "success") {
                                  final snackBar =
                                      SnackBar(content: Text('Success'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                } else {
                                  print(
                                      'Error from image repo ${state.toString()}');
                                  throw ('This file is not an image');
                                }

                                // Back to two previous pages
                                // Since previous page won't update the information,
                                // second previous page would fetch new observation
                                // from cloud and get updated information
                                int count = 0;
                                Navigator.of(context)
                                    .popUntil((_) => count++ >= 2);
                                // Navigator.pop(context);
                              }
                            } else {
                              //Navigator.pop(context);
                              print('Do nothing');
                            }
                          }),
                    ],
                  )),
            ],
          ),
        ),
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
      if (result != null) {
        _nameController.text = result.vname;
        _latinNameController.text = result.scientificName;
      }
    });
  }
}
