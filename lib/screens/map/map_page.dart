// @ dart=2.9
import 'dart:math';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ocean_view/screens/map/regulation_page.dart';
import 'package:ocean_view/shared/constants.dart';

import 'package:ocean_view/src/mpa.dart' as mpa;
import 'package:geofencing/geofencing.dart';
import 'package:ocean_view/src/mpa_regulation.dart';
import 'package:ocean_view/src/pin_information.dart';
import '../../notification_library.dart' as notification;

class MapPage extends StatelessWidget{

  const MapPage({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    print("Build MapPage");
    return MaterialApp(
      initialRoute: notification.initialRoute,
      routes: <String, WidgetBuilder>{
        HomePage.routeName: (_) => HomePage(notification.notificationAppLaunchDetails),
        SecondPage.routeName: (_) => SecondPage(notification.selectedNotificationPayload)
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage(
      this.notificationAppLaunchDetails, {
        Key? key,
      }) : super(key: key);

  static const String routeName = '/homePage';

  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Geofencing members
  String geofenceState = 'N/A';
  List<String> registeredGeofences = [];
  ReceivePort port = ReceivePort();
  final List<GeofenceEvent> triggers = <GeofenceEvent>[
    GeofenceEvent.enter,
    GeofenceEvent.dwell,
    GeofenceEvent.exit
  ];
  final AndroidGeofencingSettings androidSettings = AndroidGeofencingSettings(
      initialTrigger: <GeofenceEvent>[
        GeofenceEvent.enter,
        GeofenceEvent.exit,
        GeofenceEvent.dwell
      ],
      loiteringDelay: 1000 * 60);

  // Google map members
  late GoogleMapController? mapController;

  final LatLng _center = LatLng(32.832809, -117.271271);
  LatLng _location = LatLng(0.0,0.0);

  final Map<String, Marker> _markers = {};
  final Map<String, Polygon> _polygons = {};
  final Map<String, Circle> _circles = {};

  // MPA members
  final List<String> _names = <String>[];
  final Map<String, LatLng> _centers = {};
  final Map<String, double> _radiuses = {};
  final Map<String, double> _distances = {};

  // Pin for showing MPA information
  double _pinPillPosition = -100;
  PinInformation pinInformation = PinInformation('None', 'None', [], 'None');

  // @override
  // void initState(){
  //   super.initState();
  //
  //   notification.requestPermissions();
  //   notification.configureDidReceiveLocalNotificationSubject(context);
  //   notification.configureSelectNotificationSubject(context);
  //
  //   IsolateNameServer.registerPortWithName(
  //       port.sendPort, 'geofencing_send_port');
  //   port.listen((dynamic data) {
  //     print('Event: $data');
  //     setState(() {
  //       geofenceState = data;
  //     });
  //   });
  //   //initPlatformState();
  // }

  @override
  void dispose() {
    notification.dispose();
    mapController = null;
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    print(position);
    _location = LatLng(position.latitude,position.longitude);
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {

    // Controller moves with current location
    mapController = controller;
    await getCurrentLocation();

    // Load MPAs
    final MPAs = await mpa.getMPAs();

    // Load MPA regulations
    final mpaRegulations = await getMPARegulations();
    String generalRegulation = '';    // General regulation in certain type

    setState(() {

      _markers.clear();
      _polygons.clear();
      _circles.clear();

      var num = 1;
      for (final MPA in MPAs.features){
        var name = MPA.properties.FULLNAME;
        var type = MPA.properties.Type;
        var polygonCoords = <LatLng>[];
        var radius = 0.0;
        var points = MPA.geometry.coordinates[0];

        // Add polygon points
        for (final coord in points) {
          polygonCoords.add(LatLng(coord[1],coord[0]));
        }

        // Calculate center of polygon
        var first = points[0], last = points[points.length-1];
        if (first[1] != last[1] || first[0] != last[0]) points.add(first);
        var twicearea=0.0,
            x=0.0, y=0.0,
            nPts = points.length,
            p1, p2, f;
        for ( var i=0, j=nPts-1 ; i<nPts ; j=i++ ) {
          p1 = points[i]; p2 = points[j];
          f = p1[1]*p2[0] - p2[1]*p1[0];    // [1]:x, [0]:y
          twicearea += f;
          x += ( p1[1] + p2[1] ) * f;
          y += ( p1[0] + p2[0] ) * f;
        }
        f = twicearea * 3;
        var center = LatLng(x/f, y/f);

        // Calculate longest distance as radius (1 degree=111000 meters)
        for (final coord in points) {
          var distance = sqrt(pow(coord[1] - center.latitude, 2) +
              pow(coord[0] - center.longitude, 2));
          if (distance > radius) {
            radius = distance.toDouble();
          }
        }
        radius *= 111000;

        // Add polygons
        final polygon = Polygon(
          polygonId: PolygonId(name),
          points: polygonCoords,
          fillColor: MPA_type_color[type]!.withOpacity(0.5),
          strokeWidth: 1,
          strokeColor: MPA_type_color[type]!.withOpacity(0.5),
        );
        _polygons[name] = polygon;

        // Get general regulation according to MPA type
        if (type.length>4 && type.substring(0,4)=='SMCA') {
          generalRegulation = mpaRegulations['SMCA'];
        } else if (mpaRegulations.containsKey(type)) {
          generalRegulation = mpaRegulations[type];
        } else {
          generalRegulation = 'None';
        }

        // Add markers
        _markers[name] = Marker(
          markerId: MarkerId(name),
          position: center,
          alpha: 0.5,

          infoWindow: InfoWindow(
              title: name,
              snippet: type
          ),

          onTap: () {
            print('Tap ' + name);
            setState(() {
              _pinPillPosition = 100;
              pinInformation = PinInformation(
                  name, type,
                  mpaRegulations[name]??['None'],
                  generalRegulation);
            });
          }
        );

        // Store names, centers, radius and distances from current location
        _names.add(name);
        _centers[name] = center;
        _radiuses[name] = radius;
        _distances[name] = sqrt(pow(_location.latitude - center.latitude, 2) +
            pow(_location.longitude - center.longitude, 2))*111000;

        print('$num. Add $name, Type: $type, Radius: $radius');
        num++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Map'),
            backgroundColor: Colors.green[700],
            centerTitle: true,
          ),
          body: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                  ),
                  polygons: _polygons.values.toSet(),
                  circles: _circles.values.toSet(),
                  markers: _markers.values.toSet(),
                  myLocationEnabled: true,
                ),
                AnimatedPositioned(
                  bottom: _pinPillPosition, right: 0, left: 0,
                  duration: Duration(microseconds: 200),
                  child: Align(
                    // Force it to be aligned at the bottom of the screen
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        // Wrap it inside a container so we can provide the
                        // background white and rounded corners
                        // and nice breathing room with margins, a fixed height
                        // and a nice subtle shadow for a depth effect
                          margin: EdgeInsets.all(5),
                          height: 70,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  blurRadius: 20,
                                  offset: Offset.zero,
                                  color: Colors.grey.withOpacity(0.5),
                                )
                              ]
                          ),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:[
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children:[
                                        FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(pinInformation.locationName),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ImageIcon(
                                              AssetImage('assets/images/no-fishing.png'),
                                            ),
                                            ImageIcon(
                                              AssetImage('assets/images/duck.png'),
                                            ),
                                          ],
                                        ),
                                      ]
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_forward_ios),
                                    onPressed: () {
                                      print('Go to exceptions');
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) =>
                                              RegulationPage(pinInformation: pinInformation)
                                          )
                                      );
                                    },
                                  ),
                                )
                              ]
                          )
                      )
                  ),
                ),
              ]
          )
      ),
    );
  }

  /*
  // --- Geofence code (Unfinished) ---

  // Callback for entering or leaving geofence
  static void callback(List<String> ids, Location l, GeofenceEvent e) async {
    print('Fences: $ids Location $l Event: $e');
    final send =
    IsolateNameServer.lookupPortByName('geofencing_send_port');
    send!.send(e.toString());

    if (e==GeofenceEvent.enter) {
      print('Enter $ids');
      await notification.showNotification('enter', ids);
    }
    /*
    else {
      print('Leave $ids');
      await _showNotification('leave', ids);
    }
     */
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {

    //_status = await Permission.location.request();
    //print('Location permission status: $_status');
    print('Initializing...');
    await GeofencingManager.initialize();
    print('Initialization done');
  }

  Future<void> _registerGeofences() async {
    // Build geofences for 5 near MPAs
    _names.sort((a,b) => _distances[a]!.toDouble().compareTo(_distances[b]!));
    // print('Permission status: $_status');

    for (var i = 0; i < 3; i++) {
      var name = _names[i];
      var center = _centers[name];
      var radius = _radiuses[name];

      await GeofencingManager.registerGeofence(
          GeofenceRegion(
              name, center!.latitude, center.longitude, radius, triggers,
              androidSettings: androidSettings),
          callback).then((_) {
        GeofencingManager.getRegisteredGeofenceIds().then((value) {
          setState(() {
            registeredGeofences = value;
          });
        });
      });

      // Add circles
      final circle = Circle(
          circleId: CircleId(name),
          center: center,
          radius: radius!,
          fillColor: Colors.red.withOpacity(0.5),
          strokeWidth: 1,
          strokeColor: Colors.red.withOpacity(0.5)
      );
      _circles[name] = circle;

      print('Add Geofence of $name, '
          '(${center.latitude},${center.longitude}), radius: $radius');
    }

    setState(() {
      print('Add circles to google map.');
    });
  }
   */

}

// --- Second page for notification (Unfinished) ---
class SecondPage extends StatefulWidget {
  const SecondPage(
      this.payload, {
        Key? key,
      }) : super(key: key);

  static const String routeName = '/secondPage';

  final String? payload;

  @override
  State<StatefulWidget> createState() => SecondPageState();
}

class SecondPageState extends State<SecondPage> {
  String? _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Second Screen with payload: ${_payload ?? ''}'),
    ),
    body: Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Go back!'),
      ),
    ),
  );
}
