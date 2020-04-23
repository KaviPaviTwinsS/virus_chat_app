import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/profile/ProfilePage.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/const.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'package:permission_handler/permission_handler.dart';

class AddEmployee extends StatefulWidget {
  String _currUserId = '';
  String _currUserSignInType = '';

  AddEmployee(String signInType, String currentUserId) {
    _currUserSignInType = signInType;
    _currUserId = currentUserId;
  }

  @override
  State<StatefulWidget> createState() {
    return AddEmployeeState(_currUserSignInType, _currUserId);
  }

}

class AddEmployeeState extends State<AddEmployee> {

  String _mCurrUserId = '';
  String _mCurrUserSignInType = '';
  TextEditingController searchController;
  String _mSearchContact = '';
  Iterable<Contact> _contacts;
  Uint8List avatar;
  List<String> userList = new List<String>();
  SharedPreferences prefs;
  final ScrollController listScrollController = new ScrollController();
  bool isLoading = false;

  AddEmployeeState(String signInType, String currentUserId) {
    _mCurrUserId = signInType;
    _mCurrUserSignInType = currentUserId;
  }

  @override
  void initState() {
    super.initState();
    initialise();
  }

  @override
  void dispose() {
    listScrollController.dispose();
    print('Leng________________________________________________dispose${_contacts.length}');
    super.dispose();
  }

  Future loadUsers() async{
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {

    }else {
      for (int i = 0; i < documents.length;i++){
        if(documents[i]['phoneNo'] != null || documents[i]['phoneNo'] != '')
        userList.add(documents[i]['phoneNo']);
      }
    }
    Timer(Duration(seconds: 5), () {
      refreshContacts('a');
    });
  }
  void initialise() async {
    print('searchKey_____________________searchKey initialise');

    searchController = new TextEditingController(text: _mSearchContact);
    prefs = await SharedPreferences.getInstance();
//    loadContacts();
    loadUsers();
 /*   listScrollController.addListener(() {
      print('Listenerrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr');
      if (listScrollController.position.pixels ==
          listScrollController.position.maxScrollExtent) {
        refreshContacts('');
      }
    });*/

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 5.0, top: 40.0, right: 20.0),
                          child: new IconButton(
                            icon: new Icon(
                                Icons.arrow_back_ios, color: Colors.black),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      new ProfilePage(
                                        _mCurrUserSignInType,
                                        currentUserId: _mCurrUserId,)));
                            },
                          ),
                        )
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 5.0, top: 40.0, right: 20.0),
                      child: Text(
                        add_employee, style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                    )
                  ],
                ),
              ],
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
                      .height - 100,
                  decoration: BoxDecoration(
                      color: greyColor2,
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(30.0),
                        topRight: const Radius.circular(30.0),
                      )
                  ),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: <Widget>[
                          Card(
                            elevation: 20,
                            margin: EdgeInsets.all(20.0),
                            child: Container(
                              color: white_color,
                              child: TextField(
                                decoration: InputDecoration(
                                  contentPadding: new EdgeInsets.all(15.0),
                                  suffixIcon: IconButton(
                                    icon: new SvgPicture.asset(
                                      'images/Search.svg', height: 20.0,
                                      width: 20.0,
                                    ),
                                    onPressed: () {
                                      refreshContacts('');
                                    },
                                  ),
                                  hintText: search,
                                ),
                                controller: searchController,
                                onChanged: (value) {
                                  print('searchController $value');
                                  _mSearchContact = value;
                                  refreshContacts('');
                                },
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ),
                          _contacts != null && _contacts.length != 0 ? Flexible(
                            child: new ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                               /* if (index == _contacts.length) {
                                  return _buildProgressIndicator();
                                } else {
                                  return buildItem(_contacts.elementAt(index));
                              }*/
                                return buildItem(_contacts.elementAt(index));
                              },
                              itemCount: _contacts.length,
                              controller: listScrollController,
                            ),
                          ) : Text('Contacts Reading..................')
                        ],
                      )
                  ),
                )
            )
          ],
        )
    );
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }


  Future loadContacts() async {
/*
// Get all contacts on device
    Iterable<Contact> contacts = await ContactsService.getContacts();

// Get all contacts without thumbnail (faster)
    Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);

    print('contactscontacts__________$contacts');
// Get contacts matching a string
    Iterable<Contact> johns = await ContactsService.getContacts(*/
/*query : "john"*/ /*
);
*/

  }


  Future refreshContacts(String searchKey) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      Iterable<Contact> tempContacts;
      print('searchKey_____________________searchKey $searchKey');

      if(searchKey == ''){
        tempContacts = await ContactsService.getContacts(query: _mSearchContact);
      }else {
        tempContacts = await ContactsService.getContacts(
            query: searchKey);
      }
     /* setState(() {
        _contacts = tempContacts;
      });

*/
      // Lazy load thumbnails after rendering initial contacts.
      for (final contact in tempContacts) {
        ContactsService.getAvatar(contact).then((mavatar) {
          print('${contact.displayName}_contacts____________avatar ${mavatar}');

          if (mavatar == null) return; // Don't redraw if no c
          setState(() {
            contact.avatar = mavatar;
            prefs.setString('KEYYYYYYY', mavatar.toList().toString());
            avatar = mavatar;
          });
        });
        Iterable<Item> mPhone = contact.phones;

        for (final phone in mPhone) {
//          print('_contacts____________PHONE ${phone.value} ____ ${phone.label}');
        }
        print('_contacts____________${tempContacts.length}');
      }
      setState(() {
        isLoading = false;
        _contacts = tempContacts;
      });
    }
