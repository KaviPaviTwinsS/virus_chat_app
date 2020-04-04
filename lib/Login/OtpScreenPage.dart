import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/Login/PhoneNumberSelection.dart';
import 'package:virus_chat_app/Login/UserRegistrationPage.dart';
import 'package:virus_chat_app/Login/otp_input.dart';
import 'package:virus_chat_app/ProfilePage.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/phone_auth/code.dart';
import 'package:virus_chat_app/utils/CustomTextSpan.dart';
import 'package:virus_chat_app/utils/strings.dart';

abstract class otpUpdateListener {
}

class OtpScreenPage extends StatelessWidget {
  String mPhoneNumber = '';
  String mCountryCode = '';

  OtpScreenPage(String countryCode, String phoneNumber) {
    mCountryCode = countryCode;
    mPhoneNumber = phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: OtpApplyPage(mCountryCode, mPhoneNumber),
    );
    /*  return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
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
      home: OtpApplyPage(mPhoneNumber),
    );*/
  }
}

class OtpApplyPage extends StatefulWidget {
  String phoneNumber = '';
  String _mCountryCode = '';

  OtpApplyPage(String mCountryCode, String mPhoneNumber) {
    _mCountryCode = mCountryCode;
    phoneNumber = mPhoneNumber;
  }

  @override
  State<StatefulWidget> createState() {
    return OtpApplyPageState(_mCountryCode, phoneNumber);
  }
}

class OtpApplyPageState extends State<OtpApplyPage>
    implements otpUpdateListener {
  String mPhoneNumber = '';
  String mCountryCode = '';
  TextEditingController userOtpController = new TextEditingController();

  String _userOtp = '';
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String errorMessage = '';
  String verificationId;
  String smsOTP;
  SharedPreferences prefs;

  /// Control the input text field.
  TextEditingController _pinEditingController = TextEditingController();

  /// Decorate the outside of the Pin.
  PinDecoration _pinDecoration =
  UnderlineDecoration(enteredColor: Colors.grey, hintText: '333333');
  bool isCodeSent = false;
  String _verificationId;

  void otpUpdate(String verifyId, String smsOtp) {
    print('otpUpdate $verifyId ____ $smsOtp');
    verificationId = verifyId;
    smsOTP = smsOtp;
  }

  @override
  void initState() {
    isSignIn();
    super.initState();
    _onVerifyCode();
  }


  void isSignIn() async {
    prefs = await SharedPreferences.getInstance();
  }


  OtpApplyPageState(String _mCountryCode, String phoneNumber) {
    mCountryCode = _mCountryCode;
    mPhoneNumber = phoneNumber;
  }


  @override
  Widget build(BuildContext context) {
    return Column(
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
                otp_page,
                mPhoneNumber)
        ),
     /*   Container(
          margin: const EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
          child: TextField(
            obscureText: false,
            controller: userOtpController,
            onChanged: (userPhoneNumber) {
              _userOtp = userPhoneNumber;
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
              hintText: 'Otp',
            ),
            keyboardType: TextInputType.phone,
          ),
        ),*/
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
        Row(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(
                    left: 20.0, top: 50.0, right: 20.0),
                child: Text(resend_otp),
              ),
            ),
            new GestureDetector(
              child: Container(
                margin: const EdgeInsets.only(
                    left: 10.0, top: 10.0, right: 20.0),
                child: Text(resend_code, style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.blue,)
                ),
              ),
              onTap: () {
                verifyPhone();
              },
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(
              left: 10.0, top: 10.0, right: 20.0),
          child: RaisedButton(onPressed: () {
            firebaseAuth.currentUser().then((user) {
              print('USERRRRRRRRRRR $user');
              if (user != null) {
                signIn();
              } else {
                loginUser();
              }
            });
          },
            child: Text('VERIFY',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),),
          ),
        )

      ],
    );
  }

  void loginUser() async {
    FirebaseUser user = await firebaseAuth.currentUser();
    /* if (user == null) {
      AuthResult result = await firebaseAuth.signInAnonymously();
      user = result.user;
    }

    IdTokenResult userToken = await user.getIdToken();
    print('USER');
    print('    UID: ${user.uid}');
    print('    Token: ${userToken.token}');
    print('    Expires: ${userToken.expirationTime}');*/
    signIn();
  }

  signIn() async {
    if (smsOTP == null) {
      smsOTP = '123456';
    }
    try {
      print(
          'AUTHTTTTTTTTTTTTTTTTTT verificationId $verificationId  _______smsOTP $smsOTP');

      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );

      AuthCredential authCredential = PhoneAuthProvider.getCredential(
          verificationId: verificationId, smsCode: smsOTP);

//      if(credential == smsOTP) {
      /* Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                new ProfilePage(
                    'mobileNumber', currentUserId: '1234567890')));*/
//      Navigator.of(context).pop();
//      Navigator.of(context).pushReplacementNamed('/homepage');
//      }
//      var test = await  firebaseAuth.verifyPhoneNumber(phoneNumber: mPhoneNumber, timeout:, verificationCompleted: null, verificationFailed: verificationId, codeSent: smsOTP, codeAutoRetrievalTimeout: null);

      FirebasePhoneAuth.instantiate(
          phoneNumber: mCountryCode + mPhoneNumber);

//      FirebasePhoneAuth.signInWithPhoneNumber(smsCode: _userPhoneNumber);

//      _signInWithPhoneNumber(_userPhoneNumber);
      if (_userOtp == smsOTP) {
        // Check is already sign up
        final QuerySnapshot result = await Firestore.instance
            .collection('users')
            .where('id', isEqualTo: mPhoneNumber)
            .getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        print('documents ${documents.length}');

        if(documents.length !=0){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  new ProfilePage(
                      'MobileNumber', currentUserId:mPhoneNumber)));
        }else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  new UserRegistrationPage(
                      userPhoneNumber: mCountryCode + '\t' + mPhoneNumber,
                      userPhoneNumberWithoutCountryCode: mPhoneNumber)));
        }
      } else {
        Fluttertoast.showToast(msg: 'Please enter valid OTP');
      }
      /*final PhoneVerificationCompleted verificationCompleted = (AuthCredential credential) {
        print('verified');
      };
      final AuthResult user =
      await firebaseAuth.signInWithCredential(credential);

      final FirebaseUser currentUser = await firebaseAuth.currentUser();
      assert(user.user.uid == currentUser.uid);
*/
//      _AddNewUser(currentUser, '', user.user.uid, 'MobileNumber');

    } catch (e) {
      handleError(e);
    }
  }


