import 'package:flutter/material.dart';
import 'package:smart_system/data/firebase_database.dart';


class LabStatusPage extends StatefulWidget {

  final FirebaseData data;
  List listRoom;
  List listStatus;

  LabStatusPage({@required this.data});

  @override
  _LabStatusPageState createState() => _LabStatusPageState();
}

class _LabStatusPageState extends State<LabStatusPage> {

  bool updated = false;

  @override
  void initState() {
    super.initState();
    widget.data.getLabStatus().then((value) {
      setState(() {
        if(value != null) updated = true;
        widget.listRoom = value.keys.toList();
        widget.listStatus = value.values.toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if(updated == false)
      return _buildWaitingScreen();
    else return Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        appBar: AppBar(
          title: Text(
              "Lab status"),
          backgroundColor: Color(0xFF3777A3),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            _showBody()
          ],
        ),
        bottomNavigationBar: _showBottombar()
    );
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
            "Lab status"),
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
    return ListView.builder(
      itemCount: widget.listRoom.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildSingleLabStatus(index);
      }
    );
  }

  Widget _showBottombar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 4.0,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Icon(
                    Icons.adjust,
                    color: Color(0xFF25DA01),
                    size: 30,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                      "Opened", style: TextStyle(fontSize: 14)
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Icon(
                    Icons.adjust,
                    color: Color(0xFFFFEC00),
                    size: 30,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                      "On class", style: TextStyle(fontSize: 14)
                ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Icon(
                    Icons.adjust,
                    color: Color(0xFFE71E0A),
                    size: 30,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                      "Closed", style: TextStyle(fontSize: 14)
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleLabStatus(int index) {
    String stt = widget.listStatus[index]["Status"].toString().toLowerCase();
    return Column(
      children: <Widget>[
        Divider(height: 3.0, color: Color(0xFFF4F4F4),),
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(
              widget.listRoom[index].toString().toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18
              ),
            ),
            leading: CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF3777A3),
                child: Text(
                  "${widget.listRoom[index][0].toUpperCase()}${widget.listRoom[index][1]}",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 21
                  ),
                )
            ),
            trailing: Icon(
                Icons.adjust, color: stt == "opened" ?
                Color(0xFF25DA01) : stt == "on class" ?
                Color(0xFFFFEC00) : Color(0xFFE71E0A),
              size: 32
            ),
          ),
        ),
      ],
    );
  }
}
