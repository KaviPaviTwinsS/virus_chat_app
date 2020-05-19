import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

//import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/FacebookSignup.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/Login/PasswordSetupPage.dart';
import 'package:virus_chat_app/Login/PhoneNumberSelection.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/constants.dart';
import 'package:virus_chat_app/utils/strings.dart';

import '../profile/ProfilePage.dart';

class LoginSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => Future.value(false),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: app_name,
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
            fontFamily: 'GoogleSansFamily'
        ),
        home: LoginSelection(),
      ),
    );
  }
}

class LoginSelection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginSelectionOption();
  }
}

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
  BuildContext _mContext;

  bool isLoading = false;
  bool isLoggedIn = false;
  bool isFacebookLoggedIn = false;

  FirebaseUser currentUser;
  var facebookProfileData;

  var facebookSignup;

//  Geoflutterfire geo = Geoflutterfire();

  String userToken = '';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    initialise();
    _firebaseMessaging.getToken().then((token) =>
    {
      userToken = token,
      isGoogleSignedIn()
    });
  }

  void initialise() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(WALK_THROUGH, 'YES');
  }

  void isGoogleSignedIn() async {
    this.setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(WALK_THROUGH, 'YES');
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
    } else if (prefs.getString('signInType') == 'MobileNumber') {
      navigateToProfilePageExistingUser(context, 'MobileNumber', prefs);
    } else {
      print(
          'NANDHUUUUUUUUUUUUUUU____________________________99999999999999999  ${prefs
              .getString('userId')}');
    }
    this.setState(() {
      isLoading = false;
    });
  }

  void updateState() async {
    isLoading = false;
  }

  void isFacebookLoggedInUpdate(BuildContext context,
      SharedPreferences preferences,
      bool isLoggedIn,
      String userEmail,
      String userId,
      {profileData}) async {
    this._mContext = context;
    prefs = preferences;
    isFacebookLoggedIn = isLoggedIn;
//    Fluttertoast.showToast(msg: "Faccebook login success ${profileData['picture']['data']['url']} ___ ${profileData['email']}");
    facebookProfileData = profileData;
    if (isFacebookLoggedIn) {
      print(
          'FACEBOKkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk $facebookProfileData');
      /*   if (facebookProfileData != null) {
        updateLocalData(prefs, facebookProfileData, 'facebook');
        _AddNewUser(facebookProfileData, userEmail, userId, 'facebook');
      }
      isLoading = false;*/
      navigateToProfilePage(context, 'facebook', facebookProfileData, userId);
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
      navigateToProfilePage(context, 'google', firebaseUser, googleUser.id);
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
    if (googleSignIn == null) {
      googleSignIn = GoogleSignIn();
    }
    print('SIGN OUT VALLLL ${googleSignIn.isSignedIn() !=
        null}   ____ isLoggg $isLoggedIn');
    if (googleSignIn.isSignedIn() != null && isLoggedIn) {
      print('SIGN OUT');
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
    }
    _updatestatus();
    await FirebaseAuth.instance.signOut();
    isLoading = false;
    await clearLocalData(prefs);
  }

  Future<Null> updateLocalData(SharedPreferences prefs,
      FirebaseUser currentUser, String signInType) async {
    await prefs.setString('userId', currentUser.uid);
    await prefs.setString('email', currentUser.email);
    await prefs.setString('name', currentUser.displayName);
    await prefs.setString('phoneNo', currentUser.phoneNumber);
    await prefs.setString('nickname', currentUser.displayName);
    await prefs.setString('status', 'ACTIVE');
    await prefs.setString('photoUrl', currentUser.photoUrl);
    await prefs.setString('signInType', signInType);
    await prefs.setString('BUSINESS_ID', '');
    await prefs.setString('BUSINESS_TYPE', '');
    await prefs.setInt('createdAt',
        ((new DateTime.now()
            .toUtc()
            .microsecondsSinceEpoch) / 1000).toInt());
  }

  Future<Null> updateLocalListData(SharedPreferences prefs,
      List<DocumentSnapshot> documents, String signInType) async {
    await prefs.setString('userId', documents[0]['id']);
    await prefs.setString('email', documents[0]['email']);
    await prefs.setString('name', documents[0]['name']);
    await prefs.setString('nickname', documents[0]['nickName']);
    await prefs.setString('status', documents[0]['status']);
    await prefs.setString('photoUrl', documents[0]['photoUrl']);
    await prefs.setInt('createdAt', documents[0]['createdAt']);
    await prefs.setString('phoneNo', documents[0]['phoneNo']);
    await prefs.setString('BUSINESS_ID', documents[0]['businessId']);
    await prefs.setString('BUSINESS_TYPE', documents[0]['businessType']);
    await prefs.setString('signInType', signInType);
    await Firestore.instance
        .collection('users')
        .document(documents[0]['id'])
        .updateData({'status': 'ACTIVE'});
    print(
        'updateLocalListData___________ ${documents[0]['name']} _________ ${documents[0]['businessId']} ______${documents[0]['id']}');
//    setState(() {
    isLoading = false;
//    });
    LocationService(documents[0]['id']);
    if (signInType == 'facebook') {
      Navigator.push(
          _mContext,
          MaterialPageRoute(
              builder: (context) =>
                  UsersList(signInType,
                      documents[0]['id'], documents[0]['photoUrl'])));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  UsersList(signInType,
                      documents[0]['id'], documents[0]['photoUrl'])));
    }
  }


  void HandleThirdPartySignIn(FirebaseUser _firebaseUser, String _signinType,
      String _accountId) async {
    // Check is already sign up
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: _firebaseUser.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
//    this.setState(() {
    isLoading = true;
//    });
    if (documents.length == 0) {
      // Write data to local
      await updateLocalData(prefs, _firebaseUser, _signinType);
      // Update data to server if new user
      await _AddNewUser(_firebaseUser, '', _accountId, _signinType);
    } else {
      await updateLocalListData(prefs, documents, _signinType);
    }
    /*await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProfilePageSetup(_signinType, currentUserId: _firebaseUser.uid)));*/

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
    /*var currentLocation = UserLocation();
    var pos = currentLocationListener.whenComplete(() => {
      currentLocation=
    });*/
//    GeoFirePoint point = geo.point(
//        latitude: currentLocation.latitude,
//        longitude: currentLocation.longitude);

    // Update data to server if new user
    Firestore.instance.collection('users').document(firebaseUser.uid).setData({
      'name': firebaseUser.displayName,
      'photoUrl': firebaseUser.photoUrl,
      'email': signupUserEmail,
      'nickName': firebaseUser.displayName,
      'phoneNo': firebaseUser.phoneNumber,
      'status': 'ACTIVE',
      'id': firebaseUser.uid,
      '$loginType': loginId,
      'user_token': userToken,
      'businessId': '',
      'businessType': '',
      'businessName': '',
      'createdAt':
      ((new DateTime.now()
          .toUtc()
          .microsecondsSinceEpoch) / 1000).toInt()
    });
    UserLocation currentLocation = await LocationService(firebaseUser.uid,)
        .getLocation();
    Firestore.instance.collection('users').document(firebaseUser.uid)
        .collection('userLocation').document(firebaseUser.uid)
        .setData({
      'userLocation': new GeoPoint(
          currentLocation.latitude, currentLocation.longitude),
    });

//    setState(() {
    isLoading = false;
//    });
    if (loginType == 'facebook') {
      Navigator.push(
          _mContext,
          MaterialPageRoute(
              builder: (context) =>
                  UsersList(loginType,
                      firebaseUser.uid, firebaseUser.photoUrl)));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  UsersList(loginType,
                      firebaseUser.uid, firebaseUser.photoUrl)));
    }
  }


  @override
  Widget build(BuildContext context) {
    return
      new WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
              resizeToAvoidBottomPadding: false,
              body: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(60.0),
                            height: 300,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            child: new SvgPicture.asset(
                              'images/Logo_inner.svg',
                              height: 150,
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height - 300,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                    margin: EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    height: 45.0,
                                    child:RaisedButton(
                                    color: white_color,
    shape: RoundedRectangleBorder(
    borderRadius: new BorderRadius.circular(
    30.0),
    ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                                  return PhoneNumberSelectionPage();
                                                }
                                            ));
                                      },
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center,
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceAround,
                                        children: <Widget>[
                                          new SvgPicture.asset(
                                            'images/phone.svg',
                                            width: 20.0,
                                            height: 20.0,
                                            color: icon_color,
                                          ),
                                          Text('Continue with phone number',
                                            style: TextStyle(
                                                fontFamily: 'GoogleSansFamily',
                                                fontWeight: FontWeight.w400),),
                                        ],
                                      ),
                                    )
                                   /* RaisedButton.icon(
                                      icon: new SvgPicture.asset(
                                        'images/phone.svg',
                                        width: 20.0,
                                        height: 20.0,
                                        color: icon_color,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                                  return PhoneNumberSelectionPage();
                                                }
                                            ));
                                      },
                                      label: Text('Continue with phone number',
                                        style: TextStyle(
                                            fontFamily: 'GoogleSansFamily',
                                            fontWeight: FontWeight.w400),),
                                      color: white_color,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.circular(
                                            30.0),
                                      ),
                                    ),*/
                                  ),
                                  Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                    margin: EdgeInsets.only(left: 20.0,
                                        right: 20.0,
                                        bottom: 10.0,
                                        top: 10.0),
                                    child: Text(
                                      'Or connect using social account',
                                      style: TextStyle(
                                          fontFamily: 'GoogleSansFamily',
                                          fontWeight: FontWeight.w400),),
                                  ),
                                  Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                    margin: EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    child:
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          width: ((MediaQuery
                                              .of(context)
                                              .size
                                              .width) / 2) - 30,
                                          height: 45.0,
                                          child: RaisedButton(
                                            onPressed: (){
                                              HandleGoogleSignIn();
                                            },
                                            child : Row(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .center,
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceAround,
                                            children: <Widget>[
                                              new SvgPicture.asset(
                                                'images/gmail.svg',
                                                width: 20.0,
                                                height: 20.0,
                                              ),
                                              Text('Google',
                                                style: TextStyle(
                                                    fontFamily: 'GoogleSansFamily',
                                                    fontWeight: FontWeight
                                                        .w400),),
                                            ],
                                            ),
                                            color: white_color,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: new BorderRadius
                                                  .circular(
                                                  30.0),
                                            ),
                                          ),
                                        ),
                                        Container(
                                            height: 45.0,
                                            width: ((MediaQuery
                                                .of(context)
                                                .size
                                                .width) / 2) - 30,
                                            child: RaisedButton(
                                              child : Row(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .center,
                                                mainAxisAlignment: MainAxisAlignment
                                                    .spaceAround,
    children: <Widget>[
      new SvgPicture.asset(
        'images/fb.svg',
        width: 20.0,
        height: 20.0,
      ),
      Text('Facebook',
        style: TextStyle(
            fontFamily: 'GoogleSansFamily',
            fontWeight: FontWeight
                .w400),),
    ],
    ),

                                              onPressed: () {
                                                this.setState(() {
                                                  isLoading = true;
                                                });
                                                facebookSignup
                                                    .initiateFacebookLogin(
                                                    context, prefs);
                                              },
                                              color: white_color,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: new BorderRadius
                                                    .circular(
                                                    30.0),
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                        )
                      ],
                    ),
                    Positioned(
                      child: isLoading
                          ? Container(
                        child: Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  themeColor)),
                        ),
                        color: Colors.white.withOpacity(0.8),
                      )
                          : Container(),
                    ),
                  ]
              )
          )
      );
  }


