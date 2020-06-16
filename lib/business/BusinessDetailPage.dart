import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/business/BusinessChatData.dart';
import 'package:virus_chat_app/business/BusinessChat.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:virus_chat_app/utils/constants.dart';
import 'package:virus_chat_app/business/BusinessRecentChats.dart';


class BusinessDetailPage extends StatefulWidget {

  String _businessId = '';
  String _businessName = '';

  BusinessDetailPage(String mBusinessId, String mBusinessName) {
    _businessId = mBusinessId;
    _businessName = mBusinessName;
  }

  @override
  State<StatefulWidget> createState() {
    return BusinessDetailPageState(_businessId, _businessName);
  }

}

class BusinessDetailPageState extends State<BusinessDetailPage> {
  String _businessId = '';
  String _businessName = '';
  String _businessImage = '';
  String _businessAddress = '';
  String _businessOwnerName = '';
  String _businessNumber = '';
  String _businessDescription = '';

  String _currentUserBusinessType = '';
  String _currentUserBusinessId = '';
  SharedPreferences preferences;

  String _currentUserId = '';
  String _currentUserName ='';
  List<DocumentSnapshot> documents = new List<DocumentSnapshot>();

  bool isLoading = false;

  bool isCurrentUserCanChat = false;
  String currentUserPhoto ='';

  BusinessDetailPageState(String businessId, String businessName) {
    _businessId = businessId;
    _businessName = businessName;
  }

  @override
  void initState() {
    initialise();
    super.initState();
  }

