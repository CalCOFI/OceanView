import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_view/models/userstats.dart';
import 'package:ocean_view/screens/authenticate/verify.dart';
import 'package:ocean_view/screens/home/home.dart';
import 'package:ocean_view/screens/map/map_page.dart';
import 'package:ocean_view/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:ocean_view/models/observation.dart';
import 'package:ocean_view/services/database.dart';

class sharingForm extends StatefulWidget {
  User? thisUser;
  sharingForm({Key? key, this.thisUser}) : super(key: key);
  @override
  _sharingFormState createState() => _sharingFormState();
}

class _sharingFormState extends State<sharingForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sharing = ['Yes', 'No'];
  User? thisUser;
  late TextEditingController _pnameController;

  String? _currentSelection;

  @override
  void initState() {
    super.initState();
    this.thisUser = thisUser;
    this._pnameController = TextEditingController(text: thisUser?.displayName);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _pnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thisUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder<UserStats>(
        stream: DatabaseService(uid: thisUser?.uid as String).meStats,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserStats? newStats = snapshot.data;
            return Form(
              key: _formKey,
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 1, 20, 1),
                  child: Row(
                    children: [
                      Text(
                        'Name: ',
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _pnameController,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(50, 1, 50, 1),
                  child: DropdownButtonFormField(
                    value: _currentSelection ??
                        (newStats?.share == 'Y' ? 'Yes' : 'No'),
                    items: sharing.map((sharesel) {
                      return DropdownMenuItem(
                        value: sharesel,
                        child: Text('$sharesel'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _currentSelection =
                        val != null ? val as String : 'Yes'),
                  ),
                ),
                ElevatedButton(
                    child: Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      print(_currentSelection);
                      newStats?.share = _currentSelection == 'Yes' ? 'Y' : 'N';
                      newStats?.name = _pnameController.text;
                      DatabaseService(uid: newStats?.uid as String)
                          .updateUserStats(newStats as UserStats);
                    }),
              ]),
            );
          } else {
            return Loading();
          }
        });
  }
}

// End of Dialogue window

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
  }

  Widget build(BuildContext context) {
    String helpText =
        'If you choose to share your observations with the rest of the OceanView community, your observations will be included in the statistics that other app users can see.  You will also be able to view statistics compiled from observations submitted by other users who have chosen to share.  Your personal information will not be shared. \n\n If you choose not to share your observations, you will not have access to the statistics feature in the app.\n\n Changes to the share setting are not retroactive.  Previously stored observations will retain the setting they were originally saved with.';
    void _showSharingPanel() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(children: [
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Share observations with community?',
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Sharing your observations'),
                            content: Text(helpText),
                          ),
                        );
                      },
                      icon: Icon(Icons.help_outline))
                ],
              ),
              sharingForm()
            ]);
          });
    }

    final uStats = Provider.of<UserStats>(context);
    UserStats user = uStats;
    String? u_email = currentUser == null ? '' : currentUser?.email;
    String? u_date = currentUser == null
        ? ''
        : currentUser?.metadata.creationTime.toString();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Profile Page: ${currentUser!.displayName}'),
          centerTitle: true,
          backgroundColor: Colors.blue,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
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
                    child: Text(
                      uStats.name as String,
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
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
                    'Email verified: ',
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  Text(
                    currentUser!.emailVerified ? 'Yes   ' : 'No   ',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  currentUser!.emailVerified
                      ? Text(' ')
                      : ElevatedButton(
                          onPressed: () {
                            print('Verifying User');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VerifyScreen()),
                            );
                          },
                          child: Text('Verify')),
                ])),
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
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  //IconButton(
                  //    onPressed: () => _showSharingPanel(),
                  //    iconSize: 20,
                  //    icon: Icon(Icons.edit)),
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
                      onPressed: () => _showSharingPanel(),
                      // {
                      //  nameEnabled = false;
                      //  print('Saving...');
                      //  currentUser?.updateDisplayName(_pnameController.text);
                      //  user.uid = currentUser?.uid;
                      //  user.name = _pnameController.text;
                      //  user.email = currentUser?.email;
                      //  DatabaseService(uid: currentUser!.uid)
                      //      .updateUserStats(user);
                      //},
                      child: Text('Update Profile')),
                ],
              ),
            ),
          ]),
        ));
  }
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.blue,
    title: Text('User Profile'),
    centerTitle: true,
  );
}
