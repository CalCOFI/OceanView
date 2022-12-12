import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../../services/auth.dart';

class VerifyScreen extends StatefulWidget {
  final Function verifyEmail;
  VerifyScreen({required this.verifyEmail});

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _auth = AuthService();
  Timer? timer;

  @override
  void initState() {
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
        child: Text('An email has been sent to ${_auth.currentUser?.email}\n please verify.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> checkEmailVerified() async {
    await _auth.reload();
    if (_auth.currentUser?.emailVerified != null) {
      bool verified = _auth.currentUser?.emailVerified as bool;
      if (verified) {
        timer?.cancel();
        widget.verifyEmail();
      }
    }
  }
}
