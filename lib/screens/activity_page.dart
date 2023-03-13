import 'package:flutter/material.dart';
import 'package:ocean_view/services/auth.dart';
import 'package:ocean_view/shared/constants.dart';
import 'package:ocean_view/shared/custom_widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';

/*
  Page for activity, not finished
 */

class ActivityPage extends StatefulWidget {
  const ActivityPage({required Key key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  //final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        centerTitle: true,
        backgroundColor: themeMap['scaffold_appBar_color'],
        elevation: 0.0,
      ),
      body: Container(
        child: Stack(children: [
          CustomPainterWidgets.buildTopShape(),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                ),
                Text(
                  'What is OceanView?',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                      'OceanView is a citizen science app for recording observations of marine species along the California coast. It is created and supported by the The California Cooperative Oceanic Fisheries Investigations (CalCOFI) program.  The goals of this application are to augment existing long term ocean observations by engaging local people in the collection of marine life data. This application is a participatory citizen science application that allows recreational ocean users to upload detailed information on marine species they caught or observed, including the image of the organism, the species name, time, and location. The data collected will be used to support research and management off the coast of California.  We hope this app will inspire you to take part in and contribute to ocean observing, marine research, and to become more aware of marine conservation.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      )),
                ),
                Text(
                  'What is CalCOFI?',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DefaultTextStyle(
                      style:
                          const TextStyle(fontSize: 18, color: Colors.black87),
                      child: Wrap(
                        children: [
                          Text(
                              'The California Cooperative Oceanic Fisheries Investigations (CalCOFI) program is a marine ecosystem observing and research program off the coast of California that simultaneously collects biological, chemical, and physical observations and specimens across the California Current System (CCS) to inform research and management. For more information, ',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              )),
                          GestureDetector(
                            child: Text('please visit our website',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.blue)),
                            onTap: () async {
                              try {
                                await launchUrlString('https://calcofi.org');
                              } catch (err) {
                                debugPrint('Something bad happened');
                              }
                            },
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
