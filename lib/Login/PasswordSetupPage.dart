import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';
import 'package:virus_chat_app/profile/ProfilePage.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';

class PasswordSetup extends StatefulWidget {
  String _signinType = '';
  FirebaseUser _firebaseUser;

  String _accountId = '';

  PasswordSetup(String signinType,
      {FirebaseUser mfirebaseUser, String maccountId}) {
    _signinType = signinType;
    _firebaseUser = mfirebaseUser;
    _accountId = maccountId;
  }

  @override
  State<StatefulWidget> createState() {
    return PasswordSetupState(_signinType, _firebaseUser, _accountId);
  }

}

class PasswordSetupState extends State<PasswordSetup> {

  String userPassword = '';
  String userPhone = '';
  String newPassword = '';
  String confirmPassword = '';
  TextEditingController passwordController;
  TextEditingController phoneController;
  TextEditingController newPasswordController;
  TextEditingController confirmPasswordController;

  String _signinType = '';
  String _accountId = '';
  FirebaseUser _firebaseUser;

  bool isLoading = false;

  SharedPreferences prefs;
//  Geoflutterfire geo = Geoflutterfire();

  String userToken = '';
  bool passwordVisible = true;

  PasswordSetupState(String signinType, FirebaseUser firebaseUser,
      String accountId) {
    _accountId = accountId;
    _signinType = signinType;
    _firebaseUser = firebaseUser;
  }


  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    passwordController = TextEditingController(text: userPassword);
    phoneController = TextEditingController(text: userPhone);
    newPasswordController = TextEditingController(text: newPassword);
    confirmPasswordController = TextEditingController(text: confirmPassword);
    prefs = await SharedPreferences.getInstance();
    userToken = await prefs.getString('PUSH_TOKEN');
    print('userToken_____________________________$userToken');
    // Force refresh input
    setState(() {});
  }

  GoogleSignIn googleSignIn = GoogleSignIn();
  var facebookLogin = FacebookLogin();

  Future updateLogin() async {
    await FirebaseAuth.instance.signOut();
    if (googleSignIn.isSignedIn() != null) {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
    }
    if (facebookLogin.isLoggedIn != null) {
      await facebookLogin.logOut();
    }
  }


  Future<bool> onBackPress() async {
    print('onBackPress');
    updateLogin();
//    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new LoginSelection()));
    return Future.value(true);
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          onBackPress();
        },
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 5.0, top: 40.0, right: 20.0),
                        child: new IconButton(
                          icon: new Icon(Icons.arrow_back_ios, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => new LoginSelection()));
                            updateLogin();
                          },
                        ),
                      )
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 20.0, top: 30.0, right: 20.0),
                      child: Text(password,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        left: 20.0, top: 20.0, right: 20.0),
                    child: TextField(
                      obscureText: passwordVisible,
                      controller: passwordController,
                      onChanged: (value) {
                        userPassword = value;
                      },
                      autofocus: true,
                      decoration: new InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme
                                .of(context)
                                .primaryColorDark,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: focused_border_color, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: greyColor2, width: 2.0),
                        ),
                        hintText: 'Enter your Password',
                      ),
                    ),
                  ),
                  /* Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: (){
                forgotPassword();
              },
              child:  Container(
                child: Text('Forgot password'),
                margin: EdgeInsets.only(left: 30.0, right: 30.0),
              ),
            )
          ),*/
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
                      padding: EdgeInsets.all(30.0),
                      width: double.infinity,
                      child: SizedBox(
                          height: 45, // specific value
                          child: RaisedButton(
                            child: Text(log_in),
                            color: button_fill_color,
                            textColor: text_color,
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0),
                            ),
                            onPressed: () {
                              if (userPassword != '') {
                                this.setState(() {
                                  isLoading = true;
                                });
                                HandleThirdPartySignIn();
                              } else {
                                Fluttertoast.showToast(msg: enter_password);
                              }
                            },
                          )
                      ),
                    ),
                  )

                ],
              ),
              buildLoading()
            ],
          )
        )
    );
  }

  void forgotPassword() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 180,
            child: Container(
              child: _buildBottomNavigationMenu(),
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
          );
        });
  }

  Column _buildBottomNavigationMenu() {
    return Column(
      children: <Widget>[
        Text('Forgot Password?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0,),),
        Container(
          child: Theme(
            data: Theme.of(context).copyWith(
                primaryColor: primaryColor),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your Phone',
                contentPadding: new EdgeInsets.all(3.0),
                hintStyle: TextStyle(color: greyColor),
              ),
              controller: phoneController,
              onChanged: (value) {
                userPhone = value;
              },
            ),
          ),
          margin: EdgeInsets.only(left: 30.0, right: 30.0),
        ),
        RaisedButton(
          child: Text(send.toUpperCase()),
          color: button_fill_color,
          textColor: text_color,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
          ),
          onPressed: () {
            sendButton();
          },
        )

      ],
    );
  }

  void sendButton() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 180,
            child: Container(
              child: buildPasswordMenu(),
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
          );
        });
  }


  Column buildPasswordMenu() {
    return Column(
      children: <Widget>[
        Text('Reset Password?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0,),),
        Container(
          child: Theme(
            data: Theme.of(context).copyWith(
                primaryColor: primaryColor),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter New Password',
                contentPadding: new EdgeInsets.all(3.0),
                hintStyle: TextStyle(color: greyColor),
              ),
              controller: newPasswordController,
              onChanged: (value) {
                newPassword = value;
              },
            ),
          ),
          margin: EdgeInsets.only(left: 30.0, right: 30.0),
        ),
        Container(
          child: Theme(
            data: Theme.of(context).copyWith(
                primaryColor: primaryColor),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter Confirm Password',
                contentPadding: new EdgeInsets.all(3.0),
                hintStyle: TextStyle(color: greyColor),
              ),
              controller: confirmPasswordController,
              onChanged: (value) {
                confirmPassword = value;
              },
            ),
          ),
          margin: EdgeInsets.only(left: 30.0, right: 30.0),
        ),
        RaisedButton(
          child: Text(done.toUpperCase()),
          color: button_fill_color,
          textColor: text_color,
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0),
          ),
          onPressed: () {
            if (newPassword == '' || confirmPassword == '') {
              Fluttertoast.showToast(msg: 'Enter new and confirm password');
            }
            else if (newPassword == confirmPassword) {
              updateUserPassword();
            } else {
              Fluttertoast.showToast(
                  msg: 'Enter new and confirm password as identical');
            }
          },
        )
      ],
    );
  }

  void updateUserPassword() async {
    await Firestore.instance.collection('users')
        .document(_firebaseUser.uid)
        .updateData({
      'password': newPassword
    });
  }


  void HandleThirdPartySignIn() async {
    // Check is already sign up
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: _firebaseUser.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {
      // Write data to local
      await updateLocalData(prefs, _firebaseUser, _signinType);
      // Update data to server if new user
      await _AddNewUser(_firebaseUser, '', _accountId, _signinType);
    } else {
      if (documents[0]['password'] == userPassword) {
        // Write data to local
        await updateLocalListData(prefs, documents, _signinType);
      } else {
        Fluttertoast.showToast(msg: enter_valid_password);
      }
    }

    /*await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProfilePageSetup(_signinType, currentUserId: _firebaseUser.uid)));*/
    this.setState(() {
      isLoading = false;
    });
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
      'password': userPassword,
      'phoneNo': firebaseUser.phoneNumber,
      'status': 'ACTIVE',
      'id': firebaseUser.uid,
      '$loginType': loginId,
      'user_token': userToken,
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

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UsersList(loginType,
                    firebaseUser.uid, firebaseUser.photoUrl)));
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

  Future<Null> updateLocalData(SharedPreferences prefs,
      FirebaseUser currentUser, String signInType) async {
    await prefs.setString('userId', currentUser.uid);
    await prefs.setString('email', currentUser.email);
    await prefs.setString('name', currentUser.displayName);
    await prefs.setString('password', userPassword);
    await prefs.setString('phoneNo', currentUser.phoneNumber);
    await prefs.setString('nickname', currentUser.displayName);
    await prefs.setString('status', 'ACTIVE');
    await prefs.setString('photoUrl', currentUser.photoUrl);
    await prefs.setString('signInType', signInType);
    await prefs.setInt('createdAt',
        ((new DateTime.now()
            .toUtc()
            .microsecondsSinceEpoch) / 1000).toInt());
  }

  Future<Null> updateLocalListData(SharedPreferences prefs,
      List<DocumentSnapshot> documents, String signInType) async {
    print('updateLocalListData');
    await prefs.setString('userId', documents[0]['id']);
    await prefs.setString('email', documents[0]['email']);
    await prefs.setString('name', documents[0]['name']);
    await prefs.setString('nickname', documents[0]['nickName']);
    await prefs.setString('password', documents[0]['password']);
    await prefs.setString('status', documents[0]['status']);
    await prefs.setString('photoUrl', documents[0]['photoUrl']);
    await prefs.setInt('createdAt', documents[0]['createdAt']);
    await prefs.setString('phoneNo', documents[0]['phoneNo']);
    await prefs.setString('signInType', signInType);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UsersList(signInType,
                    documents[0]['id'], documents[0]['photoUrl'])));
  }

}