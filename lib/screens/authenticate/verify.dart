import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_view/screens/home/home.dart';
import 'dart:async';

import '../../services/auth.dart';

class VerifyScreen extends StatefulWidget {
  // final String email;
  // final String password;
  //
  // VerifyScreen({required this.email, required this.password});

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final auth = FirebaseAuth.instance;
  final _auth = AuthService();
  User? user;
  Timer? timer;

  @override
  void initState() {
    // user = auth.currentUser;
    // user?.sendEmailVerification();

    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('An email has been sent to ${user?.email}\n please verify.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> checkEmailVerified() async {
    // user = auth.currentUser;
    // await user?.reload();
    // if (user?.emailVerified != null) {
    //   bool verified = user?.emailVerified as bool;
    //   if (verified) {
    //     timer?.cancel();
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) =>
    //                 Home(title: 'OceanView Home Page', key: UniqueKey())))
    //   }
    // }
    await _auth.currentUser?.reload();
    if (_auth.currentUser?.emailVerified != null) {
      bool verified = _auth.currentUser?.emailVerified as bool;
      if (verified) {
        timer?.cancel();
        // // Sign in with email and password
        // await _auth.signInWithEmailAndPassword(
        //     widget.email, widget.password);
        Navigator.pop(context);
      }
    }
  }
}
