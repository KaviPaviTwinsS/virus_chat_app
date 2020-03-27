
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
import 'package:virus_chat_app/ProfilePage.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:virus_chat_app/colors.dart';

class UserRegistrationPage extends StatelessWidget{

  String userPhoneNumber = '';
  String userPhoneNumberWithoutCountryCode ='';
  UserRegistrationPage({Key key, @required this.userPhoneNumber,@required this.userPhoneNumberWithoutCountryCode})
      : super(key: key);


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
      home: UserRegistrationState(userPhoneNumber: userPhoneNumber,userPhoneNumberWithoutCountryCode:userPhoneNumberWithoutCountryCode),
    );
  }
}

class UserRegistrationState extends StatefulWidget{

  String userPhoneNumber = '';
  String userPhoneNumberWithoutCountryCode ='';

  UserRegistrationState({Key key, @required this.userPhoneNumber,@required this.userPhoneNumberWithoutCountryCode})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UserRegistrationScreen(userPhoneNumber: userPhoneNumber,userPhoneNumberWithoutCountryCode:userPhoneNumberWithoutCountryCode);
  }

}

class UserRegistrationScreen extends State<UserRegistrationState>{

  String userPhoneNumber = '';

  TextEditingController userNameController = new TextEditingController();
  TextEditingController userNockNameController = new TextEditingController();
  TextEditingController userEmailController = new TextEditingController();

  String _mUserName,_mUserNickName,_mUserEmail ;
  String userPhoneNumberWithoutCountryCode;
  String photoUrl = '';

  bool isLoading = false;
  File avatarImageFile;
  String _mUserId =' ';

  SharedPreferences prefs;


  UserRegistrationScreen({Key key, @required this.userPhoneNumber,@required this.userPhoneNumberWithoutCountryCode});
  @override
  void initState() {
    super.initState();
    isSignIn();
    _mUserId = userPhoneNumberWithoutCountryCode;
    // Force refresh input
    setState(() {});
  }
  void isSignIn() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => new LoginSelection()));
          },
        ),
        title: Text('Profile Page setup'),
      ),
      body: Column(
        children: <Widget>[
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
//            width: double.infinity,
//            margin: EdgeInsets.all(20.0),
          ),

          Container(
            margin: const EdgeInsets.only(left: 20.0,top: 20.0, right: 20.0),
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
            margin: const EdgeInsets.only(left: 20.0,top: 5.0, right: 20.0),
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
            margin: const EdgeInsets.only(left: 20.0,top: 5.0, right: 20.0),
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
          Container(
            child: RaisedButton(onPressed: (){
              if(_mUserName != '' && _mUserEmail !='' && photoUrl!= ''){
                _AddNewUser();
              }else{
                Fluttertoast.showToast(msg: 'Please fill all details');
              }
            },
              child: Text('REGISTER ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),),
            ),
          ),
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
      ),
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
    String fileName = _mUserId ;
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


  Future _AddNewUser() async {
    String loginType = 'Mobile';
    loginType += 'AccountId';
    UserLocation currentLocation = await LocationService(_mUserId,)
        .getLocation();
    // Update data to server if new user
    Firestore.instance.collection('users').document(_mUserId).setData({
      'name': _mUserName,
      'photoUrl': photoUrl,
      'email': _mUserEmail,
      'nickName': _mUserNickName,
      'phoneNo': userPhoneNumber,
      'status': 'ACTIVE',
      'id': _mUserId,
      '$loginType': _mUserId,
      'createdAt':
      ((new DateTime.now()
          .toUtc()
          .microsecondsSinceEpoch) / 1000).toInt()
    });
    Firestore.instance.collection('users').document(_mUserId)
        .collection('userLocation').document(_mUserId)
        .setData({
      'userLocation': new GeoPoint(
          currentLocation.latitude, currentLocation.longitude),
    });
    updateLocalListData(prefs,'MobileNumber');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePageSetup('MobileNumber',
                currentUserId: _mUserId)));

  }


  Future<Null> updateLocalListData(SharedPreferences prefs, String signInType) async {
    print('updateLocalListData');
    await prefs.setString('userId', _mUserId);
    await prefs.setString('email', _mUserEmail);
    await prefs.setString('name', _mUserName);
    await prefs.setString('nickname', _mUserNickName);
    await prefs.setString('status', 'ACTIVE');
    await prefs.setString('photoUrl', photoUrl);
    await prefs.setInt('createdAt', ((new DateTime.now().toUtc().microsecondsSinceEpoch) / 1000).toInt());
    await prefs.setInt('phoneNo', int.parse(userPhoneNumberWithoutCountryCode));
    await prefs.setString('signInType', signInType);
  }
}