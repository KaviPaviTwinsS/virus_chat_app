import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/business/UsersData.dart';
import 'package:virus_chat_app/business/BusinessChat.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/constants.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'package:virus_chat_app/business/BusinessRecentChatData.dart';

class BusinessRecentChats extends StatefulWidget {
  String _userId = '';
  String _userPhoto = '';
  String _clickedBusinessId = '';

  BusinessRecentChats(String currentUser, String currentUserPhotoUrl,
      String clickedBusinessId) {
    _userId = currentUser;
    _userPhoto = currentUserPhotoUrl;
    _clickedBusinessId = clickedBusinessId;
  }

  @override
  State<StatefulWidget> createState() {
    return BusinessRecentChatsState(_userId, _userPhoto, _clickedBusinessId);
  }

}

class BusinessRecentChatsState extends State<BusinessRecentChats> {
  SharedPreferences prefs;
  String _userSignInType = '';
  String _muserId = '';
  String _muserPhoto = '';
  List<DocumentSnapshot> documents;
  final ScrollController listScrollController = new ScrollController();
  List<String> _mChatIds = new List<String>();
  List<UsersData> _mUsersData = new List<UsersData>();
  bool isLoading = false;


  List<BusinessRecentChatData> _myEmployeeChats = new List<
      BusinessRecentChatData>();
  List<String> _myEmployeeId = new List<String>();
  List<String> _myUserId = new List<String>();


  String _currentUserBusinessType = '';
  String _currentUserBusinessId = '';

  String _clickedBusinessId = '';


  //to avoid duplication of same employee and userid
  String _mEmployeeId = '';
  String _mUserId = '';
  String _mStoreId = '';

  BusinessRecentChatsState(String userId, String userPhoto,
      String clickedBusinessId) {
    _muserId = userId;
    _muserPhoto = userPhoto;
    _clickedBusinessId = clickedBusinessId;
  }

  @override
  void initState() {
    super.initState();
    initialise();
  }

