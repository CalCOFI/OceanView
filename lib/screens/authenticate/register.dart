import 'package:ocean_view/services/auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  Register({required this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // text field states
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.brown[100],
        appBar: AppBar(
          backgroundColor: Colors.brown[400],
          elevation: 0.0,
          title: Text('Sign up to demo'),
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.person),
              label: Text('Sign in'),
              onPressed: () {
                widget.toggleView();
              },
            ),
          ],
        ),
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Form(
                key: _formKey,
                child: Column(
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      TextFormField(
                          validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                          onChanged: (val) {
                            setState(() => email = val);
                          }
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        validator: (val) => val!.length<6 ? 'Enter a password 6+ long' : null,
                        obscureText: true,
                        onChanged: (val){
                          setState(() => password  = val);
                        },
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        child: Text('Register'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.pink[400],
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()){
                            dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                            if (result == null){
                              setState(() {
                                error = 'Please apply your valid email';
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
                    ]
                )
            )
        )
    );
  }
}
