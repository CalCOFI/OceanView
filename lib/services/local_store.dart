import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:cross_file/cross_file.dart';

import 'package:ocean_view/models/picture.dart';
import 'package:ocean_view/providers/pictures.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
  Class for accessing data in local device including save image, load image,
  save observation (Unfinished), load observation (Unfinished)
 */

class LocalStoreService {
  // Get local path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Save Image File
  Future saveImage(
      BuildContext context, File imageFile, String fileName) async {
    final path = await _localPath;

    print('Save image $imageFile in $path/$fileName');

    final savedImage = await imageFile.copy('$path/$fileName');
    var _imageToStore = Picture(picName: savedImage);
    Provider.of<Pictures>(context, listen: false).storeImage(_imageToStore);
  }

  // Save Observation
  Future saveObservation(Observation observation, String fileName) async {
    final prefs = await SharedPreferences.getInstance();

    // TODO: save observation in local storage
    //   idea: observation -> json -> String -> txt file
  }

  // Load Image File
  Future<File> loadImage(String fileName) async {
    final path = await _localPath;

    File imageFile = File('$path/$fileName');

    print('Load image $imageFile in $path/$fileName');

    return imageFile;
  }
}