/*
  @override
  Widget build(BuildContext context) {
    _mContext = context;
    return
      new WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
              resizeToAvoidBottomPadding: false,
              body: Stack(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              top: 40.0, left: 20.0, right: 20.0),
                          child: Text(explore, style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 29.0)),
                        ),
                        new SvgPicture.asset(
                          'images/image.svg',
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: MediaQuery
                              .of(context)
                              .size
                              .height - 290,
                        ),
                        */ /*  new Image.asset(
            'images/image.svg',
            fit: BoxFit.fitWidth,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 170,
          ),*/ /*
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            height: 170,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                                  child: RaisedButton.icon(
                                    icon: new SvgPicture.asset(
                                      'images/phone.svg',
                                      width: 20.0,
                                      height: 20.0,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) {
                                                return PhoneNumberSelectionPage();
                                              }
                                          ));
                                    },
                                    label: Text('Continue with phone number'),
                                    color: white_color,
                                  ),
                                ),
                                Container(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  margin: EdgeInsets.only(left: 20.0,
                                      right: 20.0,
                                      bottom: 10.0,
                                      top: 10.0),
                                  child: Text('Or connect using social account'),
                                ),
                                Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                    margin: EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    child:
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          width: ((MediaQuery
                                              .of(context)
                                              .size
                                              .width) / 2) - 30,
                                          height: 40.0,
                                          child: RaisedButton.icon(
                                            icon: new SvgPicture.asset(
                                              'images/gmail.svg',
                                              width: 20.0,
                                              height: 20.0,
                                            ),
                                            onPressed: () {
                                              HandleGoogleSignIn();
//                  _settingModalBottomSheet(context);
                                            },
                                            label: Text('Google'),
                                            color: white_color,
                                          ),
                                        ),
                                        Container(
                                            height: 40.0,
                                            width: ((MediaQuery
                                                .of(context)
                                                .size
                                                .width) / 2) - 30,
                                            child: RaisedButton.icon(
                                              icon: new SvgPicture.asset(
                                                'images/fb.svg',
                                                width: 20.0,
                                                height: 20.0,
                                              ),
                                              onPressed: () {
                                                this.setState(() {
                                                  isLoading = true;
                                                });
                                                facebookSignup
                                                    .initiateFacebookLogin(
                                                    context, prefs);
                                              },
                                              label: Text('Facebook'),
                                              color: white_color,
                                            )
                                        )
                                      ],
                                    )
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    child: isLoading
                        ? Container(
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(progress_color)),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                        : Container(),
                  ),
                ],
              )
          )
      );
  }*/


  Future navigateToProfilePage(BuildContext context, String signinType,
      FirebaseUser firebaseUser, String accountId) async {
    print('LOGINGGGGGGGGGGGGGGGGGGGG $firebaseUser');
    HandleThirdPartySignIn(firebaseUser, signinType, accountId);
    /*
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProfilePageSetup(signinType, currentUserId: firebaseUser.uid)));*/
    /*  Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PasswordSetup(signinType, maccountId: accountId,
                    mfirebaseUser: firebaseUser)));*/
  }

  Future navigateToProfilePageExistingUser(BuildContext context,
      String signinType, SharedPreferences prefs) async {
    /* Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePageSetup(signinType,
                currentUserId: prefs.getString('userId'))));
*/
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UsersList(signinType, prefs.getString('userId'),
                    prefs.getString('photoUrl'))));
  }

  Future _updatestatus() async {
//    LocationService('');
    /*if(prefs.getString('userId') != '') {
      Firestore.instance
          .collection('users')
          .document(prefs.getString('userId'))
          .updateData({'status': 'LoggedOut'}).whenComplete(() {
        prefs.setString('userId', '');
      });
    }*/
  }

  Future<Null> clearLocalData(SharedPreferences prefs) async {
    await prefs.setString('email', '');
    await prefs.setString('name', '');
    await prefs.setString('nickname', '');
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
