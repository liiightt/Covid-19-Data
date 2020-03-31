import 'package:corona_tracker/home.dart';
import 'package:corona_tracker/uatheme.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corona Tracker',
      theme: UATheme.setTheme(),
      home: Home(),
    );
  }
}
