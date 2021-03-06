import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/Login/PhoneNumberSelection.dart';
import 'package:virus_chat_app/Login/UserRegistrationPage.dart';
import 'package:virus_chat_app/profile/ProfilePage.dart';
import 'file:///C:/Users/Nandhini%20S/Documents/virus_chat_app/lib/homePage/UsersList.dart';
import 'package:virus_chat_app/utils/CustomTextSpan.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'package:virus_chat_app/utils/constants.dart';
import 'package:virus_chat_app/business/UpgradeBusiness.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import './otp_input.dart';

class OTPScreen extends StatefulWidget {
  final String mobileNumber;
  String mobileNumWithoutCountryCode;

  String mCurrentLoginType;
  OTPScreen( {
    Key key,
    @required this.mobileNumber,
    @required this.mobileNumWithoutCountryCode,
    @required this.mCurrentLoginType
  })
      : assert(mobileNumber != null),
        super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState(mCurrentLoginType);
}

class _OTPScreenState extends State<OTPScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  /// Control the input text field.
  TextEditingController _pinEditingController = TextEditingController();

  /// Decorate the outside of the Pin.
  PinDecoration _pinDecoration =
  BoxLooseDecoration(strokeColor: greyColor2, hintText: '______');

  bool isCodeSent = false;
  String _verificationId;
  bool isLoading = false;
  String _mCurrentLoginType = '';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String userToken = '';

  _OTPScreenState(String mCurrentLoginType){
    _mCurrentLoginType = mCurrentLoginType;
  }


  @override
  void initState() {
    super.initState();
    _firebaseMessaging.getToken().then((token) =>
    {
      userToken = token,
    });
    isSignIn();
    _onVerifyCode();
  }

  void isSignIn() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    print("isValid - $isCodeSent");
    print("mobiel ${widget.mobileNumber}");
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 5.0, top: 40.0, right: 20.0),
                      child: new IconButton(
                        icon: new Icon(Icons.arrow_back_ios, color: Colors.black),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (
                                      context) => new PhoneNumberSelectionPage(_mCurrentLoginType)));
                        },
                      ),
                    )
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 20.0, top: 10.0, right: 20.0),
                    child: Text(verify_phone,
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 27,fontFamily: 'GoogleSansFamily'),
                    ),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(
                        left: 20.0, top: 50.0, right: 20.0),
                    child: customTextSpan(
                        otp_page, widget.mobileNumber)
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PinInputTextField(
                    pinLength: 6,
                    decoration: _pinDecoration,
                    controller: _pinEditingController,
                    autoFocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmit: (pin) {
                      if (pin.length == 6) {
                        _onFormSubmitted();
                      } else {
                        showToast("Invalid OTP", Colors.white);
                      }
                    },
                  ),
                ),
                /*Container(
                  width: 50.0,
                  height: 100.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.rectangle,
                      ),
                  child: TextField(
                    decoration: new InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: focused_border_color,
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: enabled_border_color,
                            width: 2.0),
                      ),
                      hintText: '_',
                    ),
                  ),
                ),*/
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                          left: 20.0, top: 10.0, right: 10.0),
                      child: Text(resend_otp,style: TextStyle(fontWeight: FontWeight.w400,fontFamily: 'GoogleSansFamily',color: hint_color_grey_light),),
                    ),
                    new GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.only(
                            top: 10.0, right: 10.0),
                        child: Text(resend_code, style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: text_color_blue,fontFamily: 'GoogleSansFamily')
                        ),
                      ),
                      onTap: () {
                        _onVerifyCode();
                      },
                    ),
                  ],
                ),

                Container(
                  margin: EdgeInsets.only(top: 40.0, left: 15.0, right: 15.0),
//                  padding: EdgeInsets.all(30.0),
                  width: double.infinity,
                  child: SizedBox(
                    height: 45, // specific value
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        if (_pinEditingController.text.length == 6) {
                          setState(() {
                            isLoading = true;
                          });
                          _onFormSubmitted();
                        } else {
                          if(_pinEditingController.text.length == 0)
                          showToast("Please enter OTP", Colors.red);
                          else
                            showToast("Please enter 6digits OTP", Colors.red);

                        }
                      },
                      color: button_fill_color,
                      textColor: text_color,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      child: Text(btn_otp_verify,
                        style: TextStyle(fontSize: 17,fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400),),
                    ),
                  ),
                )
              ],
            ),
          ),
          buildLoading(),
        ],
      )
    );
  }


  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(progress_color)),
        ),
        color: Colors.white.withOpacity(0.8),
      )
          : Container(),
    );
  }

  void showToast(message, Color color) {
    print(message);
    Fluttertoast.showToast(msg: message);
/*
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 2,
//        backgroundColor: white_color,
       *//* textColor: Colors.black,
        fontSize: 16.0*//*);*/
  }

  void _onVerifyCode() async {
    setState(() {
      isCodeSent = true;
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _firebaseAuth
          .signInWithCredential(phoneAuthCredential)
          .then((AuthResult value) {
        if (value.user != null) {
          // Handle loogged in state
          print(value.user.phoneNumber +"VERIFY___________" + _pinEditingController.text);
          navigationToUser(value.user);
          /* Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  user: value.user,
                ),
              ),
                  (Route<dynamic> route) => false);*/
        } else {
          showToast("Error validating OTP, try again", Colors.red);
        }
      }).catchError((error) {
        showToast("Try again in sometime", Colors.red);
      });
    };
    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      showToast(authException.message, Colors.red);
      setState(() {
        isCodeSent = false;
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "${widget.mobileNumber}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {
    print('ONFORM SUBMITTED ${_pinEditingController.text}');
    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: _pinEditingController.text);

    _firebaseAuth
        .signInWithCredential(_authCredential)
        .then((AuthResult value) {


      if (value.user != null) {
        // Handle loogged in state
        print(value.user.phoneNumber +"___________" + _pinEditingController.text);
        navigationToUser(value.user);
        /*   Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                user: value.user,
              ),
            ),
                (Route<dynamic> route) => false);*/
      } else {
        showToast("Error validating OTP, try again", Colors.red);
        setState(() {
          isLoading = false;
        });
      }
    }).catchError((error) {
      showToast("Something went wrong", Colors.red);
      setState(() {
        isLoading = false;
      });
    });
  }


  void navigationToUser(FirebaseUser firebaseUser) async {
    print('OTPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP ___ ${widget.mobileNumber} _____${firebaseUser.uid}');
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: firebaseUser.uid)
        .where('phoneNo',isEqualTo:widget.mobileNumber)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    print('OTPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP ${documents.length} ___ ');
    if (documents.length != 0) {
      await updateLocalListData(prefs, 'MobileNumber', documents, firebaseUser.uid);
      /*  Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
              new ProfilePage(
                  'MobileNumber', currentUserId:firebaseUser.uid)));*/
    } else {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
              new UserRegistrationPage(
                  userPhoneNumber: widget.mobileNumber,
                  userPhoneNumberWithoutCountryCode: widget
                      .mobileNumWithoutCountryCode,
                  mFirebaseUser: firebaseUser,mCurrentLoginType : _mCurrentLoginType)));
    }

