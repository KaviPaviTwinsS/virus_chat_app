import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'package:intl/intl.dart';
import 'package:virus_chat_app/utils/constants.dart';


class FriendRequestScreen extends StatelessWidget {

  String _mcurrentUserId = '';
  String photoUrl = '';

  FriendRequestScreen(String currentUserId, String mphotoUrl) {
    _mcurrentUserId = currentUserId;
    photoUrl = mphotoUrl;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Page',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: FriendRequestScreenState(
          _mcurrentUserId, photoUrl
      ),
    );
  }

}

class FriendRequestScreenState extends StatefulWidget {

  String _mcurrentUserId = '';
  String photoUrl = '';

  FriendRequestScreenState(String currentUserId, String mphotoUrl) {
    _mcurrentUserId = currentUserId;
    photoUrl = mphotoUrl;
  }

  @override
  State<StatefulWidget> createState() {
    return FriendRequestScreenPage(_mcurrentUserId, photoUrl);
  }
}

class FriendRequestScreenPage extends State<FriendRequestScreenState> {

  String _mcurrentUserId;
  String photoUrl;

  SharedPreferences prefs;
  String userSignInType = '';

  FriendRequestScreenPage(String currentUserId, String mphotoUrl) {
    _mcurrentUserId = currentUserId;
    photoUrl = mphotoUrl;
  }

  @override
  void initState() {
    initialise();
    super.initState();
  }


  void initialise() async {
    prefs = await SharedPreferences.getInstance();
    userSignInType = await prefs.getString('signInType');
    print('Friend Request userSignInType____ $userSignInType');
  }

  @override
  Widget build(BuildContext context) {
    print('Friend Request Build__________ ');
    return Scaffold(
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
                          icon:new SvgPicture.asset(
                            'images/back_icon.svg',
                            width: 20.0,
                            height: 20.0,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            /*  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        new UsersList(
                                            userSignInType, _mcurrentUserId,
                                            photoUrl)));*/
                          }),
                    ),
                    new Container(
                        margin: EdgeInsets.only(
                            top: 40.0, right: 10.0, bottom: 10.0),
                        child: Text(friend_request, style: TextStyle(
                            color: black_color,
                            fontSize: TOOL_BAR_TITLE_SIZE,
                            fontWeight: FontWeight.w500,fontFamily: 'GoogleSansFamily'),)
                    ),
                  ],
                ),
                Divider(color: divider_color,thickness: 1.0,),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Container(
                    margin: EdgeInsets.only(top: 80.0),
                      child: friendlist(_mcurrentUserId)
                  )
              ),
            )
          ],
        )
    );
  }
/*

  Future getFriendsList() async {
    var query11 = await Firestore.instance.collection('users').document(
        _mcurrentUserId).collection('FriendsList').getDocuments();
    query11.documents.forEach((doc) {
      print('Friend Listttttt ${doc.data}');
      print('FRIEND REQUEST ${doc['isAcceptInvitation']}');
    });
  }*/

}

class friendlist extends StatelessWidget {

  String currentUserId = '';

  friendlist(String _mcurrentUserId) {
    currentUserId = _mcurrentUserId;
  }

