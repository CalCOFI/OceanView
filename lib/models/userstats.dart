import 'dart:io';
import 'package:flutter/material.dart';

class UserStats with ChangeNotifier {
  String? documentID;
  String? uid;
  String? name;
  String? email;
  String? share;
  int? numobs;

  UserStats(
      {this.documentID,
      this.uid,
      this.name,
      this.email,
      this.share,
      this.numobs});
}
