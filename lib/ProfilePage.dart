import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  TextEditingController controllerName;
  TextEditingController controllerNickName;
  TextEditingController controllerEmail;
  TextEditingController controllerNewPassword;
  TextEditingController controllerConfirmPassword;


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
//    name = prefs.getString('name');
//    print('profile name $name');
    controllerName = new TextEditingController(text: name);
    controllerNickName = new TextEditingController(text: nickName);
    controllerEmail = new TextEditingController(text: userEmail);
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
        resizeToAvoidBottomPadding: true,
        appBar: AppBar(
            leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              navigationPage();
            },
          ),
          title: Text('Profile Page setup'),
        ),

        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              (avatarImageFile == null)
                                  ? (photoUrl != ''
                                  ? Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      Container(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                              themeColor),
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
                                borderRadius: BorderRadius.all(
                                    Radius.circular(45.0)),
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
                                borderRadius: BorderRadius.all(Radius.circular(
                                    45.0)),
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
                              )
                            ],
                          ),
                        ),
                        width: double.infinity,
                        margin: EdgeInsets.all(20.0),
                      ),
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                              primaryColor: primaryColor),
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
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 100,
                          height: 100,
                          child: IconButton(
                            icon: new SvgPicture.asset(
                              'images/post_icon.svg', height: 500.0,
                              width: 500.0,
                            ),
                            onPressed: () {
                              if (signinType == 'google')
                                loginSelectionOption.handleGoogleSignOut(prefs);
                              else if (signinType == 'facebook')
                                facebookSignup.facebookLogout(context, prefs);
                              else if (signinType == 'MobileNumber')
                                clearLocalData();
                              prefs.setString('signInType', '');
                              _updatestatus();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (
                                          context) => new LoginSelectionPage()));
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                          primaryColor: primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter your NickName',
                          contentPadding: new EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: greyColor),
                        ),
                        controller: controllerNickName,
                        onChanged: (value) {
                          nickName = value;
                        },
//                focusNode: focusNodeNickname,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                          primaryColor: primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter your Email',
                          contentPadding: new EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: greyColor),
                        ),
                        controller: controllerEmail,
                        onChanged: (value) {
                          userEmail = value;
                        },
//                focusNode: focusNodeNickname,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                  Container(
                    child: RaisedButton(
                      child: Text('Update Password'),
                      onPressed: () {
                        showAlertDialog(context);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        child: RaisedButton(
                          child: Text('Logout User'),
                          onPressed: () {

                          },
                        ),
                      ),
                      Container(
                        child: RaisedButton(
                          child: Text('Update Profile'),
                          onPressed: () {
                            if (prefs.getString('name') != name ||
                                prefs.getString('nickname') != nickName ||
                                prefs.getString('photoUrl') != photoUrl ||
                                prefs.getString('email') != userEmail) {
                              isLoading = true;
                              Firestore.instance.collection('users')
                                  .document(userId)
                                  .updateData({
                                'photoUrl': photoUrl,
                                'name': name,
                                'nickName': nickName,
                                'email': userEmail
                              });
                              storeLocalDataInternal(
                                  photoUrl, name, nickName, userEmail);
                              Fluttertoast.showToast(msg: update_success);
                            } else {
                              Fluttertoast.showToast(msg: no_data_change);
                            }
                          },
                        ),
                      )
                    ],
                  )
                ],
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

  void uploadProfile() async{
    StorageReference reference = FirebaseStorage.instance.ref().child('HELP');
    StorageUploadTask uploadTask = reference.putFile(File('This PC\Galaxy S6\Phone\Pictures'));
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

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("Update Password"),
      onPressed: () {
        if (newPassword == '' || newPassword == null) {
          Fluttertoast.showToast(msg: 'Please enter NewPassword');
        }else  if (confirmPassword == ''  || confirmPassword == null) {
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

    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Reset Password"),
      content: Container(
          width: 200.0,
          height: 230.0,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                      top: 10.0,),
                  child: TextField(
                    obscureText: true,
                    controller: controllerNewPassword,
                    onChanged: (value) {
                      newPassword = value;
                    },
                    autofocus: true,
                    decoration: new InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: focused_border_color, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: greyColor2, width: 2.0),
                      ),
                      hintText: 'New Password',
                    ),
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
                    autofocus: true,
                    decoration: new InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: focused_border_color, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: greyColor2, width: 2.0),
                      ),
                      hintText: 'Confirm Password',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
           /*     Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                         top: 10.0),
                      child: OutlineButton(
                        color: white_color,
                        child: Text('Update Password'),
                        onPressed: () {
                          if (newPassword == '' || newPassword == null) {
                            Fluttertoast.showToast(msg: 'Please enter NewPassword');
                          }else  if (confirmPassword == ''  || confirmPassword == null) {
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
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Please enter NewPassword and ConfirmPassword identical');
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 5.0, top: 10.0),
                      child: OutlineButton(
                        color: white_color,
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context, true);
//                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                )*/
              ],
            ),
          )
      ),
      actions: [
        okButton,
        cancelButton,
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

  Future _updatestatus() async {
    LocationService('');
    Firestore.instance
        .collection('users')
        .document(prefs.getString('userId'))
        .updateData({'status': 'LoggedOut'});
  }

  Future<Null> setLoader() async {
    setState(() {
      this.isLoading = false;
    });
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
    await prefs.setString('password', '');
    await prefs.setString('status', '');
    await prefs.setString('photoUrl', '');
    await prefs.setString('createdAt', '');
    await prefs.setInt('phoneNo', 0);
    await prefs.setString('signInType', '');
    await prefs.setString('userId', '');
  }
}
