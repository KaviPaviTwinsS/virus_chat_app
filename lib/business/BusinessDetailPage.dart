import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/chat/chat.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';

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

  SharedPreferences preferences;

  String _currentUserId = '';
  List<DocumentSnapshot> documents = new List<DocumentSnapshot>();

  bool isLoading = false;

  BusinessDetailPageState(String businessId, String businessName) {
    _businessId = businessId;
    _businessName = businessName;
  }

  @override
  void initState() {
    initialise();
    super.initState();
  }


  void initialise() async {
    preferences = await SharedPreferences.getInstance();
    _currentUserId = await preferences.getString('userId');
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
              Container(
//                  color: button_fill_color,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
//                  height: 150,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 0.0, bottom: 25.0),
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
                      new Container(
                          margin: EdgeInsets.only(
                              left: 0.0, bottom: 25.0),
                          child: Text(
                            capitalize(_businessName), style: TextStyle(
                              color: text_color,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),)
                      ),
                    ],
                  )
              ),
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                     /* height: MediaQuery
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
                      child: Stack(
                        children: <Widget>[
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
                          Stack(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  (_businessImage != null &&
                                      _businessImage != '') ? Center(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            bottom: 15.0, top: 15.0),
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
                                          fontWeight: FontWeight.bold),),
                                  )
                                      : Text(''),
                                  _businessAddress != null &&
                                      _businessAddress != '' ? Container(
                                    margin: EdgeInsets.only(
                                        left: 15.0, bottom: 15.0),
                                    child: Text(_businessAddress,),
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
                                              capitalize(_businessOwnerName),),
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
                                              capitalize(_businessNumber),),
                                          )
                                        ],
                                      ) : Text('')
                                    ],
                                  )
                                ],
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  child: IconButton(
                                    icon: new SvgPicture.asset(
                                      'images/business_chat.svg', height: 500.0,
                                      width: 500.0,
                                    ),
                                    onPressed: () {
                                      getBusinessUsers();
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                  )
              )
            ],
          ),
        )
    );
  }

  Future getBusinessUsers() async {
    print('Business Detail document list');

    try {
      setState(() {
        isLoading = true;
      });
      QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('businessId', isEqualTo: _businessId)
          .where('businessType', isEqualTo: 'employee')
          .getDocuments().whenComplete(() {
        setState(() {
          isLoading = false;
        });
      }).catchError((error) {
        Fluttertoast.showToast(msg: '${error.toString()}');
      });
      print('Business Detail document list ${result.documents.length}');
      var _mCheck = false;

      if (result.documents.length != 0) {
        result.documents.forEach((doc) {
//        if(doc.documentID)
          var reference = doc.data;
          var _mStatus = reference['status'];
          var _businessChatPeriority = -1;
          if (reference.containsKey('businessChatPeriority')) {
            _businessChatPeriority = reference['businessChatPeriority'];
          } else {
            _businessChatPeriority = 0;
          }
          print(
              'Business Detail document ____________ ${_businessChatPeriority} _________mCheck $_mCheck ____mStatus $_mStatus');
          if (!_mCheck && _businessChatPeriority == 0) {
            if (_mStatus != '' && _mStatus != 'LoggedOut') {
              Firestore.instance.collection('users')
                  .document(reference['id'])
                  .updateData({
                'businessChatPeriority': 1
              }).whenComplete(() {
                _mCheck = true;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Chat(
                              currentUserId: _currentUserId,
                              peerId: reference['id'],
                              peerAvatar: reference['photoUrl'],
                              isFriend: true,
                              isAlreadyRequestSent: true,
                              peerName: reference['name'],
                            )));
              });
            } else if (_mStatus == 'LoggedOut' && !_mCheck) {
              _mCheck = false;
              Fluttertoast.showToast(
                  msg: 'Business user is in LoggedOut state');
            } else if (_mStatus == '') {
              Fluttertoast.showToast(
                  msg: 'Business user not yet logged in');
            }
          } else if (_businessChatPeriority == 1) {
            if (_mStatus != '' && _mStatus != 'LoggedOut') {
              Firestore.instance.collection('users')
                  .document(reference['id'])
                  .updateData({
                'businessChatPeriority': 2
              })
                  .whenComplete(() {

              });
              _mCheck = true;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Chat(
                            currentUserId: _currentUserId,
                            peerId: reference['id'],
                            peerAvatar: reference['photoUrl'],
                            isFriend: true,
                            isAlreadyRequestSent: true,
                            peerName: reference['name'],
                          )));
            } else if (_mStatus == 'LoggedOut' && !_mCheck) {
              _mCheck = false;
              Fluttertoast.showToast(
                  msg: 'Business user is in LoggedOut state');
            }
          } else {
            if (_mStatus != '' && _mStatus != 'LoggedOut') {
              Firestore.instance.collection('users')
                  .document(reference['id'])
                  .updateData({
                'businessChatPeriority': 3
              })
                  .whenComplete(() {
                _mCheck = true;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Chat(
                              currentUserId: _currentUserId,
                              peerId: reference['id'],
                              peerAvatar: reference['photoUrl'],
                              isFriend: true,
                              isAlreadyRequestSent: true,
                              peerName: reference['name'],
                            )));
              });
            } else if (_mStatus == 'LoggedOut' && !_mCheck) {
              _mCheck = false;
              Fluttertoast.showToast(
                  msg: 'Business user is in LoggedOut state');
            }
          }
        });
      } else {
        Fluttertoast.showToast(msg: 'No business users');
      }
      return result.documents;
    } on Exception catch (e) {
      print('NANDHU BusinessDetail loadUsers Exception ${e.toString()}');
    }
  }
}