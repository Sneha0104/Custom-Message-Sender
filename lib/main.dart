import 'package:flutter/material.dart';
import 'package:custom_message_sender/views/myhomepage.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messenger',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),

    );
  }
}


