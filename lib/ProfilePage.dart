import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/FacebookSignup.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/tweetPost/MakeTweetPost.dart';
import 'package:virus_chat_app/tweetPost/NewTweetPost.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'utils/const.dart';

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
  String photoUrl = '';
  File avatarImageFile;
  bool isLoading = false;

  String userEmail = '';
  String userPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  String mobileNumber = '';
  TextEditingController controllerName;
  TextEditingController controllerNickName;
  TextEditingController controllerEmail;
  TextEditingController controllerNewPassword;
  TextEditingController controllerConfirmPassword;
  TextEditingController controllerMobileNumber;


  LoginSelectionOption loginSelectionOption;
  var facebookSignup;

  ProfilePageState(String userSigninType, String currentUserId) {
    signinType = userSigninType;
    userId = currentUserId;
  }

  @override
  void initState() {
    super.initState();
    readLocal();
    loginSelectionOption = LoginSelectionOption();
    facebookSignup = new FacebookSignup();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    signinType  = prefs.getString('signInType');
    userEmail = prefs.getString('email');
    mobileNumber = prefs.getString('phoneNo');
//    name = prefs.getString('name');
//    print('profile name $name');
    controllerName = new TextEditingController(text: name);
    controllerNickName = new TextEditingController(text: nickName);
    controllerEmail = new TextEditingController(text: userEmail);
    controllerMobileNumber = new TextEditingController(text: mobileNumber);
    controllerNewPassword = new TextEditingController(text: newPassword);
    controllerConfirmPassword =
    new TextEditingController(text: confirmPassword);
    fetchAllUsersData();

    // Force refresh input
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('profile build $name');
    return Scaffold(
      /*  appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: white_color),
            onPressed: () {
              navigationPage();
            },
          ),
          title: Text('Profile Page setup'),
        ),*/
        body: Stack(
          children: <Widget>[
            Column(
                children: <Widget>[
                  Container(
                    color: facebook_color,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: 150,
                    child:
                    Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 20.0, bottom: 40.0),
                          child: new IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                color: white_color,),
                              onPressed: () {
                                Navigator.pop(context);
//                                  navigationPage();
                              }),
                        ),
                        new Container(
                            margin: EdgeInsets.only(
                                top: 20.0, right: 10.0, bottom: 40.0),
                            child: Text(profile_header, style: TextStyle(
                                color: text_color,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),)
                        ),
                        Spacer(),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: EdgeInsets.only(
                                top: 40, bottom: 20.0, right: 10.0),
                            child: IconButton(
                              icon: new SvgPicture.asset(
                                'images/logout.svg', height: 20.0,
                                width: 20.0,
                              ),
                              onPressed: () {
                                showLogoutAlertDialog(context);
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ]
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height - 100,
                  decoration: BoxDecoration(
                      color: text_color,
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(30.0),
                        topRight: const Radius.circular(30.0),
                      )
                  ),
                  child: SingleChildScrollView(
                      child: Container(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Center(
                                    child: Stack(
                                      children: <Widget>[
                                        (avatarImageFile == null)
                                            ? (photoUrl != ''
                                            ? GestureDetector(
                                          onTap: getImage,
                                          child: Material(
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.0,
                                                      valueColor: AlwaysStoppedAnimation<
                                                          Color>(
                                                          themeColor),
                                                    ),
                                                    width: 70.0,
                                                    height: 70.0,
                                                    padding: EdgeInsets.all(
                                                        20.0),
                                                  ),
                                              imageUrl: photoUrl,
                                              width: 70.0,
                                              height: 70.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(45.0)),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                        )
                                            : IconButton(
                                          icon: Icon(
                                            Icons.account_circle,
                                            size: 70.0,
                                            color: greyColor,
                                          ),
                                          onPressed: () {
                                            getImage();
                                          },))
                                            : Material(
                                          child: Image.file(
                                            avatarImageFile,
                                            width: 70.0,
                                            height: 70.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  45.0)),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                        photoUrl == '' ? IconButton(
                                          icon: Icon(
                                            Icons.camera_alt,
                                            color: primaryColor.withOpacity(
                                                0.5),
                                          ),
                                          onPressed: getImage,
                                          padding: EdgeInsets.all(30.0),
                                          splashColor: Colors.transparent,
                                          highlightColor: greyColor,
                                          iconSize: 30.0,
                                        ) : Text('')
                                      ],
                                    ),
                                  ),
                                  width: double.infinity,
                                  margin: EdgeInsets.all(20.0),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: 30.0, right: 30.0,top:signinType != 'MobileNumber' ? 20.0 : 0.0),
                                      child: Text('First name'.toUpperCase()),
                                    ),
                                    Container(
                                      child: TextField(
                                        decoration: new InputDecoration(
                                          contentPadding: new EdgeInsets.all(
                                              15.0),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: focused_border_color,
                                                width: 1.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: greyColor, width: 1.0),
                                          ),
                                          hintText: 'Enter your name',
                                        ),
                                        controller: controllerName,
                                        onChanged: (value) {
                                          name = value;
                                        },
                                      ),
                                      margin: EdgeInsets.only(
                                          left: 30.0, right: 30.0, top: 5.0),
                                    ),
                                  ],
                                ),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 30.0, right: 30.0, top: 20.0),
                                        child: Text('Last name'.toUpperCase()),
                                      ),
                                      Container(
                                        child: TextField(
                                          decoration: new InputDecoration(
                                            contentPadding: new EdgeInsets.all(
                                                15.0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: focused_border_color,
                                                  width: 1.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: greyColor, width: 1.0),
                                            ),
                                            hintText: 'Enter your LastName',
                                          ),
                                          controller: controllerNickName,
                                          onChanged: (value) {
                                            nickName = value;
                                          },
                                        ),
                                        margin: EdgeInsets.only(
                                            left: 30.0, right: 30.0, top: 5.0),
                                      ),
                                    ]
                                ),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 30.0, right: 30.0, top: 20.0),
                                        child: Text('Email'.toUpperCase()),
                                      ),
                                      Container(
                                        decoration: new BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: signinType == 'facebook' ? greyColor2 : (signinType == 'google' && userEmail != '') ? greyColor2 : white_color
                                        ),
                                        child: TextField(
                                          enabled: signinType == 'facebook' ? false : (signinType == 'google' && userEmail != '') ? false : true ,
                                          decoration: new InputDecoration(
                                            contentPadding: new EdgeInsets.all(
                                                15.0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: focused_border_color,
                                                  width: 1.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: greyColor, width: 1.0),
                                            ),
                                            hintText: 'Enter your Email',
                                          ),
                                          controller: controllerEmail,
                                          onChanged: (value) {
                                            userEmail = value;
                                          },
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                        margin: EdgeInsets.only(
                                            left: 30.0, right: 30.0, top: 5.0),
                                      ),
                                    ]
                                ),

                                signinType == 'MobileNumber'  ? Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 30.0, right: 30.0, top: 20.0),
                                        child: Text('Mobile number'.toUpperCase()),
                                      ),
                                      Container(
                                        decoration: new BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color:  greyColor2
                                        ),
                                        child: TextField(
                                          enabled: false,
                                          controller:controllerMobileNumber ,
                                          decoration: new InputDecoration(
                                            contentPadding: new EdgeInsets.all(
                                                15.0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: focused_border_color,
                                                  width: 1.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: greyColor, width: 1.0),
                                            ),
                                            hintText: 'Enter Mobile number',
                                          ),
                                        ),
                                        margin: EdgeInsets.only(
                                            left: 30.0, right: 30.0, top: 5.0),
                                      ),
                                    ]
                                ) : Text(''),
