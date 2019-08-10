import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_system/data/firebase_authentication.dart';
import 'package:smart_system/data/firebase_database.dart';
import 'package:smart_system/data/user_data.dart';
import 'package:smart_system/ui/device_list_page.dart';
import 'package:smart_system/ui/lab_status_page.dart';
import 'package:smart_system/ui/personal_info_page.dart';
import 'package:smart_system/ui/lab_schedule_page.dart';
import 'package:smart_system/data/globals.dart' as globals;


class HomePage extends StatefulWidget {
  final BaseAuth auth;
  final FirebaseData data;
  final VoidCallback onSignedOut;
  final User user;

  HomePage({@required this.auth, @required this.onSignedOut, @required this.data, @required this.user});


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        appBar: new AppBar(
          title: new Text("Home Page"),
          backgroundColor: Color(0xFF3777A3),
          centerTitle: true,
//          actions: <Widget>[
//            new IconButton(
////                child: new Text('Logout',
////                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
//                onPressed: _signOut,
//            icon: Icon(Icons.backspace, color: Colors.white,))
        ),
        body: Stack(
          children: <Widget>[
            _showBody()
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 4.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                child: Text("Sign out", style: TextStyle(color: Colors.white, fontSize: 16)),
                color: Color(0xFF3777A3),
                onPressed: _signOut,
              )
            ],
          ),
        )
    );
  }

  Widget _showBody () {
    return ListView(
      shrinkWrap: true,
      //padding: const EdgeInsets.all(5.0),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8.0),
        ),
        _showPersonalInfo(),
        Container(
          padding: const EdgeInsets.all(18.0),
        ),
        _showLabStatus(),
        Divider(height: 3.0, color: Color(0xFFF4F4F4),),
        _showSchedule(),
        Divider(height: 3.0, color: Color(0xFFF4F4F4),),
        _showDeviceList()
      ],
    );
  }

  Widget _showPersonalInfo() {
    return Container(
      color: Colors.white70,
      child: ListTile(
        title: Text(widget.user.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey.withOpacity(0.6),
            child: Text(
              widget.user.name[0],
              style: TextStyle(
                  color: globals.isAdmin ? Colors.red : Color(0xFF3777A3),
                  fontWeight: FontWeight.w700,
                  fontSize: 25
              ),
            )
        ),
        subtitle: Container(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
              "Personal information"
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          _navigateToPersonalInfoPage(context);
          },
      ),
    );
  }

  Widget _showLabStatus() {
    return Container(
      color: Colors.white70,
      child: ListTile(
        title: Text("Check lab status",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
        leading: Icon(Icons.computer),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          _navigateToLabStatusPage(context);
        },
      ),
    );
  }

  Widget _showSchedule() {
    return Container(
      color: Colors.white70,
      child: ListTile(
        title: Text("Check lab schedule",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
        leading: Icon(Icons.event_available),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          _navigateToLabSchedulePage(context);
        },
      ),
    );
  }

  Widget _showDeviceList() {
    return Container(
      color: Colors.white70,
      child: ListTile(
        title: Text("List of devices",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
        leading: Icon(Icons.format_list_bulleted),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          _navigateToDeviceListPage(context);
        },
      ),
    );
  }

  _signOut() async {
    try {
      globals.isAdmin = false;
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }


  Future _navigateToPersonalInfoPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalInfoPage(user: widget.user, auth: widget.auth, data: widget.data,)));
  }

  Future _navigateToLabStatusPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LabStatusPage(data: widget.data)));
  }

  Future _navigateToLabSchedulePage( context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LabSchedulePage(data: widget.data)));
  }

  Future _navigateToDeviceListPage( context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DeviceListPage(data: widget.data)));
  }
}
