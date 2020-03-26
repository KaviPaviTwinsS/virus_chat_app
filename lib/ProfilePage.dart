import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/FacebookSignup.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';
import 'package:virus_chat_app/UsersList.dart';
import 'dart:convert' as JSON;

import 'const.dart';

class ProfilePageSetup extends StatelessWidget {
  final String currentUserId;
  String signinType;

  ProfilePageSetup(String userSigninType,
      {Key key, @required this.currentUserId})
      : super(key: key) {
    signinType = userSigninType;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Page',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: ProfilePage(
        signinType,
        currentUserId: currentUserId,
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String currentUserId;
  String userSigninType;

  ProfilePage(String signinType, {Key key, @required this.currentUserId})
      : super(key: key) {
    userSigninType = signinType;
  }

  @override
  State<StatefulWidget> createState() {
    return ProfilePageState(userSigninType, currentUserId);
  }
}

class ProfilePageState extends State<ProfilePage> {
  SharedPreferences prefs;

  String name = '';
  String nickName = '';
  String signinType = '';
  String userId = '';
  String photoUrl ='';

  TextEditingController controllerName;

  LoginSelectionOption loginSelectionOption;
  var facebookSignup;

  ProfilePageState(String userSigninType, String currentUserId) {
    signinType = userSigninType;
    userId = currentUserId;
  }

  @override
  void initState() {
    super.initState();
    loginSelectionOption = LoginSelectionOption();
    facebookSignup = new FacebookSignup();
    fetchAllUsersData();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
//    name = prefs.getString('name');
//    print('profile name $name');
    controllerName = new TextEditingController(text: name);
    // Force refresh input
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    print('profile build $name');
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => new LoginSelectionPage()));
          },
        ),
        title: Text('Profile Page setup'),
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            child: Text('Logout User'),
            onPressed: () {
              if (signinType == 'google')
                loginSelectionOption.handleGoogleSignOut(prefs);
              else if (signinType == 'facebook')
                facebookSignup.facebookLogout(context, prefs);
              prefs.setString('signInType', '');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new LoginSelectionPage()));
            },
          ),
//          Text('User Name $name'),
          Container(
            child: Theme(
              data: Theme.of(context).copyWith(primaryColor: primaryColor),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  contentPadding: new EdgeInsets.all(5.0),
                  hintStyle: TextStyle(color: greyColor),
                ),
                controller: controllerName,
                onChanged: (value) {
                  name = value;
                },
//                focusNode: focusNodeNickname,
              ),
            ),
            margin: EdgeInsets.only(left: 30.0, right: 30.0),
          ),
          RaisedButton(onPressed: (){
            navigationPage();
          },
          child: Text('GO to Users Page'),)
        ],
      ),
    );
  }
  void navigationPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new UsersList(signinType,userId,photoUrl)));
  }

  Future fetchAllUsersData() async {
    var document = await Firestore.instance.collection('users').document(
        userId).get();
    var profile = document.data;
    print('document ${profile['name']}');
    setState(() {
      this.name = profile['name'];
      this.controllerName = new TextEditingController(text: name);
      this.photoUrl = profile['photoUrl'];
    });

  }
}
