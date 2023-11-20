import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum Kingdoms { Animalia, Plantae }

List<AphiaRecord> AphiaFromJson(String str) => List<AphiaRecord>.from(
    json.decode(str).map((x) => AphiaRecord.fromJson(x)));

List<AphiaVernacular> VernacularFromJson(String str) =>
    List<AphiaVernacular>.from(
        json.decode(str).map((x) => AphiaVernacular.fromJson(x)));

class AphiaRecord {
  String scientificName = '';
  int aphiaID = 0;
  String taxonClass = '';
  String taxonKingdom = '';
  String langCode = '';
  String vname = '';

  AphiaRecord(
      {this.scientificName = '',
      this.aphiaID = 0,
      this.taxonClass = '',
      this.taxonKingdom = '',
      this.langCode = '',
      this.vname = ''});

  AphiaRecord.fromJson(Map<String, dynamic> json) {
    scientificName = json['valid_name'] ?? '';
    aphiaID = json['valid_AphiaID'] ?? 0;
    taxonClass = json['class'] ?? '';
    taxonKingdom = json['kingdom'] ?? '';
    langCode = '';
    vname = ' ';
  }
}

class AphiaVernacular {
  String vname = '';
  String langCode = '';

  AphiaVernacular({
    this.langCode = '',
    this.vname = '',
  });

  AphiaVernacular.fromJson(Map<String, dynamic> json) {
    vname = json['vernacular'] ?? '';
    langCode = json['language_code'] ?? '';
  }
}

class AphiaSearch {
  static Future<List<AphiaRecord>> getRecord(svalue, which) async {
    String _baseURL =
        'https://www.marinespecies.org/rest/AphiaRecordsByVernacular/';
    String _vernacURL =
        'https://www.marinespecies.org/rest/AphiaVernacularsByAphiaID/';
    String _endURL = '?like=true&offset=1';
    String searchURL = '';
    String vsearchURL = '';
    String _kingdom = 'Animalia';
    bool timedout = false;
    AphiaRecord nullv = AphiaRecord();
    nullv.vname = 'Not found';
    nullv.scientificName = 'Not found';
    nullv.langCode = 'eng';
    nullv.taxonClass = 'Not found';
    nullv.taxonKingdom = 'Not found';
    List<AphiaRecord> nullvlist = List.filled(1, nullv);
    searchURL = _baseURL + svalue + _endURL;
    _kingdom = which == Kingdoms.Plantae ? 'Plantae' : 'Animalia';
    print('Searching for ' + _kingdom);
    try {
      print('###' + searchURL);
      final response = await http
          .get(Uri.parse(searchURL))
          .timeout(const Duration(seconds: 30));
      if (200 == response.statusCode) {
        print('*** Got a response for record ***');
        final List<AphiaRecord> record = AphiaFromJson(response.body);
        //print(response.body.toString());
        // Now we have a list of records.  Let's loop through it to get vernacular names
        for (var ii = 0; ii < record.length; ii++) {
          print('####### Kingdom is ' + record[ii].taxonKingdom);
          if (record[ii].taxonKingdom != _kingdom) {
            record[ii].scientificName = '';
            continue;
          }
          vsearchURL = _vernacURL + record[ii].aphiaID.toString();
          print('??? ' + vsearchURL);
          final response_v = await http
              .get(Uri.parse(vsearchURL))
              .timeout(const Duration(seconds: 30));
          if (200 == response_v.statusCode) {
            print('Got good response');
            final List<AphiaVernacular> vrecord =
                VernacularFromJson(response_v.body);
            // Find first english vernacular containing search string
            record[ii].langCode = vrecord
                .firstWhere(
                    (element) =>
                        (element.langCode == 'eng') &&
                        element.vname.toLowerCase().contains(svalue),
                    orElse: () => AphiaVernacular())
                .langCode;
            record[ii].vname = vrecord
                .firstWhere(
                    (element) =>
                        (element.langCode == 'eng') &&
                        element.vname.toLowerCase().contains(svalue),
                    orElse: () => AphiaVernacular())
                .vname;
          } else {
            print('&&&&&& Bad status code ' + response_v.statusCode.toString());
            record[ii].vname = '';
            record[ii].langCode = '';
          }
        }
        return record
            .where((element) =>
                element.vname != '' &&
                element.vname != null &&
                element.scientificName != '')
            .toList();
      } else {
        print('Got bad response');
        return List<AphiaRecord>.empty();
      }
    } on TimeoutException {
      nullvlist[0].vname = 'Text Search timed out';
      return nullvlist;
    }
  }

  static Future<List<AphiaVernacular>> getVernacular(searchURL) async {
    try {
      final response = await http.get(searchURL);
      if (200 == response.statusCode) {
        print('Got a response for vernacular');
        print(response.body);
        final List<AphiaVernacular> vernacular =
            VernacularFromJson(response.body);
        return vernacular;
      } else {
        print('Got bad response for vernacular');
        return List<AphiaVernacular>.empty();
      }
    } catch (e) {
      print('Something went wrong in vernacular $e');
      return List<AphiaVernacular>.empty();
    }
  }
}