//                              Row(
//                                mainAxisAlignment: MainAxisAlignment
//                                    .spaceEvenly,
//                                children: <Widget>[
                                /* Container(
                                    margin: EdgeInsets.only(top: 15.0,),
                                    child: RaisedButton(
                                      color: white_color,
                                      textColor: facebook_color,
                                      hoverColor: facebook_color,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.circular(
                                            18.0),
                                      ),
                                      child: Text('Update Password'),
                                      onPressed: () {
                                        updatePassword();
//                                        showAlertDialog(context);
                                      },
                                    ),
                                  ),*/
                                Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            top:signinType == 'MobileNumber'? 15.0 : 30.0, left: 30.0, right: 30.0),
                                        width: double.infinity,
                                        child: SizedBox(
                                          height: 45, // specific value
                                          child: RaisedButton(
                                            color: facebook_color,
                                            textColor: text_color,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: new BorderRadius
                                                  .circular(
                                                  30.0),
                                            ),
                                            child: Text('Update Profile'),
                                            onPressed: () {
                                              if(name != '' || nickName != '' || photoUrl !='' || userEmail!= '') {
                                                if(name == ''){
                                                  Fluttertoast.showToast(
                                                      msg: enter_names);
                                                }else if(nickName == ''){
                                                  Fluttertoast.showToast(
                                                      msg: enter_nickname);
                                                }else if(userEmail == ''){
                                                  Fluttertoast.showToast(
                                                      msg: enter_Email);
                                                }
                                                else if ((prefs.getString('name') !=
                                                    name && name != '') ||
                                                    (nickName != '' &&
                                                        prefs.getString(
                                                            'nickname') !=
                                                            nickName) ||
                                                    (prefs.getString(
                                                        'photoUrl') !=
                                                        photoUrl &&
                                                        photoUrl != '') ||
                                                    (prefs.getString('email') !=
                                                        userEmail &&
                                                        userEmail != '')) {
                                                  isLoading = true;
                                                  bool emailValid = RegExp(
                                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                      .hasMatch(userEmail);
                                                  if (!emailValid) {
                                                    isLoading = false;
                                                    Fluttertoast.showToast(
                                                        msg: enter_valid_email);
                                                  }else {
                                                    Firestore.instance
                                                        .collection(
                                                        'users')
                                                        .document(userId)
                                                        .updateData({
                                                      'photoUrl': photoUrl,
                                                      'name': name,
                                                      'nickName': nickName,
                                                      'email': userEmail
                                                    });
                                                    storeLocalDataInternal(
                                                        photoUrl, name,
                                                        nickName,
                                                        userEmail);
                                                    Fluttertoast.showToast(
                                                        msg: update_success);
                                                    isLoading = false;
                                                  }
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg: no_data_change);
                                                }
                                              }else{
                                                Fluttertoast.showToast(
                                                    msg: no_data_change);
                                              }
                                            },
                                          ),
                                        )
                                    )
                                )
