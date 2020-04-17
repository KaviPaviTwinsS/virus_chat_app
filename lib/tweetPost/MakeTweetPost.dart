import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/chat/fullPhoto.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/tweetPost/NewTweetPost.dart';
import 'package:virus_chat_app/utils/strings.dart';

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
                      color: facebook_color,
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
                            margin: EdgeInsets.only(top: 20.0, bottom: 40.0),
                            child: new IconButton(
                                icon: Icon(Icons.arrow_back_ios,
                                  color: white_color,),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ),
                          new Container(
                              margin: EdgeInsets.only(
                                  top: 20.0, right: 10.0, bottom: 40.0),
                              child: Text('My community', style: TextStyle(
                                  color: text_color,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),)
                          ),
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
                            topLeft: const Radius.circular(30.0),
                            topRight: const Radius.circular(30.0),
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
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            listMessage = snapshot.data.documents;
            return ListView.builder(
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
    return Container(
        padding: EdgeInsets.all(5.0),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  document['userPhoto'] != '' ? Container(
                    margin: EdgeInsets.only(bottom: 15.0),
                      child: Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) =>
                              Container(
                                margin: EdgeInsets.all(5.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      themeColor),
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
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            document['userName'] != '' ? Container(
                                margin: EdgeInsets.all(5.0),
                                child: Center(
                                  child: Text(
                                      capitalize(document['userName']),
                                      style: TextStyle(color: facebook_color)
                                  ),
                                )
                            ) : Text(''),
                            document['createdAt'] != '' ? Container(
                                child: Center(
                                  child: Text(
                                      document['createdAt'],
                                      style: TextStyle(color: greyColor)
                                  ),
                                )
                            ) : Text(''),
                          ],
                        ),
                        document['content'] != '' ? Container(
                            margin: EdgeInsets.all(5.0),
                            child: Text(
                                document['content'])
                        )
                            : Text(''),
                        document['tweetPostImage'] != '' ? Center(
                          child: Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      Center(
                                      child:Container(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<
                                              Color>(
                                              themeColor),
                                        ),
                                        width: 150.0,
                                        height: 200.0,
                                        decoration: BoxDecoration(
                                          color: greyColor2,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                        ),
                                      ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                        child: Image.asset(
                                          'images/img_not_available.jpeg',
                                          width: 150.0,
                                          height: 200.0,
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
                                borderRadius: BorderRadius.all(
                                    Radius.circular(5.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) =>
                                        FullPhoto(
                                            url: document['tweetPostImage'])));
                              },
                            ),
                          ),) : Text(''),
                      ],
                    ),
                  ),
                  Spacer(),
                  Align(
                    child: getIconWidget(document),
                  )
                ],
              ),
              Divider(color: greyColor,),
              //                           <-- Divider
            ],
          ),
        )
    );
  }


  Widget getIconWidget(DocumentSnapshot document) {
    String documentName = document['categoryName'];
    if (documentName == 'Help') {
      return IconButton(
          icon: new SvgPicture.asset(
            'images/tag_help.svg', height: 30.0,
            width: 30.0,
          ));
    } else if (documentName == 'Market Place') {
      return IconButton(
          icon: new SvgPicture.asset(
            'images/tag_market_place.svg', height: 30.0,
            width: 30.0,
          ));
    } else if (documentName == 'Alert') {
      return IconButton(
          icon: new SvgPicture.asset(
            'images/tag_alert.svg', height: 30.0,
            width: 30.0,
          ));
    } else if (documentName == 'Social') {
      return IconButton(
          icon: new SvgPicture.asset(
            'images/tag_social.svg', height: 30.0,
            width: 30.0,
          ));
    } else {
      return IconButton(
          icon: new SvgPicture.asset(
            'images/tag_market_place.svg', height: 30.0,
            width: 30.0,
          ));
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