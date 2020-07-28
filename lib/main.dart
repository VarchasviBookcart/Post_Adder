import 'package:flutter/material.dart';
import 'pages/homepage.dart';
import 'pages/addpost.dart';
import 'package:post_adder/pages/Image_Upload_View.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
      routes: <String, WidgetBuilder>{
        '/homepage': (context) => MyHomePage(),
        '/addpost': (context) => AddPost(),
        '/imageuploader': (context) => ImageCapture(),
      },
    );
  }
}
