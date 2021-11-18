import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

Future<Map<String, dynamic>> getMPARegulations() async {
  final jsonText = await rootBundle
      .loadString('assets/jsons/mpa_regulations.json');

  Map<String, dynamic> regulations = jsonDecode(jsonText);

  return regulations;
}