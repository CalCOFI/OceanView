import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_view/models/userstats.dart';
import 'package:ocean_view/shared/constants.dart';
import 'package:ocean_view/shared/custom_widgets.dart';
import 'package:ocean_view/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:ocean_view/services/database.dart';
import 'package:ocean_view/services/auth.dart';

class sharingForm extends StatefulWidget {
  User? thisUser;
  Function updateAppBar;
  sharingForm({Key? key, this.thisUser, required this.updateAppBar})
      : super(key: key);
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
    this.thisUser = widget.thisUser;
    this._pnameController =
        new TextEditingController(text: thisUser?.displayName);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _pnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String helpText =
        'If you choose to share your observations with the rest of the OceanView community, your observations will be included in the statistics that other app users can see.  You will also be able to view statistics compiled from observations submitted by other users who have chosen to share.  Your personal information will not be shared. \n\n If you choose not to share your observations, you will not have access to the statistics feature in the app.\n\n Changes to the share setting are not retroactive.  Previously stored observations will retain the setting they were originally saved with.';
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
                  padding: EdgeInsets.fromLTRB(20, 1, 20, 10),
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
                  padding: EdgeInsets.fromLTRB(20, 1, 50, 1),
                  child: Row(
                    children: [
                      Text(
                        'Share: ',
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
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
                      await DatabaseService(uid: newStats?.uid as String)
                          .updateUserStats(newStats as UserStats);
                      await thisUser?.updateDisplayName(newStats.name);
                      widget.updateAppBar();
                      Navigator.pop(context);
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
  String? AppBarName = FirebaseAuth.instance.currentUser!.displayName;
  void updateAppBar() {
    setState(() {
      print('Updating App Bar');
      AppBarName = FirebaseAuth.instance.currentUser!.displayName;
    });
  }

  @override
  void initState() {
    super.initState();
    this.currentUser = currentUser;
    this.AppBarName = AppBarName;
  }

  Widget build(BuildContext context) {
    void _showSharingPanel(updateAppBar) {
      Function updateAppBar;
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
                    'Update Profile Details',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ],
              ),
              sharingForm(
                thisUser: currentUser,
                updateAppBar: this.updateAppBar,
              )
            ]);
          });
    }

    final uStats = Provider.of<UserStats>(context);
    final AuthService _auth = AuthService();
    String? u_email = currentUser == null ? '' : currentUser?.email;
    String? u_date = currentUser == null
        ? ''
        : currentUser?.metadata.creationTime.toString();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Profile Page: ${AppBarName}'),
          centerTitle: true,
          backgroundColor: topBarColor,
          elevation: 0.0,
          actions: <Widget>[
            TextButton.icon(
                onPressed: () async {
                  await _auth.signOut();
                },
                icon: Icon(Icons.person),
                label: Text('Log out'))
          ],
        ),
        body: Container(
          //SingleChildScrollView(
          //padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0.0),
          decoration: blueBoxDecoration,
          child: Stack(
            children: [
              CustomPainterWidgets.buildTopShape(),
              Column(children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 60, 10, 10),
                  child: Row(
                    children: [
                      Text(
                        'Name: ',
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                      ),
                      Expanded(
                        child: Text(
                          uStats.name ?? '',
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
                  padding: EdgeInsets.fromLTRB(20, 1, 1, 10),
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
                    padding: EdgeInsets.fromLTRB(20, 1, 1, 10),
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
                    ])),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 1, 1, 10),
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
                  padding: EdgeInsets.fromLTRB(20, 1, 1, 10),
                  child: Row(
                    children: [
                      Text(
                        'Sharing: ',
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                      ),
                      Text(
                        uStats.share == null
                            ? 'Nothing yet'
                            : uStats.share as String,
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 1, 1, 10),
                  child: Row(
                    children: [
                      Text(
                        'Number of Observations: ',
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                      ),
                      Text(
                        uStats.numobs == null ? '0' : uStats.numobs.toString(),
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
                  padding: EdgeInsets.fromLTRB(20, 1, 1, 10),
                  child: Center(
                    child: Center(
                      child: ElevatedButton(
                          onPressed: () => _showSharingPanel(updateAppBar),
                          child: Text('Update Profile')),
                    ),
                  ),
                ),
              ]),
            ],
          ),
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
