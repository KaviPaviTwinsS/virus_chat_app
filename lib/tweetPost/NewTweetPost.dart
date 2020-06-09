import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/chat/fullPhoto.dart';
import 'package:virus_chat_app/tweetPost/CategorySelection.dart';
import 'package:virus_chat_app/tweetPost/MakeTweetPost.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/constants.dart';
import 'package:virus_chat_app/utils/strings.dart';


class NewTweetPost extends StatefulWidget {
  String __mCurrentId = '';
  String _mCurrentPhotoUrl = '';

  NewTweetPost(String mCurrentId, String mCurrentPhotoUrl) {
    __mCurrentId = mCurrentId;
    _mCurrentPhotoUrl = mCurrentPhotoUrl;
  }

  @override
  State<StatefulWidget> createState() {
    return NewTweetPostState(__mCurrentId, _mCurrentPhotoUrl);
  }

}

class NewTweetPostState extends State<NewTweetPost> {

  final FocusNode focusNode = new FocusNode();
  bool isShowSticker;
  String imageUrl;
  File imageFile;
  bool isLoading;
  String mCurrentPhotoUrl = '';
  final _controller = TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  String mTweetMsg = '';
  SharedPreferences preferences;
  String currentUserId = ' ';
  String signInType = ' ';
  var listMessage;
  String peerAvatar;
  String currentUserName = '';

  String tappedCategoryName = '';
  String tappedCategoryImage = '';

  List<CategorySelection> mCategorySelect = new List<CategorySelection>();

  NewTweetPostState(String _mCurrentId, String _mCurrentPhotoUrl) {
    currentUserId = _mCurrentId;
    mCurrentPhotoUrl = _mCurrentPhotoUrl;
  }


  @override
  void initState() {
    isShowSticker = false;
    imageUrl = '';
    isLoading = false;
    focusNode.addListener(onFocusChange);
    initialise();
    setState(() {
    });

    _controller.addListener(() {
      final text = _controller.text.toLowerCase();
      _controller.value = _controller.value.copyWith(
        text: text,
        selection: TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });

    super.initState();
  }

  void initialise() async {
    preferences = await SharedPreferences.getInstance();
    signInType = await preferences.getString('signInType');
    print('NEW TWEET signInType $signInType');
    peerAvatar = await preferences.getString('photoUrl');
    currentUserName = await preferences.getString('name');
  }


  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        /*  appBar: AppBar(
          leading: new IconButton(
              icon: Icon(Icons.arrow_back_ios), onPressed: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) =>
                    UsersList(signInType,currentUserId, mCurrentPhotoUrl)));
          }),
          title: Text('Post Message'),
        ),*/
        body:Stack(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Column(
                    children: <Widget>[
                    /*  Container(
                        color: white_color,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: 150,
                        child:*/
                        Row(
                          crossAxisAlignment: CrossAxisAlignment
                              .center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 40.0, bottom: 10.0),
                              child: new IconButton(
                                  icon:new SvgPicture.asset(
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
                                child: Text('Post Message', style: TextStyle(
                                    color: black_color,
                                    fontSize: TOOL_BAR_TITLE_SIZE,
                                    fontWeight: FontWeight.w500,fontFamily: 'GoogleSansFamily'),)
                            ),
                          ],
                        ),
                      Divider(color: divider_color,thickness: 1.0,),

//                      ),
                    ]
                ),

                Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                      /*  height: MediaQuery
                            .of(context)
                            .size
                            .height - 100,
                        decoration: BoxDecoration(
                            color: text_color,
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(20.0),
                              topRight: const Radius.circular(20.0),
                            )
                        ),*/
                        child: Container(
                          child: Column(
                            children: <Widget>[
//                              buildListTweetCategory(),
                              // List of messages
                              buildTweetInput(),
                              // Input content
                              buildInput(),
                            ],
                          ),
                        )
                    )
                )
              ],
            ),
            Positioned(
              child: isLoading
                  ? Container(
                child: Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(progress_color)),
                ),
                color: Colors.white.withOpacity(0.8),
              )
                  : Container(),
            ),
          ],
        )
    );
  }


  Widget buildListTweetCategory() {
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('tweetPostCategory')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(progress_color)));
          } else {
            listMessage = snapshot.data.documents;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) =>
                  buildCategoryItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
