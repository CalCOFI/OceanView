import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocean_view/models/userstats.dart';

/*
  Class for all the user authentication services including sign in, register,
  and sign out
 */

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user stats object based on signed-in user
  UserStats? _userFromFirebaseUser(User? user) {
    return user != null
        ? UserStats(
            uid: user.uid,
            email: user.email,
            name: user.displayName,
            share: ' ',
            numobs: 0)
        : null;
  }

  // auth change user screen
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // sign in anon
  Future singInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      //return result.user;
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email & password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

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
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
