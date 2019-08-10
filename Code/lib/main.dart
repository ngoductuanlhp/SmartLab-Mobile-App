import 'package:flutter/material.dart';
import 'package:smart_system/data/firebase_authentication.dart';
import 'package:smart_system/data/firebase_database.dart';
import 'package:smart_system/ui/login_page.dart';
import 'package:smart_system/ui/root_page.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Lab',
      debugShowCheckedModeBanner: false,
      home: RootPage(auth: Auth(),data: FirebaseData()),
    );
  }
}

