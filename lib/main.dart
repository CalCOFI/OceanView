import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocean_view/providers/pictures.dart';
import 'package:ocean_view/screens/wrapper.dart';
import 'package:ocean_view/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'notification_library.dart' as notification;


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  notification.initializeNotification();
  HttpOverrides.global = new MyHttpOverrides();
  // Initialize firebase
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Pictures>(create: (_) => Pictures()),
        StreamProvider<User?>(
          create: (_) => AuthService().user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}
