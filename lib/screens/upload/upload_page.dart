import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:ocean_view/screens/upload/upload_session.dart';

import 'package:image_picker/image_picker.dart';
import 'package:ocean_view/screens/observation_page.dart';
import 'package:ocean_view/src/extract_exif.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({required Key key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  XFile? _imageFile = null;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    _imageFile = await _picker.pickImage(source: source);

    if (_imageFile == null) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          child: Text(
            'Single Observation',
            textAlign: TextAlign.center,
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
              icon: Icon(Icons.photo_camera),
              onPressed: () async {
                await _pickImage(ImageSource.camera);
                if (_imageFile != null) {
                  // Extract exif data from image file
                  PhotoMeta photoMeta =
                      await extractLocationAndTime(File(_imageFile!.path));

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ObservationPage(
                              file: _imageFile!,
                              mode: 'single',
                              photoMeta: photoMeta)));
                }
              }),
          IconButton(
              icon: Icon(Icons.photo_library),
              onPressed: () async {
                await _pickImage(ImageSource.gallery);
                if (_imageFile != null) {
                  // Extract exif data from image file
                  PhotoMeta photoMeta =
                      await extractLocationAndTime(_imageFile! as File);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ObservationPage(
                              file: _imageFile!,
                              mode: 'single',
                              photoMeta: photoMeta)));
                }
              }),
        ]),
        Text('Record Session'),
        IconButton(
          icon: Icon(Icons.not_started_outlined),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => UploadSession())),
        ),
      ],
    ));
  }
}
