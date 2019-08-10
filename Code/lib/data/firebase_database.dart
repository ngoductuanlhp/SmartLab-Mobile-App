import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

abstract class Dabase{
  Future<int> checkTypeLogin(String uid);
  Future<bool> checkAdmin(String uid);
  Future<Map> getUserData(String uid);
  Future<Map> getLabStatus();
  Future<Map> getDeviceList();
  Future<Map> getLabSchedule();
  Future<String> getPIN(String uid);
  Future changePIN(String uid, String newPIN);
}

class FirebaseData implements Dabase{
  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;

  @override
  Future<int> checkTypeLogin(String uid) async {
    DataSnapshot snapshot = await database.reference().child("Allowed UIDs").child(uid).once();
    if(snapshot.value == null || snapshot.value["Status"].toString() != "true")
      return -1;
    if(snapshot.value["ID number"].contains("Admin"))
      return 1;
    if(snapshot.value["Status"] == "true" || snapshot.value["Status"] == "True")
      return 2;
    return 3;
  }

  @override
  Future<bool> checkAdmin(String uid) async {
    DataSnapshot snapshot = await database.reference().child("Admin Key").child(uid).once();
    print(snapshot.value);
    if(snapshot.value == null || snapshot.value.toString() != "true")
      return false;
    else return true;
  }

  @override
  Future<Map> getUserData(String uid) async {
    DataSnapshot snapshot = await database.reference().child("Allowed UIDs").child(uid).once();
    if(snapshot.value == null)
      return null;
    String ID_number = snapshot.value["ID number"].toString();
    if(ID_number == null)
      return null;
    DataSnapshot snapshot1 = await database.reference().child("List of users").child(ID_number).once();
    return snapshot1.value;
  }

  @override
  Future<Map> getLabStatus() async {
    DataSnapshot snapshot = await database.reference().child("Lab status").once();
    return snapshot.value;
  }

  @override
  Future<Map> getDeviceList() async {
    DataSnapshot snapshot = await database.reference().child("List of devices").once();
    return snapshot.value;
  }

  @override
  Future<Map> getLabSchedule() async {
    DataSnapshot snapshot = await database.reference().child("Lab schedule").once();
    return snapshot.value;
  }

  void addBookSchedule(Map data, String key) {
    database.reference().child("Lab schedule").child("Courses detail").child(data["Room"]).child(key).set(data);
    for(int i = int.parse(data["Start"]) + int.parse(data["Reference"]); i <= int.parse(data["End"]) + int.parse(data["Reference"]); i++) {
      database.reference().child("Lab schedule").child("Classes").child(data["Room"]).child(i.toString()).set(key);
    }
  }

  @override
  Future changePIN(String uid, String newPIN) {
    database.reference().child("List PINs").child(uid).set(newPIN);
  }

  @override
  Future<String> getPIN(String uid) async {
    // TODO: implement getPIN
    DataSnapshot snapshot = await database.reference().child("List PINs").child(uid).once();
    return snapshot.value;
  }

}