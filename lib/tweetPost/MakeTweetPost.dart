import 'dart:io';
import 'dart:io' as Io;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart'
    show getExternalStorageDirectory, getTemporaryDirectory;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/chat/fullPhoto.dart';
import 'package:virus_chat_app/tweetPost/NewTweetPost.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'package:virus_chat_app/utils/constants.dart';

class MakeTweetPost extends StatefulWidget {
  String _mCurrentId = '';
  String _mCurrentPhotoUrl = '';

  MakeTweetPost(String mCurrentId, String mCurrentPhotoUrl) {
    _mCurrentId = mCurrentId;
    _mCurrentPhotoUrl = mCurrentPhotoUrl;
  }

  @override
  State<StatefulWidget> createState() {
    return MakeTweetPostState(_mCurrentId, _mCurrentPhotoUrl);
  }

}

class MakeTweetPostState extends State<MakeTweetPost> {
  SharedPreferences preferences;
  String mCurrentId = '';
  String signInType = '';
  String mPhotoUrl = '';
  final ScrollController listScrollController = new ScrollController();

  var listMessage;

  MakeTweetPostState(String _mCurrentId, String _mCurrentPhotoUrl) {
    mCurrentId = _mCurrentId;
    mPhotoUrl = _mCurrentPhotoUrl;
  }


  @override
  void initState() {
    super.initState();
    isSignin();
  }

