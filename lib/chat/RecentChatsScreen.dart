import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/chat/chat.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';

class RecentChatsScreen extends StatefulWidget {
  String _userId = '';
  String _userPhoto = '';

  RecentChatsScreen(String currentUser, String currentUserPhotoUrl) {
    _userId = currentUser;
    _userPhoto = currentUserPhotoUrl;
  }

  @override
  State<StatefulWidget> createState() {
    return RecentChatsScreenState(_userId, _userPhoto);
  }

}

class RecentChatsScreenState extends State<RecentChatsScreen> {

  SharedPreferences prefs;

  String _userSignInType = '';
  String _muserId = '';
  String _muserPhoto = '';

  RecentChatsScreenState(String userId, String userPhoto) {
    _muserId = userId;
    _muserPhoto = userPhoto;
  }


  @override
  void initState() {
    super.initState();
    initialise();
  }

  Future initialise() async {
    prefs = await SharedPreferences.getInstance();
    _userSignInType = await prefs.getString('signInType');

    int currentTime = ((new DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch) / 1000).toInt();


    var query = await Firestore.instance.collection('users')
        .document(_muserId).collection(
        'userLocation').document(_muserId).get();
    print('Recent Chats ___ ${_muserId} ___ ${query['UpdateTime']}');

    if(_muserId != '') {
      if (currentTime > query['UpdateTime']) {
        Firestore.instance
            .collection('users')
            .document(_muserId)
            .updateData({'status': 'INACTIVE'});
      } else {
        Firestore.instance
            .collection('users')
            .document(_muserId)
            .updateData({'status': 'ACTIVE'});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Column(
                children: <Widget>[
                  Container(
                    color: facebook_color,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height - 520,
                    child:
                    Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          child: new IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                color: white_color,),
                              onPressed: () {
                                Navigator.pop(context);
//                                navigationPage();
                              }),
                        ),
                        new Container(
                            margin: EdgeInsets.only(
                                top: 20.0, right: 10.0, bottom: 20.0),
                            child: Text(recent_chats, style: TextStyle(
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
                height: 550,
                decoration: BoxDecoration(
                    color: text_color,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(30.0),
                      topRight: const Radius.circular(30.0),
                    )
                ),
                child: UsersRecentChats(_muserId),
              ),
            )
          ],
        )
    );
  }


  void navigationPage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
            new UsersList(_userSignInType, _muserId, _muserPhoto)));
  }
}

class UsersRecentChats extends StatelessWidget {

  String currentUserId = '';

  UsersRecentChats(String _mcurrentUserId) {
    currentUserId = _mcurrentUserId;
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null || !snapshot.hasData) {
            /* return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor)));*/
            return Center(
              child: Text('No Recent chats'),
            );
          } else {
            return (snapshot.data.documents.length == 0) ? Center(
              child: Text('No Recent chats'),
            ) : Stack(
              children: <Widget>[
                new ListView(
                    scrollDirection: Axis.vertical,
                    children: snapshot.data.documents.map((document) {
                      if (document.documentID != currentUserId) {
                        print('CHATS SCREEEN ___ ${document.documentID}');
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Chat(
                                              currentUserId: currentUserId,
                                              peerId: document.documentID,
                                              peerAvatar: document['photoUrl'],
                                              isFriend: true,
                                              isAlreadyRequestSent: true,
                                            peerName : document['name']
                                          )));
                            },
                            child: new Row(
                              crossAxisAlignment: CrossAxisAlignment
                                  .center,
                              mainAxisAlignment: MainAxisAlignment
                                  .start,
                              children: <Widget>[
                                new Stack(
                                  children: <Widget>[
                                    new Container(
                                      margin: EdgeInsets.all(15.0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Material(
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 1.0,
                                                    valueColor: AlwaysStoppedAnimation<
                                                        Color>(themeColor),
                                                  ),
                                                  width: 35.0,
                                                  height: 35.0,
                                                  padding: EdgeInsets.all(10.0),
                                                ),
                                            imageUrl: document['photoUrl'],
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
                                    ),
                                    document['status'] == 'ACTIVE' ? Container(
                                        child: new SvgPicture.asset(
                                          'images/online_active.svg', height: 10.0,
                                          width: 10.0,
//                                          color: primaryColor,
                                        ),
                                        margin: EdgeInsets.only(left: 45.0,
                                            bottom: 40.0,
                                            top: 15.0,
                                            right: 5.0)) : document['status'] == 'LoggedOut' ? Container(
                                      child: new SvgPicture.asset(
                                        'images/online_inactive.svg', height: 10.0,
                                        width: 10.0,
//                                        color: primaryColor,
                                      ),
                                      margin: EdgeInsets.only(left: 45.0,
                                          bottom: 40.0,
                                          top: 15.0,
                                          right: 5.0),
                                    ) :  Container(
                                      child: new SvgPicture.asset(
                                        'images/online_idle.svg', height: 10.0,
                                        width: 10.0,
//                                        color: primaryColor,
                                      ),
                                      margin: EdgeInsets.only(left: 45.0,
                                          bottom: 40.0,
                                          top: 15.0,
                                          right: 5.0),
                                    )
                                  ],
                                ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .center,
                                mainAxisAlignment: MainAxisAlignment
                                    .start,
                                children: <Widget>[
                                  new Container(
                                    child: Text(
                                      capitalize(document['name']),style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  new Container(
                                    child: Text(
                                      capitalize(document['name']),),
                                  ),
                                ],
                              )
                              ],
                            ));
                      } else {
                        return Center(
                            child: Text('')
                        );
                      }
                    }).toList()
                )
              ],
            );
          }
        }
    );
  }
}
