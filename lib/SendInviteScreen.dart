import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:virus_chat_app/FriendRequestScreen.dart';
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/chat/chat.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/constants.dart';
import 'package:virus_chat_app/utils/strings.dart';


class SendInviteToUser extends StatefulWidget {
  String _mPeerId, _mCurrentUserId;
  String _mPhotoUrl;
  bool _misAlreadyRequestSent;
  bool _misRequestSent;
  String _mName = '';

  SendInviteToUser(String peerId, String currentUserId, String friendPhotoUrl,
      bool isAlreadyRequestSent, bool isRequestSent, String name) {
    _mPeerId = peerId;
    _mCurrentUserId = currentUserId;
    _mPhotoUrl = friendPhotoUrl;
    _misAlreadyRequestSent = isAlreadyRequestSent;
    _misRequestSent = isRequestSent;
    _mName = name;
  }

  @override
  State<StatefulWidget> createState() {
    return SendInviteToUserState(
        _mPeerId, _mCurrentUserId, _mPhotoUrl, _misAlreadyRequestSent,
        _misRequestSent, _mName);
  }

}

class SendInviteToUserState extends State<SendInviteToUser> {
  String _mPeerId, _mCurrentUserId;
  String _mPhotoUrl;
  String _mcurrentPhotoUrl;
  bool _misAlreadyRequestSent;
  bool _misRequestSent;
  bool isFriend;
  SharedPreferences prefs;

  String _userName, _userPhotoUrl;
  String _friendToken = '';
  String currentUserName = '';
  String userSignInType = '';

  String _mUserName = '';

  SendInviteToUserState(String peerId, String currentUserId,
      String friendPhotoUrl, bool isAlreadyRequestSent, bool isRequestSent,
      String mName) {
    _mPeerId = peerId;
    _mCurrentUserId = currentUserId;
    _mPhotoUrl = friendPhotoUrl;
    _misAlreadyRequestSent = isAlreadyRequestSent;
    _misRequestSent = isRequestSent;
    _mUserName = mName;
    print(
        'PERRRR IDD $_misAlreadyRequestSent _____________misRequestSent $_misRequestSent');
  }

  bool isButtonPressed = false;
  bool isRequestSent = true;

