import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_view/models/userstats.dart';
import 'package:provider/provider.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/services/database.dart';

class ProfilePage extends StatefulWidget {
  User? currentUser;
  ProfilePage({Key? key, this.currentUser}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _pnameController;
  bool nameEnabled = false;
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    this.currentUser = currentUser;
    this._pnameController =
        TextEditingController(text: currentUser?.displayName);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _pnameController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    UserStats user = UserStats();
    final uStats = Provider.of<List<UserStats>?>(context);
    if (uStats!.length > 0) {
      user = uStats.first;
    }
    print('XXXXX USER ${user.name} HAS ${user.numobs} OBSERVATIONS');
    String? u_email = currentUser == null ? '' : currentUser?.email;
    String? u_date = currentUser == null
        ? ''
        : currentUser?.metadata.creationTime.toString();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: buildAppBar(context),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
          child: Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.all(1),
              child: Row(
                children: [
                  Text(
                    'Name: ',
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  Expanded(
                    child: TextFormField(
                      enabled: nameEnabled,
                      decoration: InputDecoration(
                          hintText: nameEnabled ? 'Enter Name' : ''),
                      controller: _pnameController,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          nameEnabled = !nameEnabled;
                          if (nameEnabled) {
                            _pnameController.clear();
                          }
                        });
                      },
                      iconSize: 20,
                      icon: Icon(Icons.edit)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(1),
              child: Row(children: [
                Text(
                  'User: ',
                  style: TextStyle(color: Colors.blue, fontSize: 20),
                ),
                Text(
                  //user.email,
                  u_email as String,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.all(1),
              child: Row(children: [
                Text(
                  'Member since:',
                  style: TextStyle(color: Colors.blue, fontSize: 20),
                ),
                Text(
                  u_date as String,
                )
              ]),
            ),
            Divider(
              color: Colors.black,
            ),
            Padding(
              padding: EdgeInsets.all(1),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Sharing: ',
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  Text(
                    user.share == null ? 'Nothing yet' : user.share as String,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(1),
              child: Row(
                children: [
                  Text(
                    'Number of Observations: ',
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  Text(
                    user.numobs == null ? '0' : user.numobs.toString(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Divider(
              color: Colors.black,
            ),
            Padding(
              padding: EdgeInsets.all(1),
              child: Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        nameEnabled = false;
                        print('Saving...');
                        currentUser?.updateDisplayName(_pnameController.text);
                        user.uid = currentUser?.uid;
                        user.name = _pnameController.text;
                        user.email = currentUser?.email;
                        user.share = 'Y';
                        user.numobs = 3;
                        DatabaseService(uid: currentUser!.uid)
                            .updateUserStats(user);
                      },
                      child: Text('Save')),
                ],
              ),
            ),
          ]),
        ));
  }
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    leading: BackButton(),
    elevation: 0,
    backgroundColor: Colors.blue,
    title: Text('User Profile'),
    centerTitle: true,
  );
}
