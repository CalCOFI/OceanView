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

Map<String, Color> MPA_type_color = {
  'SMCA': Colors.blue,
  'SMR': Colors.red,
  'SMCA (No-Take)': Colors.purple,
  'Special Closure': Colors.purpleAccent,
  'FMR': Colors.red[200]!,
  'SMP': Colors.yellow,
  'SMRMA': Colors.green,
  'FMCA': Colors.blue[200]!
};