//              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
      width: double.infinity,
      height: 100.0,
//      decoration: new BoxDecoration(
//          border: new Border(
//              top: new BorderSide(color: Colors.white, width: 0.5)),
//          color: Colors.white),
    );
  }


  Widget buildCategoryItem(int index, DocumentSnapshot document) {
    bool isSelection = document['isSelected'];
    print('NANDHu DOcumenId ${isSelection}');
    mCategorySelect.add(CategorySelection(isCategorySelected: isSelection));
    return SingleChildScrollView(child: Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(8.0),
      child: new GestureDetector(
        onTap: () {
          print(
              'NANDHu mCategorySelect index____$index ____ ${mCategorySelect[index]
                  .isCategorySelected}');
          if (mCategorySelect[index].isCategorySelected) {
            setState(() {
              for (int i = 0; i < mCategorySelect.length; i++) {
                if (index == i)
                  mCategorySelect[i].isCategorySelected = true;
                else
                  mCategorySelect[i].isCategorySelected = false;
              }
            });
          }
          else {
            setState(() {
              for (int i = 0; i < mCategorySelect.length; i++) {
                if (index == i)
                  mCategorySelect[i].isCategorySelected = true;
                else
                  mCategorySelect[i].isCategorySelected = false;
              }
            });
          }
          tappedCategoryName = document['categoryName'];
          tappedCategoryImage = document['categoryImage'];
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                /* child: CachedNetworkImage(
                  placeholder: (context, url) =>
                      Container(
                        alignment: Alignment.topLeft,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      ),
                  imageUrl: document['categoryImage'],
                  width: 30.0,
                  height: 30.0,
                  fit: BoxFit.cover,
                ),*/
                  child: IconButton(
                    icon: new SvgPicture.asset(
                      document['categoryImage'],
                      width: 30.0,
                      height: 30.0,
                    ),
                  )
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 5.0),
                child: Text(document['categoryName'], style: TextStyle(
                    color: mCategorySelect[index].isCategorySelected
                        ? button_fill_color
                        : greyColor,fontSize: TWEET_TEXT_SIZE,fontFamily: 'GoogleSansFamily'),),
              ),
            )
          ],
        ),
      ),
    )
    );
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage != null &&
        listMessage[index - 1]['idFrom'] == currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage != null &&
        listMessage[index - 1]['idFrom'] != currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isSlected = false;

  Widget buildTweetInput() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.only(top: 110.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          Container(
                            alignment: Alignment.topLeft,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  progress_color),
                            ),
                            width: 50.0,
                            height: 50.0,
                          ),
                      imageUrl: mCurrentPhotoUrl,
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(45.0)),
                    clipBehavior: Clip.hardEdge,
                  ), // Edit text
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextField(
                        style: TextStyle(color: primaryColor, fontSize: 15.0),
                        controller: _controller,
                       /* onChanged: (value) {
                          mTweetMsg = value;
                        },*/
                        decoration: InputDecoration.collapsed(
                          hintText: 'What\'s happening?',
                          hintStyle: TextStyle(color: hint_color_grey_dark,fontSize: TWEET_TEXT_SIZE,fontFamily: 'GoogleSansFamily'),
                        ),
                        focusNode: focusNode,
                        autofocus: true,
                      ),
                    ),
                  ),

                ],
              ),
              imageUrl != '' ? Container(
                width: 250.0,
                height: 250.0,
                child: FlatButton(
                  child: Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          Center(
                            child:Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<
                                    Color>(
                                    progress_color),
                              ),
                              width: 50.0,
                              height: 50.0,
                              decoration: BoxDecoration(
//                                          color: greyColor2,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                            ),
                          ),
                      errorWidget: (context, url, error) =>
                          Material(
                            child:/* Image.asset(
                              'images/img_not_available.jpeg',
                              width: 250.0,
                              height: 250.0,
                              fit: BoxFit.cover,
                            ),*/
                            new SvgPicture.asset(
                              'images/user_unavailable.svg', height: 250.0,
                              width: 250.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                      imageUrl: imageUrl,
                      width: 250.0,
                      height: 250.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) =>
                        FullPhoto(url: imageUrl)));
                  },
                ),
              ) : Text(''),

            ],
          ),
        ),
       /* width: double.infinity,
        height: 300.0,
        decoration: new BoxDecoration(
            border: new Border(
                top: new BorderSide(color: greyColor2, width: 0.5)),
            color: Colors.white),*/
      ),
    );
  }


  Widget buildInput() {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          /*  // Button send image
            Center(
              child: Material(
                child: Container(
                  child: IconButton(
                    icon: new SvgPicture.asset(
                      'images/smile.svg', height: 30.0,
                      width: 30.0,
                    ),
                    onPressed: () {
                      getSticker();
                    },
                  ),
                ),
                color: Colors.white,
              ),
            ),
            Center(
              child: Material(
                child: new Container(
                  child: new IconButton(
                    icon: new SvgPicture.asset(
                      'images/camera.svg', height: 30.0,
                      width: 30.0,
                    ),
                    onPressed: getImage,
                    color: primaryColor,
                  ),
                ),
                color: Colors.white,
              ),
            ),*/
          Center(
            child: Material(
              child: new Container(
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
          ),
          Center(
            child: Material(
              child: new Container(
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
          ),
          /* Material(
                child: new Container(
                  child: new IconButton(
                    icon: new SvgPicture.asset(
                      'images/voice_highlight.svg', height: 100.0,
                      width: 100.0,
                    ),
                    onPressed: getImage,
                    color: primaryColor,
                  ),
                ),
                color: Colors.white,
              ),*/
          Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 100,
              height: 100,
              child: IconButton(
                color: button_fill_color,
                  icon: new SvgPicture.asset(
                    'images/Send.svg', height: 500.0,
                    width: 500.0,
                  ),
                  onPressed: () {
                    onSendMessage(_controller.text, imageUrl);
                  }
              ),
            ),
          ),
        ],
      ),
      width: double.infinity,
      height: 80.0,
      decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }


  Future getCamera() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.camera,imageQuality: 20);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery,imageQuality: 20);

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
//        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }


  Future onSendMessage(String content, String tweetPostUrl) async {
    // type: 0 = text, 1 = image, 2 = sticker
    if (tappedCategoryName.trim() != '') {
      if (content.trim() != '' || tweetPostUrl.trim() != '') {
        _controller.clear();

        var documentReference = Firestore.instance
            .collection('tweetPosts')
            .document();
/*

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId);
*/
      /*  Firestore.instance.runTransaction((transaction) async {
          await transaction.set(
            documentReference,
            {
              'idFrom': currentUserId,
              'timestamp': DateTime
                  .now()
                  .millisecondsSinceEpoch
                  .toString(),
              'content': content,
              'tweetPostImage': tweetPostUrl,
              'userPhoto': mCurrentPhotoUrl,
              'userName': currentUserName,
              'categoryName': tappedCategoryName,
              'categoryImage': tappedCategoryImage,
              'createdAt': DateFormat.yMd().add_jms().format(DateTime.now())
            },
          );
        });*/

        documentReference.setData({
          'idFrom': currentUserId,
          'timestamp': DateTime
              .now()
              .millisecondsSinceEpoch
              .toString(),
          'content': content,
          'tweetPostImage': tweetPostUrl,
          'userPhoto': mCurrentPhotoUrl,
          'userName': currentUserName,
          'categoryName': tappedCategoryName,
          'categoryImage': tappedCategoryImage,
          'createdAt': DateFormat.yMd().add_jms().format(DateTime.now())
        });
//      listScrollController.animateTo(
//          0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
       /* Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) =>
                MakeTweetPost(currentUserId, mCurrentPhotoUrl)));*/
       Navigator.pop(context);
        imageUrl ='';
        _controller.clear();
        sendMsg();
      } else {
        Fluttertoast.showToast(msg: 'Nothing to send');
      }
    } else {
      Fluttertoast.showToast(msg: select_category);
    }
  }

  Future sendMsg() async {
    String userToken = '';
    var query = await Firestore.instance.collection('users').getDocuments();
    query.documents.forEach((doc) {
      if (currentUserId != doc.data['id']) {
        userToken = doc.data['user_token'];
        print('user_token new post $userToken');
        sendAndRetrieveMessage(userToken);
      }
    });
  }


  final String serverToken =SERVER_KEY;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String _message = '';

  Future<Map<String, dynamic>> sendAndRetrieveMessage(String token) async {
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
            'body': 'New tweat from $currentUserName',
            'title': 'Tweat'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': token,
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