import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_system/data/firebase_authentication.dart';
import 'package:smart_system/data/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_system/data/globals.dart' as globals;


class LoginPage extends StatefulWidget {
  LoginPage({@required this.auth, @required this.onSignedIn, @required this.data});

  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final FirebaseData data;
  @override
  _LoginPageState createState() => _LoginPageState();
}

//enum FormMode {USER, ADMIN}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading;
  bool _isIos;
  String _errorMessage;
  String _email;
  String _password;
  FirebaseDatabase _data = FirebaseDatabase.instance;
//  FormMode _formMode = FormMode.USER;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Smart Lab",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF3777A3),
      ),
      body: Stack(
        //alignment: Alignment.center,
        children: <Widget>[
          _showBody(),
          _showCircularProgress()
        ],
      )
    );
  }

  Widget _showBody() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            _showLogo(),
            _showEmailInput(),
            _showPasswordInput(),
            _showButton(),
            _showErrorMessage()
          ],
        ),
      ),
    );
  }

  Widget _showLogo() {
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 50.0,
          child: Image.asset('assets/logo_circle.png'),
        ),
      ),
    );
}

  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else return Container(height: 0.0, width: 0.0,);
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          hintText: "Email",
          icon: Icon(
            Icons.email,
            color: Colors.grey,
          )
        ),
        validator: (value) => value.isEmpty ? "Email can't be empty": null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
            hintText: "Password",
            icon: Icon(
              Icons.lock,
              color: Colors.grey,
            )
        ),
        validator: (value) => value.isEmpty ? "Password can't be empty": null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget _showButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 40, 0.0, 0.0),
      child: MaterialButton(
        elevation: 5.0,
        minWidth: 200.0,
        height: 42.0,
        color: Color(0xFF3777A3),
        child: Text(
          "Login", style: TextStyle(
          fontSize: 20, color: Colors.white)
        ),
        onPressed: _validateAndSubmit,
      ),
    );
  }

//  Widget _showsecondaryButton() {
//    return FlatButton(
//      child: _formMode == FormMode.USER ?
//      Text(
//        "Are you Admin? Login as Admin",
//        style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w300)
//      ) :
//      Text(
//          "Login as User",
//          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w300)
//      ),
//      onPressed: _formMode == FormMode.USER ?
//      _changetoAdmin :
//      _changetoUser,
//    );
//  }

//  void _changetoAdmin() {
//    _formKey.currentState.reset();
//    _errorMessage = "";
//    setState(() {
//      _formMode = FormMode.ADMIN;
//    });
//  }
//
//  void _changetoUser() {
//    _formKey.currentState.reset();
//    _errorMessage = "";
//    setState(() {
//      _formMode = FormMode.USER;
//    });
//  }

  Widget _showErrorMessage() {
    if(_errorMessage != null && _errorMessage.length >0) {
      return Text(
        _errorMessage,
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300
        )
      );
    }
    else {
      return Container(
        height: 0.0,
      );
    }
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if( form.validate()) {
      form.save();
      return true;
    } else {
      setState(() {
        _isLoading = false;
      });
      return false;
    }
  }

  _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if(_validateAndSave()) {
      String userUID = "";
      int check = -1;
      try {
        userUID = await widget.auth.signInUser(_email, _password);
        check = await widget.data.checkTypeLogin(userUID);
        if(check > 0)
          print("User signed in: $userUID");
        else {
          widget.auth.signOut();
          throw  ("Not allowed");
        }
        _isLoading = false;
        if(userUID != null && userUID.length > 0 && check > 0) {
          widget.onSignedIn();
        }
      } catch(e) {
        print("Error: $e");
        setState(() {
          _isLoading = false;
          if(e == "Not allowed")
            _errorMessage = "Your account is deactived. Please activate it before sign in";
          else if(e == "Not admin")
            _errorMessage = "You are not admin";
          else if( _isIos)
            _errorMessage = e.details;
          else
            _errorMessage = e.message;
        });
      }
    }
  }

}
