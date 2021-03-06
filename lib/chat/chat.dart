import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sound/flauto.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' show get;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'
    show getExternalStorageDirectory, getTemporaryDirectory;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'file:///C:/Users/Nandhini%20S/Documents/virus_chat_app/lib/homePage/UsersList.dart';
import 'package:virus_chat_app/audiop/MyAudioRecorder.dart';
import 'package:virus_chat_app/chat/fullPhoto.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/constants.dart';
import 'package:virus_chat_app/utils/strings.dart';


class Chat extends StatelessWidget {
  final String peerId;
  final String peerAvatar;
  final String currentUserId;
  final bool isFriend;
  bool isAlreadyRequestSent;
  String peerName;



  String chatType = '';



  Chat(
      {Key key, @required this.currentUserId, @required this.peerId, @required this.peerAvatar, @required this.isFriend,
        @required this.isAlreadyRequestSent, @required this.peerName,@required this.chatType})
      : super(key: key) {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: new AppBar(
        title: new Text(
          'CHAT',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: white_color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),*/
      body: new ChatScreen(
          currentUserId: currentUserId,
          peerId: peerId,
          peerAvatar: peerAvatar,
          isFriend: isFriend,
          isAlreadyRequestSent: isAlreadyRequestSent,
          peerName: peerName,
        chatType: chatType,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String currentUserId;
  final bool isFriend;
  bool isAlreadyRequestSent;
  String peerName;
  String chatType;

  ChatScreen({Key key, @required this.currentUserId, @required this.peerId,
    @required this.peerAvatar, @required this.isFriend, @required this.isAlreadyRequestSent, @required this.peerName,@required this.chatType})
      : super(key: key);

  @override
  State createState() =>
      new ChatScreenState(currentUserId: currentUserId,
          peerId: peerId,
          peerAvatar: peerAvatar,
          isFriend: isFriend,
          isAlreadyRequestSent: isAlreadyRequestSent,
          peerName: peerName,chatType:chatType);
}

abstract class audioListener {
  void audioListenerPath(String mAudioPath);
}

class ChatScreenState extends State<ChatScreen> implements audioListener {
  ChatScreenState(
      {Key key, @required this.currentUserId, @required this.peerId, @required this.peerAvatar,
        @required this.isFriend, @required this.isAlreadyRequestSent, @required this.peerName,@required this.chatType});

  String peerId;
  String peerAvatar;
  String currentUserId;
  bool isFriend;
  String friendUrl;
  bool isAlreadyRequestSent;
  String id;
  String peerName;

  var listMessage;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  MyAudioRecorder recorder;
  String mAudioPath = '';
  String _friendToken = '';
  String currentUserName = '';

  List<String> mUsersList = List<String>();
  List<String> mUsersListName = List<String>();

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  bool isPlaying = false;
  var mIndex = -1;
  final _controller = TextEditingController();
  TextEditingController controllerName = new TextEditingController();
  String name = '';


  String chatType;
  @override
  void audioListenerPath(String audioPath) {
    mAudioPath = audioPath;
    uploadAudioFile();
  }

  @override
  void initState() {
    focusNode.addListener(onFocusChange);
    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
    recorder = new MyAudioRecorder(this);
    readLocal();


    setState(() {});

    controllerName.addListener(() {
      final text = controllerName.text;
      controllerName.value = controllerName.value.copyWith(
        text: text,
        selection: TextSelection(
            baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    super.initState();
  }

  String mDifference = '';

  Future getUserActiveTime() async {
    print('CHATTTTTTTTTTTTTTTTTTTTT getUserActiveTime $peerId');
    var document = await Firestore.instance.collection('users').document(
        peerId).collection('userLocation').document(peerId).get();
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
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
//    id = prefs.getString('userId') ?? '';
    id = currentUserId == '' ? prefs.getString('userId') : currentUserId;
    print('RECENT CHAT $id ___________peer $peerId');

    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    try {
      recorder.initializeExample(FlutterSound());
    } on Exception catch (e) {
      e.toString();
    }
    setState(() {

    });
    await getUserActiveTime();
    /* Firestore.instance.collection('users').document(id).updateData(
        {'chattingWith': peerId});*/
    _friendToken = await prefs.getString('FRIEND_USER_TOKEN');
    currentUserName = await prefs.getString('name');
    mUsersList = await prefs.getStringList('CHAT_USERS');
    mUsersListName = await prefs.getStringList('CHAT_USERS_NAME');
    controllerName = new TextEditingController(text: name);
    setState(() {});
  }

  Future uploadAudioFile() async {
    String imageUrl;
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    try {
      StorageReference reference = FirebaseStorage.instance.ref().child(
          fileName);
      StorageUploadTask uploadTask = reference.putFile(File(mAudioPath));
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
        imageUrl = downloadUrl;
        storeFile(imageUrl, fileName);
        onSendMessage(imageUrl, 5, fileName);
        setState(() {
          isLoading = false;
        });
      }, onError: (err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      });
    } on Exception catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }


  Future getImage() async {
    imageFile =
    await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 20);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }


  Future getCamera() async {
    imageFile =
    await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 20);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }


  Future onSendMessage(String content, int type, String fileName) async {
    // type: 0 = text, 1 = image, 2 = sticker
    String audioTime = '-1';
    if (type == 5) {
      if (fileName != '')
        audioTime = fileName;
    }
    print('RECENT CHAT $id ___________peer $peerId');
    print('onSendMessage ${controllerName
        .text}  ____ $imageUrl ________________groupChatId $groupChatId');

    if (controllerName.text != '') {
      content = controllerName.text;
      type = 0;
    }
    if (imageUrl != '') {
      content = imageUrl;
      type = 1;
    }

    if (content.trim() != '') {
      controllerName.clear();
      var currTime = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(currTime);

      try {
        documentReference.setData(
            {
              'idFrom': id,
              'idTo': peerId,
              'timestamp': currTime,
              'content': content,
              'audioTime': audioTime,
              'type': type
            });
        print('NAN ADd user');
      } catch (e) {
        print('Registration' + e);
      }
      /*  try {
        await Firestore.instance.runTransaction((
            transaction) async {
          await transaction.set(
            documentReference,
            {
              'idFrom': id,
              'idTo': peerId,
              'timestamp': currTime,
              'content': content,
              'audioTime': audioTime,
              'type': type
            },
          );
          print('Registration________CHATTTTTTTTTT');
        });
      } catch (e) {
    print('Registration________' + e);
    }*/
/*

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId);
*/
/*
      documentReference.setData(
        {
          'idFrom': id,
          'idTo': peerId,
          'timestamp': currTime,
          'content': content,
          'audioTime': audioTime,
          'type': type
        }
      );*/
      /*   Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': currTime,
            'content': content,
            'audioTime': audioTime,
            'type': type
          },
        );
      });*/
      /*  try {
        documentReference.setData(
            {
              'idFrom': id,
              'idTo': peerId,
              'timestamp': currTime,
              'content': content,
              'audioTime': audioTime,
              'type': type
            });
        print('NAN ADd user');
      } catch (e) {
        print('Registration' + e);
      }*/
      listScrollController.animateTo(
          0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      validate();
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
    setState(() {
      imageUrl = '';
    });
  }

  void validate() async {
    bool isExistUser = false;
    if (mUsersList != null && mUsersList.length != 0) {
      for (int j = 0; j < mUsersList.length; j++) {
        if (mUsersList[j] == peerId) {
          isExistUser = true;
        } else {
          if (peerId != currentUserId)
            mUsersList.add(peerId);
          else
            mUsersList.add(id);
          mUsersListName.add(peerName);
        }
      }
    } else {
      mUsersList = new List();
      mUsersListName = new List();
      if (peerId != currentUserId)
        mUsersList.add(peerId);
      else
        mUsersList.add(id);
      mUsersListName.add(peerName);
    }
    if (!isExistUser) {
      Firestore.instance.collection('users').document(currentUserId).updateData(
          {
            'chattingWith': FieldValue.arrayUnion(mUsersList),
            'chattingWithName': FieldValue.arrayUnion(mUsersListName)
          });
    } else {
      print('CHAT USER NOTTTTTTT isExistUser');
    }

    await sendAndRetrieveMessage();
  }


  final String serverToken = SERVER_KEY;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String _message = '';

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
            'body': 'Chat from $currentUserName',
            'title': 'Message'
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
          _showNotificationWithDefaultSound(message);
          setState(() => _message = message["notification"]["title"]);
        }, onResume: (Map<String, dynamic> message) async {
      _showNotificationWithDefaultSound(message);
      setState(() => _message = message["notification"]["title"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      setState(() => _message = message["notification"]["title"]);
    });
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['type'] == 5) {
      storeFile(document['content'], document['audioTime']);
    }

    print('BUILD ITEM $id _____________ ${document['idFrom']}');
    if (document['idFrom'] == id) {
      // Right (my message)
      return new Row(
        children: <Widget>[
          document['type'] == 0
          // Text
              ? Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  document['content'],
                  style: TextStyle(color: hint_color_grey_dark),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    DateFormat('kk:mm')
                        .format(DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document['timestamp']))),
                    style: TextStyle(color: hint_color_grey_light,
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic),
                  ),
                )
              ],
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(
                color: white_color, borderRadius: BorderRadius.circular(
                15.0),
                border: Border.all(color: chat_border_color)
            ),
            margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 15.0),
          )
              : document['type'] == 1
          // Image
              ? Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) =>
                            Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    progress_color),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: greyColor2,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                        errorWidget: (context, url, error) =>
                            Material(
                              child: /* Image.asset(
                                'images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),*/
                              new SvgPicture.asset(
                                'images/user_unavailable.svg', height: 200.0,
                                width: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                        imageUrl: document['content'],
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) =>
                          FullPhoto(url: document['content'])));
                    },
                    padding: EdgeInsets.all(0),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      DateFormat('kk:mm')
                          .format(DateTime.fromMillisecondsSinceEpoch(
                          int.parse(document['timestamp']))),
                      style: TextStyle(color: hint_color_grey_light,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                  )
                ]
            ),
            decoration: BoxDecoration(
              color: white_color,
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 15.0),
          )
          // Sticker
              : document['type'] == 5 ?
          Container(
            child: Column(
              children: <Widget>[
                new Material(
                  child: Container(
                    height: 56.0,
                    color: white_color,
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.play_circle_filled),
                          onPressed: () {
                            mIndex = index;
                            isPlaying
                                ? flutterStopPlayer(
                                listMessage[index]['content'],
                                document['audioTime'])
                                : flutterPlaySound(
                                listMessage[index]['content'],
                                document['audioTime']);
                          },
                        ),
                        (index == mIndex) ? new Slider(
                          label: index.toString(),
                          value: sliderCurrentPosition,
                          min: 0.0,
                          max: maxDuration,
                          divisions: maxDuration == 0.0 ? 1 : maxDuration
                              .toInt(),
                          onChanged: (double value) {

                          },) : new Slider(
                          label: index.toString(),
                          value: 0.0,
                          min: 0.0,
                          max: 0.0,
                          divisions: 0.0 == 0.0
                              ? 1
                              : 0.0
                              .toInt(),
                          onChanged: (double value) {},),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    DateFormat('kk:mm')
                        .format(DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document['timestamp']))),
                    style: TextStyle(color: hint_color_grey_light,
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic),
                  ),
                )
              ],
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 280.0,
            decoration: BoxDecoration(
                color: white_color,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: chat_border_color)
            ),
            margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 15.0),
          )
              :
          new Material(
            child: Container(
              height: 56.0,
              margin: EdgeInsets.only(left: 15.0),
              decoration: BoxDecoration(
                  color: chat_bg_color,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: chat_border_color)
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.play_circle_filled),
                    onPressed: () {
                      isPlaying
                          ? flutterStopPlayer(
                          listMessage[index]['content'], document['audioTime'])
                          : flutterPlaySound(
                          listMessage[index]['content'], document['audioTime']);
                    },
                  ),
                  (index == mIndex) ? new Slider(
                    label: index.toString(),
                    value: sliderCurrentPosition,
                    min: 0.0,
                    max: maxDuration,
                    divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt(),
                    onChanged: (double value) {},) : new Slider(
                    label: index.toString(),
                    value: 0.0,
                    min: 0.0,
                    max: 0.0,
                    divisions: 0.0 == 0.0
                        ? 1
                        : 0.0
                        .toInt(),
                    onChanged: (double value) {},),
                ],
              ),
            ),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      var myVal = isFirstMessageLeft(index);
      print('MYVALU ${myVal.isSelected}');
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                /*true ? Container(
                  margin: EdgeInsets.only(left: 10.0, right: 5.0),
                  child: Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  progress_color),
                            ),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                      imageUrl: peerAvatar,
                      width: 35.0,
                      height: 35.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(18.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                )
                    : Container(width: 35.0,
                  margin: EdgeInsets.only(left: 10.0, right: 5.0),
                ),*/
                document['type'] == 0
                    ?
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: Text(
                          document['content'],
                          style: TextStyle(color: hint_color_grey_dark),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          DateFormat('kk:mm')
                              .format(DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
                          style: TextStyle(color: hint_color_grey_light,
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic),
                        ),
                      )
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  margin: EdgeInsets.only(left: 15.0),
                  decoration: BoxDecoration(
                      color: chat_bg_color, borderRadius: BorderRadius.circular(
                      15.0),border: Border.all(color: chat_border_color)
                  ),
                )
                    : document['type'] == 1
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[Container(
                    child: FlatButton(
                      child: Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) =>
                              Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      progress_color),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: greyColor2,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                          errorWidget: (context, url, error) =>
                              Material(
                                child: /*Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),*/
                                new SvgPicture.asset(
                                  'images/user_unavailable.svg', height: 200.0,
                                  width: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                          imageUrl: document['content'],
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) =>
                                FullPhoto(url: document['content'])));
                      },
                      padding: EdgeInsets.all(0),
                    ),
                    margin: EdgeInsets.only(left: 5.0),
                  ),
                    Container(
                      margin: EdgeInsets.only(left: 5.0, top: 5.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          DateFormat('kk:mm')
                              .format(DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
                          style: TextStyle(color: hint_color_grey_light,
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  ],
                ) : document['type'] == 5 ?
                Container(
                  child: Column(
                      children: <Widget>[
                        new Material(
                          child: Container(
                            height: 56.0,
                           color: chat_bg_color,
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.play_circle_filled),
                                  onPressed: () {
                                    isPlaying
                                        ? flutterStopPlayer(
                                        listMessage[index]['content'],
                                        document['audioTime'])
                                        : flutterPlaySound(
                                        listMessage[index]['content'],
                                        document['audioTime']);
                                  },
                                ),
                                (index == mIndex) ? new Slider(
                                  label: index.toString(),
                                  value: sliderCurrentPosition,
                                  min: 0.0,
                                  max: maxDuration,
                                  divisions: maxDuration == 0.0
                                      ? 1
                                      : maxDuration
                                      .toInt(),
                                  onChanged: (double value) {},) : new Slider(
                                  label: index.toString(),
                                  value: 0.0,
                                  min: 0.0,
                                  max: 0.0,
                                  divisions: 0.0 == 0.0
                                      ? 1
                                      : 0.0
                                      .toInt(),
                                  onChanged: (double value) {},),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 5.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              DateFormat('kk:mm')
                                  .format(DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(document['timestamp']))),
                              style: TextStyle(color: timestamp_color,
                                  fontSize: 12.0,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        )
                      ]
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 280.0,
                  decoration: BoxDecoration(
                      color: chat_bg_color,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: chat_border_color)
                  ),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 0.0,left: 15.0),
                )
                    : Container(
                  child: new Image.asset(
                    'images/${document['content']}.gif',
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                ),
              ],
            ),
            /*    // Time
            isLastMessageLeft(index)
                ? Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                child: Text(
                  DateFormat('kk:mm')
                      .format(DateTime.fromMillisecondsSinceEpoch(
                      int.parse(document['timestamp']))),
                  style: TextStyle(color: timestamp_color,
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic),
                ),
                margin: EdgeInsets.only(left: 70.0, bottom: 5.0),
              ),
            )
                : Container()*/
          ],
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }


  FlutterSound flutterSound = FlutterSound();


  static const List<String> paths = [
    'sound.aac', // DEFAULT
    'sound.aac', // CODEC_AAC
    'sound.opus', // CODEC_OPUS
    'sound.caf', // CODEC_CAF_OPUS
    'sound.mp3', // CODEC_MP3
    'sound.ogg', // CODEC_VORBIS
    'sound.wav', // CODEC_PCM
  ];
  t_CODEC _codec = t_CODEC.CODEC_AAC;

  String myDataPath = '';

  void storeFile(String imageUrl, String fileName) async {
    Directory tempDir = await getExternalStorageDirectory();
    String uri = '${tempDir.path}/${fileName}' + '.aac';
    if (!await File(uri).exists())
      getImageFromNetwork(imageUrl, uri);
  }

  Future<Io.File> getImageFromNetwork(String url, String uri) async {
    var response = await get(url);
    File file = new File(
        uri
    );
    file.writeAsBytes(response.bodyBytes);
    return file;
  }


  flutterPlaySound(url, String fileName) async {
    Directory tempDir = await getExternalStorageDirectory();
    String uri = '${tempDir.path}/${fileName}' + '.aac';
    bool isFileExist = await File(uri).exists();
    if (isFileExist) {
      await flutterSound.startPlayer(uri);
    } else {
      storeFile(url, fileName);
      await flutterSound.startPlayer(url);
    }
    flutterSound.onPlayerStateChanged.listen((e) {
      if (flutterSound.isPlaying) {
        setState(() {
          print('My  e.currentPosition ${e.currentPosition}');
          this.sliderCurrentPosition = e.currentPosition;
          this.maxDuration = e.duration;
        });
      } else {
        flutterSound.stopPlayer();
        setState(() {
          this.sliderCurrentPosition = 0.0;
          this.maxDuration = 0.0;
        });
      }
      if (sliderCurrentPosition == maxDuration) {
        flutterSound.stopPlayer();
        setState(() {
          this.sliderCurrentPosition = 0.0;
          this.maxDuration = 0.0;
        });
      }
      if (e == null) {
        setState(() {
          this.isPlaying = false;
        });
      }
      else {
        setState(() {
          this.isPlaying = false;
        });
      }
    });
  }

  Future<dynamic> flutterStopPlayer(url, String fileName) async {
    await flutterSound.stopPlayer().then(
            (value) {
          flutterPlaySound(url, fileName);
        }
    );
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage != null &&
        listMessage[index - 1]['idFrom'] == id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage != null &&
        listMessage[index - 1]['idFrom'] != id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  var prevIndex = -1;
  var currIndex = -1;
  var isTrue = false;
  var count = 0;
  var isToSetImage = false;
  var len = 0;
  var datalen = 0;
  List<selectedVal> mList = new List();

  selectedVal mVal = null;

  selectedVal isFirstMessageLeft(int index) {
    currIndex = index;
    datalen = datalen + 1;
    print(
        'INDEX __$index _______prevIndex$prevIndex ________currIndex$currIndex  __len $len ___datalen $datalen');
    if (prevIndex == -1) {
      prevIndex = index;
    }

    print('MESSSAGE  prevIndex $prevIndex _________currIndex $currIndex');

    if (prevIndex + 1 == currIndex) {
      print('MESSSAGE');
      isTrue = true;
      mVal = selectedVal(isSelected: true, index: currIndex);
      count = count + 1;
      prevIndex = currIndex;
    } else {
      prevIndex = currIndex;
      isTrue = false;
      mVal = selectedVal(isSelected: false, index: currIndex);
      count = 0;
    }
    mList.add(mVal);
    print('MYVALU isFirstMessageLeft ${mVal.isSelected}');

    return mVal;

    if (count == 1) {
//      if(datalen == len)
      isToSetImage = true;
    } else if (count > 1) {
//      if(datalen == len)
      isToSetImage = true;
    } else {

    }
    /*if ((index >= 0 && listMessage != null) &&
        (listMessage[index]['idTo'] == id)) {
      print('NNNNNNNNNNNNNNNNNNN________1_____currIndex $currIndex ____prevIndex $prevIndex');
     if(currIndex == prevIndex+1){
       isTrue = true;
     }else{
       isTrue = false;
     }
      prevIndex = index;
    } else {
      print('NNNNNNNNNNNNNNNNNNN________2');
      return false;
    }
    print('NNNNNNNNNNNNNNNNNNN________prevIndex $prevIndex  ___currIndex $currIndex ___ msg __${listMessage[index]['content']}');

    if(isTrue) {
      print('NNNNNNNNNNNNNNNNNNN________3');
      return true;
    }
    else {
      print('NNNNNNNNNNNNNNNNNNN________4');
      return false;
    }*/


  }


  Future<bool> onBackPress() {
    /* if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Firestore.instance.collection('users').document(id).updateData(
          {'chattingWith': null});
      Navigator.pop(context);
    }*/
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isFriend != null && !isFriend) {
      return WillPopScope(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // List of messages
//
//                SendInviteToUser(
//                    peerId, currentUserId, peerAvatar, isAlreadyRequestSent),

              ],
            ),
            // Loading
            buildLoading()
          ],
        ),
        onWillPop: onBackPress,
      );
    } else {
      return Stack(
        children: <Widget>[
          Container(
            color: white_color,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
//                    color: white_color,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
//                    height: 150,
                    child:
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
                              }),
                        ),
                        new Container(
                          margin: EdgeInsets.only(
                              top: 40.0, right: 10.0, bottom: 10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  30.0),border: Border.all(color: profile_image_border_color)
                          ),
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
                              imageUrl: peerAvatar,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              peerName != '' && peerName != null ? Container(
                                margin: EdgeInsets.only(
                                    top: 30.0, right: 10.0, bottom: 5.0),
                                child: Text(
                                  peerName, style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: black_color,
                                    fontSize: 12.0,
                                    fontFamily: 'GoogleSansFamily'),
                                ),
                              ) : Text(''),
                              mDifference != 'Active Now' ? Container(
                                child: Text(
                                  'Active\t ' + mDifference + '\t ago',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: hint_color_grey_dark,
                                      fontSize: 12.0,
                                      fontFamily: 'GoogleSansFamily'),
                                ),
                              ) : Container(
                                child: Text(
                                  mDifference, style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.0,
                                    color: hint_color_grey_dark,
                                    fontFamily: 'GoogleSansFamily'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: 40.0, right: 20.0, bottom: 5.0),
                              child: IconButton(
                                icon: new SvgPicture.asset(
                                  'images/home.svg',
                                  height: 20.0,
                                  width: 20.0,
                                  color: black_color,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UsersList(currentUserId,
                                                  '',  '')));
                                },
                              ),
                            )
                        )
                      ],
                    ),

                  ),
                  Divider(color: divider_color, thickness: 1.0,),
                  // List of messages
                  buildListMessage(),
