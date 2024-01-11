import 'package:ocean_view/services/auth.dart';
import 'package:ocean_view/shared/constants.dart';
import 'package:ocean_view/shared/custom_widgets.dart';
import 'package:ocean_view/shared/loading.dart';
import 'package:flutter/material.dart';

/*
  Register page that user can register the account on Firebase
  User will automatically sign in after successfully registering
 */
class Register extends StatefulWidget {
  final Function toggleView;
  Register({required this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field states
  String email = '';
  String password = '';
  String error = '';

  // Validate and return all errors as a List
  //
  // Here are the patterns and what it means:
  // r'^
  //   (?=.*?[A-Z])      // should contain at least one upper case
  //   (?=.*?[a-z])      // should contain at least one lower case
  //   (?=.*?[0-9])      // should contain at least one digit
  //   (?=.*?[!@#\$&*~]) // should contain at least one Special character
  //   .{8,}             // Must be at least 8 characters in length
  // $
  //
  // Source: https://stackoverflow.com/questions/56253787/how-to-handle-textfield-validation-in-password-in-flutter
  List<PasswordError> passwordValidator(String password) {
    List<PasswordError> errors = [];
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add(PasswordError.upperCase);
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add(PasswordError.lowerCase);
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add(PasswordError.digit);
    }
    if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
      errors.add(PasswordError.specialCharacter);
    }
    if (!RegExp(r'.{8,}').hasMatch(password)) {
      errors.add(PasswordError.eigthCharacter);
    }

    return errors;
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading('Registering...')
        : Scaffold(
            backgroundColor: topBarColor,
            appBar: AppBar(
              backgroundColor: topBarColor,
              elevation: 0.0,
              title: Text('Sign up to OceanView'),
              actions: <Widget>[
                TextButton.icon(
                  icon: Icon(
                    Icons.person,
                    color: Colors.blue.shade900,
                  ),
                  label: Text('Sign in'),
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
                              // validator: (val) => val!.length < 6
                              //     ? 'Enter a password 6+ long'
                              //     : null,
                              validator: (password) {
                                if (password != null) {
                                  // Get all errors
                                  final validators =
                                      passwordValidator(password);

                                  // Returns null if password is valid
                                  if (validators.isEmpty) return null;

                                  // Join all errors that start with "-"
                                  return validators
                                      .map((e) => '- ${e.message}')
                                      .join('\n');
                                }
                                return null;
                              },
                              obscureText: true,
                              onChanged: (val) {
                                setState(() => password = val);
                              },
                            ),
                            SizedBox(height: 20.0),
                            ElevatedButton(
                              child: Text('Register'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: topBarColor,
                                textStyle: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => loading = true);
                                  dynamic result =
                                      await _auth.registerWithEmailAndPassword(
                                          email, password);
                                  if (result == null) {
                                    setState(() {
                                      error = 'Please apply your valid email';
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