  Future onSelectNotification(String payload) async {
    print('BUsiness detail nottify $_businessChatData ____ $notifyId');
    if(notifyId == '1000'/* && !isOpened*/) {
      print('________1000');
//      isOpened = true;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BusinessChat(
                    currentUserId: businessId,
                    peerId: userId,
                    peerAvatar: photoUrl,
                    isFriend: true,
                    isAlreadyRequestSent: true,
                    peerName: name,
                    chatType: CHAT_TYPE_BUSINESS,
                  )));
    }
  }

  void initialise() async {
    preferences = await SharedPreferences.getInstance();
    _currentUserId = await preferences.getString('userId');
    _currentUserName =await preferences.getString('name');
    _currentUserBusinessType = await preferences.getString('BUSINESS_TYPE');
    _currentUserBusinessId = await preferences.getString('BUSINESS_ID');
    currentUserPhoto = await preferences.getString('photoUrl');
    if(_currentUserBusinessId != ''){
      if(_currentUserBusinessId == _businessId) {
        isCurrentUserCanChat = false;
      }else{
        isCurrentUserCanChat = true;
      }
    }else{
      isCurrentUserCanChat = true;
    }
    setState(() {
      isLoading = true;
    });
    Firestore.instance
        .collection('business')
        .document(_businessId).get().then((DocumentSnapshot documentReference) {
      if (documentReference.documentID.isNotEmpty) {
        print('Business detail___________ ${documentReference
            .documentID} _______${documentReference
            .data['photoUrl']} __________$_businessId');
        _businessAddress = documentReference.data['businessAddress'];
        _businessOwnerName = documentReference.data['ownerName'];
        _businessNumber = documentReference.data['businessNumber'];
        _businessImage = documentReference.data['photoUrl'];
        _businessName = documentReference.data['businessName'];
        _businessDescription = documentReference.data['businessDescription'];
        print('BUSINESS IMAGE ___${_businessImage != null &&
            _businessImage != ''}');
      } else {}
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('BUSINESS IMAGE ___build${_businessImage != null &&
        _businessImage != ''}');
    return Scaffold(
        body: Scaffold(
          body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            left: 0.0, bottom: 10.0, top: 40.0),
                        child: new IconButton(
                            icon: new SvgPicture.asset(
                              'images/back_icon.svg',
                              width: 20.0,
                              height: 20.0,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
//                                  navigationPage();
                            }),
                      ),

                   /*   new Container(
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
                            errorWidget: (context, url,
                                error) =>
                                Material(
                                  child: *//* Image.asset(
                                                      'images/img_not_available.jpeg',
                                                      width: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width - 30,
                                                      height: 200.0,
                                                      fit: BoxFit.cover,
                                                    ),*//*
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
                            imageUrl: _businessImage,
                            width: 35.0,
                            height: 35.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(18.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                      ),*/
                      new Container(
                          margin: EdgeInsets.only(
                              left: 0.0, bottom: 10.0, top: 40.0),
                          child: Text(
                            capitalize(_businessName), style: TextStyle(
                              color: black_color,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500),)
                      ),
                      Spacer(),
                      (_currentUserBusinessType == BUSINESS_TYPE_EMPLOYEE  || _currentUserBusinessType == BUSINESS_TYPE_OWNER)&& _businessId == _currentUserBusinessId? Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: EdgeInsets.only(
                                top: 40.0, right: 10.0, bottom: 5.0,left: 10.0),
                            child: IconButton(
                              icon: new SvgPicture.asset(
                                'images/business_conversation.svg',
                                height: 20.0,
                                width: 20.0,
                                color: black_color,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BusinessRecentChats(_currentUserId,_businessImage,_businessId,currentUserPhoto)));
                              },
                            ),
                          )
                      ) : Container()
                    ],
                  ),
                  Divider(color: divider_color, thickness: 1.0,),

                ],
              ),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Stack(
                    children: <Widget>[

                      Stack(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              (_businessImage != null &&
                                  _businessImage != '') ? Center(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        bottom: 15.0,
                                        top: 140.0,
                                        left: 15.0,
                                        right: 15.0),
                                    child: Material(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<
                                                    Color>(
                                                    progress_color),
                                              ),
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: greyColor2,
                                                borderRadius: BorderRadius
                                                    .all(
                                                  Radius.circular(5.0),
                                                ),
                                              ),
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
                                                height: 200.0,
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
                                        imageUrl: _businessImage,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width - 30,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                  )
                              ) : Text(''),
                              _businessName != null && _businessName != ''
                                  ? Container(
                                margin: EdgeInsets.only(
                                    left: 15.0, bottom: 10.0),
                                child: Text(capitalize(_businessName),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'GoogleSansFamily',
                                      color: black_color,
                                      fontSize: 20.0),),
                              )
                                  : Text(''),
                              _businessAddress != null &&
                                  _businessAddress != '' ? Container(
                                margin: EdgeInsets.only(
                                    left: 15.0, bottom: 20.0),
                                child: Text(_businessAddress, style: TextStyle(
                                    fontFamily: 'GoogleSansFamily',
                                    fontWeight: FontWeight.w400,
                                    color: hint_color_grey_dark),),
                              ) : Text(''),
                              _businessDescription != null &&
                                  _businessDescription != '' ? Container(
                                margin: EdgeInsets.only(
                                    left: 15.0, bottom: 20.0, right: 15.0),
                                child: Text(_businessDescription,
                                  style: TextStyle(
                                      fontFamily: 'GoogleSansFamily',
                                      fontWeight: FontWeight.w400,
                                      color: hint_color_grey_dark),),
                              ) : Text(''),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: <Widget>[
                                  _businessOwnerName != null &&
                                      _businessOwnerName != '' ?
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 15.0, bottom: 15.0),
                                        child:
                                        new SvgPicture.asset(
                                          'images/user.svg', height: 20.0,
                                          width: 20.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 5.0, bottom: 15.0),
                                        child: Text(
                                          capitalize(_businessOwnerName),
                                          style: TextStyle(
                                              fontFamily: 'GoogleSansFamily',
                                              fontWeight: FontWeight.w400,
                                              color: hint_color_grey_dark),),
                                      )
                                    ],
                                  ) : Text(''),
                                  _businessNumber != null &&
                                      _businessNumber != '' ?
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 15.0, bottom: 15.0),
                                        child:
                                        new SvgPicture.asset(
                                          'images/phone_outline.svg',
                                          height: 20.0,
                                          width: 20.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            right: 15.0,
                                            bottom: 15.0,
                                            left: 5.0),
                                        child: Text(
                                          capitalize(_businessNumber),
                                          style: TextStyle(
                                              fontFamily: 'GoogleSansFamily',
                                              fontWeight: FontWeight.w400,
                                              color: hint_color_grey_dark),),
                                      )
                                    ],
                                  ) : Text('')
                                ],
                              )
                            ],
                          ),
                          isCurrentUserCanChat ?  Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: 100,
                              height: 100,
                              child: IconButton(
                                icon: new SvgPicture.asset(
                                  'images/business_chat.svg',
                                  height: 500.0,
                                  width: 500.0,
                                ),
                                onPressed: () {
                                  StartBusinessChat();
                                },
                              ),
                            ),
                          ) : Container()
                        ],
                      ),
                    ],
                  )
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
                  ) : Container()
              ),
            ],
          ),
        )
    );
  }


  Future getBusinessUsers() async {
    print('Business Detail document list  _businessId__ $_businessId');

    try {
      setState(() {
        isLoading = true;
      });
      QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('businessId', isEqualTo: _businessId)
//          .where('businessType', isEqualTo: 'employee')
          .where('status', isEqualTo: 'ACTIVE')
          .getDocuments().then((result) {
        print('Business Detail document list ${result.documents.length}');
        var _mCheck = false;
        var isChatOpened = false;

        List<BusinessChatData> mChatList = List<BusinessChatData>();
        for (var number in result.documents) {
          var index = result.documents.indexOf(number);
          var reference = result.documents
              .elementAt(index)
              .data;
          var _businessChatPeriority = 0;
          if (reference.containsKey('businessChatPeriority')) {
            _businessChatPeriority = reference['businessChatPeriority'];
          } else {
            _businessChatPeriority = 0;
          }
          print(
              'Origin forEach loop  ${reference['businessChatPeriority']} ___$_businessChatPeriority');
          mChatList.add(BusinessChatData(businessId: reference['businessId'],
              businessChatPriority: reference['businessChatPeriority'],
              userId: reference['id'],
              name: reference['name'],
              photoUrl: reference['photoUrl'],
              userToken: reference['user_token'],
              businessName: reference['businessName'],
              businessChatWith: reference['businessChatWith']));
        }

        var mIsChatPriorityOne = false; // 0
        var mIsChatPriorityTwo = false; //1
        var mIsChatPriorityThree = false; //2
        var mIsChatPriorityFour = false; //3

        var mIsChatOneListData = BusinessChatData();
        var mIsChatTwoListData = BusinessChatData();
        var mIsChatThreeListData = BusinessChatData();
        var mIsChatFourListData = BusinessChatData();

        for (var mValue in mChatList) {
          var index = mChatList.indexOf(mValue);
          var myCurrentChatPriority = mChatList
              .elementAt(index)
              .businessChatPriority;
          print(
              '______________________INDEX________$index __________myCurrentChatPriority __$myCurrentChatPriority');
          if (myCurrentChatPriority == 0) {
            mIsChatPriorityOne = true;
            mIsChatOneListData = mChatList.elementAt(index);
          } else if (myCurrentChatPriority == 1) {
            mIsChatPriorityTwo = true;
            mIsChatTwoListData = mChatList.elementAt(index);
          } else if (myCurrentChatPriority == 2) {
            mIsChatPriorityThree = true;
            mIsChatThreeListData = mChatList.elementAt(index);
          } else {
            mIsChatPriorityFour = true;
            Firestore.instance.collection('users')
                .document(mIsChatFourListData.userId)
                .updateData({
              'businessChatPeriority': 0,
              'businessChatWith': mIsChatFourListData.userId
            });
            Firestore.instance.collection('users')
                .document(_currentUserId)
                .updateData({
              'businessChatWith': mIsChatFourListData.userId
            });
            mIsChatFourListData = mChatList.elementAt(index);
          }
        }


        if (mIsChatPriorityOne) {
          Firestore.instance.collection('users')
              .document(mIsChatOneListData.userId)
              .updateData({
            'businessChatPeriority': 1,
            'businessChatWith': mIsChatOneListData.userId
          }).whenComplete(() {
            Firestore.instance.collection('users')
                .document(_currentUserId)
                .updateData({
              'businessChatWith': mIsChatOneListData.userId
            });
            _mCheck = true;
            setState(() {
              isLoading = false;
            });
            if (mIsChatOneListData.userId != _currentUserId) {
              if (!isChatOpened) {
                isChatOpened = true;
                sendAndRetrieveMessage(mIsChatOneListData.userToken,
                    mIsChatOneListData.businessName,mIsChatOneListData);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BusinessChat(
                              currentUserId: _businessId,
                              peerId: mIsChatOneListData.userId,
                              peerAvatar: mIsChatOneListData.photoUrl,
                              isFriend: true,
                              isAlreadyRequestSent: true,
                              peerName: mIsChatOneListData.name,
                              chatType: CHAT_TYPE_BUSINESS,
                            )));
              } else {
//                Fluttertoast.showToast(
//                    msg: 'Business user 0 ');
              }
            } else {
              if (_currentUserBusinessId == _businessId) {
                if (_currentUserBusinessType == BUSINESS_TYPE_EMPLOYEE) {
                  if (mIsChatOneListData.businessChatWith != '') {
                    Firestore.instance.collection('users').document(
                        mIsChatOneListData.businessChatWith).get().then((
                        DocumentSnapshot documentReference) =>
                    {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BusinessChat(
                                    currentUserId: _businessId,
                                    peerId: documentReference.data['id'],
                                    peerAvatar: documentReference
                                        .data['photoUrl'],
                                    isFriend: true,
                                    isAlreadyRequestSent: true,
                                    peerName: documentReference.data['name'],
                                    chatType: CHAT_TYPE_BUSINESS,
                                  )))
                    });
                  } else {
                    Fluttertoast.showToast(
                        msg: 'No Business users ');
                  }
                }
              } else {
                Fluttertoast.showToast(
                    msg: 'No Business users ');
              }
            }
          });
        } else if (mIsChatPriorityTwo) {
          Firestore.instance.collection('users')
              .document(mIsChatTwoListData.userId)
              .updateData({
            'businessChatPeriority': 2,
            'businessChatWith': mIsChatTwoListData.userId
          }).whenComplete(() {
            Firestore.instance.collection('users')
                .document(_currentUserId)
                .updateData({
              'businessChatWith': mIsChatTwoListData.userId
            });
            _mCheck = true;
            setState(() {
              isLoading = false;
            });
            if (mIsChatTwoListData.userId != _currentUserId) {
              if (!isChatOpened) {
                isChatOpened = true;
                sendAndRetrieveMessage(mIsChatTwoListData.userToken,
                    mIsChatTwoListData.businessName,mIsChatTwoListData);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BusinessChat(
                              currentUserId: _businessId,
                              peerId: mIsChatTwoListData.userId,
                              peerAvatar: mIsChatTwoListData.photoUrl,
                              isFriend: true,
                              isAlreadyRequestSent: true,
                              peerName: mIsChatTwoListData.name,
                              chatType: CHAT_TYPE_BUSINESS,
                            )));
              } else {
//                Fluttertoast.showToast(
//                    msg: 'Business user 0 ');
              }
            } else {
              if (_currentUserBusinessId == _businessId) {
                if (_currentUserBusinessType == BUSINESS_TYPE_EMPLOYEE) {
                  if (mIsChatTwoListData.businessChatWith != '') {
                    Firestore.instance.collection('users').document(
                        mIsChatTwoListData.businessChatWith).get().then((
                        DocumentSnapshot documentReference) =>
                    {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BusinessChat(
                                    currentUserId: _businessId,
                                    peerId: documentReference.data['id'],
                                    peerAvatar: documentReference
                                        .data['photoUrl'],
                                    isFriend: true,
                                    isAlreadyRequestSent: true,
                                    peerName: documentReference.data['name'],
                                    chatType: CHAT_TYPE_BUSINESS,
                                  )))
                    });
                  } else {
                    Fluttertoast.showToast(
                        msg: 'No Business users ');
                  }
                }
              } else {
                Fluttertoast.showToast(
                    msg: 'No Business users ');
              }
            }
          });
        } else if (mIsChatPriorityThree) {
          Firestore.instance.collection('users')
              .document(mIsChatThreeListData.userId)
              .updateData({
            'businessChatPeriority': 3,
            'businessChatWith': mIsChatThreeListData.userId
          }).whenComplete(() {
            Firestore.instance.collection('users')
                .document(_currentUserId)
                .updateData({
              'businessChatWith': mIsChatThreeListData.userId
            });
            _mCheck = true;
            setState(() {
              isLoading = false;
            });
            if (mIsChatThreeListData.userId != _currentUserId) {
              if (!isChatOpened) {
                isChatOpened = true;
                sendAndRetrieveMessage(mIsChatThreeListData.userToken,
                    mIsChatThreeListData.businessName,mIsChatThreeListData);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BusinessChat(
                              currentUserId: _businessId,
                              peerId: mIsChatThreeListData.userId,
                              peerAvatar: mIsChatThreeListData.photoUrl,
                              isFriend: true,
                              isAlreadyRequestSent: true,
                              peerName: mIsChatThreeListData.name,
                              chatType: CHAT_TYPE_BUSINESS,
                            )));
              } else {
//                Fluttertoast.showToast(
//                    msg: 'Business user 0 ');
              }
            } else {
              if (_currentUserBusinessId == _businessId) {
                if (_currentUserBusinessType == BUSINESS_TYPE_EMPLOYEE) {
                  if (mIsChatThreeListData.businessChatWith != '') {
                    Firestore.instance.collection('users').document(
                        mIsChatThreeListData.businessChatWith).get().then((
                        DocumentSnapshot documentReference) =>
                    {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BusinessChat(
                                    currentUserId: _businessId,
                                    peerId: documentReference.data['id'],
                                    peerAvatar: documentReference
                                        .data['photoUrl'],
                                    isFriend: true,
                                    isAlreadyRequestSent: true,
                                    peerName: documentReference.data['name'],
                                    chatType: CHAT_TYPE_BUSINESS,
                                  )))
                    });
                    /* Firestore.instance.collection('users').document(
                      _currentUserId).get().then((DocumentSnapshot documentReference) => {

                 });*/
                  } else {
                    Fluttertoast.showToast(
                        msg: 'No Business users ');
                  }
                }
              } else {
                Fluttertoast.showToast(
                    msg: 'No Business users ');
              }
            }
          });
        } else if (mIsChatPriorityFour) {
          Firestore.instance.collection('users')
              .document(mIsChatFourListData.userId)
              .updateData({
            'businessChatPeriority': 0,
            'businessChatWith': mIsChatFourListData.userId
          }).whenComplete(() {
            Firestore.instance.collection('users')
                .document(_currentUserId)
                .updateData({
              'businessChatWith': mIsChatFourListData.userId
            });
            _mCheck = true;
            setState(() {
              isLoading = false;
            });
            if (mIsChatFourListData.userId != _currentUserId) {
              if (!isChatOpened) {
                isChatOpened = true;
                sendAndRetrieveMessage(mIsChatFourListData.userToken,
                    mIsChatFourListData.businessName,mIsChatFourListData);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BusinessChat(
                              currentUserId: _businessId,
                              peerId: mIsChatFourListData.userId,
                              peerAvatar: mIsChatFourListData.photoUrl,
                              isFriend: true,
                              isAlreadyRequestSent: true,
                              peerName: mIsChatFourListData.name,
                              chatType: CHAT_TYPE_BUSINESS,
                            )));
              } else {
//              Fluttertoast.showToast(
//                  msg: 'Business user 0 ');
              }
            } else {
              if (_currentUserBusinessId == _businessId) {
                if (_currentUserBusinessType == BUSINESS_TYPE_EMPLOYEE) {
                  if (mIsChatFourListData.businessChatWith != '') {
                    Firestore.instance.collection('users').document(
                        mIsChatFourListData.businessChatWith).get().then((
                        DocumentSnapshot documentReference) =>
                    {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BusinessChat(
                                    currentUserId: _businessId,
                                    peerId: documentReference.data['id'],
                                    peerAvatar: documentReference
                                        .data['photoUrl'],
                                    isFriend: true,
                                    isAlreadyRequestSent: true,
                                    peerName: documentReference.data['name'],
                                    chatType: CHAT_TYPE_BUSINESS,
                                  )))
                    });
                    /* Firestore.instance.collection('users').document(
                      _currentUserId).get().then((DocumentSnapshot documentReference) => {

                 });*/
                  } else {
                    Fluttertoast.showToast(
                        msg: 'No Business users ');
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: 'No Business users ');
                }
              }
            }
          }
          );
        }
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: '${error.toString()}');
      });
