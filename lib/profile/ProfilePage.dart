import 'dart:io';
import 'package:intl/intl.dart';


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
import 'package:virus_chat_app/business/AddEmployee.dart';
import 'package:virus_chat_app/business/UpgradeBusiness.dart';
import 'package:virus_chat_app/tweetPost/MakeTweetPost.dart';
import 'package:virus_chat_app/tweetPost/NewTweetPost.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'package:virus_chat_app/Login/PhoneNumberSelection.dart';
import '../utils/constants.dart';
import 'package:virus_chat_app/version2/settingsPage/SettingsPage.dart';

/*
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
}*/

class ProfilePageSetup extends StatefulWidget {
  final String currentUserId;
  String userSigninType;

  ProfilePageSetup(String signinType, {Key key, @required this.currentUserId})
      : super(key: key) {
    userSigninType = signinType;
  }

  @override
  State<StatefulWidget> createState() {
    return ProfilePageState(userSigninType, currentUserId);
  }
}

class ProfilePageState extends State<ProfilePageSetup> {
  SharedPreferences prefs;
  String name = '';
  String nickName = '';
  String signinType = '';
  String userId = '';
  String photoUrl = '';
  String mNewPhotoUrl = '';
  File avatarImageFile;
  bool isLoading = false;
  String userEmail = '';
  String userPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  String mobileNumber = '';
  String businessId = '';
  String businessName = '';
  String businessNumber = '';
  String businessAddress = '';
  String businessImage = '';
  String _mBusinessType = '';
  String businessCreatedTime = '';
  int _noOfEmployees = 0;
  TextEditingController controllerName = new TextEditingController();
  TextEditingController controllerNickName = new TextEditingController();
  TextEditingController controllerEmail = new TextEditingController();
  TextEditingController controllerNewPassword = new TextEditingController();
  TextEditingController controllerConfirmPassword = new TextEditingController();
  TextEditingController controllerMobileNumber = new TextEditingController();

  FocusNode myFocusNode;

  LoginSelectionOption loginSelectionOption;
  var facebookSignup;

  bool isUploadInProgress = false;

  ProfilePageState(String userSigninType, String currentUserId) {
    signinType = userSigninType;
    userId = currentUserId;
  }

  @override
  void initState() {
    readLocal();
    loginSelectionOption = LoginSelectionOption();
    facebookSignup = new FacebookSignup();
    myFocusNode = new FocusNode();
    myFocusNode.addListener(onFocusChange);

    super.initState();
  }


