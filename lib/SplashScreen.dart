import 'dart:async';

import 'package:flutter/material.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenPage> {

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  void navigationPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
        builder: (context) => new LoginSelectionPage()));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Image.asset('images/splashnew.png',fit: BoxFit.cover,),
      ),
    );
  }
}
