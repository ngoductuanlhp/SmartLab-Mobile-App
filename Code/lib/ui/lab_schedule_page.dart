import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_system/data/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:smart_system/data/globals.dart' as globals;

const int rootTimestamp = 1564333200;

class LabSchedulePage extends StatefulWidget {

  final FirebaseData data;

  LabSchedulePage({@required this.data});

  @override
  _LabSchedulePageState createState() => _LabSchedulePageState();
}

enum Mode {VIEWSCHEDULE, BOOKSCHEDULE}

class _LabSchedulePageState extends State<LabSchedulePage> {
  Map labSchedule;
  List roomList;
  Map classesList;
  Map coursesDetailList;
  bool updated = false;
  int count = 0;
  DateTime _date  = DateTime.now();
  int timestampSelected;
  String roomSeleted = "Not selected";
  String dateSeleted = "Not selected";
  int timestampPicked;
  List<int> courseOfTheDay;
  String _value;
  Mode mode = Mode.VIEWSCHEDULE;

  String _lecturerBooked;
  String _courseBooked;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  List<DropdownMenuItem<String>> listDrop = [];
  List classesCount = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"];
  List<DropdownMenuItem<String>> listDropClasses;
  String startClass;
  String endClass;

  String _errorMessage;
  bool _errorLecturer = false;
  bool _errorCourse = false;
  TextEditingController _controllerLecturer = TextEditingController();
  TextEditingController _controllerCourse = TextEditingController();

