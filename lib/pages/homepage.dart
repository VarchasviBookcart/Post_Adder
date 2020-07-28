import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('widget.title'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text(
                'Add Post',
                style: TextStyle(fontSize: 25, color: Colors.pink),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/addpost');
              },
              color: Colors.lightGreenAccent,
            ),
            SizedBox(
              height: 20.0,
            ),
            RaisedButton(
              child: Text(
                'Edit Post',
                style: TextStyle(fontSize: 25, color: Colors.pink),
              ),
              onPressed: () {},
              color: Colors.lightGreenAccent,
            ),
            SizedBox(
              height: 20.0,
            ),
            RaisedButton(
              child: Text(
                'Delete Post',
                style: TextStyle(fontSize: 25, color: Colors.pink),
              ),
              onPressed: () {},
              color: Colors.lightGreenAccent,
            ),
          ],
        ),
      ),
    );
  }
}