  Future<bool> onBackPress() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    initial();
    super.initState();
  }

  void initial() async {
    prefs = await SharedPreferences.getInstance();
    if (_misAlreadyRequestSent != null && _misAlreadyRequestSent) {
      setState(() {
        isButtonPressed = !isButtonPressed;
      });
    }
    await getUserActiveTime();
    _userName = await prefs.getString('name');
    _userPhotoUrl = await prefs.getString('photoUrl');
    _friendToken = await prefs.getString('FRIEND_USER_TOKEN');
    currentUserName = await prefs.getString('name');
    userSignInType = await prefs.getString('signInType');
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    if (!isButtonPressed) {
      print('_________________________isButtonPressed __$isButtonPressed');
      sendInvite();
    }
//    flutterLocalNotificationsPlugin.initialize(initializationSettings,);
  }


  Future onSelectNotification(String payload) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                FriendRequestScreenState(
                    _mCurrentUserId,
                    _mcurrentPhotoUrl)));
  }

  String mDifference = '';

  Future getUserActiveTime() async {
    print('_mPeerId________________$_mPeerId');
    var document = await Firestore.instance.collection('users').document(
        _mPeerId).collection('userLocation').document(_mPeerId).get();
    var chatData = document.data;
    var date = new DateTime.fromMillisecondsSinceEpoch(
        chatData['UpdateTime']);
    var currDate = ((new DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch) / 1000).toInt();
    var currTime = new DateTime.fromMillisecondsSinceEpoch(
        currDate);
    var differenceDays = currTime
        .difference(date)
        .inDays;
    var differenceHours = currTime
        .difference(date)
        .inHours;
    var differenceMins = currTime
        .difference(date)
        .inMinutes;
    var differenceSecs = currTime
        .difference(date)
        .inSeconds;
    if (differenceDays == 0) {
      if (differenceHours == 0) {
        if (differenceMins == 0) {
          if (differenceSecs == 0) {
            mDifference = 'Active Now';
          } else {
            mDifference = differenceSecs.toString() + '\t secs';
          }
        } else {
          mDifference = differenceMins.toString() + '\t mins';
        }
      } else {
        mDifference = differenceHours.toString() + '\t hours';
      }
    } else {
      if (differenceDays == 1) {
        mDifference = differenceDays.toString() + '\t day';
      } else if (differenceDays == 30) {
        differenceDays = 1;
      } else {
        mDifference = differenceDays.toString() + '\t days';
      }
    }
    setState(() {

    });
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 40.0, bottom: 10.0),
                          child: new IconButton(
                              icon: new SvgPicture.asset(
                                'images/back_icon.svg',
                                width: 20.0,
                                height: 20.0,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
//                                                Navigator.push(
//                                                    context, MaterialPageRoute(
//                                                    builder: (context) =>
//                                                        UsersList(userSignInType,
//                                                            _mCurrentUserId,
//                                                            _userPhotoUrl)));
                              }),
                        ),
                        new Container(
                          margin: EdgeInsets.only(
                              top: 40.0, right: 10.0, bottom: 10.0),
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) =>
                                  Container(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.0,
                                      valueColor: AlwaysStoppedAnimation<
                                          Color>(progress_color),
                                    ),
                                    width: 35.0,
                                    height: 35.0,
                                    padding: EdgeInsets.all(10.0),
                                  ),
                              errorWidget: (context, url,
                                  error) =>
                                  Material(
                                    child: /* Image.asset(
                                                      'images/img_not_available.jpeg',
                                                      width: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width - 30,
                                                      height: 200.0,
                                                      fit: BoxFit.cover,
                                                    ),*/
                                    new SvgPicture.asset(
                                      'images/user_unavailable.svg',
                                      width: 35.0,
                                      height: 35.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(18.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
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
                       Column(
                         mainAxisAlignment: MainAxisAlignment.start,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: <Widget>[
                           Container(
                             margin: EdgeInsets.only(
                                 top: 30.0, right: 10.0, bottom: 5.0),
                             child: Text(
                               _mUserName, style: TextStyle(
                                 fontWeight: FontWeight.w500,
                                 color: black_color,
                                 fontSize: 15.0,
                                 fontFamily: 'GoogleSansFamily'),
                             ),
                           ),
                           mDifference != 'Active Now' ? Container(
                             child: Text(
                               'Active \t ' + mDifference + '\t ago',
                               style: TextStyle(
                                   fontWeight: FontWeight.w400,
                                   fontFamily: 'GoogleSansFamily',
                                   fontSize: 13.0,
                                   color: hint_color_grey_light),
                             ),
                           ) : Container(
                             child: Text(
                               mDifference, style: TextStyle(
                                 fontWeight: FontWeight.w400,
                                 fontFamily: 'GoogleSansFamily',
                                 fontSize: 13.0,
                                 color: hint_color_grey_light),
                             ),
                           ),
                         ],
                       )
                      ],
                    ),
                    Divider(color: divider_color, thickness: 1.0,),
                  ],
                ),

                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 15.0),
                                child: new SvgPicture.asset(
                                  'images/invite_sent.svg',
                                  width: 80.0,
                                  height: 80.0,
                                ),
                              ),
                              !isButtonPressed ? /*RaisedButton(
                                  color: white_color,
                                  child: Text('Sent Invite',),
                                  onPressed: () {
//                                    if (!_misAlreadyRequestSent) {
                                    }
//                                  }
                              )*/
                              Container(
                                margin: EdgeInsets.only(top: 15.0),
                                child: Text('Invite Sent!', style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20.0,
                                    fontFamily: 'GoogleSansFamily'),),
                              )
                                  : _misRequestSent == null ? Container(
                                margin: EdgeInsets.only(top: 15.0),
                                child: Text('Invite Sent!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20.0,
                                      fontFamily: 'GoogleSansFamily'),),
                              ) : (!_misAlreadyRequestSent != null &&
                                  !_misAlreadyRequestSent)
                                  ? Container(
                                  margin: EdgeInsets.only(top: 15.0),
                                  child: Text(
                                    'Invitation Received', style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20.0,
                                      fontFamily: 'GoogleSansFamily'),))
                                  : !_misRequestSent
                                  ? Container(
                                  margin: EdgeInsets.only(top: 15.0),
                                  child: Text(
                                    'Invitation Received', style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20.0,
                                      fontFamily: 'GoogleSansFamily'),))
                                  : Container(
                                margin: EdgeInsets.only(top: 15.0),
                                child: Text('Already invitation sent',
                                  style: TextStyle(fontWeight: FontWeight.w500,
                                      fontSize: 20.0),),
                              ),
                              Container(
                                    padding: EdgeInsets.all(30.0),
                                margin: EdgeInsets.only(
                                    left: 20.0, right: 20.0),
                                child: Text(
                                  'You\'ll be able to chat with $_mUserName once your invitation has been accepted.',
                                  style: TextStyle(fontWeight: FontWeight.w400,
                                      fontFamily: 'GoogleSansFamily',
                                      color: hint_color_grey_dark,),textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                        )
                    )
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: buildInput(),
                )

              ])
      ),
    );
  }


  Widget buildInput() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              /* Material(
                child: new Container(
                  margin: EdgeInsets.only(left: 10.0),
                  child: new IconButton(
                    icon: new SvgPicture.asset(
                      'images/smile.svg', height: 20.0,
                      width: 20.0,
                    ),
                    onPressed: getImage,
                    color: primaryColor,
                  ),
                ),
                color: Colors.white,
              ),*/
              Material(
                child: new Container(
                  margin: EdgeInsets.only(left: 10.0, top: 10.0),
//                  margin: new EdgeInsets.symmetric(horizontal: 1.0),
                  child: new IconButton(
                    icon: new SvgPicture.asset(
                      'images/camera.svg', height: 20.0,
                      width: 20.0,
                    ),
                    color: primaryColor,
                  ),
                ),
                color: Colors.white,
              ),
              // Button send image
              Material(
                child: new Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: new IconButton(
                    icon: new SvgPicture.asset(
                      'images/pic.svg', height: 20.0,
                      width: 20.0,
                    ),
                    color: primaryColor,
                  ),
                ),
                color: Colors.white,
              ),
              Material(
                child: Listener(
                    onPointerDown: (details) {
                      print('onPointerDown');
//                audioClicked = true;
                    },
                    onPointerUp: (details) {
                      print('onPointerUp');
                    },
                    child: GestureDetector(
                      onTap: () {
                      },
                      child: Stack(
                        children: <Widget>[
                          Center(child: new Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: new IconButton(
                              icon: new SvgPicture.asset(
                                'images/voice.svg', height: 20.0,
                                width: 20.0,
                              ),
                              onPressed: () {
                              },
                            ),
                          ),
                          ),
                Center(child: new Container(
                            margin: EdgeInsets.only(top: 10.0),
//                            margin: new EdgeInsets.symmetric(horizontal: 1.0),
                            child:  new IconButton(
                              icon: new SvgPicture.asset(
                                'images/voice.svg', height: 20.0,
                                width: 20.0,
                              ),
                              onPressed: () {
                              },
                            ),
                          ),
                          )
                        ],
                      ),
                    )
                ),
                color: Colors.white,
              ),
              // Edit text
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 20.0, bottom: 5.0),
                  child: TextField(
                    style: TextStyle(color: black_color, fontSize: 15.0),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: chat_hint,
                      hintStyle: TextStyle(color: hint_color_grey_dark,
                          fontFamily: 'GoogleSansFamily',
                          fontWeight: FontWeight.w400),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: focused_border_color,
                            width: 0.5),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(30.0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: greyColor, width: 0.5),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(30.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Button send message
              Material(
                child: Container(
                    width: 90,
                    height: 90,
                    child: new IconButton(
                      icon: new SvgPicture.asset(
                        'images/Send.svg', height: 90.0,
                        width: 90.0,
                        allowDrawingOutsideViewBox: true,
                      ),
                      onPressed: () =>
                          Fluttertoast.showToast(msg: 'Waiting for friend request'),
                      color: primaryColor,
                    )
                ),
                color: Colors.white,
              ),

            ],
          )
        ],
      ),
      width: double.infinity,
      height: 150.0,
      decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Future sendInvite() async {
    print('sendInvite____________');
    try {
      /* var documentReference = Firestore.instance
          .collection('users')
          .document(_mCurrentUserId)
          .collection('FriendsList')
          .document(_mPeerId);*/
      // Update data to server if new user

      /*Firestore.instance.runTransaction((transaction) async {
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
        ).catchError((error){
          error.toString();
        });
      })*/
      /*   var documentReference1 = Firestore.instance
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
          ).catchError((error){
            error.toString();
          });
        });*/

      Firestore.instance
          .collection('users')
          .document(_mCurrentUserId)
          .collection('FriendsList')
          .document(_mPeerId).setData({
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
      }).whenComplete(() {
        Firestore.instance
            .collection('users')
            .document(_mPeerId)
            .collection('FriendsList')
            .document(_mCurrentUserId).setData({
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
        });
      }).whenComplete(() {
        sendAndRetrieveMessage();
      });
    } on Exception catch (e) {
      e.toString();
    }
    setState(() {
      isButtonPressed = !isButtonPressed;
      _misRequestSent = null;
    });
  }

  final String serverToken = SERVER_KEY;
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

  void getMessage() {
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