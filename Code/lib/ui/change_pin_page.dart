import 'package:flutter/material.dart';
import 'package:smart_system/data/user_data.dart';
import 'package:smart_system/data/firebase_database.dart';

bool isNumeric(String str) {
  if(str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}

class ChangePINPage extends StatefulWidget {

  final User user;
  final FirebaseData data;
  ChangePINPage({@required this.user, @required this.data});

  @override
  _ChangePINPageState createState() => _ChangePINPageState();
}

class _ChangePINPageState extends State<ChangePINPage> {
  bool isLoading = false;
  String _oldPIN;
  String _newPIN;
  String _newPINConfirm;
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
            "Change PIN"),
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
            "Change PIN"),
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
          _showOldPIN(),
          _showNewPIN(),
          _showNewPINConfirm(),
          Padding(
            padding: const EdgeInsets.all(8.0),
          ),
        ],
      ),
    );
  }

  Widget _showOldPIN() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.number,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          labelText: "Old PIN:",
        ),
        validator: (value) => value.isEmpty ? "Old PIN can't be empty": value.length != 4 ? "PIN has 4 numbers" : null,
        onSaved: (value) => _oldPIN = value.trim(),
      ),
    );
  }

  _showNewPIN() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.number,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          labelText: "New PIN:",
        ),
        validator: (value) => value.isEmpty ? "New PIN can't be empty": value.length != 4 ? "PIN has 4 numbers" : null,
        onSaved: (value) => _newPIN = value.trim(),
      ),
    );
  }

  Widget _showNewPINConfirm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.number,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          labelText: "Confirm new PIN:",
        ),
        validator: (value) => value.isEmpty ? "Confirm PIN can't be empty": value.length != 4 ? "PIN has 4 numbers" : null,
        onSaved: (value) => _newPINConfirm = value.trim(),
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
            onPressed: _submitChangePIN,
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

  void _submitChangePIN() async {
    setState(() {
      isLoading = true;
      _errorMessage = "";
    });
    if(_validateAndSave()) {
      try {
        String userPIN = await widget.data.getPIN(widget.user.UID);
        if(_oldPIN != userPIN)
          throw ("Old PIN is not correct");
        if (_newPIN != _newPINConfirm)
          throw ("New PINs aren't matched");
        if(!isNumeric(_newPIN) || !isNumeric(_newPINConfirm))
          throw ("PIN contains only number");
        await widget.data.changePIN(widget.user.UID, _newPIN);
        setState(() {
            isLoading = false;
        });
        print("OK");
        showDialog(context: context, builder: (BuildContext context) {
            return SimpleDialog(
              title: Text("Change PIN successful"),
              children: [
                Text("Your PIN has been changed"
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
        } catch (e) {
        isLoading = false;
        print(e);
        setState(() {
          if (e == "Old PIN is not correct")
            _errorMessage = "Old PIN is not correct";
          else if (e == "New PINs aren't matched")
            _errorMessage = "New PINs aren't matched";
          else if (e == "PIN contains only number")
            _errorMessage = "PIN contains only number";
          else if( _isIos)
            _errorMessage = e.details;
          else
            _errorMessage = e.message;
        });
      }
    }
  }
}