  void isSignin() async {
    preferences = await SharedPreferences.getInstance();
//    mCurrentId = await preferences.getString('userId');
    signInType = await preferences.getString('signInType');
//    mPhotoUrl = await preferences.getString('photoUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
//        appBar: AppBar(
//          title: Text(community),
        /* actions: <Widget>[
            IconButton(
              icon: new SvgPicture.asset(
                'images/community.svg', height: 50.0,
                width: 50.0,
                color: text_color,
              ),
              onPressed: () {

              },
            )
          ],*/
//        ),
        body: WillPopScope(
          child: Stack(
            children: <Widget>[
              Column(
                  children: <Widget>[
                    Container(
                      color: button_fill_color,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: 130,
                      child:
                      Row(
                        crossAxisAlignment: CrossAxisAlignment
                            .center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 40.0, bottom: 40.0),
                            child: new IconButton(
                                icon: Icon(Icons.arrow_back_ios,
                                  color: white_color,),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ),
                          new Container(
                              margin: EdgeInsets.only(
                                  top: 40.0,bottom: 40.0),
                              child: Text('My Community', style: TextStyle(
                                  color: text_color,
                                  fontSize: TOOL_BAR_TITLE_SIZE,
                                  fontWeight: FontWeight.w700,fontFamily: 'GoogleSansFamily'),)
                          ),

                          Spacer(),
                          Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 45.0, right: 20.0, bottom: 5.0),
                                child: IconButton(
                                  icon: new SvgPicture.asset(
                                    'images/community.svg',
                                    height: 20.0,
                                    width: 20.0,
                                    color: white_color,
                                  ),
                                  onPressed: () {
                                  },
                                ),
                              )
                          )
                        ],
                      ),
                    ),
                  ]
              ),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height - 105,
                      decoration: BoxDecoration(
                          color: text_color,
                          borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(20.0),
                            topRight: const Radius.circular(20.0),
                          )
                      ),
                      child: Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              // List of messages
                              buildListMessage(),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: 100,
                              height: 100,
                              child: IconButton(
                                icon: new SvgPicture.asset(
                                  'images/post_icon.svg', height: 500.0,
                                  width: 500.0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NewTweetPost(
                                                  mCurrentId, mPhotoUrl)));
                                },
                              ),
                            ),
                          )
                        ],
                      )
                  )
              )
            ],
          ),
        )
    );
  }

  Widget buildListMessage() {
    print('mCurrentId BuildMEsss $mCurrentId');
    return Flexible(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('tweetPosts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(progress_color)));
          } else {
            listMessage = snapshot.data.documents;
            return  (listMessage.length == 0) ?   Center(
              child: Text(no_tweet),
            ) :ListView.builder(
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) =>
                  buildItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
//              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    var url =document['userName'] + index.toString();
    if(document['tweetPostImage'] != '')
    storeFile(document['tweetPostImage'],url);
    return Container(
        padding: EdgeInsets.all(5.0),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Stack(
                children: <Widget>[
                  document['userPhoto'] != '' ? Container(
                      margin: EdgeInsets.only(left : 10.0,bottom: document['tweetPostImage'] != '' ? 210.0 : 100.0),
                      child: Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) =>
                              Container(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      progress_color),
                                ),
                                width: 35.0,
                                height: 35.0,
                              ),
                          imageUrl: document['userPhoto'],
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(45.0)),
                        clipBehavior: Clip.hardEdge,
                      )
                  )
                      : Text(''),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[document['userName'] != '' ? Container(
                              margin: EdgeInsets.only(left: 60.0,bottom: 5.0),
                              child: Text(
                                  capitalize(document['userName']),
                                  style: TextStyle(color: button_fill_color,fontWeight: FontWeight.w700,fontFamily: 'GoogleSansFamily')
                              )
                          ) : Text(''),
                            document['createdAt'] != '' ? Container(
                                margin: EdgeInsets.only(left : 10.0,right: 5.0),
                                child: Text(
                                    document['createdAt'],
                                    style: TextStyle(color: greyColor,fontSize: 10.0,fontFamily: 'GoogleSansFamily')
                                )
                            ) : Text(''),
                            Spacer(),
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: EdgeInsets.only(right: 10.0,bottom: 5.0),
                                child: getIconWidget(document),
                              ),
                            )
                          ],
                        ),
                      ),
                      document['content'] != '' ? Container(
                          margin: EdgeInsets.only(left: 60.0,bottom: 15.0),
                          width: MediaQuery.of(context).size.width - 100,
                          child: Text(
                              document['content'],style: TextStyle(fontFamily: 'GoogleSansFamily'),)
                      )
                          : Text(''),
                      document['tweetPostImage'] != '' ? Container(
                        margin: EdgeInsets.only(left: 45.0,bottom: 15.0),
                        child: FlatButton(
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) =>
                                  Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          progress_color),
                                    ),
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      color: greyColor2,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                    ),
                                  ),
                              errorWidget: (context, url, error) =>
                                  Material(
                                    child: /*Image.asset(
                                      'images/img_not_available.jpeg',
                                      width: 150.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),*/
                                    new SvgPicture.asset(
                                      'images/user_unavailable.svg', height: 250.0,
                                      width: 150.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                              imageUrl: document['tweetPostImage'],
                              width: 150.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: () {
                            isExistFile(document,index);
                          },
                      ),) : Text(''),

                    ],
                  )

                ],
              ),
              Divider(),


            ],
          ),
        )
    );

  }

  Future isExistFile(DocumentSnapshot document,int index) async{
    var uriName = document['userName']+index.toString();
    Directory tempDir = await getExternalStorageDirectory();
    String uri = '${tempDir.path}/${uriName}' + '.jpeg';
    bool isFileExist = await File(uri).exists();
    print('MAKEEEEEEEEEEEE TWEET $uri _____ $isFileExist');
//    if (isFileExist) {
//      Navigator.push(
//          context, MaterialPageRoute(builder: (context) =>
//          FullPhoto(url: uri)));
//    }else{
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>
          FullPhoto(url: document['tweetPostImage'])));
//    }
  }

  Future storeFile(String imageUrl, String fileName) async {
    Directory tempDir = await getExternalStorageDirectory();
    String uri = '${tempDir.path}/${fileName}' + '.jpeg';
    print('uriuriuriuriuriuriuriuriuriuriuriuriuriuriuriuriuriuriuriuri __$uri');
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

  Widget getIconWidget(DocumentSnapshot document) {
    String documentName = document['categoryName'];
    if (documentName == 'Help') {
      return new SvgPicture.asset(
        'images/tag_help.svg', height: 30.0,
        width: 30.0,
      );
    } else if (documentName == 'Market Place') {
      return new SvgPicture.asset(
        'images/tag_market_place.svg', height: 30.0,
        width: 30.0,
      );
    } else if (documentName == 'Alert') {
      return  new SvgPicture.asset(
        'images/tag_alert.svg', height: 30.0,
        width: 30.0,
      );
    } else if (documentName == 'Social') {
      return  new SvgPicture.asset(
        'images/tag_social.svg', height: 30.0,
        width: 30.0,
      );
    } else {
      return new SvgPicture.asset(
        'images/tag_market_place.svg', height: 30.0,
        width: 30.0,
      );
    }
  }


  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage != null &&
        listMessage[index - 1]['idFrom'] != mCurrentId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

}