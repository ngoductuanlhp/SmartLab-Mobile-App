import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_system/data/user_data.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'package:smart_system/data/firebase_authentication.dart';
import 'package:smart_system/data/firebase_database.dart';
import 'package:smart_system/data/globals.dart' as globals;

class RootPage extends StatefulWidget {
  RootPage({@required this.auth, @required this.data});
  final BaseAuth auth;
  final FirebaseData data;
  User user;
  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus {NOT_DETERMINED, NOT_LOGGED_IN, LOGGED_IN}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userID = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.auth.getCurrentUser().then((user) async {
      if(user != null) {
        FirebaseUser user = await widget.auth.getCurrentUser();
        String uid = user.uid;
        Map userData;
        if(uid != null && uid.length >0) {
          userData = await widget.data.getUserData(uid);
          globals.isAdmin = await widget.data.checkTypeLogin(uid) == 1 ? true : false;
        }
        print(userData);
        widget.user = User(userData);
      }
      setState(() {
        if(user != null) {
          _userID = user?.uid;
        }
        authStatus = user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user) async {
      if(user != null) {
        FirebaseUser user = await widget.auth.getCurrentUser();
        String uid = user.uid;
        Map userData = await widget.data.getUserData(uid);
        print(userData);
        widget.user = User(userData);
        globals.isAdmin = await widget.data.checkTypeLogin(uid) == 1 ? true : false;
      }
      setState(() {
        _userID = user.toString();
        authStatus = AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onSignedOut() {
    globals.isAdmin = false;
    widget.user = User(null);
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userID = "";
    });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return LoginPage(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
          data: widget.data,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if(_userID != null && _userID.length > 0) {
          print("Is admin? ${globals.isAdmin}");
          return HomePage(
            auth: widget.auth,
            data: widget.data,
            onSignedOut: _onSignedOut,
            user: widget.user
          );
        } else return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }

}
