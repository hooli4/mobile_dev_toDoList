import 'package:flutter/material.dart';
import 'screens/ToDoListMainScreen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ToDoListMainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}