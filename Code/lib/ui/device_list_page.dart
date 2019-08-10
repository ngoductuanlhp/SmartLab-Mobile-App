import 'package:flutter/material.dart';
import 'package:smart_system/data/firebase_database.dart';

int count = 0;
class DeviceListPage extends StatefulWidget {

  final FirebaseData data;
  List listDevice;
  List listStatus;

  DeviceListPage({@required this.data});

  @override
  _DeviceListPageState createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {

  var _borrowed;
  bool updated = false;

  _DeviceListPageState() {
    this._borrowed = 0;
  }

  final TextEditingController _borrowDeviceController = TextEditingController();

  @override
  void initState() {
    widget.data.getDeviceList().then((value) {
      setState(() {
        if(value != null) {
          updated = true;
          widget.listDevice = value.keys.toList();
          widget.listStatus = value.values.toList();
          count = value.length;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(updated == false)
      return _buildWaitingScreen();
    else return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
            "List of devices"),
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
            "List of devices"),
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
        itemCount: count,
        itemBuilder: (BuildContext context, int index) {
          return _buildSingleDeviceStatus(index);
        }
    );
  }

  Widget _buildSingleDeviceStatus(int index) {
    int total = int.parse(widget.listStatus[index]["Total"].toString());
    int remained = int.parse(widget.listStatus[index]["Remained"].toString());
    return Column(
      children: <Widget>[
        Divider(height: 3.0, color: Color(0xFFF4F4F4),),
        ListTile(
          title: Text(
            widget.listDevice[index].toString(),
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Text(
              "Total: ${total.toString()}",
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  fontStyle: FontStyle.italic
              ),
            ),
          ),
          leading: CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF3777A3),
              child: Text(
                "${(index + 1).toString()}",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 21
                ),
              )
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Remained",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                ),
              Text(
                remained.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 26,
                  color: remained <= 0 ? Color(0xFFE71E0A) : Color(0xFF25DA01)
                ),
              )
            ],
          ),
          //onTap: () => _showDialog(context),
        )
      ]
    );
  }

}