/*
  void _signInWithPhoneNumber(String smsCode) async {
    await FirebaseAuth.instance
        .signInWithPhoneNumber(
        verificationId: verificationId,
        smsCode: smsCode)
        .then((FirebaseUser user) async {
      final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
      assert(user.uid == currentUser.uid);
      print('signed in with phone number successful: user -> $user');
    });

  }*/

  handleError(PlatformException error) {
    print(error);
    print('NANHDU        $error');

    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        Navigator.of(context).pop();
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }


  Future<Null> updateLocalListData(SharedPreferences prefs,
      String signInType, List<DocumentSnapshot> documents) async {
    print('updateLocalListData');
    await prefs.setString('userId', documents[0]['id']);
    await prefs.setString('email', documents[0]['email']);
    await prefs.setString('name', documents[0]['name']);
    await prefs.setString('nickname', documents[0]['nickName']);
    await prefs.setString('status', 'ACTIVE');
    await prefs.setString('photoUrl', documents[0]['photoUrl']);
    await prefs.setInt('createdAt', documents[0]['createdAt']);
    await prefs.setString('phoneNo', documents[0]['phoneNo']);
    await prefs.setString('signInType', signInType);
  }


  Future<void> verifyPhone() async {
    String phoneNo = mCountryCode+mPhoneNumber;
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      otpUpdate(verificationId, smsOTP);
      print('verificationId $verificationId');
    };
    try {
      await firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNo,
          // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent: smsOTPSent,
          // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print('phoneAuthCredential${phoneAuthCredential.providerId}');
          },
          verificationFailed: (AuthException exceptio) {
            print('phoneAuthCredential exceptio ${exceptio.message}');
          });
    } catch (e) {
      handleError(e);
    }
  }


  void showToast(message, Color color) {
    print(message);
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 2,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }


  void _onVerifyCode() async {
    setState(() {
      isCodeSent = true;
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      firebaseAuth
          .signInWithCredential(phoneAuthCredential)
          .then((AuthResult value) {
        if (value.user != null) {
          // Handle loogged in state
          print('VERIFY USER _onVerifyCode ${value.user}');

          print(value.user.phoneNumber);
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

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: "$mCountryCode ${widget.phoneNumber}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {
    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: _pinEditingController.text);

    firebaseAuth
        .signInWithCredential(_authCredential)
        .then((AuthResult value) {
      if (value.user != null) {
        print('VERIFY USER ${value.user}');
        // Handle loogged in state
        print(value.user.phoneNumber);
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


}
