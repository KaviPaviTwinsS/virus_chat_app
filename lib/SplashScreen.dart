import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';
import 'package:http/http.dart' as http;

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _message = '';
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  SharedPreferences preferences;
  String userToken ='';

  _register() {
    _firebaseMessaging.getToken().then((token) => {print( 'token FCMMMMMMM   ___ $token'),
      callOnFcmApiSendPushNotifications(token)});
//    Stream<String> fcmStream = _firebaseMessaging.onTokenRefresh;
//    fcmStream.listen((token) {
//      print( 'token FCMMMMMMM REFRESSSSHHH  ___ $token');
//    });
  }
  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  Future<bool> callOnFcmApiSendPushNotifications(String token) async {
    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
//      "registration_ids" : token,
      "notification" : {
        "title": 'NewTextTitle',
        "body" : 'NewTextBody',
        "to": token
      }
    };

    final headerss = {
      'content-type': 'application/json',
      'Authorization': 'AAAA1iQ7au4:APA91bGvPY8CpYvutHVhzh7RL-xyybt7lxPNU_OxXPCJdxDtyZain9hxgliGV9OQyaXLiKXJyVUhpQm0tygEz4YfisEdGIOLyNo3vgUguNMEpBVEaEwUfONgErCLALyrrLTroFhfq5YD'
    };

    final response = await http.post(postUrl,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headerss);
    // check the status code for the result
    int statusCode = response.statusCode;
    if (response.statusCode == 200) {
      // on success do sth
      print('test ok push CFM');
      return true;
    } else {
      print(' CFM error ${statusCode}');
      // on failure do sth
      return false;
    }

  }
// Replace with server token from firebase console settings.
  final String serverToken = 'AAAA1iQ7au4:APA91bGvPY8CpYvutHVhzh7RL-xyybt7lxPNU_OxXPCJdxDtyZain9hxgliGV9OQyaXLiKXJyVUhpQm0tygEz4YfisEdGIOLyNo3vgUguNMEpBVEaEwUfONgErCLALyrrLTroFhfq5YD';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
    await firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true),
    );

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'this is a body',
            'title': 'this is a title'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': await firebaseMessaging.getToken(),
        },
      ),
    );

    final Completer<Map<String, dynamic>> completer =
    Completer<Map<String, dynamic>>();
    getMessage();
//    firebaseMessaging.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        completer.complete(message);
//        _showNotificationWithDefaultSound(message);
//      },
//    );

    return completer.future;
  }
  Future _showNotificationWithDefaultSound(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message["notification"]["title"],
      message["notification"]["body"],
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  void getMessage(){
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
          _showNotificationWithDefaultSound(message);
          setState(() => _message = message["notification"]["title"]);
        }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      _showNotificationWithDefaultSound(message);
      setState(() => _message = message["notification"]["title"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      setState(() => _message = message["notification"]["title"]);
    });
  }


  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
//    _register();
    _firebaseMessaging.getToken().then((token) => {
      userToken = token ,
    initialise()
    });
  }

  void initialise() async{
    preferences = await SharedPreferences.getInstance();
    print( 'token FCMMMMMMM   ___ $userToken');
    await preferences.setString('PUSH_TOKEN', userToken);
    startTime();
//    sendAndRetrieveMessage();
//    getMessage();
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }
  void navigationPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
        builder: (context) => new LoginSelectionPage()));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Image.asset('images/splashnew.png',fit: BoxFit.cover,),
      ),
    );
  }
}
