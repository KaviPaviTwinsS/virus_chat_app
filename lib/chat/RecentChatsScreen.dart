import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'file:///C:/Users/Nandhini%20S/Documents/virus_chat_app/lib/homePage/UsersList.dart';
import 'package:virus_chat_app/business/UsersData.dart';
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
  List<DocumentSnapshot> documents;
  final ScrollController listScrollController = new ScrollController();
  List<String> _mChatIds = new List<String>();
  List<UsersData> _mUsersData = new List<UsersData>();
  bool isLoading = false;

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
    _mChatIds.clear();
    _mUsersData.clear();
    print('Recent Chats ____________TEST INIT${_mChatIds
        .length} ________muserId $_muserId');
    isLoading = true;
    Firestore.instance
        .collection('users')
        .document(_muserId).get().then((DocumentSnapshot snapshot) {

          if(snapshot.data.length != 0) {
            if (snapshot.data['chattingWith'] != null) {
              List<String> _chatIds = List.from(snapshot.data['chattingWith']);

              List<UsersData> _usersData = new List<UsersData> ();
              if(_chatIds.length != 0) {
                for (int i = 0; i < _chatIds.length; i++) {
                  Firestore.instance
                      .collection('users')
                      .document(_chatIds[i]).get().then((
                      DocumentSnapshot snapshot) {
                        String groupChatId ='';
                    if (_muserId.hashCode <= snapshot.data['id'].hashCode) {
                      groupChatId = '$_muserId-${snapshot.data['id']}';
                    } else {
                      groupChatId = '${snapshot.data['id']}-$_muserId';
                    }
                    Firestore.instance
                        .collection('messages')
                        .document(groupChatId)
                        .collection(groupChatId)
                        .orderBy('timestamp', descending: true)
                        .limit(20)
                        .getDocuments().then((value){
                          List<DocumentSnapshot> mDocument = value.documents;
                      print('VALUE ______________________Last message ${mDocument[0].data['content']}');
                      setState(() {
                        isLoading = false;
                      });
                      _usersData.add(
                          UsersData(businessId: snapshot.data['businessId'],
                              businessName: snapshot.data['businessName'],
                              businessType: snapshot.data['businessType'],
                              createdAt: snapshot.data['createdAt'],
                              email: snapshot.data['email'],
                              id: snapshot.data['id'],
                              name: snapshot.data['name'],
                              nickName: snapshot.data['nickName'],
                              phoneNo: snapshot.data['phoneNo'],
                              photoUrl: snapshot.data['photoUrl'],
                              status: snapshot.data['status'],
                              userDistanceISWITHINRADIUS: snapshot
                                  .data['userDistanceISWITHINRADIUS'],
                              user_token: snapshot.data['user_token'],lastMessage: mDocument[0].data['content']));
                      if (i + 1 == _chatIds.length) {
                        print(
                            'Recent Chats ___________chatting_${i}VALUEEEEEEEEE _______');
                        setState(() {
                          this._mChatIds = _chatIds;
                          this._mUsersData = _usersData;
                        });
                      }
                    });

                  });
                }
              }else{
                setState(() {
                  isLoading =false;
                });
              }
            }else{
              setState(() {
                isLoading =false;
              });
            }
          }else{
            setState(() {
              isLoading =false;
            });
          }

      print('Recent Chats ___________chatting_${_mChatIds.length} _______');
    });
    prefs = await SharedPreferences.getInstance();
    _userSignInType = await prefs.getString('signInType');
    print('Recent Chats ___________TESTTTTTTTTTTTTTT_______');
  }


  @override
  Widget build(BuildContext context) {
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
                            child: Text(recent_chats, style: TextStyle(
                                color: black_color,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,fontFamily: 'GoogleSansFamily'),)
                        ),

                      ],
                  ),
                  Divider(color: divider_color,thickness: 1.0,),
                ]
            ),
            Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    margin: EdgeInsets.only(top: 80.0),
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: buildListMessage(),
                  ),
                ),
                Positioned(
                  child: isLoading
                      ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              progress_color)),
                    ),
                    color: Colors.white.withOpacity(0.8),
                  )
                      : Container(),
                ),
              ],
            )
          ],
        )
    );
  }

  Widget buildListMessage() {
    print('Recent chat buildListMessage ___CHAT $_mChatIds  ___len ${_mChatIds
        .length}');
    return Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height - 100,
        child:
        (_mChatIds != null && _mChatIds.length != 0) && (_mUsersData != null && _mUsersData.length != 0)? ListView.builder(
          itemBuilder: (context, index) =>
              buildRecentUsers(index, _mChatIds),
          itemCount: _mChatIds.length,
          controller: listScrollController,
        ) : Center(
          child: Text('No recent chats'),
        )
    );
  }

  void navigationPage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
            new UsersList( _muserId,_userSignInType, _muserPhoto)));
  }


  Future<DocumentSnapshot> getUserData(String mChatId) async {
    isLoading = true;
    _mDocumentSnapShot =
    await Firestore.instance.collection('users').document(mChatId)
        .get()
        .whenComplete(() {
      isLoading = false;
    });
    if (_mDocumentSnapShot != null) {
      print('Recent chat _mdocumentSnapshot ${_mDocumentSnapShot['id']}');
      this.name = _mDocumentSnapShot['name'];
      this.photoUrl = _mDocumentSnapShot['photoUrl'];
      this._userStatus = _mDocumentSnapShot['status'];
    }
    return _mDocumentSnapShot;
  }

  DocumentSnapshot _mDocumentSnapShot;
  String name = '';
  String photoUrl = '';
  String _userStatus = '';

  Widget buildRecentUsers(int index, List<String> _mChatList) {
    print('buildRecentUsers_____________${_mUsersData.length } __________${(_mChatList[index])}');
    if (_mChatList.length == 0) {
      return Center(
          child: Text(no_Recent_chat));
    } else if (_mChatList.length > 0 && _mUsersData.length != 0) {
        print('Recent chat _mChatList ${_mChatList[index]}');
        UsersData usersData = _mUsersData[index];
        return usersData != null ? GestureDetector(
            onTap: () {
              print(
                  'Recent chat onTAP _________$_muserId _____peer ${usersData
                      .id}');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Chat(
                            currentUserId: _muserId,
                            peerId: usersData.id,
                            peerAvatar: usersData.photoUrl,
                            isFriend: true,
                            isAlreadyRequestSent: true,
                            peerName: usersData.name,
                          )));
            },
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              margin: EdgeInsets.all(5.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment
                    .center,
                mainAxisAlignment: MainAxisAlignment
                    .start,
                children: <Widget>[
                  new Stack(
                    children: <Widget>[
                      usersData != null &&
                          usersData.photoUrl != null ? new Container(
                        margin: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                30.0),border: Border.all(color: profile_image_border_color)
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
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
                              imageUrl: usersData.photoUrl,
                              width: 50.0,
                              height: 50.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(30.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                        ),
                      ) : new Container(
                          margin: EdgeInsets.all(15.0),
                          width: 50.0,
                          height: 50.0,
                          child: new SvgPicture.asset(
                            'images/user_unavailable.svg',
                            width: 35.0,
                            height: 35.0,
                          ),
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: profile_image_border_color),
                          )),
                      usersData != null &&
                          usersData.status == 'ACTIVE' ? Container(
                          child: new SvgPicture.asset(
                            'images/online_active.svg', height: 15.0,
                            width: 15.0,
                          ),
                          margin: EdgeInsets.only(left: 45.0,
                              bottom: 40.0,
                              top: 12.0,
                              right: 5.0)) : usersData != null &&
                          usersData.status == 'LoggedOut'
                          ? Container(
                        child: new SvgPicture.asset(
                          'images/online_inactive.svg', height: 15.0,
                          width: 15.0,
                        ),
                        margin: EdgeInsets.only(left: 45.0,
                            bottom: 40.0,
                            top: 12.0,
                            right: 5.0),
                      )
                          : Container(
                        child: new SvgPicture.asset(
                          'images/online_idle.svg', height: 15.0,
                          width: 15.0,
                        ),
                        margin: EdgeInsets.only(left: 45.0,
                            bottom: 40.0,
                            top: 12.0,
                            right: 5.0),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start,
                    mainAxisAlignment: MainAxisAlignment
                        .start,
                    children: <Widget>[
                      usersData != null && usersData.name != '' ? new Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: Text(
                          capitalize(usersData.name),
                          style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'GoogleSansFamily',color: hint_color_grey_dark),),
                      ) : Text(''),
                      usersData != null && usersData.lastMessage != '' ? new Container(
                        width: MediaQuery.of(context).size.width - 120,
                        margin: EdgeInsets.only(top: 5.0,right: 5.0),
                        child: Text(
                          usersData.lastMessage,
                          overflow: TextOverflow.ellipsis,
                          style:  TextStyle(fontWeight: FontWeight.w500,fontFamily: 'GoogleSansFamily',color: hint_color_grey_light,fontSize: 12.0,),),
                      ) : Text(''),
                    ],
                  )
                ],
              ),
            )
        ) : Center(child: Text(no_Recent_chat),);
    }
  }
}