//    firebaseUser.unlinkFromProvider(firebaseUser.providerId);

  }


  Future<Null> updateLocalListData(SharedPreferences prefs,
      String signInType, List<DocumentSnapshot> documents, String uid) async {
    print('________________________________________________otp ___${userToken}');
    await prefs.setString('userId', documents[0]['id']);
    await prefs.setString('email', documents[0]['email']);
    await prefs.setString('name', documents[0]['name']);
    await prefs.setString('nickname', documents[0]['nickName']);
    await prefs.setString('status', 'ACTIVE');
    await prefs.setString('photoUrl', documents[0]['photoUrl']);
    await prefs.setString('BUSINESS_ID', documents[0]['businessId']);
    await prefs.setInt('createdAt', ((new DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch) / 1000).toInt());
    await prefs.setString('phoneNo', documents[0]['phoneNo']);
    await prefs.setString('signInType', signInType);
    await prefs.setString('BUSINESS_TYPE', documents[0]['businessType']);
    await Firestore.instance
        .collection('users')
        .document(documents[0]['id'])
        .updateData({'status': 'ACTIVE','user_token' : userToken});

    if(documents[0]['businessId'] != null && documents[0]['businessId'] != '') {
      await Firestore.instance
          .collection('business')
          .document(documents[0]['businessId'])
          .updateData({'status': 'ACTIVE'});
    }

    setState(() {
      isLoading = false;
    });



    if(_mCurrentLoginType == 'phone') {
      LocationService(uid,'','');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  UsersList(
                      uid,'MobileNumber', documents[0]['photoUrl'])));
      print('updateLocalListData NANDHU');
    }else{
      if((documents[0]['businessId'] != null && documents[0]['businessId'] == '') || (documents[0]['businessType'] != null && documents[0]['businessType'] != BUSINESS_TYPE_OWNER)) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    UpgradeBusiness(uid, _mCurrentLoginType)));
      }else{
        LocationService(uid,'','');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    UsersList(
                        uid,'MobileNumber', documents[0]['photoUrl'])));
      }
    }

    /* Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProfilePageSetup('MobileNumber',
                    currentUserId: uid)));*/
  }
}