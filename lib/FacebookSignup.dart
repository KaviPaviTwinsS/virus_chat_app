import 'dart:convert' as JSON;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';

class FacebookSignup {

  var facebookLogin = FacebookLogin();

  var _loginPageState = new LoginSelectionOption();
  var profileData;

  void initiateFacebookLogin(BuildContext context,SharedPreferences prefs) async {
    var facebookLoginResult = await facebookLogin.logIn(['email', 'public_profile']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        _loginPageState.isFacebookLoggedInUpdate(context,prefs,false,'','');
        break;
      case FacebookLoginStatus.cancelledByUser:
        _loginPageState.isFacebookLoggedInUpdate(context,prefs,false,'','');
        break;
      case FacebookLoginStatus.loggedIn:
        FacebookAccessToken myToken = facebookLoginResult.accessToken;
        AuthCredential credential =
        FacebookAuthProvider.getCredential(accessToken: myToken.token);
// this line do auth in firebase with your facebook credential.
        FirebaseUser firebaseUser =
            (await FirebaseAuth.instance.signInWithCredential(credential)).user;

        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=id,name,first_name,last_name,email,picture,gender&access_token=${facebookLoginResult
                .accessToken.token}');
        var profile = JSON.jsonDecode(graphResponse.body);
        _loginPageState.isFacebookLoggedInUpdate(context,prefs,true,profile['email'],profile['id'], profileData: firebaseUser);
        break;
    }
  }

  facebookLogout(BuildContext context,SharedPreferences prefs) async {
    if(facebookLogin.isLoggedIn != null ) {
      await facebookLogin.logOut();
      _loginPageState.isFacebookLoggedInUpdate(context, prefs, false, '', '');
    }
    print("Logged out");
  }
}