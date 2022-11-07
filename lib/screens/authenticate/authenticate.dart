import 'package:ocean_view/screens/authenticate/sign_in.dart';
import 'package:ocean_view/screens/authenticate/register.dart';
import 'package:flutter/material.dart';

/*
  A wrapper widget for showing SignIn page or Register page
 */
class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignIn = true;

  // Functions that will be called in SignIn or Register
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }


  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return SignIn(toggleView: toggleView);
    } else {
      return Register(toggleView: toggleView);
    }
  }
}
