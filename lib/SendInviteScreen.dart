import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/chat/chat.dart';
import 'package:virus_chat_app/utils/colors.dart';


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
  String _mcurrentPhotoUrl;
  bool _misAlreadyRequestSent;
  bool isFriend;
  SharedPreferences prefs;

  String _userName,_userPhotoUrl;
  String _friendToken = '';
  String currentUserName ='';
  String userSignInType = '';


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
    userSignInType = await prefs.getString('signInType');
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
    return Scaffold(
    /*  appBar: AppBar(
        leading: new IconButton(
            icon: Icon(Icons.arrow_back_ios), onPressed: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  Chat(currentUserId:_mCurrentUserId ,peerId: _mPeerId,peerAvatar: _mPhotoUrl,isFriend: false,isAlreadyRequestSent: _misAlreadyRequestSent,)));
        }),
      ),*/
      body:Stack(
        children: <Widget>[
        SingleChildScrollView(
        child: Column(
            children: <Widget>[
              Row(
                 children: <Widget>[
                   Container(
                       color: facebook_color,
                       width:  MediaQuery
                           .of(context)
                           .size
                           .width ,
                       height: 80,
                       child: Column(
                         children: <Widget>[
                           Row(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: <Widget>[
                             Container(
                               margin: EdgeInsets.only(top: 25.0),
                               child:   new IconButton(
                                   icon: Icon(Icons.arrow_back_ios,color: white_color,), onPressed: () {
                                 Navigator.push(context, MaterialPageRoute(
                                     builder: (context) =>
                                         UsersList(userSignInType,_mCurrentUserId,_userPhotoUrl)));
                               }),
                             ),
                               new Container(
                                   margin: EdgeInsets.only(
                                      top: 30.0, right: 10.0),
                                   child: Material(
                                       child: CachedNetworkImage(
                                         placeholder: (context, url) =>
                                             Container(
                                               child: CircularProgressIndicator(
                                                 strokeWidth: 1.0,
                                                 valueColor: AlwaysStoppedAnimation<
                                                     Color>(themeColor),
                                               ),
                                               width: 55.0,
                                               height: 55.0,
                                               padding: EdgeInsets.all(10.0),
                                             ),
                                         imageUrl: _mPhotoUrl,
                                         width: 35.0,
                                         height: 35.0,
                                         fit: BoxFit.cover,
                                       ),
                                       borderRadius: BorderRadius.all(
                                         Radius.circular(18.0),
                                       ),
                                       clipBehavior: Clip.hardEdge,
                                   ),
                                 ),
                               Container(
                                 margin: EdgeInsets.only(
                                     top: 40.0, right: 10.0),
                                 child: Text(
                                   currentUserName, style: TextStyle(
                                     fontWeight: FontWeight.bold,
                                     color: text_color),
                                 ),
                               ),
                           /* Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 30.0, right: 10.0),
                                  child: Text(
                                    currentUserName, style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: text_color),
                                  ),
                                ),
                                *//*Container(
                                  margin: EdgeInsets.only(
                                      top: 5.0, right: 10.0),
                                  child: Text(
                                    'Active Now', style: TextStyle(
                                      color: text_color),
                                  ),
                                )*//*
                              ],
                            )*/
                             ],
                           ),

                                 ]
                   ),
                   ),
                 ],
              ),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height:MediaQuery
                          .of(context)
                          .size
                          .height - 80,
                      decoration: BoxDecoration(
                          color: text_color,
                          borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(30.0),
                            topRight: const Radius.circular(30.0),
                          )
                      ),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new SvgPicture.asset(
                              'images/accept.svg',
                              width: 80.0,
                              height: 80.0,
                            ),
                          !isButtonPressed ? RaisedButton(
                              color: white_color,
                              child: Text('Sent Invite' ,),
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
                          ) : Text('Invite sent',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),
                          Container(
                            padding: EdgeInsets.all(20.0),
                            child: Text('You\'ll be able to chat with VALENTINE once your invitation has been accepted.'),
                          )
                        ],
                      )
                  )
              )
            ],
          )
        )
    ])
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