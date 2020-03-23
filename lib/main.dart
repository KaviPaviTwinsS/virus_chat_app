import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/FacebookSignup.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';
import 'package:virus_chat_app/ProfilePage.dart';
import 'package:virus_chat_app/SplashScreen.dart';
import 'package:virus_chat_app/UserLocation.dart';

//void main() => runApp(SplashScreenPage());


void main() {
  runApp(new MaterialApp(
    home: new SplashScreenPage(),
    routes: <String, WidgetBuilder>{
      '/HomeScreen': (BuildContext context) => new LoginSelectionPage()
    },
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: LoginOptionPageState(),
    );
  }
}

class LoginOptionPageState extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginOptionPage();
  }
}

class LoginOptionPage extends State<LoginOptionPageState> {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  bool isFacebookLoggedIn = false;

  FirebaseUser currentUser;
  var facebookProfileData;

  var facebookSignup;

  @override
  void initState() {
    super.initState();
    isGoogleSignedIn();
  }

  void isGoogleSignedIn() async {
    this.setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();
    facebookSignup = new FacebookSignup();
    isLoggedIn = await googleSignIn.isSignedIn();
    isFacebookLoggedIn = await facebookSignup.facebookLogin.isLoggedIn;
    if (isLoggedIn || isFacebookLoggedIn) {
      navigateToProfilePageExistingUser(context, prefs);
    }
    this.setState(() {
      isLoading = false;
    });
  }

  void updateState() async {
    this.setState(() {
      isLoading = false;
    });
  }

  void isFacebookLoggedInUpdate(
      BuildContext context,
      SharedPreferences preferences,
      bool isLoggedIn,
      String userEmail,
      String userId,
      {profileData}) async {
    prefs = preferences;
    isFacebookLoggedIn = isLoggedIn;
//    Fluttertoast.showToast(msg: "Faccebook login success ${profileData['picture']['data']['url']} ___ ${profileData['email']}");
    facebookProfileData = profileData;
    if (isFacebookLoggedIn) {
      if (facebookProfileData != null) {
        updateLocalData(prefs, facebookProfileData);
        _AddNewUser(facebookProfileData, userEmail, userId, 'facebook');
      }
      isLoading = false;
      navigateToProfilePage(context, facebookProfileData);
    } else {
//      Fluttertoast.showToast(msg: "Sign in fail");
      clearLocalData(prefs);
      isLoading = false;
      _updatestatus();
    }
  }

  Future<Null> HandleGoogleSignIn() async {
    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseUser firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('userId', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        _AddNewUser(firebaseUser, '', googleUser.id, 'google');
        // Write data to local
        currentUser = firebaseUser;
        updateLocalData(prefs, currentUser);
      } else {
        // Write data to local
        updateLocalListData(prefs, documents);
      }
      Fluttertoast.showToast(msg: "Sign in success");
      this.setState(() {
        isLoading = false;
      });
      navigateToProfilePage(context, firebaseUser);
    } else {
//      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  Future<Null> handleGoogleSignOut() async {
    this.setState(() {
      isLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    if (googleSignIn.isSignedIn() != null && isLoggedIn) {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
    }
    _updatestatus();
    this.setState(() {
      isLoading = false;
    });
    clearLocalData(prefs);
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocation>(
        builder: (context) => LocationService('').locationStream,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Virus Chat HomePage'),
          ),
          body: Column(
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  HandleGoogleSignIn();
                },
                child: Text('Google Signup'),
              ),
              RaisedButton(
                onPressed: () {
                  this.setState(() {
                    isLoading = true;
                  });
                  facebookSignup.initiateFacebookLogin(context, prefs);
                },
                child: Text('Facebook signup'),
              ),
              RaisedButton(
                onPressed: () {
                  verifyPhone();
                },
                child: Text('Continue with mobile number'),
              ),
              RaisedButton(
                onPressed: () {
                  handleGoogleSignOut();
                },
                child: Text('Logout'),
              ),
              RaisedButton(
                onPressed: () {
                  facebookSignup.facebookLogout(context, prefs);
                },
                child: Text('Facebook logout'),
              ),
            ],
          ),
        )
    );
  }

  String verificationId;
  String errorMessage = '';
  String phoneNo = '+91 7540011847';
  String smsOTP;

  Future<void> verifyPhone() async {
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsOTPDialog(context).then((value) {
        print('sign in');
      });
    };
    try {
      await firebaseAuth.verifyPhoneNumber(
          phoneNumber: this.phoneNo,
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
                    print('USERRRRRRRRRRR ${user.phoneNumber}');
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
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        Navigator.of(context).pop();
        smsOTPDialog(context).then((value) {
          print('sign in');
        });
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
          ((new DateTime.now().toUtc().microsecondsSinceEpoch) / 1000).toInt()
    });
  }

  Future navigateToProfilePage(
      BuildContext context, FirebaseUser firebaseUser) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProfilePageSetup('',currentUserId: firebaseUser.uid)));
  }

  Future navigateToProfilePageExistingUser(
      BuildContext context, SharedPreferences prefs) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProfilePageSetup('',currentUserId: prefs.getString('userId'))));
  }

  Future _updatestatus() async {
    Firestore.instance
        .collection('users')
        .document(prefs.getString('userId'))
        .updateData({'status': 'LoggedOut'});
  }

  Future<Null> updateLocalData(
      SharedPreferences prefs, FirebaseUser currentUser) async {
    await prefs.setString('userId', currentUser.uid);
    await prefs.setString('email', currentUser.email);
    await prefs.setString('name', currentUser.displayName);
    await prefs.setString('password', 'passwordstatic');
    await prefs.setString('phoneNo', currentUser.phoneNumber);
    await prefs.setString('nickname', currentUser.displayName);
    await prefs.setString('status', 'ACTIVE');
    await prefs.setString('photoUrl', currentUser.photoUrl);
    await prefs.setInt('createdAt',
        ((new DateTime.now().toUtc().microsecondsSinceEpoch) / 1000).toInt());
  }

  Future<Null> updateLocalListData(
      SharedPreferences prefs, List<DocumentSnapshot> documents) async {
    print('updateLocalListData');
    await prefs.setString('userId', documents[0]['uid']);
    await prefs.setString('email', documents[0]['email']);
    await prefs.setString('name', documents[0]['displayName']);
    await prefs.setString('nickname', documents[0]['displayName']);
    await prefs.setString('password', documents[0]['password']);
    await prefs.setString('status', documents[0]['status']);
    await prefs.setString('photoUrl', documents[0]['photoUrl']);
    await prefs.setInt('createdAt', documents[0]['createdAt']);
    await prefs.setInt('phoneNo', documents[0]['phoneNo']);
  }

  Future<Null> clearLocalData(SharedPreferences prefs) async {
    await prefs.setString('email', '');
    await prefs.setString('name', '');
    await prefs.setString('nickname', '');
    await prefs.setString('password', '');
    await prefs.setString('status', '');
    await prefs.setString('photoUrl', '');
    await prefs.setString('createdAt', '');
    await prefs.setInt('phoneNo', 0);
  }
}


//var userLocation = Provider.of<UserLocation>(context);
//print('userLocation build');
