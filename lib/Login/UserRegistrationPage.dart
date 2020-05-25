import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'package:virus_chat_app/utils/constants.dart';

class UserRegistrationPage extends StatelessWidget {

  String userPhoneNumber = '';
  String userPhoneNumberWithoutCountryCode = '';
  FirebaseUser mFirebaseUser;

  UserRegistrationPage(
      {Key key, @required this.userPhoneNumber, @required this.userPhoneNumberWithoutCountryCode, @required this.mFirebaseUser})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      /*  appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new LoginSelection()));
            },
          ),
          title: Text(user_registration),
        ),*/
      body: UserRegistrationState(userPhoneNumber: userPhoneNumber,
          userPhoneNumberWithoutCountryCode: userPhoneNumberWithoutCountryCode,
          myFirebaseUser: mFirebaseUser),
    );
  }
}

class UserRegistrationState extends StatefulWidget {

  String userPhoneNumber = '';
  String userPhoneNumberWithoutCountryCode = '';

  FirebaseUser myFirebaseUser;

  UserRegistrationState(
      {Key key, @required this.userPhoneNumber, @required this.userPhoneNumberWithoutCountryCode, @required this.myFirebaseUser})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UserRegistrationScreen(userPhoneNumber: userPhoneNumber,
        userPhoneNumberWithoutCountryCode: userPhoneNumberWithoutCountryCode,
        firebaseUser: myFirebaseUser);
  }

}

class UserRegistrationScreen extends State<UserRegistrationState> {

  String userPhoneNumber = '';
  FirebaseUser firebaseUser;
  TextEditingController userNameController = new TextEditingController();
  TextEditingController userNockNameController = new TextEditingController();
  TextEditingController userEmailController = new TextEditingController();

  String userPhoneNumberWithoutCountryCode = '';
  String photoUrl = '';

  bool isLoading = false;
  File avatarImageFile;

  SharedPreferences prefs;
  String userToken = '';


  UserRegistrationScreen(
      {Key key, @required this.userPhoneNumber, @required this.userPhoneNumberWithoutCountryCode, @required this.firebaseUser});

