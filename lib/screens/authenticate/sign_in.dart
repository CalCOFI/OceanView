import 'package:ocean_view/services/auth.dart';
import 'package:ocean_view/shared/constants.dart';
import 'package:ocean_view/shared/custom_widgets.dart';
import 'package:ocean_view/shared/loading.dart';
import 'package:flutter/material.dart';

/*
  SignIn page that user can sign in with registered email and password
 */
class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({required this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field states
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading('Signing in...')
        : Scaffold(
            backgroundColor: topBarColor,
            appBar: AppBar(
              backgroundColor: topBarColor,
              elevation: 0.0,
              title: Text('Sign in to OceanView'),
              actions: <Widget>[
                TextButton.icon(
                  icon: Icon(
                    Icons.person,
                    color: Colors.blue.shade900,
                  ),
                  label: Text('Register'),
                  onPressed: () {
                    widget.toggleView();
                  },
                ),
              ],
            ),
            body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Dolphins.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                //padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Stack(
                  children: [
                    CustomPainterWidgets.buildTopShape(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 50.0, 8.0, 0.0),
                      child: Form(
                          key: _formKey,
                          child: Column(children: <Widget>[
                            SizedBox(height: 20.0),
                            TextFormField(
                                decoration: textInputDecoration.copyWith(
                                    hintText: 'Email'),
                                validator: (val) =>
                                    val!.isEmpty ? 'Enter an email' : null,
                                onChanged: (val) {
                                  setState(() => email = val);
                                }),
                            SizedBox(height: 20.0),
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'Password'),
                              validator: (val) => val!.length < 6
                                  ? 'Enter a password 6+ long'
                                  : null,
                              obscureText: true,
                              onChanged: (val) {
                                setState(() => password = val);
                              },
                            ),
                            SizedBox(height: 20.0),
                            ElevatedButton(
                              child: Text('Sign in'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: topBarColor,
                                textStyle: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => loading = true);
                                  dynamic result =
                                      await _auth.signInWithEmailAndPassword(
                                          email, password);
                                  if (result == null) {
                                    setState(() {
                                      error =
                                          'COULD NOT SIGN IN WITH THOSE CREDENTIALS';
                                      loading = false;
                                    });
                                  }
                                }
                              },
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              error,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            )
                          ])),
                    ),
                  ],
                )),
          );
  }
}
