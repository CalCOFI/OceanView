import 'package:flutter/material.dart';

class PinInformation {
  late String locationName;
  late String locationType;
  late List<dynamic> exceptions;
  late String generalRegulation;

  PinInformation(String locationName, String locationType, List<dynamic> exceptions, String generalRegulation) {
    this.locationName = locationName;
    this.locationType = locationType;
    this.exceptions = exceptions;
    this.generalRegulation = generalRegulation;
  }
}