//                                ],
//                              )
                              ]
                          )
                      )
                  )
              ),
            ),
            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                child: Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
                ),
                color: Colors.white.withOpacity(0.8),
              )
                  : Container(),
            ),
          ],
        )
    );
  }


  void uploadProfile() async {
    StorageReference reference = FirebaseStorage.instance.ref().child('HELP');
    StorageUploadTask uploadTask = reference.putFile(
        File('This PC\Galaxy S6\Phone\Pictures'));
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      print('DOWNLOAD URLLLLLLLLLLLLL $downloadUrl');
    }, onError: (err) {
      setState(() {
//        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }


  showLogoutAlertDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog logoutAlert = AlertDialog(
        content: Container(
            width: 200.0,
            height: 90.0,
            child: SingleChildScrollView(
                child: Column(
                    children: <Widget>[
                      Text('Are you sure want to logout?'),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[

                            RaisedButton(
                              color: white_color,
                              child: Text("No"),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true).pop(
                                    'dialog');
                              },
                            ),
                            RaisedButton(
                              child: Text("Yes"),
                              color: white_color,
                              onPressed: () {
                                if (signinType == 'google')
                                  loginSelectionOption.handleGoogleSignOut(
                                      prefs);
                                else if (signinType == 'facebook')
                                  facebookSignup.facebookLogout(context, prefs);
                                else if (signinType == 'MobileNumber')
                                  clearLocalData();
                                prefs.setString('signInType', '');
                                _updatestatus();
                                /* Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginSelection()
                                    ),
                                    ModalRoute.withName("/HomeScreen")
                                );*/
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (
                                            context) => new LoginSelection()));
                                Navigator.of(context, rootNavigator: true).pop(
                                    'dialog');
                              },
                            ),
                          ],
                        ),
                      )
                    ]
                )
            )
        ));
    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return logoutAlert;
      },
    );
  }


  void updatePassword() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              color: Color(0xFF737373),
              height: 300,
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              left: 20.0, right: 30.0, top: 20.0),
                          child: Text('Update Password?', style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),),
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    left: 20.0, right: 30.0, top: 20.0),
                                child: Text('New password'.toUpperCase()),
                              ),
                              Container(
                                child: TextField(
                                  decoration: new InputDecoration(
                                      contentPadding: new EdgeInsets.all(
                                          15.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: focused_border_color,
                                            width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: greyColor2, width: 1.0),
                                      ),
                                      hintText: 'Enter new password',
                                      hintStyle: TextStyle(
                                          color: primaryColor, fontSize: 10.0)
                                  ),
                                  controller: controllerNewPassword,
                                  obscureText: true,
                                  onChanged: (value) {
                                    newPassword = value;
                                  },
                                ),
                                margin: EdgeInsets.only(
                                    left: 20.0, right: 30.0, top: 5.0),
                              ),
                            ]
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    left: 20.0, right: 30.0, top: 20.0),
                                child: Text('Confirm password'.toUpperCase()),
                              ),
                              Container(
                                child: TextField(
                                  decoration: new InputDecoration(
                                      contentPadding: new EdgeInsets.all(
                                          15.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: focused_border_color,
                                            width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: greyColor2, width: 1.0),
                                      ),
                                      hintText: 'Enter confirm password',
                                      hintStyle: TextStyle(
                                          color: primaryColor, fontSize: 10.0)
                                  ),
                                  controller: controllerConfirmPassword,
                                  obscureText: true,
                                  onChanged: (value) {
                                    confirmPassword = value;
                                  },
                                ),
                                margin: EdgeInsets.only(
                                    left: 20.0, right: 30.0, top: 5.0),
                              ),
                            ]
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceEvenly,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 15.0,),
                              child: RaisedButton(
                                color: white_color,
                                textColor: facebook_color,
                                hoverColor: facebook_color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(
                                      18.0),
                                ),
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15.0,),
                              child: RaisedButton(
                                color: facebook_color,
                                textColor: text_color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(
                                      18.0),
                                ),
                                child: Text('Save'),
                                onPressed: () {
                                  if (newPassword == '' ||
                                      newPassword == null) {
                                    Fluttertoast.showToast(
                                        msg: 'Please enter NewPassword');
                                  } else if (confirmPassword == '' ||
                                      confirmPassword == null) {
                                    Fluttertoast.showToast(
                                        msg: 'Please enter ConfirmPassword');
                                  } else if (confirmPassword == newPassword) {
                                    if (confirmPassword == userPassword) {
                                      Fluttertoast.showToast(
                                          msg: 'Entered Password are same as existing password');
                                    } else {
                                      Firestore.instance.collection('users')
                                          .document(userId)
                                          .updateData({
                                        'password': confirmPassword,
                                      });
                                      _updatePassword(confirmPassword);
                                      Fluttertoast.showToast(
                                          msg: 'Password updated successfully');
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'Please enter NewPassword and ConfirmPassword identical');
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                            )
                          ],
                        )
                      ]
                  ),
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .canvasColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10),
                      topRight: const Radius.circular(10),
                    ),
                  ),
                ),
              )
          );
        });
  }


  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = RaisedButton(
      child: Text("Update"),
      color: white_color,
      onPressed: () {
        if (newPassword == '' || newPassword == null) {
          Fluttertoast.showToast(msg: 'Please enter NewPassword');
        } else if (confirmPassword == '' || confirmPassword == null) {
          Fluttertoast.showToast(
              msg: 'Please enter ConfirmPassword');
        } else if (confirmPassword == newPassword) {
          if (confirmPassword == userPassword) {
            Fluttertoast.showToast(
                msg: 'Entered Password are same as existing password');
          } else {
            Firestore.instance.collection('users')
                .document(userId)
                .updateData({
              'password': confirmPassword,
            });
            _updatePassword(confirmPassword);
            Fluttertoast.showToast(
                msg: 'Password updated successfully');
            Navigator.of(context, rootNavigator: true).pop('dialog');
          }
        } else {
          Fluttertoast.showToast(
              msg: 'Please enter NewPassword and ConfirmPassword identical');
        }
      },
    );

    Widget cancelButton = RaisedButton(
      color: white_color,
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Change Password"),
      content: Container(
          width: 200.0,
          height: 220.0,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                    top: 10.0,),
                  child: TextField(
                    obscureText: true,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'New Password',
                      contentPadding: new EdgeInsets.all(5.0),
                      hintStyle: TextStyle(color: greyColor),
                    ),
                    controller: controllerNewPassword,
                    onChanged: (value) {
                      newPassword = value;
                    },
                    keyboardType: TextInputType.phone,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      top: 20.0),
                  child: TextField(
                    obscureText: true,
                    controller: controllerConfirmPassword,
                    onChanged: (value) {
                      confirmPassword = value;
                    },
                    decoration: new InputDecoration(
                      contentPadding: new EdgeInsets.all(5.0),
                      hintText: 'Confirm Password',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      RaisedButton(
                        child: Text("Update"),
                        color: white_color,
                        onPressed: () {
                          if (newPassword == '' || newPassword == null) {
                            Fluttertoast.showToast(
                                msg: 'Please enter NewPassword');
                          } else if (confirmPassword == '' ||
                              confirmPassword == null) {
                            Fluttertoast.showToast(
                                msg: 'Please enter ConfirmPassword');
                          } else if (confirmPassword == newPassword) {
                            if (confirmPassword == userPassword) {
                              Fluttertoast.showToast(
                                  msg: 'Entered Password are same as existing password');
                            } else {
                              Firestore.instance.collection('users')
                                  .document(userId)
                                  .updateData({
                                'password': confirmPassword,
                              });
                              _updatePassword(confirmPassword);
                              Fluttertoast.showToast(
                                  msg: 'Password updated successfully');
                              Navigator.of(context, rootNavigator: true).pop(
                                  'dialog');
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Please enter NewPassword and ConfirmPassword identical');
                          }
                        },
                      ),
                      RaisedButton(
                        color: white_color,
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop(
                              'dialog');
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          )
      ),
      actions: [
//        okButton,
//        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  Future _updatePassword(String password) async {
    await prefs.setString('password', password);
  }

  GoogleSignIn googleSignIn = GoogleSignIn();
  var facebookLogin = FacebookLogin();

  Future _updatestatus() async {
    clearLocalData();

    Firestore.instance
        .collection('users')
        .document(userId)
        .updateData({'status': 'LoggedOut'});
    if (googleSignIn.isSignedIn() != null) {
      await googleSignIn.signOut();
    }
    if (facebookLogin.isLoggedIn != null) {
      await facebookLogin.logOut();
    }
    await FirebaseAuth.instance.signOut();


  }

  Future<Null> setLoader() async {
    setState(() {
      this.isLoading = false;
    });
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 30);

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
          print('DOWNLOAD URL PROFILE $photoUrl');
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
            builder: (context) => new UsersList(signinType, userId, photoUrl)));
  }

  Future fetchAllUsersData() async {
    if (prefs.containsKey('userId') && prefs.getString('userId') != null) {
      if (prefs.getString('userId') == '') {
        var document = await Firestore.instance.collection('users').document(
            userId).get();
        var profile = document.data;
        print('document ${profile['name']}');
        setState(() {
          storeLocalData(profile);
          this.name = profile['name'];
          this.photoUrl = profile['photoUrl'];
          this.userEmail = profile['email'];
          this.nickName = profile['nickName'];
          this.userPassword = profile['password'];
          if(profile['phoneNo'] != null && signinType == 'MobileNumber')
          this.mobileNumber = profile['phoneNo'];
          this.controllerName = new TextEditingController(text: name);
          this.controllerNickName = new TextEditingController(text: nickName);
          this.controllerEmail = new TextEditingController(text: userEmail);
        });
      } else {
        setState(() {
          this.name = prefs.getString('name');
          this.photoUrl = prefs.getString('photoUrl');
          this.userEmail = prefs.getString('email');
          this.nickName = prefs.getString('nickname');
          this.userPassword = prefs.getString('password');
          if(prefs.getString('phoneNo') != null && signinType == 'MobileNumber')
            this.mobileNumber = prefs.getString('phoneNo');
          this.controllerName = new TextEditingController(text: name);
          this.controllerNickName = new TextEditingController(text: nickName);
          this.controllerEmail = new TextEditingController(text: userEmail);
        });
      }
    } else {
      var document = await Firestore.instance.collection('users').document(
          userId).get();
      var profile = document.data;
      print('document ${profile['name']}');
      setState(() {
        storeLocalData(profile);
        this.name = profile['name'];
        this.photoUrl = profile['photoUrl'];
        this.userEmail = profile['email'];
        this.nickName = profile['nickName'];
        this.userPassword = profile['password'];
        if(profile['phoneNo'] != null && signinType == 'MobileNumber')
          this.mobileNumber = profile['phoneNo'];
        this.controllerName = new TextEditingController(text: name);
        this.controllerNickName = new TextEditingController(text: nickName);
        this.controllerEmail = new TextEditingController(text: userEmail);
      });
    }
  }


  Future storeLocalData(Map<String, dynamic> profile) async {
    await prefs.setString('userId', profile['id']);
    await prefs.setString('email', profile['email']);
    await prefs.setString('name', profile['name']);
    await prefs.setString('nickname', profile['nickName']);
    await prefs.setString('status', 'ACTIVE');
    await prefs.setString('photoUrl', profile['photoUrl']);
    await prefs.setInt('createdAt', ((new DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch) / 1000).toInt());
    await prefs.setString('phoneNo', profile['phoneNo']);
    await prefs.setString('signInType', signinType);
    print(
        'CHATTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT ${profile['chattingWith']}');
    await prefs.setStringList('CHAT_USERS', profile['chattingWith']);
  }


  Future storeLocalDataInternal(String photoUrl, String name, String nickName,
      String email) async {
    await prefs.setString('userId', userId);
    await prefs.setString('email', email);
    await prefs.setString('name', name);
    await prefs.setString('nickname', nickName);
    await prefs.setString('status', 'ACTIVE');
    await prefs.setString('photoUrl', photoUrl);
    await prefs.setInt('createdAt', ((new DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch) / 1000).toInt());
    await prefs.setString('signInType', signinType);
  }

  Future<Null> clearLocalData() async {
    await prefs.setString('email', '');
    await prefs.setString('name', '');
    await prefs.setString('nickname', '');
    await prefs.setString('status', '');
    await prefs.setString('photoUrl', '');
    await prefs.setString('createdAt', '');
    await prefs.setInt('phoneNo', 0);
    await prefs.setString('signInType', '');
    await prefs.setString('userId', '');
    LocationService('').locationStream;
  }
}
