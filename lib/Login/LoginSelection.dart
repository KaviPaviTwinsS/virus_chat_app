import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:virus_chat_app/Login/PasswordSetupPage.dart';
import 'package:virus_chat_app/Login/PhoneNumberSelection.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:virus_chat_app/UsersList.dart';

import '../ProfilePage.dart';

class LoginSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
 /* final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );
*/

  GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  bool isFacebookLoggedIn = false;

  FirebaseUser currentUser;
  var facebookProfileData;

  var facebookSignup;

  Geoflutterfire geo = Geoflutterfire();

  String userToken ='';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.getToken().then((token) => {
      userToken = token ,
    isGoogleSignedIn()
    });
  }

  void isGoogleSignedIn() async {
    this.setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('PUSH_TOKEN', userToken);
    facebookSignup = new FacebookSignup();
    isLoggedIn = await googleSignIn.isSignedIn();
    isFacebookLoggedIn = await facebookSignup.facebookLogin.isLoggedIn;
    print('lodinnnn ${await prefs.getString('PUSH_TOKEN')}');
    if (prefs.getString('signInType') == 'google') {
//      navigateToUsersPage("google");
      navigateToProfilePageExistingUser(context, 'google', prefs);
    } else if (prefs.getString('signInType') == 'facebook') {
//      navigateToUsersPage("facebook");
      navigateToProfilePageExistingUser(context, 'facebook', prefs);
    }else  if (prefs.getString('signInType') == 'MobileNumber') {
      navigateToProfilePageExistingUser(context, 'MobileNumber', prefs);
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
   /*   if (facebookProfileData != null) {
        updateLocalData(prefs, facebookProfileData, 'facebook');
        _AddNewUser(facebookProfileData, userEmail, userId, 'facebook');
      }
      isLoading = false;*/
      navigateToProfilePage(context, 'facebook', facebookProfileData,userId);
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

      navigateToProfilePage(context, 'google', firebaseUser,googleUser.id);
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
    isLoggedIn = true;
    await FirebaseAuth.instance.signOut();
    print('SIGN OUT VALLLL ${googleSignIn.isSignedIn() != null}   ____ isLoggg $isLoggedIn');
    if (googleSignIn.isSignedIn() != null && isLoggedIn) {
      print('SIGN OUT');
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
      resizeToAvoidBottomPadding: false,
      body: Container(
      child : Column(
        children: <Widget>[
          new Image.asset(
            'images/splashnew.png',
            fit: BoxFit.fitWidth,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 170,
          ),
       Align(
         alignment: Alignment.bottomCenter,
         child: Container(
           width: MediaQuery.of(context).size.width,
           height: 170,
           child:  Column(
             children: <Widget>[
               OutlineButton.icon(
                 icon: Icon(Icons.call),
                 onPressed: () {
                   Navigator.push(
                       context,
                       MaterialPageRoute(
                           builder: (context) =>
                               PhoneNumberSelectionPage()));
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
         ),
       )
        ],
      ),
      )
    );
  }

  Future navigateToProfilePage(BuildContext context, String signinType,
      FirebaseUser firebaseUser, String accountId) async {
    /*
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProfilePageSetup(signinType, currentUserId: firebaseUser.uid)));*/
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PasswordSetup(signinType,maccountId:accountId,mfirebaseUser: firebaseUser)));
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

  Future navigateToUsersPage(String userSignInType) async {
   /* Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UsersList(userSignInType,prefs.getString('userId'))));*/
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
    await prefs.setString('phoneNo', documents[0]['phoneNo']);
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
