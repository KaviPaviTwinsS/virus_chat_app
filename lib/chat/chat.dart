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
import 'package:virus_chat_app/audiop/MyAudioRecorder.dart';
import 'package:virus_chat_app/chat/fullPhoto.dart';
import 'package:virus_chat_app/utils/colors.dart';


class Chat extends StatelessWidget {
  final String peerId;
  final String peerAvatar;
  final String currentUserId;
  final bool isFriend;
  bool isAlreadyRequestSent;
  String peerName;

  Chat(
      {Key key, @required this.currentUserId, @required this.peerId, @required this.peerAvatar, @required this.isFriend, @required this.isAlreadyRequestSent, @required this.peerName})
      : super(key: key) {
    print('ISSSSSSSSSSSSSSSSSSSSSSSSSSSSSS     ${this.isAlreadyRequestSent}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
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
      ),
      body: new ChatScreen(
          currentUserId: currentUserId,
          peerId: peerId,
          peerAvatar: peerAvatar,
          isFriend: isFriend,
          isAlreadyRequestSent: isAlreadyRequestSent,
          peerName: peerName
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

  ChatScreen({Key key, @required this.currentUserId, @required this.peerId,
    @required this.peerAvatar, @required this.isFriend, @required this.isAlreadyRequestSent, @required this.peerName})
      : super(key: key);

  @override
  State createState() =>
      new ChatScreenState(currentUserId: currentUserId,
          peerId: peerId,
          peerAvatar: peerAvatar,
          isFriend: isFriend,
          isAlreadyRequestSent: isAlreadyRequestSent,
          peerName: peerName);
}

abstract class audioListener {
  void audioListenerPath(String mAudioPath);
}

class ChatScreenState extends State<ChatScreen> implements audioListener {
  ChatScreenState(
      {Key key, @required this.currentUserId, @required this.peerId, @required this.peerAvatar,
        @required this.isFriend, @required this.isAlreadyRequestSent, @required this.peerName});

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

  final TextEditingController textEditingController = new TextEditingController();
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


  @override
  void audioListenerPath(String audioPath) {
    print('audioPath $audioPath');
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
    recorder.initializeExample(FlutterSound());
    super.initState();
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
    id = prefs.getString('id') ?? currentUserId;
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    /* Firestore.instance.collection('users').document(id).updateData(
        {'chattingWith': peerId});*/
    _friendToken = await prefs.getString('FRIEND_USER_TOKEN');
    currentUserName = await prefs.getString('name');
    mUsersList = await prefs.getStringList('CHAT_USERS');
    mUsersListName = await prefs.getStringList('CHAT_USERS_NAME');
    setState(() {});
  }

  Future uploadAudioFile() async {
    print('uploadAudioFile $mAudioPath');
    String imageUrl;
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    print('downloadUrl Filename $fileName');
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    File file =File(mAudioPath);
    assert(file.existsSync());
    StorageUploadTask uploadTask = reference.putFile(File(mAudioPath));
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
//        isLoading = false;
        storeFile(imageUrl, fileName);
        onSendMessage(imageUrl, 5, fileName);
      });
    }, onError: (err) {
      setState(() {
//        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }


  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

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
        onSendMessage(imageUrl, 1, '');
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }


  void onSendMessage(String content, int type, String fileName) {
    // type: 0 = text, 1 = image, 2 = sticker
    String audioTime = '-1';
    if (type == 5) {
      if (fileName != '')
        audioTime = fileName;
    }
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime
          .now()
          .millisecondsSinceEpoch
          .toString());
/*

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId);
*/


      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime
                .now()
                .millisecondsSinceEpoch
                .toString(),
            'content': content,
            'audioTime': audioTime,
            'type': type
          },
        );
      });

      listScrollController.animateTo(
          0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      validate();
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  void validate() async {
    print('VALIDATE');
    bool isExistUser = false;
    if (mUsersList != null && mUsersList.length != 0) {
      for (int j = 0; j < mUsersList.length; j++) {
        print('CHAT USER PEERRRRRRRRRRRRRRRRRRRRRRRRRRRRR ${mUsersList[j]}');
        if (mUsersList[j] == peerId) {
          isExistUser = true;
        } else {
          mUsersList.add(peerId);
          mUsersListName.add(peerName);
        }
      }
    } else {
      mUsersList = new List();
      mUsersListName = new List();
      mUsersList.add(peerId);
      mUsersListName.add(peerName);
    }
    if (!isExistUser) {
      print('CHAT USER isExistUser ${mUsersList.length}');
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


  final String serverToken = 'AAAA1iQ7au4:APA91bGvPY8CpYvutHVhzh7RL-xyybt7lxPNU_OxXPCJdxDtyZain9hxgliGV9OQyaXLiKXJyVUhpQm0tygEz4YfisEdGIOLyNo3vgUguNMEpBVEaEwUfONgErCLALyrrLTroFhfq5YD';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String _message = '';

  Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
    print('_friendToken_____________________________chat $_friendToken');
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

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['type'] == 5) {
      storeFile(document['content'], document['audioTime']);
    }
    print(
        'CONTENTTTTTTTTTTTTTTTTTTTTTTTTT___ ${ document['type']} ___${document['audioTime']}');
    if (document['idFrom'] == id) {
      // Right (my message)
      return new Row(
        children: <Widget>[
          document['type'] == 0
          // Text
              ? Container(
            child: Text(
              document['content'],
              style: TextStyle(color: primaryColor),
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(
                color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
          )
              : document['type'] == 1
          // Image
              ? Container(
            child: FlatButton(
              child: Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) =>
                      Container(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
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
                        child: Image.asset(
                          'images/img_not_available.jpeg',
                          width: 200.0,
                          height: 200.0,
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
            margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
          )
          // Sticker
              : document['type'] == 5 ?
          new Material(
            child: Container(
              height: 56.0,
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.play_circle_filled),
                    onPressed: () {
                      isPlaying
                          ? flutterStopPlayer(
                          document['content'], document['audioTime'])
                          : flutterPlaySound(
                          document['content'], document['audioTime']);
                    },
                  ),
                  new Slider(
                    label: index.toString(),
                    value: sliderCurrentPosition,
                    min: 0.0,
                    max: maxDuration,
                    divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt(),
                    onChanged: (double value) {},),
                ],
              ),
            ),
          )
              :
          new Material(
            child: Container(
              height: 56.0,
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.play_circle_filled),
                    onPressed: () {
                      isPlaying
                          ? flutterStopPlayer(
                          document['content'], document['audioTime'])
                          : flutterPlaySound(
                          document['content'], document['audioTime']);
                    },
                  ),
                  new Slider(
                    label: index.toString(),
                    value: sliderCurrentPosition,
                    min: 0.0,
                    max: maxDuration,
                    divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt(),
                    onChanged: (double value) {},),
                ],
              ),
            ),
          ) /*Container(
            child: new Image.asset(
              'images/${document['content']}.gif',
              width: 100.0,
              height: 100.0,
              fit: BoxFit.cover,
            ),
            margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
          ),*/
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                        Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                themeColor),
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
                )
                    : Container(width: 35.0),
                document['type'] == 0
                    ? Container(
                  child: Text(
                    document['content'],
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: primaryColor,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(left: 10.0),
                )
                    : document['type'] == 1
                    ? Container(
                  child: FlatButton(
                    child: Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) =>
                            Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    themeColor),
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
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
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
                  margin: EdgeInsets.only(left: 10.0),
                ) : document['type'] == 5 ?
                new Material(
                  child: Container(
                    height: 56.0,
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.play_circle_filled),
                          onPressed: () {
                            isPlaying
                                ? flutterStopPlayer(
                                document['content'], document['audioTime'])
                                : flutterPlaySound(
                                document['content'], document['audioTime']);
                          },
                        ),
                        new Slider(
                          label: index.toString(),
                          value: sliderCurrentPosition,
                          min: 0.0,
                          max: maxDuration,
                          divisions: maxDuration == 0.0 ? 1 : maxDuration
                              .toInt(),
                          onChanged: (double value) {},),
                      ],
                    ),
                  ),
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

            // Time
            isLastMessageLeft(index)
                ? Container(
              child: Text(
                DateFormat('dd MMM kk:mm')
                    .format(DateTime.fromMillisecondsSinceEpoch(
                    int.parse(document['timestamp']))),
                style: TextStyle(color: greyColor,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),
              ),
              margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
            )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
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
    print(
        'urlllllllllllllllllllllllllllllllllllllllllllll_____ $uri _____$imageUrl');
    if (!await File(uri).exists())
      getImageFromNetwork(imageUrl, uri);
    print('myDataPath $myDataPath');
  }

  Future<Io.File> getImageFromNetwork(String url, String uri) async {
    var response = await get(url);
    print('getImageFromNetwork');
    File file = new File(
        uri
    );
    file.writeAsBytes(response.bodyBytes);
//
//    file.writeAsBytesSync(response.bodyBytes);
//    var cacheManager = await CacheManager.getInstance();
//    Io.File file = await cacheManager.getFile(url);
    return file;
  }


  flutterPlaySound(url, String fileName) async {
    Directory tempDir = await getExternalStorageDirectory();
    String uri = '${tempDir.path}/${fileName}' + '.aac';
    bool isFileExist = await File(uri).exists();
    if (isFileExist) {
      print('EXISTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT');
      await flutterSound.startPlayer(uri);
    } else {
      print(
          'EXISTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT__________________________');
      storeFile(url, fileName);
      await flutterSound.startPlayer(url);
    }
    flutterSound.onPlayerStateChanged.listen((e) {
      if (flutterSound.isPlaying) {
        setState(() {
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
      print(
          "Playing NUlllllllllllllllllllll $maxDuration ____ $sliderCurrentPosition _____$e");
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
          print('VALUEEEEEEEEEEEEEEEEEEEEEEEE $value');
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
    print('groupChatId______________________ $isFriend _____ ${isFriend !=
        null} ___${peerAvatar}');
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
      return WillPopScope(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // List of messages
                buildListMessage(),

                // Sticker
                (isShowSticker ? buildSticker() : Container()),

                // Input content
                buildInput(),
              ],
            ),

            // Loading
            buildLoading()
          ],
        ),
        onWillPop: onBackPress,
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
              valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
        ),
        color: Colors.white.withOpacity(0.8),
      )
          : Container(),
    );
  }


  bool audioClicked = false;

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
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
                onTap: (){
                  print('CHAT SOUTTTTTTTTTTTTTTTTTTTTT');
                  if(audioClicked) {
                    setState(() {
                      audioClicked = false;
                    });
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
                      margin: new EdgeInsets.symmetric(horizontal: 1.0),
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
                        margin: new EdgeInsets.symmetric(horizontal: 1.0),
                        child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
                        : Center(child: new Container(
                      margin: new EdgeInsets.symmetric(horizontal: 1.0),
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
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: getImage,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.face),
                onPressed: getSticker,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () =>
                    onSendMessage(textEditingController.text, 0, ''),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
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
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            listMessage = snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }
}
