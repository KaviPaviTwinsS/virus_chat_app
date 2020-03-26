import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';
import 'package:virus_chat_app/Login/OtpScreenPage.dart';
import 'package:virus_chat_app/colors.dart';

class PhoneNumberSelectionPage extends StatelessWidget {
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
      home: PhoneNumberSelection(),
    );
  }
}


class PhoneNumberSelection extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return PhoneNumberSelectionState();
  }

}

class PhoneNumberSelectionState extends State<PhoneNumberSelection> {
  TextEditingController userPhoneNumberController = new TextEditingController();
  String _userPhoneNumber = '';



  String verificationId;
  String errorMessage = '';
  String phoneNo = '+91 7540011847';
  String smsOTP;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

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
                    builder: (context) => new LoginSelectionPage()));
          },
        ),

      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 20.0, top: 30.0, right: 20.0),
            child: Text('What is your phone number?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 30.0,top: 30.0, right: 30.0),
                child: Text('+91 '),
              ),
              Expanded(child: Container(
                margin: const EdgeInsets.only(left: 20.0,top: 20.0, right: 20.0),
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
                    hintText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              ),

            ],
          ),
          Container(
            child: RaisedButton(onPressed: (){
              verifyPhone();
            },
              child: Text('CONTINUE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),),
            ),
          )
        ],
      ),
    );
  }


  OtpApplyPageState listener = new OtpApplyPageState('');
  Future<void> verifyPhone() async {
    String phoneNo = '+91 '+_userPhoneNumber;
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
   /*   smsOTPDialog(context).then((value) {
        print('sign in');
      });*/
      print('verificationId $verificationId');
      listener.otpUpdate(verificationId,smsOTP);
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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new OtpScreenPage(_userPhoneNumber)));

  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter SMS Code'),
            content: Container(
              height: 85,
              child: Column(children: [
                TextField(
                  onChanged: (value) {
                    this.smsOTP = value;
                  },
                ),
                (errorMessage != ''
                    ? Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                )
                    : Container())
              ]),
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                child: Text('Done'),
                onPressed: () {
                  firebaseAuth.currentUser().then((user) {
                    print('USERRRRRRRRRRR ${user.toString()}');
                    if (user != null) {
                      Navigator.of(context).pop();
//                      Navigator.of(context).pushReplacementNamed('/homepage');
                    } else {
                      signIn();
                    }
                  });
                },
              )
            ],
          );
        });
  }

  handleError(PlatformException error) {
    print('NANHDU        error');
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

  signIn() async {
    try {

      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      final AuthResult user =
      await firebaseAuth.signInWithCredential(credential);
      final FirebaseUser currentUser = await firebaseAuth.currentUser();
      assert(user.user.uid == currentUser.uid);
//      Navigator.of(context).pop();
//      Navigator.of(context).pushReplacementNamed('/homepage');
    } catch (e) {
      handleError(e);
    }
  }
}
