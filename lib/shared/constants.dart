import 'package:flutter/material.dart';

/*
  File for saving constants that will be used in different files
 */

const textInputDecoration = InputDecoration(
  hintText: 'Email',
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2.0)
  ),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.pink, width: 2.0)
  ),
);

// Color for regions of MPA on GoogleMap, which is according to color on CDFW
Map<String, Color> MPA_type_color = {
  'SMR': Colors.red,
  'SMCA': Colors.blue,
  'SMCA (No-Take)': Colors.purple,
  'Special Closure': Colors.purpleAccent,
  'SMRMA': Colors.green,
  'FMR': Colors.red[200]!,
  'SMP': Colors.yellow,
  'FMCA': Colors.blue[200]!
};

// Corresponding images for each type of MPA
Image get_mpa_image(String path) {
  return Image.asset(
    path,
    width: 30,
    height: 30,
    fit: BoxFit.fitWidth,
  );
}

Map<String, List<Image>> MPA_type_icon = {
  'SMR': [
    get_mpa_image('assets/images/No_Fishing.png'),
    get_mpa_image('assets/images/No_Collecting.png'),
  ],
  'SMCA': [
    get_mpa_image('assets/images/Fishing_SomeRestrictions.png'),
    get_mpa_image('assets/images/Collecting_SomeRestrictions.png'),
  ],
  'SMCA (No-Take)': [
    get_mpa_image('assets/images/No_Fishing.png'),
    get_mpa_image('assets/images/No_Collecting.png'),
  ],
  'Special Closure': [
    get_mpa_image('assets/images/Entry_SomeRestrictions.png'),
  ],
  'SMRMA': [
    get_mpa_image('assets/images/WaterfowlHunting_OK.png'),
  ],
  'FMR': [
    get_mpa_image('assets/images/No_Fishing.png'),
    get_mpa_image('assets/images/No_Collecting.png'),
  ],
  'SMP': [
    get_mpa_image('assets/images/No_Fishing.png'),
    get_mpa_image('assets/images/No_Collecting.png'),
  ],
  'FMCA': [
    get_mpa_image('assets/images/No_Fishing.png'),
    get_mpa_image('assets/images/No_Collecting.png'),
  ],
};

// Default value of properties of observations
String STATUS = 'Observe';
String CONFIDENTIALITY = 'Share with scientists';

Map<String, String> descriptionMap = {
  'length': 'longer',
  'weight': 'heavier'
};