  @override
  Widget build(BuildContext context) {
    print('Friend Request Build__________ Stream');

    return new StreamBuilder(
        stream: Firestore.instance.collection('users').document(
            currentUserId).collection('FriendsList').where(
            'isRequestSent', isEqualTo: false).where(
            'IsAcceptInvitation', isEqualTo: false).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null || !snapshot.hasData) {
            /* return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(progress_color)));*/
            return Center(
              child: Text(pending_request,style: TextStyle(fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400),),
            );
          } else {
            return (snapshot.data.documents.length == 0) ? Center(
              child: Text(pending_request,style: TextStyle(fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400),),
            ) : new ListView(
                scrollDirection: Axis.vertical,
                children: snapshot.data.documents.map((document) {
                  if (document.documentID != currentUserId) {
                    var date = new DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document['timestamp']));
                    var currDate =  ((new DateTime.now()
                        .toUtc()
                        .microsecondsSinceEpoch) / 1000).toInt();
                    var currTime =new DateTime.fromMillisecondsSinceEpoch(
                        currDate);
                    var differenceDays =currTime.difference(date).inDays;
                    var differenceHours =currTime.difference(date).inHours;
                    var differenceMins=currTime.difference(date).inMinutes;
                    var differenceSecs=currTime.difference(date).inSeconds;
                    String mDifference = '';
                    if( differenceDays == 0){
                      if(differenceHours == 0){
                        if(differenceMins == 0){
                          if(differenceSecs == 0){
                          }else{
                            mDifference = differenceSecs.toString() +'\tsecs';
                          }
                        }else{
                          mDifference = differenceMins.toString() +'\tmins';
                        }
                      }else{
                        mDifference = differenceHours.toString() +'\thours';
                      }
                    }else{
                      if(differenceDays == 1){
                        mDifference = differenceDays.toString() +'\tday';
                      }else if(differenceDays == 30){
                        differenceDays = 1;
                      }else{
                        mDifference = differenceDays.toString() +'\tdays';
                      }
                    }
                    return GestureDetector(
                        onTap: () {},
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment
                              .center,
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween,
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.only(top : 20.0,left: 10.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) =>
                                        Container(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor: AlwaysStoppedAnimation<
                                                Color>(
                                                progress_color),
                                          ),
                                          width: 70.0,
                                          height: 70.0,
                                          padding: EdgeInsets.all(20.0),
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
                                            height: 250.0,
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width - 30,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius
                                              .all(
                                            Radius.circular(5.0),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                    imageUrl: document['friendPhotoUrl'],
                                    width: 70.0,
                                    height: 70.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(45.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Container(
                                  margin: EdgeInsets.only(left : 13.0,top : 20.0),
                                  child: Text(
                                    capitalize(document['friendName']),
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w500),),
                                ),
                                new Container(
                                  margin: EdgeInsets.only(left : 13.0,top: 5.0),
                                  child:Text('Requested '+mDifference+'\tago',style: TextStyle(fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400,color: hint_color_grey_dark),),
                                )
                              ],
                            ),
                            Spacer(),
                            Container(
                              height: 40.0,
                              width: 40.0,
                              margin: EdgeInsets.only(top : 20.0,right: 10.0),
                              child: FloatingActionButton(
                                backgroundColor: white_color,
                                  child: new SvgPicture.asset(
                                      'images/friend_decline.svg'
                                  ),
                                  onPressed: () {
                                    Firestore.instance.collection(
                                        'users').document(
                                        document['requestFrom']).collection(
                                        'FriendsList')
                                        .document(document['receiveId'])
                                        .delete();
                                    Firestore.instance.collection(
                                        'users').document(
                                        document['receiveId'])
                                        .collection('FriendsList')
                                        .document(document['requestFrom'])
                                        .delete();
                                    Fluttertoast.showToast(
                                        msg: request_Reject);
                                  },
                              ),
                            ),
                            Container(
                                height: 40.0,
                                width: 40.0,
                                margin: EdgeInsets.only(top : 20.0,right: 10.0),
                                child: FloatingActionButton(
                                  backgroundColor: white_color,
                                  child: SvgPicture.asset(
                                      'images/friend_accept.svg',),
                                    onPressed: () {
                                      Firestore.instance.collection(
                                          'users').document(
                                          document['requestFrom']).collection(
                                          'FriendsList')
                                          .document(document['receiveId'])
                                          .updateData(
                                          {'IsAcceptInvitation': true});
                                      Firestore.instance.collection(
                                          'users').document(
                                          document['receiveId'])
                                          .collection('FriendsList')
                                          .document(
                                          document['requestFrom'])
                                          .updateData(
                                          {'IsAcceptInvitation': true});
                                      Fluttertoast.showToast(
                                          msg: request_Accept);
                                    },
                                )
                            )
                          ],
                        ));
                  } else {
                    return Center(
                      child: Text(pending_request),
                    );
                  }
                }).toList()
            );
          }
        }
    );
  }
}