  void loadListRoom() {
    listDrop = [];
    listDrop = roomList.map((val) => DropdownMenuItem<String>(
      child: Text(val,style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      )),
      value: val,
    )).toList();
  }

  @override
  void initState() {
    _errorMessage = "";
    listDropClasses = [];
    listDropClasses = classesCount.map((val) => new DropdownMenuItem<String>(child: Text(val.toString()), value: val, )).toList();
    courseOfTheDay = [];
    timestampSelected = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    print(timestampSelected);
    widget.data.getLabSchedule().then((value) {
      if(value != null) {
        setState(() {
          labSchedule = value;
          roomList = value["Classes"].keys.toList();
          classesList = value["Classes"];
          coursesDetailList = value["Courses detail"];
          print(classesList);
          print(coursesDetailList);
          loadListRoom();
          updated = true;
        });
      }
    });
    // TODO: implement initState
    super.initState();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context, initialDate: _date, firstDate: DateTime(2019), lastDate: DateTime(2022)
    );
    timestampPicked = (picked.millisecondsSinceEpoch / 1000).round();
    //print(timestampPicked);
    if(picked != null && timestampPicked != timestampSelected) {
      _onSubmit(timestampPicked, roomSeleted, DateFormat('dd/MM/yyyy').format(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    if(updated == false)
      return _buildWaitingScreen();
    else return Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        appBar: AppBar(
          title: Text(
              "Lab schedule"),
          backgroundColor: Color(0xFF3777A3),
          centerTitle: true,
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Container(
              color: Colors.white,
                padding: EdgeInsets.all(4.0),
                child: _showDatePicked()
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(4.0),
              child: _showRoomPicked(),
            ),
            FlatButton(
              child: mode == Mode.VIEWSCHEDULE ?
              Text(
                "Change to book schedule",
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400)
              ) :
              Text(
                "Change to schedule",
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400)
              ),
              onPressed: () {
                setState(() {
                  if(mode == Mode.BOOKSCHEDULE)
                    mode = Mode.VIEWSCHEDULE;
                  else if(globals.isAdmin == false) {
                    showDialog(context: context, builder: (BuildContext context) {
                      return SimpleDialog(
                        title: Text("Access denied"),
                        children: [
                          Text("Only lecturer and admin can book schedule", style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                          ),),
                        ],
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        backgroundColor: Colors.white,
                      );
                    });
                  }
                  else mode = Mode.BOOKSCHEDULE;
                });
              }
            ),
            Divider(
              height: 8.0,
              color: Colors.black54,
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  mode == Mode.VIEWSCHEDULE ? "Schedule" : "Book schedule",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ),
            _showBody()
          ],
        ),
    );
  }

  Widget _showBody() {
    if(mode == Mode.VIEWSCHEDULE)
      return _buildViewMode();
    else return _buildBookMode();
  }

  Widget _buildViewMode() {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Material(
        child: _buildListSchedule(),
      ),
    );
  }

  Widget _buildBookMode() {
    return Container(
      padding: const EdgeInsets.all(5.0),
      color: Colors.white,
        child: Column(
          children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                    child: TextField(
                      controller: _controllerLecturer,
                      decoration: InputDecoration(
                          hintText: "Lecturer",
                          errorText: _errorCourse ? "Lecturer can't be empty" : null,
                          icon: Icon(
                            Icons.person_outline,
                            color: Colors.grey,
                          )
                      ),

                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                    child: TextField(
                      controller: _controllerCourse,
                      decoration: InputDecoration(
                          hintText: "Course",
                          errorText: _errorLecturer ? "Lecturer can't be empty" : null,
                          icon: Icon(
                            Icons.library_books,
                            color: Colors.grey,
                          )
                      ),
                    ),
                  ),
                ],
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Start:",style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400
                  ),),
                ),
                Container(
                  color: Colors.white,
                  margin: const EdgeInsets.all(4.0),
                  padding: const EdgeInsets.only(left: 4.0, right:2.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isDense: true,
                      items: listDropClasses,
                      onChanged: (value) {
                        setState(() {
                          startClass = value;
                        });
                      },
                      value: startClass,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("End:", style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400
                    ),),
                ),
                Container(
                  color: Colors.white,
                  margin: const EdgeInsets.all(4.0),
                  padding: const EdgeInsets.only(left: 4.0, right:2.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isDense: true,
                      items: listDropClasses,
                      onChanged: (value) {
                        setState(() {
                          endClass = value;
                        });
                      },
                      value: endClass,
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  color: Color(0xFF3777A3),
                  child: Text(
                    "Cancel",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white
                      )
                  ),
                  onPressed: _cancelBook,
                ),
                RaisedButton(
                  color: Color(0xFF3777A3),
                  child: Text(
                      "Book",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white
                      )
                  ),
                  onPressed: _onSubmitBookSchedule,
                )
              ],
            ),
            _showErrorMessage()
          ],
        ),
    );
  }

  void _cancelBook() {
    setState(() {
      _controllerLecturer.clear();
      _controllerCourse.clear();
      startClass = "1";
      endClass = "1";
    });
  }

  bool _validateAndSave() {
    setState(() {
      _errorMessage = "";
    });
      if(_controllerLecturer.text.isEmpty && _controllerCourse.text.isEmpty) {
        setState(() {
          _errorLecturer = true;
          _errorCourse = true;
        });
        return false;
      }
      if(_controllerCourse.text.isEmpty) {
        setState(() {
          _errorCourse = true;
        });
        return false;
      }
      else {
        setState(() {
          _errorLecturer = false;
          _errorCourse = false;
        });
        _lecturerBooked = _controllerLecturer.text;
        _courseBooked = _controllerCourse.text;
        return true;
      }
  }

  void _onSubmitBookSchedule() {
    if(_validateAndSave()) {
      try {
        if (roomSeleted == " Not selected")
          throw ("Please select room");
        if (dateSeleted == " Not selected")
          throw ("Please select date");
        if(int.parse(endClass) < int.parse(startClass))
          throw ("Invalid start and end classes");
        if (dateSeleted != "Not selected" && roomSeleted != "Not selected") {
          int temp = ((timestampPicked - rootTimestamp) ~/ 86400) * 12;
          int key = temp + int.parse(startClass);
//          print(key);
//          print(roomSeleted);
//          print(dateSeleted);
//          print(_courseBooked);
//          print(_lecturerBooked);
//          print(classesList);
          for (int i = temp + int.parse(startClass); i <=
              temp + int.parse(endClass); i++) {
            print(classesList[roomSeleted]);
            if (int.parse(classesList[roomSeleted][i].toString()) != 0)
              throw ("There are already classes at this time");
          }
          for (int i = temp + int.parse(startClass); i <=
              temp + int.parse(endClass); i++) {
            classesList[roomSeleted][i] = key;
          }
          Map temp_data = {
            "Start": startClass,
            "End": endClass,
            "Reference": temp.toString(),
            "Course": _courseBooked,
            "Lecturer": _lecturerBooked,
            "Date": dateSeleted,
            "Room": roomSeleted
          };
          coursesDetailList[roomSeleted][key.toString()] = temp_data;
          widget.data.addBookSchedule(temp_data, key.toString());
          String tempStart = startClass;
          String tempEnd = endClass;
          print("OKKKK");
          showDialog(context: context, builder: (BuildContext context) {
            return SimpleDialog(
              title: Text("Book successful"),
              children: [
                Text("Course: ${_courseBooked}\nLecturer: ${_lecturerBooked}\nDate: ${dateSeleted}\nRoom: ${roomSeleted}\nStart class: ${tempStart}\nEnd class: ${tempEnd}"
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
          setState(() {
            _controllerLecturer.clear();
            _controllerCourse.clear();
            startClass = "1";
            endClass = "1";
          });
        }
      } catch (e) {
        print("Error: $e");
        setState(() {
          if (e == "Please select date")
            _errorMessage = "Please select date";
          else if (e == "There are already classes at this time")
            _errorMessage = "There are already classes at this time";
          else if (e == "Invalid start and end classes")
            _errorMessage = "Invalid start and end classes";
          else _errorMessage = "Error";
        });
      }
    }
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
            "Lab schedule"),
        backgroundColor: Color(0xFF3777A3),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _showDatePicked() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        RaisedButton(
          color: Color(0xFF3777A3),
          child: Text("Select date",style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white
            )
          ),
          onPressed: () {
            _selectDate(context);
          },
        ),
        Text(
          "Date: $dateSeleted",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400
          ),
        ),
      ],
    );
  }

  Widget _showRoomPicked() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          color: Color(0xFF3777A3),
          padding: const EdgeInsets.only(left: 4.0, right:2.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: Text("Select room",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white
                  )
              ),
              items: listDrop,
              onChanged: (value) {
                _onSubmit(timestampSelected, value, dateSeleted);
              },
              value: _value,
            ),
          ),
        ),
        Text(
          "Room: $roomSeleted",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400
          ),
        ),
      ],
    );
  }

  Widget _buildListSchedule() {
    final ScrollController controller = ScrollController();
    return SizedBox(
      child: ListView.builder(
        shrinkWrap: true,
        controller: controller,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return _buildSingleListSchedule(index);
        },
        itemCount: courseOfTheDay.length
      )
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

  void _onSubmit(int timestampPicked, String roomPicked, String datePicked) {
    if(timestampPicked == timestampSelected && roomPicked == "Not selected")
      return;
    setState(() {
      if(timestampPicked != timestampSelected){
        timestampSelected = timestampPicked;
        dateSeleted = datePicked;
      }
      if(roomPicked != roomSeleted)
        roomSeleted = roomPicked;
      if(dateSeleted != "Not selected" && roomSeleted != "Not selected") {
        courseOfTheDay = [];
        int temp = ((timestampPicked - rootTimestamp) ~/ 86400) * 12;
        print(temp);
        for(int i = temp + 1; i <= temp + 12; i++){
          if(int.parse(classesList[roomSeleted][i].toString()) != 0 && int.parse( classesList[roomSeleted][i].toString()) == i) {
            courseOfTheDay.add(i);
            print(classesList[roomSeleted][i]);
            print(i);
          }
        }
        for(int i = 0; i< courseOfTheDay.length; i++) {
          print(coursesDetailList[roomSeleted][courseOfTheDay[i].toString()]);
        }
      }
    });
  }

  Widget _buildSingleListSchedule(int index) {
    Map data = coursesDetailList[roomSeleted][courseOfTheDay[index].toString()];
    return Column(
        children: <Widget>[
          Divider(height: 3.0, color: Color(0xFFF4F4F4),),
          ListTile(
            title: Text(
              data["Course"].toString(),
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                data["Lecturer"],
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
                  "Classes",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                ),
                Text(
                  "${data["Start"]} - ${data["End"]}",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 26,
                      color: Color(0xFF25DA01)
                  ),
                )
              ],
            ), //onTap: () => _showDialog(context),
          )
        ]
    );
  }
}
