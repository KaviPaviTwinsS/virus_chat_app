import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';

class UserRegistrationPage extends StatelessWidget {

  String userPhoneNumber = '';
  String userPhoneNumberWithoutCountryCode = '';
  FirebaseUser mFirebaseUser;

  UserRegistrationPage(
      {Key key, @required this.userPhoneNumber, @required this.userPhoneNumberWithoutCountryCode,@required this.mFirebaseUser})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
        appBar: AppBar(
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
        ),
      body: UserRegistrationState(userPhoneNumber: userPhoneNumber,
          userPhoneNumberWithoutCountryCode: userPhoneNumberWithoutCountryCode,myFirebaseUser:mFirebaseUser),
    );
  }
}

class UserRegistrationState extends StatefulWidget {

  String userPhoneNumber = '';
  String userPhoneNumberWithoutCountryCode = '';

  FirebaseUser myFirebaseUser;
  UserRegistrationState(
      {Key key, @required this.userPhoneNumber, @required this.userPhoneNumberWithoutCountryCode,@required this.myFirebaseUser})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UserRegistrationScreen(userPhoneNumber: userPhoneNumber,
        userPhoneNumberWithoutCountryCode: userPhoneNumberWithoutCountryCode,firebaseUser: myFirebaseUser);
  }

}

class UserRegistrationScreen extends State<UserRegistrationState> {

  String userPhoneNumber = '';
  FirebaseUser firebaseUser;
  TextEditingController userNameController = new TextEditingController();
  TextEditingController userNockNameController = new TextEditingController();
  TextEditingController userEmailController = new TextEditingController();

  String _mUserName =' ', _mUserNickName ='', _mUserEmail ='';

  String userPhoneNumberWithoutCountryCode ='';
  String photoUrl = '';

  bool isLoading = false;
  File avatarImageFile;

  SharedPreferences prefs;
  String userToken='';


  UserRegistrationScreen(
      {Key key, @required this.userPhoneNumber, @required this.userPhoneNumberWithoutCountryCode,@required this.firebaseUser});

  @override
  void initState() {
    super.initState();
    isSignIn();
    // Force refresh input
    setState(() {});
  }

  void isSignIn() async {
    prefs = await SharedPreferences.getInstance();
    userToken = await prefs.getString('PUSH_TOKEN');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Avatar
              Container(
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
              ),

              // Input
              Column(
                children: <Widget>[
                  // Username
                  Container(
                    margin: const EdgeInsets.only(
                        left: 20.0, top: 20.0, right: 20.0),
                    child: TextField(
                      obscureText: false,
                      controller: userNameController,
                      onChanged: (userPhoneNumber) {
                        _mUserName = userPhoneNumber;
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
                      controller: userNockNameController,
                      onChanged: (userPhoneNumber) {
                        _mUserNickName = userPhoneNumber;
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
                      controller: userEmailController,
                      onChanged: (userPhoneNumber) {
                        _mUserEmail = userPhoneNumber;
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 30.0,left: 10.0,right: 10.0),
                  padding: EdgeInsets.all(30.0),
                  width: double.infinity,
                  child : SizedBox(
                    height: 45, // specific value
                    child: RaisedButton(onPressed: () {
                      print('USER RIGISTRSST _mUserEmail$_mUserEmail ___mUserName$_mUserName __photoUrl$photoUrl');
                      if (_mUserName != '' && _mUserEmail != '' &&
                          photoUrl != '') {
                        _AddNewUser(firebaseUser);
                      } else {
                        print('NAN registrationValidation');
                        registrationValidation();
                      }
                    },
                      color: facebook_color,
                      textColor: text_color,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                      ),
                      child: Text(btn_register,
                        style: TextStyle(fontSize: 17),),
                    ),
                  ),
                ),
              )
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
    String fileName = firebaseUser.uid;
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


  Future _AddNewUser(FirebaseUser firebaseUser) async {
    String loginType = 'Mobile';
    loginType += 'AccountId';
    updateLocalListData(prefs, 'MobileNumber');

    // Update data to server if new user
    try {
      Firestore.instance.collection('users').document(firebaseUser.uid).setData(
          {
            'name': _mUserName,
            'photoUrl': photoUrl,
            'email': _mUserEmail,
            'nickName': _mUserNickName,
            'phoneNo': userPhoneNumber,
            'status': 'ACTIVE',
            'id': firebaseUser.uid,
            '$loginType': firebaseUser.uid,
            'user_token': userToken,
            'createdAt':
            ((new DateTime.now()
                .toUtc()
                .microsecondsSinceEpoch) / 1000).toInt()
          });
      print('NAN ADd user');

    }catch(e){
      print('Registration'+e);
    }
    UserLocation currentLocation = await LocationService(firebaseUser.uid,)
        .getLocation();
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
    await prefs.setString('email', _mUserEmail);
    await prefs.setString('name', _mUserName);
    await prefs.setString('nickname', _mUserNickName);
    await prefs.setString('status', 'ACTIVE');
    await prefs.setString('photoUrl', photoUrl);
    await prefs.setInt('createdAt', ((new DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch) / 1000).toInt());
    await prefs.setString('phoneNo', userPhoneNumberWithoutCountryCode);
    await prefs.setString('signInType', signInType);
  /*  Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProfilePageSetup('MobileNumber',
                    currentUserId: firebaseUser.uid)));*/
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UsersList(signInType,
                    firebaseUser.uid,photoUrl)));
  }


  void registrationValidation(){
    bool emailValid = false;

    print('_mUserEmail $_mUserEmail');
    if(photoUrl =='' || photoUrl == null){
      Fluttertoast.showToast(
          msg: upload_profile);
    } else if(_mUserName == '' || _mUserName == null) {
      Fluttertoast.showToast(
          msg: enter_name);
    }else if(_mUserEmail == '' || _mUserEmail == null){
      Fluttertoast.showToast(
          msg: enter_email);
    }else{
      emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_mUserEmail);
      if(!emailValid){
        Fluttertoast.showToast(
            msg: enter_valid_email);
      }
    }

  }
}