import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class SendInviteToUser extends StatefulWidget{
  String _mPeerId, _mCurrentUserId;
  String _mPhotoUrl;
  bool _misAlreadyRequestSent;
  SendInviteToUser(String peerId, String currentUserId,String friendPhotoUrl,bool isAlreadyRequestSent) {
    _mPeerId = peerId;
    _mCurrentUserId = currentUserId;
    _mPhotoUrl = friendPhotoUrl;
    _misAlreadyRequestSent= isAlreadyRequestSent;
  }
  @override
  State<StatefulWidget> createState() {
    return SendInviteToUserState(_mPeerId,_mCurrentUserId,_mPhotoUrl,_misAlreadyRequestSent);
  }

}
class SendInviteToUserState extends State<SendInviteToUser> {
  String _mPeerId, _mCurrentUserId;
  String _mPhotoUrl;
  bool _misAlreadyRequestSent;
  SharedPreferences prefs;

  String _userName,_userPhotoUrl;
  String _friendToken = '';
  String currentUserName ='';


  SendInviteToUserState(String peerId, String currentUserId,String friendPhotoUrl,bool isAlreadyRequestSent) {
    print('PERRRR IDD $peerId');
    _mPeerId = peerId;
    _mCurrentUserId = currentUserId;
    _mPhotoUrl = friendPhotoUrl;
    _misAlreadyRequestSent= isAlreadyRequestSent;
  }
  bool isButtonPressed = false;

  @override
  void initState() {
    initial();
    super.initState();
  }

  void initial() async{
    prefs = await SharedPreferences.getInstance();
    if(_misAlreadyRequestSent){
      setState(() {
        isButtonPressed =!isButtonPressed;
      });
    }
    _userName =  await prefs.getString('name');
    _userPhotoUrl =await prefs.getString('photoUrl');
    _friendToken = await prefs.getString('FRIEND_USER_TOKEN');
    currentUserName = await prefs.getString('name');
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,);
  }
  @override
  Widget build(BuildContext context) {
    return  Flexible(
              child : Center(
                child: RaisedButton(
                  child: Text( isButtonPressed ? 'Invitation sent Successfully Waiting for accept' : ' Sent Invitation' ,),
                  onPressed: () {
                    if (!_misAlreadyRequestSent) {
                      var documentReference = Firestore.instance
                          .collection('users')
                          .document(_mCurrentUserId)
                          .collection('FriendsList')
                          .document(_mPeerId);
                      Firestore.instance.runTransaction((transaction) async {
                        await transaction.set(
                          documentReference,
                          {
                            'requestFrom': _mCurrentUserId,
                            'receiveId': _mPeerId,
                            'IsAcceptInvitation': false,
                            'isRequestSent': true,
                            'friendPhotoUrl': _userPhotoUrl,
                            'friendName': _userName,
                            'isAlreadyRequestSent': true,
                            'timestamp': DateTime
                                .now()
                                .millisecondsSinceEpoch
                                .toString(),
                          },
                        );
                      });
                      var documentReference1 = Firestore.instance
                          .collection('users')
                          .document(_mPeerId)
                          .collection('FriendsList')
                          .document(_mCurrentUserId);
                      Firestore.instance.runTransaction((transaction) async {
                        await transaction.set(
                          documentReference1,
                          {
                            'requestFrom': _mCurrentUserId,
                            'receiveId': _mPeerId,
                            'IsAcceptInvitation': false,
                            'isRequestSent': false,
                            'friendPhotoUrl': _userPhotoUrl,
                            'friendName': _userName,
                            'isAlreadyRequestSent': true,
                            'timestamp': DateTime
                                .now()
                                .millisecondsSinceEpoch
                                .toString(),
                          },
                        );
                      });
                      sendAndRetrieveMessage();
                      setState(() {
                        isButtonPressed = !isButtonPressed;
                      });
                    }
                  }
                ),
              )
    );
  }
  final String serverToken = 'AAAA1iQ7au4:APA91bGvPY8CpYvutHVhzh7RL-xyybt7lxPNU_OxXPCJdxDtyZain9hxgliGV9OQyaXLiKXJyVUhpQm0tygEz4YfisEdGIOLyNo3vgUguNMEpBVEaEwUfONgErCLALyrrLTroFhfq5YD';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String _message = '';

  Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
    print('_friendToken_____________________________ $_friendToken');
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
            'body': 'Friend Request from $currentUserName',
            'title': 'Friend Request'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': _friendToken,
        },
      ),
    );

    final Completer<Map<String, dynamic>> completer =
    Completer<Map<String, dynamic>>();
    getMessage();
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
    firebaseMessaging.configure(
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


}