import 'package:flutter/material.dart';
import 'package:smart_system/data/user_data.dart';
import 'package:smart_system/data/firebase_authentication.dart';
import 'package:smart_system/data/firebase_database.dart';


class ChangePasswordPage extends StatefulWidget {

  final User user;
  final BaseAuth auth;
  final FirebaseData data;
  ChangePasswordPage({@required this.user, @required this.auth, @required this.data});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool isLoading = false;
  String _oldPassword;
  String _newPassword;
  String _newPasswordConfirm;
  String _errorMessage;

  bool _isIos;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    if(isLoading == true)
      return _buildWaitingScreen();
    else return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
            "Change password"),
        backgroundColor: Color(0xFF3777A3),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          _showBody()
        ],
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
            "Change password"),
        backgroundColor: Color(0xFF3777A3),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _showBody() {
    return Container(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
            ),
            _showForm(),
            Padding(
              padding: const EdgeInsets.all(8.0),
            ),
            _showButton(),
            _showErrorMessage()
          ],
        ),
      )
    );
  }

  Widget _showForm() {
    return Container(
      color: Colors.white,
      child: Column(
          children: <Widget>[
            _showOldPassword(),
            _showNewPassword(),
            _showNewPasswordConfirm(),
            Padding(
              padding: const EdgeInsets.all(8.0),
            ),
          ],
        ),
    );
  }

  Widget _showOldPassword() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          labelText: "Old password:",
        ),
        validator: (value) => value.isEmpty ? "Old password can't be empty": null,
        onSaved: (value) => _oldPassword = value.trim(),
      ),
    );
  }

  _showNewPassword() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          labelText: "New password:",
        ),
        validator: (value) => value.isEmpty ? "New password can't be empty": value.length < 6 ? "Password has at least 6 character" : null,
        onSaved: (value) => _newPassword = value.trim(),
      ),
    );
  }

  Widget _showNewPasswordConfirm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          labelText: "Confirm new password:",
        ),
        validator: (value) => value.isEmpty ? "Confirm password can't be empty": null,
        onSaved: (value) => _newPasswordConfirm = value.trim(),
      ),
    );
  }

  Widget _showButton() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            child: Text(
              "Back",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white
                )
            ),
            color: Color(0xFF3777A3),
            onPressed: () {
              _formKey.currentState.reset();
              Navigator.pop(context, null);
            },
          ),
          RaisedButton(
            child: Text(
                "Change",
                style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white
            )
            ),
            color: Color(0xFF3777A3),
            onPressed: _submitChangePassword,
          )
        ],
      ),
    );
  }
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
    } else return false;
  }

  void _submitChangePassword() async {
    setState(() {
      isLoading = true;
      _errorMessage = "";
    });
    if(_validateAndSave()) {
      try {
        if (_newPassword != _newPasswordConfirm)
          throw ("New passwords aren't matched");
        bool check = await widget.auth.changePassword(widget.user.email, _oldPassword, _newPassword);
        if(check) {
          setState(() {
            isLoading = false;
          });
          print("OK");
          showDialog(context: context, builder: (BuildContext context) {
            return SimpleDialog(
              title: Text("Change password successful"),
              children: [
                Text("Your password has been changed"
                  , style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400
                  ),),
              ],
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              backgroundColor: Colors.white,
            );
          });
          _formKey.currentState.reset();
        }
      } catch (e) {
        isLoading = false;
        print(e);
        setState(() {
          if (e == "Old password is incorrect")
            _errorMessage = "Old password is incorrect";
          else if (e == "New passwords aren't matched")
            _errorMessage = "New passwords aren't matched";
          else if( _isIos)
            _errorMessage = e.details;
          else
            _errorMessage = e.message;
        });
      }
    }
  }
}