/*
//    PermissionStatus permissionStatus = await _getContactPermission();
//    if (permissionStatus == PermissionStatus.granted) {
    // Load without thumbnails initially.
    Iterable<Contact> contacts;
    if(_mSearchContact == ''){
      contacts = await ContactsService.getContacts();
    }else {
      contacts = await ContactsService.getContacts(
          query: _mSearchContact);
    }
    setState(() {
      _contacts = contacts;
    });


    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((mavatar) {
        print('${contact.displayName}_contacts____________avatar ${mavatar}');

        if (mavatar == null) return; // Don't redraw if no c
        setState(() {
          contact.avatar = mavatar;
          prefs.setString('KEYYYYYYY', mavatar.toList().toString());
          avatar = mavatar;
        });
      });
      Iterable<Item> mPhone = contact.phones;
      for (final phone in mPhone) {
//          print('_contacts____________PHONE ${phone.value} ____ ${phone.label}');
      }
      print('_contacts____________${contacts.length}');
    }
//    } else {
//      _handleInvalidPermissions(permissionStatus);
//    }
*/
  }

  updateContact() async {
    Contact ninja = _contacts
        .toList()
        .firstWhere((contact) => contact.familyName.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);

    refreshContacts('');
  }

  Future<PermissionStatus> _getContactPermission() async {
    /*PermissionStatus permission = await Permissions()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.restricted) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
      await PermissionHandler()
          .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }*/
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to location data denied",
          details: null);
    } else
      /*if (permissionStatus == PermissionStatus.disabled) {*/ {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

/*
  Future<Widget> BuildList() async {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) =>
          buildItem(_contacts),
      itemCount: _contacts.length,
      controller: listScrollController,
    );
  }*/

  Widget buildItem(Contact contacts) {
    print('LEGTHTHHHHHHHHHHHHHHHH ${_contacts.length}');
    String mContactPhone = '';
    String mContactName = '';
    bool alreadyUser = false;
    // Lazy load thumbnails after rendering initial contacts.
//    for (final contact in contacts) {
//      ContactsService.getAvatar(contacts).then((mavatar) {
////        print('${contacts.displayName}_contacts____________avatar ${mavatar}');
//
////        if (mavatar == null) return; // Don't redraw if no c
//        setState(() {
//          contacts.avatar = mavatar;
//          avatar = mavatar;
//        });
//      });
    Iterable<Item> mPhone = contacts.phones;
    avatar = contacts.avatar;
    for (final phone in mPhone) {
      mContactPhone = phone.value;
//        print('_contacts____________PHONE ${phone.value} ____ ${phone.label}');
    }
    mContactName = contacts.displayName;
//      print('_contacts____________${contacts.displayName} __ ${contacts
//          .avatar} ____${mPhone}');
//    }
    for(int i= 0;i<userList.length;i++){
      if(mContactPhone == userList[i]){
        alreadyUser = true;
      }
    }
    return Container(
      margin: EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              avatar != null && avatar != '' ? Material(
                child: Image.memory(
                  avatar,
                  width: 70,
                  height: 70.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(40.0),
                ),
                clipBehavior: Clip.hardEdge,
              ) : Material(
                child: Icon(
                  Icons.account_circle,
                  size: 70.0,
                  color: greyColor,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(40.0),
                ),
                clipBehavior: Clip.hardEdge,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    child: Text(mContactName,
                      style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 5.0),
                    child: Text(mContactPhone),
                  ),
                ],
              ),
              !alreadyUser && _mSearchContact.length == MOBILE_NUMBER_LENGTH ? Align(
                alignment: Alignment.topRight,
                child:  IconButton(
                  icon: new SvgPicture.asset(
                    'images/employee_add.svg', height: 20.0,
                    width: 20.0,
                  ),
                  onPressed: () {

                  },
                ),
              ): alreadyUser && _mSearchContact.length == MOBILE_NUMBER_LENGTH ? Align(
                alignment: Alignment.topRight,
                child:  IconButton(
                  icon: new SvgPicture.asset(
                    'images/employee_invite.svg', height: 20.0,
                    width: 20.0,
                  ),
                  onPressed: () {

                  },
                ),
              ):Text('')
            ],
          ),
          Divider()
        ],
      ),
    );
  }

}