  Future initialise() async {
    _mChatIds.clear();
    _mUsersData.clear();
    isLoading = true;


    prefs = await SharedPreferences.getInstance();
    _userSignInType = await prefs.getString('signInType');
    _currentUserBusinessType = await prefs.getString('BUSINESS_TYPE');
    _currentUserBusinessId = await prefs.getString('BUSINESS_ID');


    if (_currentUserBusinessType == BUSINESS_TYPE_OWNER) {
      QuerySnapshot result = await Firestore.instance
          .collection('chatRooms')
          .where('storeId', isEqualTo: _clickedBusinessId)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      print('Business owner ${documents.length} ____clickedBusinessId $_clickedBusinessId');
      if (documents.length != 0) {
        setState(() {
          isLoading = false;
        });
        _mChatIds = new List<String>();
        List<BusinessRecentChatData> _newEmployeeChats = new List<
            BusinessRecentChatData>();
        HashMap map1 = new HashMap<String, BusinessRecentChatData>();
        for (var number in result.documents) {
          var index = result.documents.indexOf(number);
          var reference = result.documents
              .elementAt(index)
              .data;

          map1[reference['employeeId']+reference['userId']] = BusinessRecentChatData(
              createDate: reference['createDate'],
              employeeId: reference['employeeId'],
              isCreated: reference['isCreated'],
              storeId: reference['storeId'],
              userId: reference['userId'],
              userName: reference['userName'],
              employeeName: reference['employeeName'],
          employeePhotoUrl: reference['employeePhotoUrl'],
          employeeStatus: reference['employeeStatus']);
        }

        map1.forEach((key, value) {
          _newEmployeeChats.add(value);
        });
        setState(() {
          this._myEmployeeChats = _newEmployeeChats;
        });

     /*   if (_myEmployeeChats.length != 0) {
          List<UsersData> _usersData = new List<UsersData> ();
          if (_myEmployeeChats.length != 0) {
            for (int i = 0; i < _myEmployeeChats.length; i++) {
              Firestore.instance
                  .collection('users')
                  .document(_myEmployeeChats[i].userId).get().then((
                  DocumentSnapshot snapshot) {
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
                        user_token: snapshot.data['user_token']));
                setState(() {
                  this._mChatIds = _mChatIds;
                  this._mUsersData = _usersData;
                });
                *//*  if (i + 1 == _chatIds.length) {
                    print(
                        'Recent Chats ___________chatting_${i}VALUEEEEEEEEE _______');
                    setState(() {
                      this._mChatIds = _chatIds;
                      this._mUsersData = _usersData;
                    });
                  }*//*
              });
            }
          } else {
            setState(() {
              isLoading = false;
            });
          }
          print('owner recent chat ${documents.length}');
        }*/
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: 'Chat Room empty');
      }
    } else if (_currentUserBusinessType == BUSINESS_TYPE_EMPLOYEE) {
      QuerySnapshot result = await Firestore.instance
          .collection('chatRooms')
          .where('storeId', isEqualTo: _currentUserBusinessId)
          .where('employeeId', isEqualTo: _muserId)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;

      if (documents.length != 0) {
        setState(() {
          isLoading = false;
        });
        List<BusinessRecentChatData> _newEmployeeChats = new List<
            BusinessRecentChatData>();
        HashMap map1 = new HashMap<String, BusinessRecentChatData>();
        for (var number in result.documents) {
          var index = result.documents.indexOf(number);
          var reference = result.documents
              .elementAt(index)
              .data;
          map1[reference['employeeId']+reference['userId']] = BusinessRecentChatData(
              createDate: reference['createDate'],
              employeeId: reference['employeeId'],
              isCreated: reference['isCreated'],
              storeId: reference['storeId'],
              userId: reference['userId'],
              userName: reference['userName'],
              employeeName: reference['employeeName'],
              employeePhotoUrl: reference['employeePhotoUrl'],
              employeeStatus: reference['employeeStatus']);
        }

        map1.forEach((key, value) {
          _newEmployeeChats.add(value);
        });
        setState(() {
          this._myEmployeeChats = _newEmployeeChats;
        });

        /*   List<UsersData> _usersData = new List<UsersData> ();
        if (_mChatIds.length != 0) {
          for (int i = 0; i < _mChatIds.length; i++) {
            Firestore.instance
                .collection('users')
                .document(_mChatIds[i]).get().then((DocumentSnapshot snapshot) {
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
                      user_token: snapshot.data['user_token']));
              setState(() {
                isLoading = false;
              });
              setState(() {
                this._mChatIds = _mChatIds;
                this._mUsersData = _usersData;
              });
              *//*   if (i + 1 == _chatIds.length) {
                print(
                    'Recent Chats ___________chatting_${i}VALUEEEEEEEEE _______');
                setState(() {
                  this._mChatIds = _chatIds;
                  this._mUsersData = _usersData;
                });
              }*//*
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }*/
        print('owner recent chat employee${documents.length}');
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: 'Chat Room empty');
      }
    } else {

    }
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
                              fontWeight: FontWeight.w500,
                              fontFamily: 'GoogleSansFamily'),)
                      ),

                    ],
                  ),
                  Divider(color: divider_color, thickness: 1.0,),
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
        (_myEmployeeChats != null && _myEmployeeChats.length != 0) ?
        ListView.builder(
          itemBuilder: (context, index) =>
              buildRecentUsers(index, _myEmployeeChats),
          itemCount: _myEmployeeChats.length,
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
            new UsersList(_userSignInType, _muserId, _muserPhoto)));
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

  Widget buildRecentUsers(int index, List<BusinessRecentChatData> myEmployeeChats) {
    print('buildRecentUsers_____________${myEmployeeChats
        .length } __________${(myEmployeeChats[index])}');
    if (myEmployeeChats.length == 0) {
      return Center(
          child: Text(no_Recent_chat));
    } else if (myEmployeeChats.length > 0 && myEmployeeChats.length != 0) {
      print('Recent chat _mChatList ${myEmployeeChats[index]}');
      BusinessRecentChatData usersData = myEmployeeChats[index];
      return usersData != null ? GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BusinessChat(
                          currentUserId: usersData.userId,
                          peerId: usersData.employeeId,
                          peerAvatar: usersData.employeePhotoUrl,
                          isFriend: true,
                          isAlreadyRequestSent: true,
                          peerName: usersData.employeeName,
                          businessId: _clickedBusinessId
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
                    usersData!= null && usersData.employeePhotoUrl != null ? new Container(
                      margin: EdgeInsets.all(10.0),
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
                            imageUrl: usersData.employeePhotoUrl,
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
                        )),
                    usersData != null &&
                        usersData == 'ACTIVE' ? Container(
                        child: new SvgPicture.asset(
                          'images/online_active.svg', height: 15.0,
                          width: 15.0,
                        ),
                        margin: EdgeInsets.only(left: 50.0,
                            bottom: 40.0,
                            top: 15.0,
                            right: 15.0)) : usersData != null &&
                        usersData.employeeStatus == 'LoggedOut'
                        ? Container(
                      child: new SvgPicture.asset(
                        'images/online_inactive.svg', height: 15.0,
                        width: 15.0,
                      ),
                      margin: EdgeInsets.only(left: 50.0,
                          bottom: 40.0,
                          top: 15.0,
                          right: 15.0),
                    )
                        : Container(
                      child: new SvgPicture.asset(
                        'images/online_idle.svg', height: 15.0,
                        width: 15.0,
                      ),
                      margin: EdgeInsets.only(left: 50.0,
                          bottom: 40.0,
                          top: 15.0,
                          right: 15.0),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .start,
                  mainAxisAlignment: MainAxisAlignment
                      .start,
                  children: <Widget>[
                    usersData != null && usersData.employeeName != '' ? new Container(
                      margin: EdgeInsets.only(top: 5.0),
                      child: Text(
                        capitalize(usersData.employeeName),
                        style: TextStyle(fontWeight: FontWeight.w500,
                            fontFamily: 'GoogleSansFamily',
                            color: hint_color_grey_dark),),
                    ) : Text(''),
                    usersData != null && usersData.userName != '' ? new Container(
                      margin: EdgeInsets.only(top: 5.0),
                      child: Text(
                        'Chatted with'+'\t'+capitalize(usersData.userName),
                        style: TextStyle(fontWeight: FontWeight.w500,
                            fontFamily: 'GoogleSansFamily',
                            color: hint_color_grey_light),),
                    ) : Text(''),
                    /* usersData != null && usersData.name != '' ? new Container(
                        child: Text(
                          capitalize(usersData.name),),
                      ) : Text(''),*/
                  ],
                )
              ],
            ),
          )
      ) : Center(child: Text(no_Recent_chat),);
    }
  }
}