  void onFocusChange() {
    if (myFocusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
//        isShowSticker = false;
      });
    }
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    fetchAllUsersData();
    userId = prefs.getString('userId');
    signinType = prefs.getString('signInType');
    userEmail = prefs.getString('email');
    photoUrl = prefs.getString('photoUrl');
    mNewPhotoUrl = prefs.getString('photoUrl');
    businessId = prefs.getString('BUSINESS_ID');
    print('businessId $businessId');
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

    // Force refresh input
    setState(() {});
  }

  Future getBusinessDetails() async {
    print('businessName_____________$businessName');
    if (businessId != '' && ((businessName == null || businessName == '') ||
        (businessImage == null || businessImage == ''))) {
      var document = await Firestore.instance.collection('business').document(
          businessId).get();
      if (document.exists) {
        var businessDetails = document.data;
        setState(() {
          isLoading = false;
          this.businessId = businessDetails['businessId'];
          this.businessName = businessDetails['businessName'];
          this.businessAddress = businessDetails['businessAddress'];
          this.businessNumber = businessDetails['businessNumber'];
          this.businessImage = businessDetails['photoUrl'];
          this.businessCreatedTime = businessDetails['createdAt'].toString();
          this._noOfEmployees = businessDetails['employeeCount'];
        });
        await prefs.setString('BUSINESS_ID', businessId);
        await prefs.setString('BUSINESS_NAME', businessName);
        await prefs.setString('BUSINESS_ADDRESS', businessAddress);
        await prefs.setString('BUSINESS_NUMBER', businessNumber);
        await prefs.setString('BUSINESS_IMAGE', businessImage);
        await prefs.setString('BUSINESS_CREATED_AT', businessCreatedTime);
        await prefs.setInt('BUSINESS_EMPLOYEES_COUNT', _noOfEmployees);
      }
    } else {
      setState(() {
        isLoading = false;
        businessId = prefs.getString('BUSINESS_ID');
        businessName = prefs.getString('BUSINESS_NAME');
        businessAddress = prefs.getString('BUSINESS_ADDRESS');
        businessNumber = prefs.getString('BUSINESS_NUMBER');
        businessImage = prefs.getString('BUSINESS_IMAGE');
        businessCreatedTime = prefs.getString('BUSINESS_CREATED_AT');
        _noOfEmployees = prefs.getInt('BUSINESS_EMPLOYEES_COUNT');
      });
    }

    print(
        'businessName__________________ $businessId __________$businessImage');
  }

  void onBackpress() {
//    Navigator.pop(context);
    navigationPage();
  }

  @override
  Widget build(BuildContext context) {
    businessId = prefs.getString('BUSINESS_ID');
    print('profile build $businessId');
    if (businessId != null && businessId != '')
      fetchAllUsersData();

    return WillPopScope(
        onWillPop: () {
          onBackpress();
        },
        child: Scaffold(
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
                  SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment
                                .center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    top: 40.0, bottom: 10.0),
                                child: new IconButton(
                                    icon: new SvgPicture.asset(
                                      'images/back_icon.svg',
                                      width: 20.0,
                                      height: 20.0,
                                    ),
                                    onPressed: () {
//                                    Navigator.pop(context);
                                      navigationPage();
                                    }),
                              ),
                              new Container(
                                  margin: EdgeInsets.only(
                                      top: 40.0, right: 10.0, bottom: 10.0),
                                  child: Text(profile_header, style: TextStyle(
                                      color: black_color,
                                      fontSize: TOOL_BAR_TITLE_SIZE,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'GoogleSansFamily'),)
                              ),

                              Spacer(),
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: 40, bottom: 10.0, right: 10.0),
                                  child: IconButton(
                                    icon: new SvgPicture.asset(
                                      'images/logout.svg', height: 20.0,
                                      width: 20.0,
                                      color: black_color,
                                    ),
                                    onPressed: () {
                                      /* Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (
                                                context) => new SettingsPage()));*/
                                      showLogoutAlertDialog(context);
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                          Divider(color: divider_color,thickness: 1.0,),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Center(
                                    child: Stack(
                                      children: <Widget>[
                                        (avatarImageFile == null)
                                            ? ((photoUrl != null &&
                                            photoUrl != '') ||
                                            photoUrl != mNewPhotoUrl
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
                                                          progress_color),
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
                                          icon: Container(
                                            child: new SvgPicture.asset(
                                              'images/camera.svg',
                                              height: 35.0,
                                              width: 35.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          onPressed: getImage,
                                          padding: EdgeInsets.all(40.0),
                                          splashColor: Colors.transparent,
                                          highlightColor: greyColor,
                                          iconSize: 20.0,
                                        ) : ((photoUrl != '' &&
                                            mNewPhotoUrl != '') &&
                                            photoUrl != mNewPhotoUrl)
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
                                                          progress_color),
                                                    ),
                                                    width: 70.0,
                                                    height: 70.0,
                                                    padding: EdgeInsets.all(
                                                        20.0),
                                                  ),
                                              imageUrl: mNewPhotoUrl,
                                              width: 70.0,
                                              height: 70.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(45.0)),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                        )
                                            : Text('')
                                      ],
                                    ),
                                  ),
                                  width: double.infinity,
                                  margin: EdgeInsets.all(20.0),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
