import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';
import 'package:virus_chat_app/ProfilePage.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:virus_chat_app/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';

class PasswordSetup extends StatefulWidget{
  String _signinType ='';
  FirebaseUser _firebaseUser ;
  String _accountId ='';
  PasswordSetup(String signinType, {FirebaseUser mfirebaseUser, String maccountId}){
    _signinType =signinType;
    _firebaseUser =mfirebaseUser;
    _accountId = maccountId;
  }

  @override
  State<StatefulWidget> createState() {
    return PasswordSetupState(_signinType,_firebaseUser,_accountId);
  }

}

class PasswordSetupState extends State<PasswordSetup>{

  String userPassword ='';
  TextEditingController passwordController;

  String _signinType = '';
  String _accountId = '';
  FirebaseUser _firebaseUser ;
  bool isLoading = false;

  SharedPreferences prefs;
  Geoflutterfire geo = Geoflutterfire();


  PasswordSetupState(String signinType, FirebaseUser firebaseUser, String accountId){
    _accountId = accountId;
    _signinType = signinType;
    _firebaseUser = firebaseUser;
  }


  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async{
    passwordController = TextEditingController(text: userPassword);
    prefs = await SharedPreferences.getInstance();
    // Force refresh input
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Column(
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
                                context) => new LoginSelectionPage()));
                  },
                ),
              )
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 30.0, top: 30.0, right: 20.0),
              child: Text(password,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
              ),
            ),
          ),
          Container(
            child: Theme(
              data: Theme.of(context).copyWith(
                  primaryColor: primaryColor),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your Password',
                  contentPadding: new EdgeInsets.all(3.0),
                  hintStyle: TextStyle(color: greyColor),
                ),
                controller: passwordController,
                onChanged: (value) {
                  userPassword = value;
                },
              ),
            ),
            margin: EdgeInsets.only(left: 30.0, right: 30.0),
          ),
          RaisedButton(
            child: Text(log_in.toUpperCase()),
            onPressed: (){
              if(userPassword != '') {
                HandleThirdPartySignIn();
              }else{
                Fluttertoast.showToast(msg: enter_password);
              }
            },
          )
        ],
      ),
    );
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
        if(documents[0]['password'] == userPassword) {
          // Write data to local
          await updateLocalListData(prefs, documents, _signinType);
        }else{
          Fluttertoast.showToast(msg: enter_valid_password);
        }
      }

   await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProfilePageSetup(_signinType, currentUserId: _firebaseUser.uid)));
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
      'password': userPassword,
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

}