//      return result.documents;

    } on Exception catch (e) {
      print('NANDHU BusinessDetail loadUsers Exception ${e.toString()}');
    }
  }

  Future StartBusinessChat() async {
    try {
      setState(() {
        isLoading = true;
      });
      Firestore.instance
          .collection('users')
          .where('businessId', isEqualTo: _businessId)
          .where('status', isEqualTo: 'ACTIVE')
          .getDocuments().then((result) {
        List<BusinessChatData> mChatList = List<BusinessChatData>();
        var userListData = result.documents;
        if (userListData.length != 0) {
          for (var number in result.documents) {
            var index = result.documents.indexOf(number);
            var reference = result.documents
                .elementAt(index)
                .data;
            var _businessChatPeriority = 0;
            if (reference.containsKey('businessChatPeriority')) {
              _businessChatPeriority = reference['businessChatPeriority'];
            } else {
              _businessChatPeriority = 0;
            }
            print('________________________Status ${reference['status']}');
            mChatList.add(BusinessChatData(businessId: reference['businessId'],
                businessChatPriority: reference['businessChatPeriority'],
                userId: reference['id'],
                name: reference['name'],
                photoUrl: reference['photoUrl'],
                userToken: reference['user_token'],
                businessName: reference['businessName'],
                businessType: reference['businessType'],
                userStatus: reference['status']));
          }

          var isPriorityOne = false; //is priority 0
          var isPriorityTwo = false; //is priority 1
          var isPriorityThree = false; //is priority 2
          var isPriorityFour = false; //is priority 3

          var employeeOneData = BusinessChatData(); //priority 0 data
          var employeeTwoData = BusinessChatData(); //priority 1 data
          var employeeThreeData = BusinessChatData(); //priority 2 data
          var employeeFourData = BusinessChatData(); //priority 3 data


          var isChatOpened = false;

          var employeeCount = 0;
          var ownerCount = 0;
          var ownerId = '';

          /**
           * To find the owner and employee count
           */
          for (var mValue in mChatList) {
            var index = mChatList.indexOf(mValue); // through an index
            var businessType = mChatList
                .elementAt(index)
                .businessType;
            if (businessType == BUSINESS_TYPE_EMPLOYEE)
              employeeCount = employeeCount + 1;
            else if (businessType == BUSINESS_TYPE_OWNER) {
              ownerCount = ownerCount + 1;
              ownerId = mChatList
                  .elementAt(index)
                  .userId;
            }
          }

          var ownerAvailable = false;
          var employeeAvailable = false;

          if (employeeCount == 0) {
            if (ownerCount == 0) {
              Fluttertoast.showToast(
                  msg: 'Business Owner not available');
            } else {
              /**
               * To assign owner as a contact person for the user if employees not available
               */
              for (var mValue in mChatList) {
                var index = mChatList.indexOf(mValue); // through an index
                var myCurrentChatPriority = mChatList
                    .elementAt(index)
                    .businessChatPriority;
                var businessType = mChatList
                    .elementAt(index)
                    .businessType;
                var businessOwnerId = mChatList
                    .elementAt(index)
                    .userId;
                if (myCurrentChatPriority == 0) {
                  isPriorityOne = true;
                  if (businessType == BUSINESS_TYPE_OWNER &&
                      businessOwnerId != _currentUserId) {
                    employeeOneData = mChatList.elementAt(index);
                    ownerAvailable = true;
                  }
                } else if (myCurrentChatPriority == 1) {
                  isPriorityTwo = true;
                  if (businessType == BUSINESS_TYPE_OWNER &&
                      businessOwnerId != _currentUserId) {
                    employeeTwoData = mChatList.elementAt(index);
                    ownerAvailable = true;
                  }
                } else if (myCurrentChatPriority == 2) {
                  isPriorityThree = true;
                  if (businessType == BUSINESS_TYPE_OWNER &&
                      businessOwnerId != _currentUserId) {
                    employeeThreeData = mChatList.elementAt(index);
                    ownerAvailable = true;
                  }
                } else {
                  isPriorityFour = true;
                  Firestore.instance.collection('users')
                      .document(employeeFourData.userId)
                      .updateData({
                    'businessChatPeriority': 0,
                  });
                  if (businessType == BUSINESS_TYPE_OWNER &&
                      businessOwnerId != _currentUserId) {
                    ownerAvailable = true;
                    employeeFourData = mChatList.elementAt(index);
                  }
                }
              }
            }
          } else {
            for (var mValue in mChatList) {
              var index = mChatList.indexOf(mValue); // through an index
              var myCurrentChatPriority = mChatList
                  .elementAt(index)
                  .businessChatPriority;
              var businessType = mChatList
                  .elementAt(index)
                  .businessType;
              var businessEmployeeId = mChatList
                  .elementAt(index)
                  .userId;
              print(
                  '______________________INDEX________$index __________myCurrentChatPriority __$myCurrentChatPriority');

              if (myCurrentChatPriority == 0) {
                isPriorityOne = true;
                if (businessType == BUSINESS_TYPE_EMPLOYEE &&
                    businessEmployeeId != _currentUserId) {
                  employeeOneData = mChatList.elementAt(index);
                  employeeAvailable = true;
                }
              } else if (myCurrentChatPriority == 1) {
                isPriorityTwo = true;
                if (businessType == BUSINESS_TYPE_EMPLOYEE &&
                    businessEmployeeId != _currentUserId) {
                  employeeTwoData = mChatList.elementAt(index);
                  employeeAvailable = true;
                }
              } else if (myCurrentChatPriority == 2) {
                isPriorityThree = true;
                if (businessType == BUSINESS_TYPE_EMPLOYEE &&
                    businessEmployeeId != _currentUserId) {
                  employeeThreeData = mChatList.elementAt(index);
                  employeeAvailable = true;
                }
              } else {
                isPriorityFour = true;
                Firestore.instance.collection('users')
                    .document(employeeFourData.userId)
                    .updateData({
                  'businessChatPeriority': 0,
                });
                if (businessType == BUSINESS_TYPE_EMPLOYEE &&
                    businessEmployeeId != _currentUserId) {
                  employeeFourData = mChatList.elementAt(index);
                  employeeAvailable = true;
                }
              }
            }
          }

          if (employeeAvailable || ownerAvailable) {
            if (isPriorityOne) {
              Firestore.instance.collection('users')
                  .document(employeeOneData.userId)
                  .updateData({
                'businessChatPeriority': 1,
              }).whenComplete(() {
                Firestore.instance.collection('chatRooms').add({
                  'createDate': DateFormat.yMd().add_jms().format(
                      DateTime.now()),
                  'employeeId': employeeOneData.userId,
                  'isCreated': true,
                  'storeId': _businessId,
                  'userId': _currentUserId,
                  'employeeName' : employeeOneData.name,
                  'userName':_currentUserName,
                  'employeePhotoUrl':employeeOneData.photoUrl,
                  'employeeStatus': 'ACTIVE'
                }).whenComplete(() {
                  setState(() {
                    isLoading = false;
                  });
                  if (!isChatOpened) {
                    isChatOpened = true;
                    sendAndRetrieveMessage(employeeOneData.userToken,
                        employeeOneData.businessName,employeeOneData);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BusinessChat(
                                  currentUserId: _currentUserId,
                                  peerId: employeeOneData.userId,
                                  peerAvatar: _businessImage,
                                  isFriend: true,
                                  isAlreadyRequestSent: true,
                                  peerName: _businessName,
                                  chatType: CHAT_TYPE_BUSINESS,
                                )));
                  } else {
//                Fluttertoast.showToast(
//                    msg: 'Business user 0 ');
                  }
                });
              });
            } else if (isPriorityTwo) {
              Firestore.instance.collection('users')
                  .document(employeeTwoData.userId)
                  .updateData({
                'businessChatPeriority': 2,
              }).whenComplete(() {
               /* Firestore.instance.collection('chatRooms').document(
                    _currentUserId).setData({
                  'createDate': DateFormat.yMd().add_jms().format(
                      DateTime.now()),
                  'employeeId': employeeTwoData.userId,
                  'isCreated': true,
                  'storeId': _businessId,
                  'userId': _currentUserId
                }).*/
                Firestore.instance.collection('chatRooms').add({
                  'createDate': DateFormat.yMd().add_jms().format(
                      DateTime.now()),
                  'employeeId': employeeTwoData.userId,
                  'isCreated': true,
                  'storeId': _businessId,
                  'userId': _currentUserId,
                  'employeeName' : employeeTwoData.name,
                  'userName':_currentUserName,
                  'employeePhotoUrl':employeeTwoData.photoUrl,
                  'employeeStatus': 'ACTIVE'
                }).whenComplete(() {
                  setState(() {
                    isLoading = false;
                  });
                  if (!isChatOpened) {
                    isChatOpened = true;
                    sendAndRetrieveMessage(employeeTwoData.userToken,
                        employeeTwoData.businessName,employeeTwoData);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BusinessChat(
                                  currentUserId: _currentUserId,
                                  peerId: employeeTwoData.userId,
                                  peerAvatar: _businessImage,
                                  isFriend: true,
                                  isAlreadyRequestSent: true,
                                  peerName: _businessName,
                                  chatType: CHAT_TYPE_BUSINESS,
                                )));
                  } else {
//                Fluttertoast.showToast(
//                    msg: 'Business user 0 ');
                  }
                });
              });
            } else if (isPriorityThree) {
              Firestore.instance.collection('users')
                  .document(employeeThreeData.userId)
                  .updateData({
                'businessChatPeriority': 3,
              }).whenComplete(() {
                Firestore.instance.collection('chatRooms').add({
                  'createDate': DateFormat.yMd().add_jms().format(
                      DateTime.now()),
                  'employeeId': employeeThreeData.userId,
                  'isCreated': true,
                  'storeId': _businessId,
                  'userId': _currentUserId,
                  'employeeName' : employeeThreeData.name,
                  'userName':_currentUserName,
                  'employeePhotoUrl':employeeThreeData.photoUrl,
                  'employeeStatus': 'ACTIVE'
                })/*;
                Firestore.instance.collection('chatRooms').document(
                    _currentUserId).setData({
                  'createDate': DateFormat.yMd().add_jms().format(
                      DateTime.now()),
                  'employeeId': employeeThreeData.userId,
                  'isCreated': true,
                  'storeId': _businessId,
                  'userId': _currentUserId
                })*/.whenComplete(() {
                  setState(() {
                    isLoading = false;
                  });
                  if (!isChatOpened) {
                    isChatOpened = true;
                    sendAndRetrieveMessage(employeeThreeData.userToken,
                        employeeThreeData.businessName,employeeThreeData);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BusinessChat(
                                  currentUserId: _currentUserId,
                                  peerId: employeeThreeData.userId,
                                  peerAvatar: _businessImage,
                                  isFriend: true,
                                  isAlreadyRequestSent: true,
                                  peerName: _businessName,
                                  chatType: CHAT_TYPE_BUSINESS,
                                )));
                  } else {
//                Fluttertoast.showToast(
//                    msg: 'Business user 0 ');
                  }
                });
              });
            } else if (isPriorityFour) {
              Firestore.instance.collection('users')
                  .document(employeeFourData.userId)
                  .updateData({
                'businessChatPeriority': 0,
              }).whenComplete(() {
                Firestore.instance.collection('chatRooms').add({
                  'createDate': DateFormat.yMd().add_jms().format(
                      DateTime.now()),
                  'employeeId': employeeFourData.userId,
                  'isCreated': true,
                  'storeId': _businessId,
                  'userId': _currentUserId,
                  'employeeName' : employeeFourData.name,
                  'userName':_currentUserName,
                  'employeePhotoUrl':employeeFourData.photoUrl,
                  'employeeStatus': 'ACTIVE'
                }).
               /* Firestore.instance.collection('chatRooms').document(
                    _currentUserId).setData({
                  'createDate': DateFormat.yMd().add_jms().format(
                      DateTime.now()),
                  'employeeId': employeeFourData.userId,
                  'isCreated': true,
                  'storeId': _businessId,
                  'userId': _currentUserId
                }).*/whenComplete(() {
                  setState(() {
                    isLoading = false;
                  });
                  if (!isChatOpened) {
                    isChatOpened = true;
                    sendAndRetrieveMessage(employeeFourData.userToken,
                        employeeFourData.businessName,employeeFourData);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BusinessChat(
                                  currentUserId: _currentUserId,
                                  peerId: employeeFourData.userId,
                                  peerAvatar: _businessImage,
                                  isFriend: true,
                                  isAlreadyRequestSent: true,
                                  peerName: _businessName,
                                  chatType: CHAT_TYPE_BUSINESS,
                                )));
                  } else {
//              Fluttertoast.showToast(
//                  msg: 'Business user 0 ');
                  }
                });
              }
              );
            }
          } else {
            setState(() {
              isLoading = false;
            });
            if (!ownerAvailable) {
              Fluttertoast.showToast(
                  msg: 'Business ownerUnavailable');
            }

            if (!employeeAvailable) {
              Fluttertoast.showToast(
                  msg: 'Business employeeUnavailable');
            }
          }
        } else {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: 'Owner and Employees unavailable');
        }
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: '${error.toString()}');
      });
    } on Exception catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: '${e.toString()}');
    }
  }


  final String serverToken = SERVER_KEY;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String _message = '';
  BusinessChatData _businessChatData;
  String notifyId;
  String userId ='';
  String name ='';
  String photoUrl ='';
  String businessId ='';
  bool isOpened = false;


  Future<Map<String, dynamic>> sendAndRetrieveMessage(String token,
      String businessName, BusinessChatData mIsChatListData) async {
    print('Business detail sendAndRetrieveMessage ___token $token');
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
            'body': 'Business Chat from user ${mIsChatListData.name} in $businessName.Kindly go to business chat.',
            'title': 'Business Chat'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1000',
            'status': 'done',
            'userId':mIsChatListData.userId,
            'name':mIsChatListData.name,
            'photoUrl':mIsChatListData.photoUrl,
            'businessId':_currentUserId,
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
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    await flutterLocalNotificationsPlugin.show(
      1000,
      message["notification"]["title"],
      message["notification"]["body"],
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
    _businessChatData = message["data"]["data"];
    notifyId = message["data"]["id"];
    userId = message["data"]["userId"];
    name =message["data"]["name"];
    photoUrl = message["data"]["photoUrl"];
    businessId = message["data"]["businessId"];
//    onSelectNotification('');
  }


  void getMessage() {
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message ___ ${ message["data"]["id"]} ______ ${message["data"]["data"] }');
          _showNotificationWithDefaultSound(message);
          setState(() {
            _message = message["notification"]["title"];
            _businessChatData = message["data"]["data"];
            notifyId = message["data"]["id"];
          });
        }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message ___ ${ message["data"]["id"]} ______ ${message["data"]["data"] }');
      _showNotificationWithDefaultSound(message);
      setState(() {
        _message = message["notification"]["title"];
        _businessChatData = message["data"]["data"];
        notifyId = message["data"]["id"];
      });
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on onLaunch $message ___ ${ message["data"]["id"]} ______ ${message["data"]["data"] }');
      _showNotificationWithDefaultSound(message);
      setState(() {
        _message = message["notification"]["title"];
        _businessChatData = message["data"]["data"];
        notifyId = message["data"]["id"];
      });
    });
  }
}