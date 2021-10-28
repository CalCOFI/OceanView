import 'package:flutter/material.dart';

class PinInformation {
  late String locationName;
  late String locationType;
  late List<dynamic> exceptions;

  PinInformation(String locationName, String locationType, List<dynamic> exceptions) {
    this.locationName = locationName;
    this.locationType = locationType;
    this.exceptions = exceptions;
  }
}