import 'package:flutter/material.dart';
import 'package:ocean_view/models/aphia_record.dart';

enum Kingdoms { Animalia, Plantae }

class AphiaParseDemo extends StatefulWidget {
  final String svalue;
  final Kingdoms which;

  AphiaParseDemo({required this.svalue, required this.which}) : super();

  @override
  _AphiaParseDemoState createState() => _AphiaParseDemoState();
}

class _AphiaParseDemoState extends State<AphiaParseDemo> {
  _AphiaParseDemoState();
  String svalue = '';
  String _baseURL =
      'https://www.marinespecies.org/rest/AphiaRecordsByVernacular/';
  String _vernacURL =
      'https://www.marinespecies.org/rest/AphiaVernacularsByAphiaID/';
  String _endURL = '?like=true&offset=1';
  String _URL = '';
  String _URLv = '';
  var _record = <AphiaRecord>[];
  var _vernacular = <AphiaVernacular>[];
  bool _loading = true;

  //bool _loading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      //_URL = _baseURL + widget.svalue + _endURL;
      _loading = true;
      AphiaSearch.getRecord(widget.svalue, widget.which).then((record) {
        setState(() {
          _record = record;
          _loading = false;
        });
      });
    });
    print('Number of records: ${_record.length}');
  }

  @override
  Widget build(BuildContext context) {
    print(widget.svalue);
    return Scaffold(
      appBar: AppBar(
        title: Text(_loading ? 'Loading...' : 'Species Lookup from WoRMS'),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: _record == null
            ? Text(
                'No items found',
              )
            : ListView.builder(
                //itemCount: null == _fish ? 0 : _fish.length,
                itemCount: null == _record ? 0 : _record.length,
                itemBuilder: (context, index) {
                  AphiaRecord record = _record[index];
                  return ListTile(
                    title: Text(record.vname ?? ''),
                    subtitle: Text(record.scientificName ?? ''),
                    onTap: () {
                      print('Selected ${record.scientificName}');
                      Navigator.pop(context, record);
                    },
                  );
                }),
      ),
    );
  }
}
