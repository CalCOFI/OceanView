import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:ocean_view/models/picture.dart';
import 'package:ocean_view/providers/pictures.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStoreService {
  late Directory appDir;

  // Save Image
  Future saveImage(BuildContext context, File imageFile, String fileName) async {
    appDir = await getApplicationDocumentsDirectory();

    print('Save image $imageFile in ${appDir.path}/$fileName');

    final savedImage = await imageFile.copy('${appDir.path}/$fileName');
    var _imageToStore = Picture(picName: savedImage);
    Provider.of<Pictures>(context, listen: false).storeImage(_imageToStore);
  }

  // Save Observation
  Future saveObservation(Observation observation, String fileName) async {
    final prefs = await SharedPreferences.getInstance();

    // TODO: save observation in local storage
    //   idea: observation -> json -> String -> txt file
  }


}