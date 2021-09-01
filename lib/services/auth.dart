import 'package:firebase_auth/firebase_auth.dart';

import 'database.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // auth change user screen
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // sign in anon
  Future singInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // sign in email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email & password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // create the document for the user with the uid
      // await DatabaseService(uid: result.user!.uid).updateUserData('0', 'new crew members', 100);

      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try{
      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }


}