  @override
  void initState() {
    super.initState();
    isSignIn();
    // Force refresh input
    setState(() {});


    userNameController.addListener(() {
      final text = userNameController.text.toLowerCase();
      userNameController.value = userNameController.value.copyWith(
        text: text,
        selection: TextSelection(
            baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });


    userNockNameController.addListener(() {
      final text = userNockNameController.text.toLowerCase();
      userNockNameController.value = userNockNameController.value.copyWith(
        text: text,
        selection: TextSelection(
            baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });

    userEmailController.addListener(() {
      final text = userEmailController.text.toLowerCase();
      userEmailController.value = userEmailController.value.copyWith(
        text: text,
        selection: TextSelection(
            baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  void isSignIn() async {
    prefs = await SharedPreferences.getInstance();
    userToken = await prefs.getString('PUSH_TOKEN');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[

        Stack(
          children: <Widget>[
            Column(
                children: <Widget>[
                  Container(
                    color: button_fill_color,
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
                              }),
                        ),
                        new Container(
                            margin: EdgeInsets.only(
                                top: 20.0, right: 10.0, bottom: 40.0),
                            child: Text(user_registration, style: TextStyle(
                                color: text_color,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'GoogleSansFamily'
                            ),)
                        ),
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
                        topLeft: const Radius.circular(20.0),
                        topRight: const Radius.circular(20.0),
                      )
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        // Avatar
                        Container(
                          child: Center(
                            child: Stack(
                              children: <Widget>[
                                (avatarImageFile == null)
                                    ? (photoUrl != null &&
                                    photoUrl != ''
                                    ? GestureDetector(
                                    onTap: getImage,
                                    child: Material(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                valueColor: AlwaysStoppedAnimation<
                                                    Color>(progress_color),
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
                                )
                                    : Container(
                                  width: 100.0,
                                  height: 100.0,
                                  child: IconButton(
                                    icon: new SvgPicture.asset(
                                      'images/user_unavailable.svg',
                                      height: 70.0,
                                      width: 70.0,
                                      fit: BoxFit.cover,
                                    ),
                                    onPressed: () {
                                      getImage();
                                    },),
                                ))
                                    : GestureDetector(
                              onTap: (){
                                print('getImage');
                                getImage();
                              },
                              child :Material(
                                  child: Image.file(
                                    avatarImageFile,
                                    width: 90.0,
                                    height: 90.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(45.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                ),
                                photoUrl == '' ? IconButton(
                                  icon:new SvgPicture.asset(
                                    'images/camera.svg',
                                    height: 35.0,
                                    width: 35.0,
                                    fit: BoxFit.cover,
                                  ),
                                  onPressed: getImage,
                                  padding: EdgeInsets.all(40.0),
                                  splashColor: Colors.transparent,
                                  highlightColor: greyColor,
                                  iconSize: 20.0,
                                ) : Text(''),
                              ],
                            ),
                          ),
                          width: double.infinity,
                          margin: EdgeInsets.all(20.0),
                        ),

                        // Input
                        Column(
                          children: <Widget>[
                            // Username
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 5.0, top: 20.0, right: 5.0),
                              child: TextField(
                                obscureText: false,
                                controller: userNameController,
                                /* onChanged: (userPhoneNumber) {
                                  _mUserName = userPhoneNumber;
                                },*/
                                decoration: new InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: focused_border_color,
                                        width: 0.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: enabled_border_color,
                                        width: 0.5),
                                  ),
                                  hintText: 'Name',
                                  hintStyle: TextStyle(fontSize: HINT_TEXT_SIZE,
                                      fontFamily: 'GoogleSansFamily'),
                                ),
                              ),
                            ),

                            Container(
                              margin: const EdgeInsets.only(
                                  left: 5.0, top: 5.0, right: 5.0),
                              child: TextField(
                                obscureText: false,
                                controller: userNockNameController,
                                /* onChanged: (userPhoneNumber) {
                                  _mUserNickName = userPhoneNumber;
                                },*/
                                decoration: new InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: focused_border_color,
                                        width: 0.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: enabled_border_color,
                                        width: 0.5),
                                  ),
                                  hintText: 'Last name',
                                  hintStyle: TextStyle(fontSize: HINT_TEXT_SIZE,
                                      fontFamily: 'GoogleSansFamily'),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 5.0, top: 5.0, right: 5.0),
                              child: TextField(
                                obscureText: false,
                                controller: userEmailController,
                                /*   onChanged: (userPhoneNumber) {
                                  _mUserEmail = userPhoneNumber;
                                },*/
                                decoration: new InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: focused_border_color,
                                        width: 0.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: enabled_border_color,
                                        width: 0.5),
                                  ),
                                  hintText: 'Email',
                                  hintStyle: TextStyle(fontSize: HINT_TEXT_SIZE,
                                      fontFamily: 'GoogleSansFamily'),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.only(
                                top: 30.0, left: 5.0, right: 5.0),
//                            padding: EdgeInsets.all(30.0),
                            width: MediaQuery.of(context).size.width - 10,
                            child: SizedBox(
                              height: 45, // specific value
                              child: RaisedButton(
                                onPressed: () {
                                  if (userNameController.text != '' &&
                                      userEmailController.text != '' &&
                                      photoUrl != '') {
                                    _AddNewUser(firebaseUser);
                                  } else {
                                    print('NAN registrationValidation');
                                    registrationValidation();
                                  }
                                },
                                color: button_fill_color,
                                textColor: text_color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                                child: Text(btn_register,
                                  style: TextStyle(fontSize: BUTTON_TEXT_SIZE,
                                      fontFamily: 'GoogleSansFamily'),),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
//                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  ),
                )
            )
          ],
        ),
        // Loading
        Positioned(
          child: isLoading
              ? Container(
            child: Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(progress_color)),
            ),
            color: Colors.white.withOpacity(0.8),
          )
              : Container(),
        ),
      ],
    );
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 20);
    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = firebaseUser.uid;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Fluttertoast.showToast(msg: "Profile picture updated successfully");
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


  Future _AddNewUser(FirebaseUser firebaseUser) async {
    String loginType = 'Mobile';
    loginType += 'AccountId';
    await updateLocalListData(prefs, 'MobileNumber');
    UserLocation currentLocation = await LocationService(firebaseUser.uid,)
        .getLocation();

    // Update data to server if new user
    try {
      Firestore.instance.collection('users').document(firebaseUser.uid).setData(
          {
            'name': userNameController.text,
            'photoUrl': photoUrl,
            'email': userEmailController.text,
            'nickName': userNockNameController.text,
            'phoneNo': userPhoneNumber,
            'status': 'ACTIVE',
            'id': firebaseUser.uid,
            '$loginType': firebaseUser.uid,
            'user_token': userToken,
            'businessId': '',
            'businessType': '',
            'businessName': '',
            'createdAt':
            ((new DateTime.now()
                .toUtc()
                .microsecondsSinceEpoch) / 1000).toInt()
          });
      print('NAN ADd user');
    } catch (e) {
      print('Registration' + e);
    }
    Firestore.instance.collection('users').document(firebaseUser.uid)
        .collection('userLocation').document(firebaseUser.uid)
        .setData({
      'userLocation': new GeoPoint(
          currentLocation.latitude, currentLocation.longitude),
    });
  }


  Future<Null> updateLocalListData(SharedPreferences prefs,
      String signInType) async {
    print('updateLocalListData');
    await prefs.setString('userId', firebaseUser.uid);
    await prefs.setString('email', userEmailController.text);
    await prefs.setString('name', userNameController.text);
    await prefs.setString('nickname', userNockNameController.text);
    await prefs.setString('status', 'ACTIVE');
    await prefs.setString('photoUrl', photoUrl);
    await prefs.setInt('createdAt', ((new DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch) / 1000).toInt());
    await prefs.setString('phoneNo', userPhoneNumberWithoutCountryCode);
    await prefs.setString('BUSINESS_ID', '');
    await prefs.setString('BUSINESS_TYPE', '');
    await prefs.setString('signInType', signInType);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UsersList(signInType,
                    firebaseUser.uid, photoUrl)));
    /*  Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProfilePageSetup('MobileNumber',
                    currentUserId: firebaseUser.uid)));*/

  }


  void registrationValidation() {
    bool emailValid = false;

    if (photoUrl == '' || photoUrl == null) {
      Fluttertoast.showToast(
          msg: upload_profile);
    } else
    if (userNameController.text == '' || userNameController.text == null) {
      Fluttertoast.showToast(
          msg: enter_name);
    } else
    if (userEmailController.text == '' || userEmailController.text == null) {
      Fluttertoast.showToast(
          msg: enter_email);
    } else {
      emailValid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(userEmailController.text);
      if (!emailValid) {
        Fluttertoast.showToast(
            msg: enter_valid_email);
      }
    }
  }
}