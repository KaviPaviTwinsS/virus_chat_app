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



  Future<Null> _login() async {
    // Let's force the users to login using the login dialog based on WebViews. Yay!
    facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    final FacebookLoginResult result =
    await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        _showMessage('''
         Logged in!
         
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');
        break;
      case FacebookLoginStatus.cancelledByUser:
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }
  void _showMessage(String message) {
    print('NANDHU FAVBBBBBBBBBBBBB $message');
  }
  void initiateFacebookLogin(BuildContext context,SharedPreferences prefs) async {
    // Let's force the users to login using the login dialog based on WebViews. Yay!
    facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    final FacebookLoginResult result =
    await facebookLogin.logIn(['email', 'public_profile']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        FacebookAccessToken myToken = result.accessToken;
        AuthCredential credential =
        FacebookAuthProvider.getCredential(accessToken: myToken.token);
// this line do auth in firebase with your facebook credential.
        FirebaseUser firebaseUser =
            (await FirebaseAuth.instance.signInWithCredential(credential)).user;

        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=id,name,first_name,last_name,email,picture,gender&access_token=${
                result
                .accessToken.token}');
        var profile = JSON.jsonDecode(graphResponse.body);
        _loginPageState.isFacebookLoggedInUpdate(context,prefs,true,profile['email'],profile['id'], profileData: firebaseUser);
        final FacebookAccessToken accessToken = result.accessToken;
        _showMessage('''
         Logged in!
         
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');
        break;
      case FacebookLoginStatus.cancelledByUser:
        _loginPageState.isFacebookLoggedInUpdate(context,prefs,false,'','');
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        _loginPageState.isFacebookLoggedInUpdate(context,prefs,false,'','');
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
   /* var facebookLoginResult = await facebookLogin.logIn(['email', 'public_profile']);
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
    }*/
  }

  facebookLogout(BuildContext context,SharedPreferences prefs) async {
    if(facebookLogin.isLoggedIn != null ) {
      await facebookLogin.logOut();
      _loginPageState.isFacebookLoggedInUpdate(context, prefs, false, '', '');
    }
    print("Logged out");
  }
}