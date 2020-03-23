import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/FacebookSignup.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:virus_chat_app/UsersList.dart';

import '../ProfilePage.dart';

class LoginSelectionPage extends StatelessWidget {
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
      home: LoginSelection(),
    );
  }
}

class LoginSelection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginSelectionOption();
  }
}
/*
class LoginSelectionOption extends State<LoginSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: <Widget>[
      new Image.asset(
        'images/splashnew.png',
        fit: BoxFit.fitWidth,
        width: 500,
        height: 500,
      ),
      OutlineButton.icon(
        icon: Icon(Icons.call),
        onPressed: () {},
        label: Text('Continue with Phone number'),
      ),
      Text('Or connect using social account'),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton.icon(
            icon: new Image.asset('images/google.png'),
            onPressed: () {
              _settingModalBottomSheet(context);
            },
            label: Text('Google'),
          ),
          RaisedButton.icon(
            icon: new Image.asset('images/facebook.png'),
            onPressed: () {},
            label: Text('Facebook'),
          )
        ],
      )
    ]));
  }



  void _settingModalBottomSheet(context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.music_note),
                    title: new Text('Music'),
                    onTap: () => {}
                ),
                new ListTile(
                  leading: new Icon(Icons.videocam),
                  title: new Text('Video'),
                  onTap: () => {},
                ),
              ],
            ),
          );
        }
    );
  }


}*/

class LoginSelectionOption extends State<LoginSelection> {
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

  Geoflutterfire geo = Geoflutterfire();

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
    print('lodinnnn ${prefs.getString('signInType')}');
    if (prefs.getString('signInType') == 'google') {
      navigateToUsersPage();
//      navigateToProfilePageExistingUser(context, 'google', prefs);
    } else if (prefs.getString('signInType') == 'facebook') {
      navigateToUsersPage();
//      navigateToProfilePageExistingUser(context, 'facebook', prefs);
    }
    this.setState(() {
      isLoading = false;
    });
  }

  void updateState() async {
    isLoading = false;
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
        updateLocalData(prefs, facebookProfileData, 'facebook');
        _AddNewUser(facebookProfileData, userEmail, userId, 'facebook');
      }
      isLoading = false;
      navigateToProfilePage(context, 'facebook', facebookProfileData);
    } else {
//      Fluttertoast.showToast(msg: "Sign in fail");
      isLoading = false;
      _updatestatus();
      await clearLocalData(prefs);
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
        // Write data to local
        currentUser = firebaseUser;
        updateLocalData(prefs, currentUser, 'google');
        // Update data to server if new user
        _AddNewUser(firebaseUser, '', googleUser.id, 'google');
      } else {
        // Write data to local
        updateLocalListData(prefs, documents, 'google');
      }
      Fluttertoast.showToast(msg: "Sign in success");
      this.setState(() {
        isLoading = false;
      });
      navigateToProfilePage(context, 'google', firebaseUser);
    } else {
//      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  Future handleGoogleSignOut(SharedPreferences preferences) async {
    prefs = preferences;
    isLoading = true;
    await FirebaseAuth.instance.signOut();
    if (googleSignIn.isSignedIn() != null && isLoggedIn) {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
    }
    _updatestatus();
    isLoading = false;
    await clearLocalData(prefs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          new Image.asset(
            'images/splashnew.png',
            fit: BoxFit.fitWidth,
            width: 500,
            height: 500,
          ),
          OutlineButton.icon(
            icon: Icon(Icons.call),
            onPressed: () {
              verifyPhone();
            },
            label: Text('Continue with Phone number'),
          ),
          Text('Or connect using social account'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton.icon(
                icon: new Image.asset('images/google.png'),
                onPressed: () {
                  HandleGoogleSignIn();
//                  _settingModalBottomSheet(context);
                },
                label: Text('Google'),
              ),
              RaisedButton.icon(
                icon: new Image.asset('images/facebook.png'),
                onPressed: () {
                  this.setState(() {
                    isLoading = true;
                  });
                  facebookSignup.initiateFacebookLogin(context, prefs);
                },
                label: Text('Facebook'),
              )
            ],
          )
        ],
      ),
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
    UserLocation currentLocation = await LocationService(firebaseUser.uid,).getLocation();
    /*var currentLocation = UserLocation();
    var pos = currentLocationListener.whenComplete(() => {
      currentLocation=
    });*/
    GeoFirePoint point = geo.point(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude);

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
   Firestore.instance.collection('users').document(firebaseUser.uid).collection('userLocation').document(firebaseUser.uid).setData({
     'userLocation' : new GeoPoint(currentLocation.latitude, currentLocation.longitude),
   });

  }

  Future navigateToProfilePage(BuildContext context, String signinType,
      FirebaseUser firebaseUser) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProfilePageSetup(signinType, currentUserId: firebaseUser.uid)));
  }

  Future navigateToProfilePageExistingUser(
      BuildContext context, String signinType, SharedPreferences prefs) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePageSetup(signinType,
                currentUserId: prefs.getString('userId'))));
  }

  Future navigationLoginPage() async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => new LoginSelectionPage()));
  }

  Future navigateToUsersPage() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UsersList(prefs.getString('userId'))));
  }

  Future _updatestatus() async {
    LocationService('');
    Firestore.instance
        .collection('users')
        .document(prefs.getString('userId'))
        .updateData({'status': 'LoggedOut'});
  }

  Future<Null> updateLocalData(SharedPreferences prefs,
      FirebaseUser currentUser, String signInType) async {
    await prefs.setString('userId', currentUser.uid);
    await prefs.setString('email', currentUser.email);
    await prefs.setString('name', currentUser.displayName);
    await prefs.setString('password', 'passwordstatic');
    await prefs.setString('phoneNo', currentUser.phoneNumber);
    await prefs.setString('nickname', currentUser.displayName);
    await prefs.setString('status', 'ACTIVE');
    await prefs.setString('photoUrl', currentUser.photoUrl);
    await prefs.setString('signInType', signInType);
    await prefs.setInt('createdAt',
        ((new DateTime.now().toUtc().microsecondsSinceEpoch) / 1000).toInt());
  }

  Future<Null> updateLocalListData(SharedPreferences prefs,
      List<DocumentSnapshot> documents, String signInType) async {
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
    await prefs.setString('signInType', signInType);
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
    await prefs.setString('signInType', '');
    await prefs.setString('userId', '');
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.music_note),
                    title: new Text('Music'),
                    onTap: () => {}),
                new ListTile(
                  leading: new Icon(Icons.videocam),
                  title: new Text('Video'),
                  onTap: () => {},
                ),
              ],
            ),
          );
        });
  }
}
