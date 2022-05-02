import 'dart:io';
import 'package:flutter/material.dart';

/*
  Implementation of picture as element in pictures
 */
class Picture with ChangeNotifier {
  final File picName;

  Picture({
    required this.picName,
  });
}