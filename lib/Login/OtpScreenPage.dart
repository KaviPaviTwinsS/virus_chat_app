import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/Login/PhoneNumberSelection.dart';
import 'package:virus_chat_app/ProfilePage.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:virus_chat_app/colors.dart';
import 'package:virus_chat_app/utils/CustomTextSpan.dart';

abstract class otpUpdateListener {
}

class OtpScreenPage extends StatelessWidget {
  String mPhoneNumber = '';

  OtpScreenPage(String phoneNumber) {
    mPhoneNumber = phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}

class OtpApplyPage extends StatefulWidget {
  String phoneNumber = '';

  OtpApplyPage(String mPhoneNumber) {
    phoneNumber = mPhoneNumber;
  }

  @override
  State<StatefulWidget> createState() {
    return OtpApplyPageState(phoneNumber);
  }
}

class OtpApplyPageState extends State<OtpApplyPage>
    implements otpUpdateListener {
  String mPhoneNumber = '';
  TextEditingController userPhoneNumberController = new TextEditingController();

  String _userPhoneNumber = '';
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String errorMessage = '';
  String verificationId;
  String smsOTP;

  void otpUpdate(String verifyId, String smsOtp) {
    print('otpUpdate $verifyId ____ $smsOtp');
    verificationId = verifyId;
    smsOTP = smsOtp;
  }


  OtpApplyPageState(String phoneNumber) {
    mPhoneNumber = phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => new PhoneNumberSelectionPage()));
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 20.0, top: 30.0, right: 20.0),
            child: Text('Verify phone number',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ),
          Container(
              margin: const EdgeInsets.only(left: 20.0, top: 30.0, right: 20.0),
              child: customTextSpan(
                  'Check your messages.We have sent you the pin at ',
                  mPhoneNumber)
          ),
          Expanded(child: Container(
            margin: const EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
            child: TextField(
              obscureText: false,
              controller: userPhoneNumberController,
              onChanged: (userPhoneNumber) {
                _userPhoneNumber = userPhoneNumber;
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
          ),
          ),
          Container(
            child: RaisedButton(onPressed: () {
              firebaseAuth.currentUser().then((user) {
                print('USERRRRRRRRRRR $user');
                if (user != null) {
                  signIn();
                }else{
                  loginUser();
                }
              });
            },
              child: Text('VERIFY',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),),
            ),
          )

        ],
      ),
    );
  }

  void loginUser() async {
    FirebaseUser user = await firebaseAuth.currentUser();

    if (user == null) {
      AuthResult result = await firebaseAuth.signInAnonymously();
      user = result.user;
    }

    IdTokenResult userToken = await user.getIdToken();
    print('USER');
    print('    UID: ${user.uid}');
    print('    Token: ${userToken.token}');
    print('    Expires: ${userToken.expirationTime}');
    signIn();
  }

  signIn() async {
    if (smsOTP == null) {
      smsOTP = '123456';
    }
    try {
      print('AUTHTTTTTTTTTTTTTTTTTT ');

      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );

      print('AUTHTTTTTTTTTTTTTTTTTT______ ${credential}');
//      if(credential == smsOTP) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                new ProfilePage(
                    'mobileNumber', currentUserId: '1234567890')));
//      Navigator.of(context).pop();
//      Navigator.of(context).pushReplacementNamed('/homepage');
//      }
      final AuthResult user =
      await firebaseAuth.signInWithCredential(credential);

      final FirebaseUser currentUser = await firebaseAuth.currentUser();
      assert(user.user.uid == currentUser.uid);

      _AddNewUser(currentUser, '', user.user.uid, 'MobileNumber');

    } catch (e) {
      handleError(e);
    }
  }

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
        /* smsOTPDialog(context).then((value) {
          print('sign in');
        });*/
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }


  Future _AddNewUser(FirebaseUser firebaseUser, String userEmail, String userId,
      String loginType) async {
    var signupUserEmail = '';
    var loginId = userId;
    if (firebaseUser.email == null) {
      signupUserEmail = userEmail;
    } else {
      signupUserEmail = firebaseUser.email;
    }
    loginType += 'AccountId';
    UserLocation currentLocation = await LocationService(firebaseUser.uid,)
        .getLocation();
    // Update data to server if new user
    Firestore.instance.collection('users').document(firebaseUser.uid).setData({
      'name': firebaseUser.displayName,
      'photoUrl': firebaseUser.photoUrl,
      'email': signupUserEmail,
      'nickName': firebaseUser.displayName,
      'password': 'passwordstatic',
      'phoneNo': firebaseUser.phoneNumber,
      'status': 'ACTIVE',
      'id': firebaseUser.uid,
      '$loginType': loginId,
      'createdAt':
      ((new DateTime.now()
          .toUtc()
          .microsecondsSinceEpoch) / 1000).toInt()
    });
    Firestore.instance.collection('users').document(firebaseUser.uid)
        .collection('userLocation').document(firebaseUser.uid)
        .setData({
      'userLocation': new GeoPoint(
          currentLocation.latitude, currentLocation.longitude),
    });
  }

}