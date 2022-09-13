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
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Welcome'),
          centerTitle: true,
          backgroundColor: themeMap['scaffold_appBar_color'],
          elevation: 0.0,
          actions: <Widget>[
            TextButton.icon(
                onPressed: () async {
                  await _auth.signOut();
                },
                icon: Icon(Icons.person),
                label: Text('Log out'))
          ]),
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
                          GestureDetector(
                            child: Text(
                                'The California Cooperative Oceanic Fisheries Investigations (CalCOFI)',
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
                          Text(
                              'is a marine ecosystem observing and research program off the coast of California that simultaneously collects biological, chemical, and physical observations and specimens across the California Current System (CCS) to inform research and management. CalCOFI has been sampling since 1949 and is one of the world’s longest running, integrated ocean ecosystem sampling programs. While originally focused on questions related to sustainable fisheries, CalCOFI observations also inform questions related to integrated ocean management, renewable energy, offshore aquaculture, tourism, as well as marine spatial planning, all in the context of climate change. The CalCOFI community is a diverse network of people within various local, state, federal, and international organizations, who come together to share information, exchange ideas, and develop priorities for long-term monitoring in support of ecosystem and marine resource management and resilience in the California Current System.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ))
                        ],
                      ),
                    )),
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
                      'We hope this app will inspire you to take part in and contribute to ocean observing, marine research, and to become more aware of marine conservation. The goals of this application are to augment existing long term ocean observations off the coast of California by engaging local people in the collection of marine life data. This application is a participatory citizen science application that allows recreational ocean users to upload detailed information on marine species they caught or observed, including the image of the organism, the species name, time, and location. The data collected will be used to support research and management off the coast of California.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      )),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
