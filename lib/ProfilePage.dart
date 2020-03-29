import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/FacebookSignup.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/colors.dart';
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
  File avatarImageFile;
  bool isLoading = false;

  String userEmail ='';

  TextEditingController controllerName;
  TextEditingController controllerNickName;
  TextEditingController controllerEmail;



  LoginSelectionOption loginSelectionOption;
  var facebookSignup;

  ProfilePageState(String userSigninType, String currentUserId) {
    signinType = userSigninType;
    userId = currentUserId;
  }

  @override
  void initState() {
    loginSelectionOption = LoginSelectionOption();
    facebookSignup = new FacebookSignup();
    fetchAllUsersData();
    readLocal();
    super.initState();

  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
//    name = prefs.getString('name');
//    print('profile name $name');
    controllerName = new TextEditingController(text: name);
    controllerNickName = new TextEditingController(text: nickName);
    controllerEmail = new TextEditingController(text: userEmail);

    // Force refresh input
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    print('profile build $name');
    /*return Scaffold(
      appBar: AppBar(
       *//* leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => new LoginSelectionPage()));
          },
        ),*//*
        title: Text('Profile Page setup'),
      ),*/
      /*body: Column(
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
      ),*/
//    );

  return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Avatar
            /*  Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (avatarImageFile == null)
                          ? (photoUrl != ''
                          ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                            ),
                            width: 90.0,
                            height: 90.0,
                            padding: EdgeInsets.all(20.0),
                          ),
                          imageUrl: photoUrl,
                          width: 90.0,
                          height: 90.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(45.0)),
                        clipBehavior: Clip.hardEdge,
                      )
                          : Icon(
                        Icons.account_circle,
                        size: 90.0,
                        color: greyColor,
                      ))
                          : Material(
                        child: Image.file(
                          avatarImageFile,
                          width: 90.0,
                          height: 90.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(45.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: primaryColor.withOpacity(0.5),
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(30.0),
                        splashColor: Colors.transparent,
                        highlightColor: greyColor,
                        iconSize: 30.0,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),*/

              // Input
              Column(
                children: <Widget>[
                  // Username
                  Container(
                    margin: const EdgeInsets.only(
                        left: 20.0, top: 20.0, right: 20.0),
                    child: TextField(
                      obscureText: false,
                      controller: controllerName,
                      onChanged: (userPhoneNumber) {
                        name = userPhoneNumber;
                      },
                      decoration: new InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: focused_border_color, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: enabled_border_color, width: 2.0),
                        ),
                        hintText: 'Name',
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(
                        left: 20.0, top: 5.0, right: 20.0),
                    child: TextField(
                      obscureText: false,
                      controller: controllerNickName,
                      onChanged: (userPhoneNumber) {
                        nickName = userPhoneNumber;
                      },
                      decoration: new InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: focused_border_color, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: enabled_border_color, width: 2.0),
                        ),
                        hintText: 'Nick Name',
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        left: 20.0, top: 5.0, right: 20.0),
                    child: TextField(
                      obscureText: false,
                      controller: controllerEmail,
                      onChanged: (userPhoneNumber) {
                        userEmail = userPhoneNumber;
                      },
                      decoration: new InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: focused_border_color, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: enabled_border_color, width: 2.0),
                        ),
                        hintText: 'Email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),

                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              // Button
              Container(
                child: RaisedButton(onPressed: () {
                  if (name != '' && userEmail != '' &&
                      photoUrl != '') {

                  } else {

                  }
                },
                  child: Text('UPDATE ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 19),),
                ),
              ),
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
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        ),

        // Loading
        Positioned(
          child: isLoading
              ? Container(
            child: Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
            ),
            color: Colors.white.withOpacity(0.8),
          )
              : Container(),
        ),
      ],
    );
  }


  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = userId;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Fluttertoast.showToast(msg: "Upload success");
          setState(() {
            isLoading = false;
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
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
      this.photoUrl = profile['photoUrl'];
      this.userEmail = profile['email'];
      this.nickName = profile['nickName'];
      this.controllerName = new TextEditingController(text: name);
      this.controllerNickName = new TextEditingController(text: nickName);
      this.controllerEmail = new TextEditingController(text: userEmail);
    });

  }
}
