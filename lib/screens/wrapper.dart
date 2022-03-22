import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_view/screens/authenticate/authenticate.dart';
import 'package:flutter/material.dart';

import 'package:ocean_view/screens/home/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);

    // Return either Home or Authenticate widget
    if (user == null) {
      return Authenticate();
    } else {
      return Home(title: 'OceanView Home Page', key: UniqueKey());
    }
  }
}
