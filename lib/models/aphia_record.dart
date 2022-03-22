import "dart:convert";
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
    scientificName = json['valid_name'];
    aphiaID = json['valid_AphiaID'];
    taxonClass = json['class'];
    taxonKingdom = json['kingdom'];
    langCode = ' ';
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
    vname = json['vernacular'];
    langCode = json['language_code'];
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
    AphiaRecord goodv = AphiaRecord();
    searchURL = _baseURL + svalue + _endURL;
    _kingdom = which == Kingdoms.Plantae ? 'Plantae' : 'Animalia';
    print('Searching for ' + _kingdom);
    try {
      print('###' + searchURL);
      final response = await http.get(Uri.parse(searchURL));
      if (200 == response.statusCode) {
        print('*** Got a response for record ***');
        final List<AphiaRecord> record = AphiaFromJson(response.body);
        // Now we have a list of records.  Let's loop through it to get vernacular names
        for (var ii = 0; ii < record.length; ii++) {
          print('####### Kingdom is ' + record[ii].taxonKingdom);
          if (record[ii].taxonKingdom != _kingdom) {
            record[ii].scientificName = '';
            continue;
          }
          vsearchURL = _vernacURL + record[ii].aphiaID.toString();
          print('??? ' + vsearchURL);
          final response_v = await http.get(Uri.parse(vsearchURL));
          if (200 == response_v.statusCode) {
            final List<AphiaVernacular> vrecord =
                VernacularFromJson(response_v.body);
            // Find first english vernacular containing search string
            record[ii].langCode = vrecord
                .firstWhere(
                    (element) =>
                        element.langCode == 'eng' &&
                        element.vname.contains(svalue),
                    orElse: () => AphiaVernacular())
                .langCode;
            record[ii].vname = vrecord
                .firstWhere(
                    (element) =>
                        element.langCode == 'eng' &&
                        element.vname.contains(svalue),
                    orElse: () => AphiaVernacular())
                .vname;
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
    } catch (e) {
      print('Something went wrong $e');
      return List<AphiaRecord>.empty();
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
