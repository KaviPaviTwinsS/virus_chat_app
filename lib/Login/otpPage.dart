
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:virus_chat_app/Login/PhoneNumberSelection.dart';
import 'package:virus_chat_app/Login/UserRegistrationPage.dart';
import 'package:virus_chat_app/ProfilePage.dart';
import 'package:virus_chat_app/utils/CustomTextSpan.dart';
import 'package:virus_chat_app/utils/strings.dart';

import './otp_input.dart';

class OTPScreen extends StatefulWidget {
  final String mobileNumber;
  String mobileNumWithoutCountryCode;
  OTPScreen({
    Key key,
    @required this.mobileNumber,
    @required this.mobileNumWithoutCountryCode
  })  : assert(mobileNumber != null),
        super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Control the input text field.
  TextEditingController _pinEditingController = TextEditingController();

  /// Decorate the outside of the Pin.
  PinDecoration _pinDecoration =
  UnderlineDecoration(enteredColor: Colors.grey, hintText: '333333');

  bool isCodeSent = false;
  String _verificationId;

  @override
  void initState() {
    super.initState();
    _onVerifyCode();
  }

  @override
  Widget build(BuildContext context) {
    print("isValid - $isCodeSent");
    print("mobiel ${widget.mobileNumber}");
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 5.0, top: 40.0, right: 20.0),
                  child: new IconButton(
                    icon: new Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (
                                  context) => new PhoneNumberSelectionPage()));
                    },
                  ),
                )
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 20.0, top: 30.0, right: 20.0),
                child: Text(verify_phone,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                ),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(left: 20.0, top: 30.0, right: 20.0),
                child: customTextSpan(
                    'Check your messages.We have sent you the pin at ',widget.mobileNumber)
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
                    showToast("Invalid OTP", Colors.red);
                  }
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0)),
                    child: Text(
                      "VERIFY",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (_pinEditingController.text.length == 6) {
                        _onFormSubmitted();
                      } else {
                        showToast("Invalid OTP", Colors.red);
                      }
                    },
                    padding: EdgeInsets.all(16.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showToast(message, Color color) {
    print(message);
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 2,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
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
          print(value.user.phoneNumber);
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

    // TODO: Change country code

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "${widget.mobileNumber}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {
    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: _pinEditingController.text);

    _firebaseAuth
        .signInWithCredential(_authCredential)
        .then((AuthResult value) {
      if (value.user != null) {
        // Handle loogged in state
        print(value.user.phoneNumber);
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
      }
    }).catchError((error) {
      showToast("Something went wrong", Colors.red);
    });
  }


  void navigationToUser(FirebaseUser firebaseUser) async{
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo:firebaseUser.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    print('documents ${documents.length}');
    if(documents.length !=0){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
              new ProfilePage(
                  'MobileNumber', currentUserId:firebaseUser.uid)));
    }else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
              new UserRegistrationPage(
                  userPhoneNumber: widget.mobileNumber,
                  userPhoneNumberWithoutCountryCode: widget.mobileNumWithoutCountryCode,mFirebaseUser : firebaseUser)));
    }
  }
}