/*
                    // Sticker
                    (isShowSticker ? buildSticker() : Container()),
*/
                  imageUrl != '' ? FlatButton(
                    child: Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) =>
                            Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    progress_color),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: greyColor2,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                        imageUrl: imageUrl,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) =>
                          FullPhoto(url: imageUrl)));
                    },
                    padding: EdgeInsets.all(0),
                  ) : Text(''),
                  // Input content
                  buildInput(),
                ]
            ),
          ),
          /*Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
               */ /* height: MediaQuery
                    .of(context)
                    .size
                    .height - 100,
                decoration: BoxDecoration(
                    color: text_color,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(20.0),
                      topRight: const Radius.circular(20.0),
                    )
                ),*/ /*
                child: Column(
                  children: <Widget>[

                    // List of messages
                    buildListMessage(),
*/ /*
                    // Sticker
                    (isShowSticker ? buildSticker() : Container()),
*/ /*
                    imageUrl != '' ? FlatButton(
                      child: Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) =>
                              Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      progress_color),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: greyColor2,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                          imageUrl: imageUrl,
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) =>
                            FullPhoto(url: imageUrl)));
                      },
                      padding: EdgeInsets.all(0),
                    ) : Text(''),
                    // Input content
                    buildInput(),
                  ],
                ),
              ),
            ),*/
          // Loading
          buildLoading()
        ],
      );
    }
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2, ''),
                child: new Image.asset(
                  'images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2, ''),
                child: new Image.asset(
                  'images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2, ''),
                child: new Image.asset(
                  'images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2, ''),
                child: new Image.asset(
                  'images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2, ''),
                child: new Image.asset(
                  'images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2, ''),
                child: new Image.asset(
                  'images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2, ''),
                child: new Image.asset(
                  'images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2, ''),
                child: new Image.asset(
                  'images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2, ''),
                child: new Image.asset(
                  'images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
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


  bool audioClicked = false;

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
                    onPressed: getCamera,
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
                    onPressed: getImage,
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
                        if (audioClicked) {
                          setState(() {
                            audioClicked = false;
                          });
                          setState(() {
                            isLoading = true;
                          });
                          recorder.stopRecorder();
                        }
                        else {
                          setState(() {
                            audioClicked = true;
                          });
                        }
                      },
                      child: Stack(
                        children: <Widget>[
                          Center(child: new Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: audioClicked ? new IconButton(
                              icon: new SvgPicture.asset(
                                'images/voice_highlight.svg', height: 20.0,
                                width: 20.0,
                              ),
                              onPressed: () {
                                setState(() {
                                  audioClicked = false;
                                });
                                print('CHAT STOPRECORDER');
                                recorder.stopRecorder();
                              },
                            ) : new IconButton(
                              icon: new SvgPicture.asset(
                                'images/voice.svg', height: 20.0,
                                width: 20.0,
                              ),
                              onPressed: () {
                                setState(() {
                                  audioClicked = true;
                                });
                                print('CHAT STARTRECORDER');
                                recorder.startRecorder();
                              },
                            ),
                          ),
                          ),
                          audioClicked ? Container(
                              margin: EdgeInsets.only(top: 10.0),
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      progress_color)))
                              : Center(child: new Container(
                            margin: EdgeInsets.only(top: 10.0),
//                            margin: new EdgeInsets.symmetric(horizontal: 1.0),
                            child: audioClicked ? new IconButton(
                              icon: new SvgPicture.asset(
                                'images/voice_highlight.svg', height: 20.0,
                                width: 20.0,
                              ),
                              onPressed: () {
                                setState(() {
                                  audioClicked = false;
                                });
                                print('CHAT STOPRECORDER _____________');
                                recorder.stopRecorder();
                              },
                            ) : new IconButton(
                              icon: new SvgPicture.asset(
                                'images/voice.svg', height: 20.0,
                                width: 20.0,
                              ),
                              onPressed: () {
                                setState(() {
                                  audioClicked = true;
                                });
                                print('CHAT STARTRECORDER___________________');
                                recorder.startRecorder();
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
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(left: 20.0, bottom: 5.0),
                  child: TextField(
//                    maxLines: null,
//                    keyboardType: TextInputType.multiline,
                    style: TextStyle(color: black_color, fontSize: 15.0),
                    controller: controllerName,
                    onChanged: (value) {
                      name = value;
                    },
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
                    focusNode: focusNode,
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
                          onSendMessage(imageUrl, 1, ''),
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


  Widget buildListMessage() {
    print('chatType_$chatType');
//    groupChatId = '$peerId-$id';
    return Flexible(
      child: groupChatId == ''
          ? Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(progress_color)))
          : StreamBuilder(
        stream: Firestore.instance
            .collection('messages')
            .document(groupChatId)
            .collection(groupChatId)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print(
                'chat ___buildListMessage _____________NOTTT______$groupChatId ___');

            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(progress_color)));
          } else {
            listMessage = snapshot.data.documents;
//            len = snapshot.data.documents.length;
//            mList = listMessage;
//            len = mList.length;
            for (int i = 0; i < snapshot.data.documents.length; i++) {
              DocumentSnapshot documentSnapshot = snapshot.data.documents[i];
              if (documentSnapshot['idFrom'] == id) {} else {
                len = len + 1;
//                isFirstMessageLeft(i);
              }
            }

            for (int j = 0; j < mList.length; j++) {
              print('MESSSAGELISTTTTT ${mList[j].isSelected} _____${mList[j]
                  .index}');
            }
            return ListView.builder(
//              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, listMessage[index]),
              itemCount: listMessage.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }
}
