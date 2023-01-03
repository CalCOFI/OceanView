import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/*
  File for saving constants that will be used in different files
 */

const textInputDecoration = InputDecoration(
  hintText: 'Email',
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 2.0)),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.pink, width: 2.0)),
);

const topBarColor = Colors.lightBlueAccent;
Color bottomBarColor = Colors.teal.shade100;

BoxDecoration blueBoxDecoration = BoxDecoration(
  gradient: LinearGradient(
      colors: [Colors.blue.shade100, Colors.teal.shade50, Colors.blue.shade50]),
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
const String NAME = 'None';
const String LATINNAME = 'Unknown';
const String STATUS = 'Observe';
const double LENGTH = 0.0;
const double WEIGHT = 0.0;
const String TIME = 'None';
const double LATITUDE = 0;
const double LONGITUDE = 0;
const String CONFIDENTIALITY = 'Share with community';
const int CONFIDENCE = 2;
const String URL = 'None';
const String STOPWATCHSTART = 'None';
Map<int, String> CONFIDENCE_MAP = {
  1: 'Low',
  2: 'Medium',
  3: 'High',
};

Map<String, String> descriptionMap = {'length': 'longer', 'weight': 'heavier'};

// Theme for all pages
Map<String, Color> themeMap = {
  'scaffold_appBar_color': Colors.lightBlueAccent,
  'elevated_button_color': Colors.lightBlueAccent,
};
