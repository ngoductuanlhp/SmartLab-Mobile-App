import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_system/data/user_data.dart';
import 'package:smart_system/data/globals.dart' as globals;
import 'package:smart_system/ui/change_password_page.dart';
import 'package:smart_system/data/firebase_authentication.dart';
import 'package:smart_system/data/firebase_database.dart';
import 'package:smart_system/ui/change_pin_page.dart';

class PersonalInfoPage extends StatelessWidget {

  final User user;
  final BaseAuth auth;
  final FirebaseData data;

  PersonalInfoPage({@required this.user, @required this.auth, @required this.data});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
            "Personal Info"),
        backgroundColor: Color(0xFF3777A3),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          _showBody(context)
        ],
      ),
    );
  }

  Widget _showBody(context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        _showCard("Name"),
        _showName(),
        _showCard("Email"),
        _showEmail(),
        _showCard("Gender"),
        _showGender(),
        _showCard("ID number"),
        _showID_number(),
        _showCard(""),
        _showChangePassword(context),
        _showCard(""),
        _showChangePIN(context)
      ],
    );
  }

  Widget _showCard(String str) {
    if(str == "")
      return Container(
        color: Color(0xFFF4F4F4),
        padding: const EdgeInsets.all(6.0),
      );
    else return Container(
      color: Color(0xFFF4F4F4),
      padding: const EdgeInsets.all(8.0),
      child: Text(
          str,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          )
      ),
    );
  }

  Widget _showName() {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
        child: ListTile(
          title: Text(
              user.name,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400
              )
          ),
        )
    );
  }

  Widget _showEmail() {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
        child: ListTile(
          title: Text(
              user.email,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400
              )
          ),
        )
    );
  }

  Widget _showGender() {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
        child: ListTile(
          title: Text(
              user.gender,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400
              )
          ),
        )
    );
  }

  Widget _showID_number() {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
        child: ListTile(
          title: Text(
              user.ID_number,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400
              )
          ),
        )
    );
  }

  Widget _showChangePassword(context) {
    return Container(
        color: Colors.white,
        child: ListTile(
          title: Text(
              "Change password",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.blue
              )
          ),
          onTap: () {
            _navigateToChangePasswordPage(context);
          },
          trailing: Icon(Icons.arrow_forward_ios),
        )
    );
  }

  Widget _showChangePIN(context) {
    return Container(
        color: Colors.white,
        child: ListTile(
          title: Text(
              "Change PIN",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.blue
              )
          ),
          onTap: () {
            _navigateToChangePINPage(context);
          },
          trailing: Icon(Icons.arrow_forward_ios),
        )
    );
  }

  Future _navigateToChangePasswordPage(context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage(user: user, auth: auth, data: data,)));
  }

  Future _navigateToChangePINPage(context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePINPage(user: user, data: data,)));
  }
}