/*                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 10.0,
                                          right: 10.0,
                                          top: signinType != 'MobileNumber'
                                              ? 20.0
                                              : 0.0),
                                      child: Text('First name'.toUpperCase(),
                                        style: TextStyle(
                                            fontFamily: 'GoogleSansFamily',color: text_color_grey,fontSize: 12.0),),
                                    ),*/
                                    Container(
                                      child: TextField(
                                        decoration: new InputDecoration(
                                          contentPadding: new EdgeInsets.all(
                                              15.0),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: focused_border_color,
                                                width: 0.5),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: greyColor, width: 0.5),
                                          ),
                                          labelText: capitalize('First name'),
                                          hintStyle: TextStyle(
                                              fontSize: HINT_TEXT_SIZE,
                                              fontFamily: 'GoogleSansFamily'),
                                        ),
                                        controller: controllerName,
                                        onChanged: (value) {
                                          name = value;
                                        },
                                        textInputAction: TextInputAction.next,
                                        focusNode: myFocusNode,
                                        /* onChanged: (value) {
                                          name = value;
                                        },*/
                                      ),
                                      margin: EdgeInsets.only(
                                          left: 20.0, right: 20.0, top: 10.0),
                                    ),
                                  ],
                                ),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      /*Container(
                                        margin: EdgeInsets.only(
                                            left: 10.0, right: 10.0, top: 25.0),
                                        child: Text('Last name'.toUpperCase(),
                                          style: TextStyle(
                                              fontFamily: 'GoogleSansFamily',color: text_color_grey,fontSize: 12.0),),
                                      ),*/
                                      Container(
                                        child: TextField(
                                          decoration: new InputDecoration(
                                            contentPadding: new EdgeInsets.all(
                                                15.0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: focused_border_color,
                                                  width: 0.5),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: greyColor, width: 0.5),
                                            ),
                                            labelText: capitalize('Last Name'),
                                            hintStyle: TextStyle(
                                                fontSize: HINT_TEXT_SIZE,
                                                fontFamily: 'GoogleSansFamily'),
                                          ),
                                          controller: controllerNickName,
                                          textInputAction: TextInputAction.next,
                                          onChanged: (value) {
                                            nickName = value;
                                          },
                                        ),
                                        margin: EdgeInsets.only(
                                            left: 20.0, right: 20.0, top: 30.0),
                                      ),
                                    ]
                                ),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      /*Container(
                                        margin: EdgeInsets.only(
                                            left: 10.0, right: 10.0, top: 25.0),
                                        child: Text('Email'.toUpperCase(),
                                          style: TextStyle(
                                              fontFamily: 'GoogleSansFamily',color: text_color_grey,fontSize: 12.0),),
                                      ),*/
                                      Container(
                                        decoration: new BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: signinType == 'facebook'
                                                ? greyColor2
                                                : (signinType == 'google' &&
                                                userEmail != '')
                                                ? greyColor2
                                                : white_color
                                        ),
                                        child: TextField(
                                          enabled: signinType == 'facebook'
                                              ? false
                                              : (signinType == 'google' &&
                                              userEmail != '') ? false : true,
                                          decoration: new InputDecoration(
                                            contentPadding: new EdgeInsets.all(
                                                15.0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: focused_border_color,
                                                  width: 0.5),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: greyColor, width: 0.5),
                                            ),
                                            labelText: capitalize('Email'),
                                            hintStyle: TextStyle(
                                                fontSize: HINT_TEXT_SIZE,
                                                fontFamily: 'GoogleSansFamily'),
                                          ),
                                          controller: controllerEmail,
                                          textInputAction: TextInputAction.done,
                                          onChanged: (value) {
                                            userEmail = value;
                                          },
                                          keyboardType: TextInputType
                                              .emailAddress,
                                        ),
                                        margin: EdgeInsets.only(
                                            left: 20.0, right: 20.0, top: 30.0),
                                      ),
                                    ]
                                ),

                                signinType == 'MobileNumber' ? Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                     /* Container(
                                        margin: EdgeInsets.only(
                                            left: 20.0, right: 20.0, top: 25.0),
                                        child: Text(
                                          'Mobile number'.toUpperCase(),
                                          style: TextStyle(
                                            fontFamily: 'GoogleSansFamily',
                                            color: text_color_grey,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w400,),
                                        ),
                                      ),*/


                                      Container(
                                        child: TextField(
                                          readOnly: true,
                                          decoration: new InputDecoration(
                                            contentPadding: new EdgeInsets.all(
                                                15.0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: focused_border_color,
                                                  width: 0.5),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: greyColor, width: 0.5),
                                            ),
                                            labelText: capitalize('Mobile number'),
                                            hintStyle: TextStyle(
                                                fontSize: HINT_TEXT_SIZE,
                                                fontFamily: 'GoogleSansFamily'),
                                          ),
                                          controller: controllerMobileNumber,
                                          textInputAction: TextInputAction.done,
                                          onChanged: (value) {
                                            mobileNumber = value;
                                          },
                                        ),
                                        margin: EdgeInsets.only(
                                            left: 20.0, right: 20.0, top: 30.0),
                                      ),
                                     /* Container(
                                        decoration: new BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: unfocused_field_color
                                        ),
                                        child: TextField(
                                          enabled: false,
                                          controller: controllerMobileNumber,
                                          decoration: new InputDecoration(
                                            contentPadding: new EdgeInsets.all(
                                                15.0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: focused_border_color,
                                                  width: 0.5),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: greyColor, width: 0.5),
                                            ),
                                            hintText: capitalize(
                                                'Mobile number'),
                                            hintStyle: TextStyle(
                                                fontSize: HINT_TEXT_SIZE,
                                                fontFamily: 'GoogleSansFamily'),
                                          ),
                                        ),
                                        margin: EdgeInsets.only(
                                            left: 20.0, right: 20.0, top: 5.0),
                                      ),*/
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
                                      textColor: button_fill_color,
                                      hoverColor: button_fill_color,
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
                                            top: signinType == 'MobileNumber'
                                                ? 30.0
                                                : 30.0,
                                            left: 15.0,
                                            right: 15.0),
                                        width: double.infinity,
                                        child: SizedBox(
                                          height: 45, // specific value
                                          child: RaisedButton(
                                            color: button_fill_color,
                                            textColor: text_color,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: new BorderRadius
                                                  .circular(
                                                  30.0),
                                            ),
                                            child: Text('Update Profile',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'GoogleSansFamily'),),
                                            onPressed: () {
                                              if (!isUploadInProgress) {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                name = controllerName.text;
                                                if (name != '' ||
                                                    nickName != '' ||
                                                    photoUrl != '' ||
                                                    userEmail != '' ||
                                                    photoUrl != mNewPhotoUrl) {
                                                  if (name == '') {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                    Fluttertoast.showToast(
                                                        msg: enter_names);
                                                  }/* else if (nickName == '') {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                    Fluttertoast.showToast(
                                                        msg: enter_nickname);
                                                  } */else if (userEmail == '') {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                    Fluttertoast.showToast(
                                                        msg: enter_Email);
                                                  }
                                                  else if ((prefs.getString(
                                                      'name') !=
                                                      name && name != '') ||
                                                      (nickName != '' &&
                                                          prefs.getString(
                                                              'nickname') !=
                                                              nickName) ||
                                                      (mNewPhotoUrl !=
                                                          photoUrl &&
                                                          photoUrl != '') ||
                                                      (prefs.getString(
                                                          'email') !=
                                                          userEmail &&
                                                          userEmail != '') ||
                                                      photoUrl !=
                                                          mNewPhotoUrl) {
                                                    bool emailValid = RegExp(
                                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                        .hasMatch(userEmail);
                                                    if (!emailValid) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      Fluttertoast.showToast(
                                                          msg: enter_valid_email);
                                                    } else {
                                                      Firestore.instance
                                                          .collection(
                                                          'users')
                                                          .document(userId)
                                                          .updateData({
                                                        'photoUrl': mNewPhotoUrl,
                                                        'name': name,
                                                        'nickName': nickName,
                                                        'email': userEmail
                                                      }).whenComplete(() =>
                                                      {
                                                        storeLocalDataInternal(
                                                            mNewPhotoUrl, name,
                                                            nickName,
                                                            userEmail),
                                                        Fluttertoast.showToast(
                                                            msg: update_success),
                                                        isLoading = false,

                                                        // Force refresh input
                                                        setState(() {}),

                                                      });
                                                    }
                                                  } else {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                    Fluttertoast.showToast(
                                                        msg: no_data_change);
                                                  }
                                                } else {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                  Fluttertoast.showToast(
                                                      msg: no_data_change);
                                                }
                                              } else {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                Fluttertoast.showToast(
                                                    msg: 'Profile picture upload in progress');
                                              }
                                            },
                                          ),
                                        )
                                    )
                                ),
                                (businessId != '' && businessId != null  && _mBusinessType == BUSINESS_TYPE_OWNER )
                                    ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 10.0, top: 15.0),
                                      child: Divider(),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 20.0, top: 10.0, bottom: 15.0),
                                      child: Text(business, style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'GoogleSansFamily'),),
                                    ),
                                    businessImage != null && businessImage != ''
    ? Center(
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 15.0,
                                              left: 20.0,
                                              right: 20.0),
                                          child: Material(
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                    child: CircularProgressIndicator(
                                                      valueColor: AlwaysStoppedAnimation<
                                                          Color>(
                                                          progress_color),
                                                    ),
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color: greyColor2,
                                                      borderRadius: BorderRadius
                                                          .all(
                                                        Radius.circular(5.0),
                                                      ),
                                                    ),
                                                  ),
                                              errorWidget: (context, url,
                                                  error) =>
                                                  Material(
                                                    child: /* Image.asset(
                                                      'images/img_not_available.jpeg',
                                                      width: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width - 30,
                                                      height: 200.0,
                                                      fit: BoxFit.cover,
                                                    ),*/
                                                    new SvgPicture.asset(
                                                      'images/user_unavailable.svg',
                                                      height: 250.0,
                                                      width: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width - 30,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    borderRadius: BorderRadius
                                                        .all(
                                                      Radius.circular(5.0),
                                                    ),
                                                    clipBehavior: Clip.hardEdge,
                                                  ),
                                              imageUrl: businessImage,
                                              width: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width - 30,
                                              height: 250.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15.0)),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                        )
                                    )
                                        : Text(''),
                                    businessName != null && businessName != ''
                                        ? Container(
                                      margin: EdgeInsets.only(
                                          left: 20.0, bottom: 10.0),
                                      child: Text(capitalize(businessName),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'GoogleSansFamily'),),
                                    )
                                        : Text(''),
                                    businessAddress != null &&
                                        businessAddress != '' ? Container(
                                      margin: EdgeInsets.only(
                                          left: 20.0, bottom: 15.0),
                                      child: Text(businessAddress,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'GoogleSansFamily',
                                            color: hint_color_grey_dark),),
                                    ) : Text(''),
                                    businessCreatedTime != null &&
                                        businessCreatedTime != '' ? Container(
                                      margin: EdgeInsets.only(
                                          left: 20.0, bottom: 15.0),
                                      child: Text(created_at + '\t' +
                                          DateFormat('dd-MM-yyyy')
                                              .format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(
                                                    businessCreatedTime)),),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'GoogleSansFamily',
                                            color: hint_color_grey_light),),
                                    ) : Text(''),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: <Widget>[
                                        _noOfEmployees != null  ? Align(
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              left: 20.0,),
                                            child: Text(
                                              _noOfEmployees.toString() +
                                                  '\t' + employees,
                                              style: TextStyle(
                                                  fontFamily: 'GoogleSansFamily'),),
                                          ),
                                        ) : Text(''),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddEmployee(
                                                            signinType, userId,
                                                            businessId)));
                                          },
                                          child: Container(
                                            child: Row(
//                                                mainAxisAlignment: MainAxisAlignment.end,
//                                                crossAxisAlignment: CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10.0,
                                                      bottom: 20.0),
                                                  child: new SvgPicture.asset(
                                                    'images/employee_add.svg',
                                                    height: 20.0,
                                                    width: 20.0,
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 20.0,
                                                      bottom: 20.0),
                                                  child: Text(add_employee,
                                                    style: TextStyle(
                                                        color: button_fill_color,
                                                        fontSize: 15.0,
                                                        fontFamily: 'GoogleSansFamily'),),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
//                                ],
                                  ],
                                )
                                    : Text(''),

                                businessId == '' || businessId == null/* || (businessId != ''  && _mBusinessType == BUSINESS_TYPE_EMPLOYEE )*/ ? Align(
                                    alignment: Alignment.bottomRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        print('Business click');
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpgradeBusiness(
                                                        userId, '')));
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .end,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .end,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(
                                                right: 10.0,
                                                top: signinType !=
                                                    'MobileNumber' ? 5.0 : 0.0,
                                                bottom: signinType !=
                                                    'MobileNumber'
                                                    ? 15.0
                                                    : 15.0),
                                            child: new SvgPicture.asset(
                                              'images/business_highlight.svg',
                                              height: 20.0,


                                              width: 20.0,
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                right: 20.0,
                                                top: signinType !=
                                                    'MobileNumber' ? 5.0 : 0.0,
                                                bottom: signinType !=
                                                    'MobileNumber'
                                                    ? 15.0
                                                    : 15.0),
                                            child: Text(upgrade_business,
                                              style: TextStyle(
                                                  color: button_fill_color,
                                                  fontSize: 15.0,
                                                  fontFamily: 'GoogleSansFamily',
                                                  fontWeight: FontWeight
                                                      .w500),),
                                          )

                                        ],
                                      ),
                                    )
                                ) : Text(''),
                              ]
                          ),
                          // Loading
                          /*  Positioned(
                  child: isLoading
                      ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              progress_color)),
                    ),
//                    color: Colors.white.withOpacity(0.8),
                  )
                      : Container(),
                ),*/
                        ],
                      )
                  )
                ]
            )
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
                    children:
                    <Widget>[
                      Text('Are you sure want to logout?',
                        style: TextStyle(fontFamily: 'GoogleSansFamily'),),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[

                            RaisedButton(
                              color: white_color,
                              child: Text("No", style: TextStyle(
                                  fontFamily: 'GoogleSansFamily')),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true).pop(
                                    'dialog');
                              },
                            ),
                            RaisedButton(
                              child: Text("Yes", style: TextStyle(
                                  fontFamily: 'GoogleSansFamily')),
                              color: white_color,
                              onPressed: () {
                                if (signinType == 'google') {
                                  loginSelectionOption.handleGoogleSignOut(
                                      prefs);
                                  prefs.setString('userId', '');
                                }
                                else if (signinType == 'facebook')
                                  facebookSignup.facebookLogout(context, prefs);
                                else {


                                }
                                /*  else if (signinType == 'MobileNumber')
                                  clearLocalData();*/
                                prefs.setString('signInType', '');

                                Navigator.of(context, rootNavigator: true).pop(
                                    'dialog');
                                _updatestatus();
                                clearLocalData();
                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                                    PhoneNumberSelectionPage('phone')), (Route<dynamic> route) => false);
                              /*  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (
                                            context) => new PhoneNumberSelectionPage('phone')));*/
                                /* Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginSelection()
                                    ),
                                    ModalRoute.withName("/HomeScreen")
                                );*/

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
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0,
                              fontFamily: 'GoogleSansFamily'),),
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    left: 20.0, right: 30.0, top: 20.0),
                                child: Text('New password'.toUpperCase(),
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansFamily')),
                              ),
                              Container(
                                child: TextField(
                                  decoration: new InputDecoration(
                                    contentPadding: new EdgeInsets.all(
                                        15.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: focused_border_color,
                                          width: 0.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: greyColor2, width: 0.5),
                                    ),
                                    hintText: 'Enter new password',
                                    hintStyle: TextStyle(
                                        fontSize: HINT_TEXT_SIZE,
                                        fontFamily: 'GoogleSansFamily'),
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
                                child: Text('Confirm password'.toUpperCase(),
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansFamily')),
                              ),
                              Container(
                                child: TextField(
                                  decoration: new InputDecoration(
                                    contentPadding: new EdgeInsets.all(
                                        15.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: focused_border_color,
                                          width: 0.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: greyColor2, width: 0.5),
                                    ),
                                    hintText: 'Enter confirm password',
                                    hintStyle: TextStyle(
                                        fontSize: HINT_TEXT_SIZE,
                                        fontFamily: 'GoogleSansFamily'),
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
                                textColor: button_fill_color,
                                hoverColor: button_fill_color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(
                                      18.0),
                                ),
                                child: Text('Cancel', style: TextStyle(
                                    fontFamily: 'GoogleSansFamily')),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15.0,),
                              child: RaisedButton(
                                color: button_fill_color,
                                textColor: text_color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(
                                      18.0),
                                ),
                                child: Text('Save', style: TextStyle(
                                    fontFamily: 'GoogleSansFamily')),
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
      child: Text("Update", style: TextStyle(fontFamily: 'GoogleSansFamily')),
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
      child: Text("Cancel", style: TextStyle(fontFamily: 'GoogleSansFamily')),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
          "Change Password", style: TextStyle(fontFamily: 'GoogleSansFamily')),
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
                      hintStyle: TextStyle(fontSize: HINT_TEXT_SIZE,
                          fontFamily: 'GoogleSansFamily'),
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
                      hintStyle: TextStyle(fontSize: HINT_TEXT_SIZE,
                          fontFamily: 'GoogleSansFamily'),
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
                        child: Text("Update",
                            style: TextStyle(fontFamily: 'GoogleSansFamily')),
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
                        child: Text("Cancel",
                            style: TextStyle(fontFamily: 'GoogleSansFamily')),
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
    print(
        'PROFILE _updatestatus ___________user $userId ______business $businessId');
    await prefs.setString('USERSTATUS', 'LOGOUT');
    await Firestore.instance
        .collection('users')
        .document(userId)
        .updateData({'status': 'LoggedOut'});

    if (businessId != null && businessId != '') {
      await Firestore.instance
          .collection('business')
          .document(businessId)
          .updateData({'status': 'LoggedOut'});
    }

    await clearLocalData();
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
    print('get IMAGE');
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
    setState(() {
      isLoading = true;
    });
    isUploadInProgress = true;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
//          photoUrl = downloadUrl;
          mNewPhotoUrl = downloadUrl;
          print('DOWNLOAD URL PROFILE $photoUrl');
          isUploadInProgress = false;
          Fluttertoast.showToast(msg: "Profile picture Upload successfully");
          setState(() {
            isLoading = false;
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          isUploadInProgress = false;
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        isUploadInProgress = false;
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      isUploadInProgress = false;
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void navigationPage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => new UsersList(signinType, userId, photoUrl)));
  }

  Future fetchAllUsersData() async {
    name = controllerName.text;
    if (prefs.containsKey('userId') && prefs.getString('userId') != null) {
      if (prefs.getString('userId') == '' ||
          prefs.getString('BUSINESS_ID') == '') {
        print('NANDHU FETCH USER');
        setState(() {
          isLoading = true;
        });
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
          if (profile['phoneNo'] != null && signinType == 'MobileNumber')
            this.mobileNumber = profile['phoneNo'];
          this.businessId = profile['businessId'];
          this._mBusinessType = profile['businessType'];
          this.controllerName = new TextEditingController(text: name);
          this.controllerNickName = new TextEditingController(text: nickName);
          this.controllerEmail = new TextEditingController(text: userEmail);
        });
      } else {
        print('NANDHU FETCH USER_________________________');
        setState(() {
          this.name = prefs.getString('name');
          this.photoUrl = prefs.getString('photoUrl');
          this.userEmail = prefs.getString('email');
          this.nickName = prefs.getString('nickname');
          this.userPassword = prefs.getString('password');
          this.businessId = prefs.getString('BUSINESS_ID');
          this.businessCreatedTime = prefs.getString('BUSINESS_CREATED_AT');
          this.businessName = prefs.getString('BUSINESS_NAME');
          this.businessAddress = prefs.getString('BUSINESS_ADDRESS');
          this.businessImage = prefs.getString('BUSINESS_IMAGE');
          this._mBusinessType = prefs.getString('BUSINESS_TYPE');
          if (prefs.getString('phoneNo') != null &&
              signinType == 'MobileNumber')
            this.mobileNumber = prefs.getString('phoneNo');
          this.controllerName = new TextEditingController(text: name);
          this.controllerNickName = new TextEditingController(text: nickName);
          this.controllerEmail = new TextEditingController(text: userEmail);
        });
      }
    } else {
      print('NANDHU FETCH USER____________NOT NULL');
      this.isLoading = true;
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
        this.businessId = profile['businessId'];
        this._mBusinessType = profile['businessType'];
        if (profile['phoneNo'] != null && signinType == 'MobileNumber')
          this.mobileNumber = profile['phoneNo'];
        this.controllerName = new TextEditingController(text: name);
        this.controllerNickName = new TextEditingController(text: nickName);
        this.controllerEmail = new TextEditingController(text: userEmail);
      });
    }
    if (businessId != '' && businessId != null) {
      isLoading = true;
      getBusinessDetails();
    } else {
      isLoading = false;
    }
  }


  Future storeLocalData(Map<String, dynamic> profile) async {
    await prefs.setString('BUSINESS_ID', profile['businessId']);
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
    setState(() {
      isLoading = false;
    });
    setState(() {
      this.name = name;
      this.photoUrl = photoUrl;
      this.userEmail = email;
      this.nickName = nickName;
      this.controllerName = new TextEditingController(text: name);
      this.controllerNickName = new TextEditingController(text: nickName);
      this.controllerEmail = new TextEditingController(text: userEmail);
    });
  }

  Future<Null> clearLocalData() async {
    await prefs.setString('email', '');
    await prefs.setString('name', '');
    await prefs.setString('userId', '');
    await prefs.setString('nickname', '');
    await prefs.setString('status', '');
    await prefs.setString('photoUrl', '');
    await prefs.setString('createdAt', '');
    await prefs.setInt('phoneNo', 0);
    await prefs.setString('signInType', '');
    await prefs.setString('BUSINESS_ID', '');
    await prefs.setString('BUSINESS_NAME', '');
    await prefs.setString('BUSINESS_ADDRESS', '');
    await prefs.setString('BUSINESS_NUMBER', '');
    await prefs.setString('BUSINESS_IMAGE', '');
    await prefs.setString('BUSINESS_CREATED_AT', '');
    await prefs.setInt('BUSINESS_EMPLOYEES_COUNT', 0);
//    LocationService('').locationStream;
  }
}
