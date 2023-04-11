import 'package:flutter/material.dart';
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
  Timer? _timerVerify;
  Timer? _timerResend;
  int _countdown = 60;
  bool _buttonEnabled = false;

  @override
  void initState() {
    _timerVerify = Timer.periodic(Duration(seconds: 5), (_timerVerify) {
      checkEmailVerified();
    });
    _startTimerResend();
    super.initState();
  }

  void _startTimerResend() {
    _timerResend = Timer.periodic(Duration(seconds: 1), (_timerResend) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _buttonEnabled = true;
          _timerResend.cancel();
        }
      });
    });
  }


  @override
  void dispose() {
    _timerVerify?.cancel();
    _timerResend?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Resend email'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => _auth.signOut(),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'An email has been sent to ${_auth.currentUser?.email}\n please verify.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          ),
          ElevatedButton(
            onPressed: () {
              if (_buttonEnabled){
                setState(() {
                  _buttonEnabled = false;
                  _countdown = 60;
                });
                _startTimerResend();
                _auth.currentUser?.sendEmailVerification();
              };
            },
            child: Text(
              _buttonEnabled? "Resend" : "Resend ($_countdown)"
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: _buttonEnabled ? Colors.blue : Colors.grey,
              elevation: 2.0,
              textStyle: TextStyle(fontSize: 18.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> checkEmailVerified() async {
    await _auth.reload();
    if (_auth.currentUser?.emailVerified != null) {
      bool verified = _auth.currentUser?.emailVerified as bool;
      if (verified) {
        _timerVerify?.cancel();
        widget.verifyEmail();
      }
    }
  }
}
