library ocean_view.notification_library;
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/subjects.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:ocean_view/MapPage.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
BehaviorSubject<String?>();

const MethodChannel platform =
MethodChannel('dexterx.dev/flutter_local_notifications_example');

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

var initialRoute = HomePage.routeName;
var notificationAppLaunchDetails;
String? selectedNotificationPayload;

Future<void> initializeNotification() async{
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();


  notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    initialRoute = SecondPage.routeName;
  }

  const initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final initializationSettingsIOS =
  IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  const initializationSettingsMacOS =
  MacOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false);
  final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
        if (payload != null) {
          debugPrint('notification payload: $payload');
        }
        selectedNotificationPayload = payload;
        selectNotificationSubject.add(payload);
      });
}

void requestPermissions() {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      MacOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
}

void configureDidReceiveLocalNotificationSubject(var context) {
  didReceiveLocalNotificationSubject.stream
      .listen((ReceivedNotification receivedNotification) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: receivedNotification.title != null
            ? Text(receivedNotification.title!)
            : null,
        content: receivedNotification.body != null
            ? Text(receivedNotification.body!)
            : null,
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      SecondPage(receivedNotification.payload),
                ),
              );
            },
            child: const Text('Ok'),
          )
        ],
      ),
    );
  });
}

void configureSelectNotificationSubject(var context) {
  selectNotificationSubject.stream.listen((String? payload) async {
    await Navigator.pushNamed(context, '/secondPage');
  });
}

Future<void> showNotification(String str, List<String> ids) async {
  const androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker');
  const platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
  0, 'Urgent!!!', 'You are ${str}ing ${ids[0]}.', platformChannelSpecifics,
  payload: 'item x');
}

void dispose(){
  didReceiveLocalNotificationSubject.close();
  selectNotificationSubject.close();
}