import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:virus_chat_app/business/flutter_sms.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/constants.dart';
import 'package:virus_chat_app/utils/strings.dart';

class AddEmployee extends StatefulWidget {
  String _currUserId = '';
  String _currUserSignInType = '';
  String _mBusinessId = '';

  AddEmployee(String signInType, String currentUserId,String businessId) {
    _currUserSignInType = signInType;
    _currUserId = currentUserId;
    _mBusinessId = businessId;
  }

  @override
  State<StatefulWidget> createState() {
    return AddEmployeeState(_currUserSignInType, _currUserId,_mBusinessId);
  }

}

class AddEmployeeState extends State<AddEmployee> {

  String _mCurrUserId = '';
  String _mCurrUserSignInType = '';
  String _mBusinessId ='';
  int _noOfEmployee = 0;
  TextEditingController searchController;
  String _mSearchContact = '';
  Iterable<Contact> _contacts;
  Uint8List avatar;
//  List<String> userList = new List<String>();
  List<DocumentSnapshot> documents;
  SharedPreferences prefs;
  final ScrollController listScrollController = new ScrollController();
  bool isLoading = false;
  String _mBusinessName = '';

  AddEmployeeState(String signInType, String currentUserId, String mBusinessId) {
    _mCurrUserId = currentUserId;
    _mCurrUserSignInType = signInType;
    _mBusinessId = mBusinessId;
  }

  @override
  void initState() {
    super.initState();
    initialise();
  }

  @override
  void dispose() {
    listScrollController.dispose();
    print('NANDHU AddEmployeeState dispose');
    super.dispose();
  }

  Future<List<DocumentSnapshot>> loadUsers() async{
    print('NANDHU AddEmployeeState loadUsers');
    try{
      QuerySnapshot result = await Firestore.instance
          .collection('users')
          .getDocuments();
      return result.documents;
    }on Exception catch (e) {
      print('NANDHU AddEmployeeState loadUsers Exception ${e.toString()}');
    }
    print('NANDHU AddEmployeeState loadUsers length ${documents.length}');

    /*Firestore.instance
          .collection('users')
          .getDocuments().then((result){
        documents = result.documents;
        print('loadUsers_______________________${documents.length}');
*//*
        if (documents.length == 0) {

        }else {
          for (int i = 0; i < documents.length;i++){
            if(documents[i]['phoneNo'] != null && documents[i]['phoneNo'] != '')
              userList.add(documents[i]['phoneNo']);
          }
        }*//*
      });*/

 /*   if (documents.length == 0) {
      print('loadUsers_______________________LENGTH${documents.length}');
    }else {
      for (int i = 0; i < documents.length;i++){
//        if(documents[i]['phoneNo'] != null && documents[i]['phoneNo'] != '')
          print('loadUsers_______________________LENGTH${documents.length} ______________________${documents[i]['phoneNo']}');
      }
    }*/

  }

  Future  initialise() async {
    documents = new List<DocumentSnapshot>();
    print('NANDHU AddEmployeeState initialise');
    searchController = new TextEditingController(text: _mSearchContact);
    prefs = await SharedPreferences.getInstance();
    _mBusinessName = await prefs.getString('BUSINESS_NAME');
    _noOfEmployee = await prefs.getInt('BUSINESS_EMPLOYEES_COUNT');
    documents = await loadUsers();
    Timer(Duration(seconds: 2), ()  {
      _mSearchContact = 'a';
      refreshContacts('a');
    });
/* QuerySnapshot querySnapshot = await Firestore.instance.collection("users").getDocuments();
    userList= querySnapshot.documents;
    print('refreshContacts_____________ ${userList.length}');
*/
//    loadContacts();
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
    print('NANDHU AddEmployeeState build');
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
                                Icons.arrow_back_ios, color: black_color),
                            onPressed: () {
                             /* Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      new ProfilePage(
                                        _mCurrUserSignInType,
                                        currentUserId: _mCurrUserId,)));*/
                             Navigator.pop(context);
                            },
                          ),
                        )
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 5.0, top: 40.0, right: 20.0),
                      child: Text(
                        add_employee, style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 20.0,fontFamily: 'GoogleSansFamily',color: black_color),
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
//                      color: greyColor2,
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(20.0),
                        topRight: const Radius.circular(20.0),
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
                                  border: InputBorder.none,
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
                                  if(_mSearchContact.length > 10)
                                    refreshContacts('');
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
                                return buildItem(_contacts.elementAt(index),index);
                              },
                              itemCount: _contacts.length,
                              controller: listScrollController,
                            ),
                          ) : Text('Contacts Reading..................',style: TextStyle(fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400,color: hint_color_grey_light),)
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
);_getContactPermission
*/

  }


  Future refreshContacts(String searchKey) async {
    print('NANDHU AddEmployeeState refreshContacts key ___${searchKey} ___text ${searchController.text}');
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      if (!isLoading) {
        setState(() {
          isLoading = true;
        });
        Iterable<Contact> tempContacts;
        if(searchKey == ''){
          tempContacts = await ContactsService.getContactsForPhone(searchController.text);
        }else {
          tempContacts = await ContactsService.getContacts(query: searchKey);
        }
        print('NANDHU AddEmployeeState tempContacts length ${tempContacts.length}');
        // Lazy load thumbnails after rendering initial contacts.
        for (final contact in tempContacts) {
          ContactsService.getAvatar(contact).then((mavatar) {
            setState(() {
              contact.avatar = mavatar;
              avatar = mavatar;
            });
          });
          Iterable<Item> mPhone = contact.phones;
          for (final phone in mPhone) {
            mContactPhone = phone.value;
            mContactPhone = getPhoneValidation(
                mContactPhone.toString().replaceAll(' ', ''));
          }
        }
        setState(() {
          isLoading = false;
          _contacts = tempContacts;
        });
      }
    } else {
     _handleInvalidPermissions(permissionStatus);
    }
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
    print('_getContactPermission');
    var status = await Permission.contacts.status;
    if (await Permission.contacts.request().isGranted) {

    }
   /* PermissionStatus permission = await Permissions()
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
   return status;
  }

  void  _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      Fluttertoast.showToast(msg: 'Contact permission denied');
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to location data denied",
          details: null);
    } else
      /*if (permissionStatus == PermissionStatus.disabled) {*/ {
//      Fluttertoast.showToast(msg: 'Contact permission disabled');
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

  String mContactPhone = '';
  String mContactName = '';
  bool alreadyUser = false;
  String alreadyUserInBusiness = '';
  String alreadyUserId = '';
  String alreadyUserbusinessId = '';
  Contact _mContacts;

  String getPhoneValidation(String mPhone){
    print('NANDHU AddEmployeeState getPhoneValidation mPhone length ${mPhone.length} ___________________________$mPhone');
    var _tempPhone = '';
    if(mPhone.length == 10){
      _tempPhone = mPhone;
    }else if(mPhone.length == 11){
      _tempPhone = mPhone.substring(1,mPhone.length);
    }else if(mPhone.length == 12){
      _tempPhone = mPhone.substring(2,mPhone.length);
    }else if(mPhone.length == 13){
      _tempPhone = mPhone.substring(3,mPhone.length);
    }else if(mPhone.length == 14){
      _tempPhone = mPhone.substring(4,mPhone.length);
    }else if(mPhone.length == 15){
      _tempPhone = mPhone.substring(5,mPhone.length);
    }else if(mPhone.length == 16){
      _tempPhone = mPhone.substring(6,mPhone.length);
    }else{
      _tempPhone = mPhone;
    }
    return _tempPhone;
  }



  String getPhoneValidationNewEmployee(String mPhone){
    print('NANDHU AddEmployeeState getPhoneValidation mPhone length ${mPhone.length} ___________________________$mPhone');
    var _tempPhone = '';
    if(mPhone.length == 10){
      _tempPhone = mPhone;
    }else if(mPhone.length == 11){
      _tempPhone = mPhone.substring(1,mPhone.length);
    }else if(mPhone.length == 12){
      _tempPhone = mPhone.substring(2,mPhone.length);
    }else if(mPhone.length == 13){
      _tempPhone = mPhone.substring(3,mPhone.length);
    }else if(mPhone.length == 14){
      _tempPhone = mPhone.substring(4,mPhone.length);
    }else if(mPhone.length == 15){
      _tempPhone = mPhone.substring(5,mPhone.length);
    }else if(mPhone.length == 16){
      _tempPhone = mPhone.substring(6,mPhone.length);
    }else{
      _tempPhone = '-101';
    }
    return _tempPhone;
  }


  Future contactCheck(Contact contacts) async{
    print('NANDHU AddEmployeeState contactCheck');
    _mContacts = contacts;
    alreadyUserInBusiness = '';
    Iterable<Item> mPhone = contacts.phones;
    avatar = contacts.avatar;
    for (final phone in mPhone) {
      mContactPhone = phone.value;
      mContactPhone = mContactPhone.replaceAll(' ', '');
      mContactPhone = getPhoneValidation(mContactPhone.replaceAll(' ', ''));
    }
    mContactName = contacts.displayName;
    if(documents.length !=0) {
      alreadyUser = false;
      for (int i = 0; i < documents.length; i++) {
        print('NANDHU AddEmployeeState documents phoneNo____${documents[i]['phoneNo']} _____mContactPhone$mContactPhone');
        if(documents[i]['phoneNo'] != '' && documents[i]['phoneNo'] != null) {
          var _mPhone = getPhoneValidation(documents[i]['phoneNo'].toString().replaceAll(' ', ''));
          print('____________________________ $mContactPhone _____________$_mPhone');
          if (mContactPhone == _mPhone) {
              print('NANDHU AddEmployeeState documents mContactPhone____EQUAL}');
              alreadyUser = true;
              alreadyUserId = documents[i]['id'];
              alreadyUserbusinessId = documents[i]['businessId'];
              print('NANDHU AddEmployeeState documents IDDDDDDDDDDDD ___alreadyUserId___ ${alreadyUserId} ___alreadyUserbusinessId ___ ${alreadyUserbusinessId}');
              if(alreadyUserbusinessId != null && alreadyUserbusinessId == _mBusinessId)
                alreadyUserInBusiness = 'SAME';
              else if(alreadyUserbusinessId != null && alreadyUserbusinessId != '')
                alreadyUserInBusiness = 'DIFF';
              else
                alreadyUserInBusiness ='';
            } else {
              print('NANDHU AddEmployeeState documents mContactPhone____NOT___EQUAL}');
            }
        }
      }
    }
  }

  Widget buildItem(Contact contacts, int index) {
    _mContacts = contacts;
    alreadyUserInBusiness = '';
    Iterable<Item> mPhone = contacts.phones;
    avatar = contacts.avatar;
    for (final phone in mPhone) {
      mContactPhone = phone.value;
      mContactPhone = getPhoneValidation(mContactPhone.toString().replaceAll(' ', ''));
    }
    mContactName = contacts.displayName;
    if(documents.length !=0) {
      alreadyUser = false;
      for (int i = 0; i < documents.length; i++) {
        print('NANDHU AddEmployeeState buildItem ___documents phoneNo____${documents[i]['phoneNo']} _____mContactPhone$mContactPhone');
        if(documents[i]['phoneNo'] != '' && documents[i]['phoneNo'] != null) {
          print('TRIMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM ${documents[i]['phoneNo'].toString().replaceAll(' ', '')}');
          var _mPhone = getPhoneValidation(documents[i]['phoneNo'].toString().replaceAll(' ', ''));
          print('____________________________ $mContactPhone _____________$_mPhone');
          if (mContactPhone == _mPhone) {
            print('NANDHU AddEmployeeState buildItem ___documents mContactPhone____EQUAL}');
            alreadyUser = true;
            alreadyUserId = documents[i]['id'];
            alreadyUserbusinessId = documents[i]['businessId'];
            print('NANDHU AddEmployeeState buildItem ___documents IDDDDDDDDDDDD ___alreadyUserId___ ${alreadyUserId} ___alreadyUserbusinessId ___ ${alreadyUserbusinessId}_______mBusinessId __$_mBusinessId');
            if(alreadyUserbusinessId != null && alreadyUserbusinessId == _mBusinessId)
              alreadyUserInBusiness = 'SAME';
            else if(alreadyUserbusinessId != null && alreadyUserbusinessId != '')
              alreadyUserInBusiness = 'DIFF';
            else
              alreadyUserInBusiness ='';
          } else {
            print('NANDHU AddEmployeeState buildItem ___documents mContactPhone____NOT___EQUAL}');
          }
        }
      }
    }
    return GestureDetector(
      onTap: (){
      },
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
               Container(
                 margin: EdgeInsets.only(top: 10.0,left: 15.0),
                 child: /* avatar != null && avatar != '' ? Material(
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
                 ) : */Material(
                   child: new SvgPicture.asset(
                     'images/user_unavailable.svg',
                     height: 70.0,
                     width: 70.0,
                     fit: BoxFit.cover,
                   ),
                   borderRadius: BorderRadius.all(
                     Radius.circular(40.0),
                   ),
                   clipBehavior: Clip.hardEdge,
                 ),
               ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 20.0,top: 25.0),
                      child: Text(mContactName,
                        style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'GoogleSansFamily',color: black_color),),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 5.0),
                      child: Text(mContactPhone,style: TextStyle(fontWeight: FontWeight.w400,fontFamily: 'GoogleSansFamily',color: hint_color_grey_dark),),
                    ),
                  ],
                ),
                Spacer(),
                !alreadyUser && _contacts.length !=0 && _mSearchContact != 'a' ? GestureDetector(
                  onTap: (){
                    print('ADD Employeee $contacts _____________ index $index ______${_contacts.elementAt(index)}');
                    AddNewEmployee(_contacts.elementAt(index));
                  },
                  child:Container(
                    margin: EdgeInsets.only(right: 10.0,left : 0.0,top: 20.0, bottom: 0.0),
                    child:  Align(
                      alignment: Alignment.topRight,
                      child: Card(
                        elevation: 3.0,
                        shape: CircleBorder(),
                    child: new SvgPicture.asset(
                          'images/employee_invite.svg', height: 40.0,
                          width: 40.0,
                           allowDrawingOutsideViewBox: true,
                         ),
                  )
                    ),
                  )
                ): alreadyUser && _mSearchContact.length == MOBILE_NUMBER_LENGTH && _mSearchContact != 'a'? GestureDetector(
                    onTap: (){
                      print('ADD AddUserAsEmployee $alreadyUserId');
                      AddUserAsEmployee(_contacts.elementAt(index));
                    },
                    child:Container(
                  margin: EdgeInsets.only(right: 10.0, top: 20.0, bottom: 5.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child:Card(
                      elevation: 3.0,
                      shape: CircleBorder(),
                      child: new SvgPicture.asset(
                        'images/employee_add.svg', height: 40.0,
                        width: 40.0,
                        allowDrawingOutsideViewBox: true,
                      ),
                    )
                  ),
                    )
                ): GestureDetector(
                    onTap: (){
                      print('ADD Employeee $contacts _____________ index $index ______${_contacts.elementAt(index)}');
                      AddNewEmployee(_contacts.elementAt(index));
                    },
                    child:Container(
                     /* margin: EdgeInsets.only(right: 10.0,left : 0.0,top: 20.0, bottom: 0.0),
                      child:  Align(
                        alignment: Alignment.topRight,
                        child:
                            Card(
                              elevation: 13.0,
                              shape: CircleBorder(),
                      child:new SvgPicture.asset(
                          'images/employee_invite.svg', height: 60.0,
                          width: 60.0,
                          allowDrawingOutsideViewBox: true,
                        ),
                    )
                      ),*/
                    )
                )
              ],
            ),
//            Divider()
          ],
        ),
      ),
    );
  }

  Future AddNewEmployee(Contact contacts) async {
    Iterable<Item> mPhone = contacts.phones;
    Iterable<Item> mEmail = contacts.emails;
    String _mContactEmail = '';
    String _mContactPhone = '';
    for (final phone in mEmail) {
      _mContactEmail = phone.value;
    }
    avatar = contacts.avatar;
    _mContacts = contacts;
    alreadyUserInBusiness = '';
    for (final phone in mPhone) {
      _mContactPhone = phone.value;
      print('naga______________phone $_mContactPhone ');
      mContactPhone = phone.value;
      mContactPhone = getPhoneValidationNewEmployee(
          _mContactPhone.toString().replaceAll(' ', ''));
    }
    mContactName = contacts.displayName;
    if (documents.length != 0) {
      if (mContactPhone == '-101')
        Fluttertoast.showToast(msg: 'Please add a valid phone number');
      else {
        alreadyUser = false;
        for (int i = 0; i < documents.length; i++) {
          print(
              'NANDHU AddEmployeeState AddNewEmployee ___documents phoneNo____${documents[i]['phoneNo']} _____mContactPhone$mContactPhone');
          if (documents[i]['phoneNo'] != '' &&
              documents[i]['phoneNo'] != null) {
            var _mPhone = getPhoneValidation(
                documents[i]['phoneNo'].toString().replaceAll(' ', ''));
            print(
                '____________________________ $mContactPhone _____________$_mPhone');
            if (mContactPhone == _mPhone) {
              print(
                  'NANDHU AddEmployeeState AddNewEmployee ___documents mContactPhone____EQUAL}');
              alreadyUser = true;
              alreadyUserId = documents[i]['id'];
              alreadyUserbusinessId = documents[i]['businessId'];
              print(
                  'NANDHU AddEmployeeState AddNewEmployee ___documents IDDDDDDDDDDDD ___alreadyUserId___ ${alreadyUserId} ___alreadyUserbusinessId ___ ${alreadyUserbusinessId}_________mBusinessId__$_mBusinessId');
              if (alreadyUserbusinessId != null &&
                  alreadyUserbusinessId == _mBusinessId)
                alreadyUserInBusiness = 'SAME';
              else
              if (alreadyUserbusinessId != null && alreadyUserbusinessId != '')
                alreadyUserInBusiness = 'DIFF';
              else
                alreadyUserInBusiness = '';
            } else {
              print(
                  'NANDHU AddEmployeeState AddNewEmployee___documents mContactPhone____NOT___EQUAL');
            }
          }
        }
      }
    }
    if (mContactPhone != '-101') {
      DocumentReference reference = Firestore.instance.collection('users')
          .document();
      print(
          'NANDHU AddEmployeeState AddNewEmployee Reference check ___alreadyUserInBusiness_${alreadyUserInBusiness}');
      setState(() {
        isLoading = true;
      });
      if (alreadyUserInBusiness == 'SAME') {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Already employee in this business');
        Navigator.pop(context);
      } else if (alreadyUserInBusiness == 'DIFF') {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: 'Already employee in this  some other business');
        Navigator.pop(context);
      } else {
        print(
            'NANDHU AddEmployeeState AddNewEmployee Reference check ___alreadyUserInBusiness_ELSEEEEEEEEEEEEEEEEE___${reference
                .documentID}');
        alreadyUserInBusiness = 'SAME';
        try {

          /*Firestore.instance.runTransaction((
            transaction) async {
          await transaction.set(
            reference,
            {
              'name': contacts.displayName,
//      'photoUrl': _mUserPhotoUrl,
              'email': _mContactEmail,
              'nickName': contacts.middleName,
              'phoneNo': COUNTRY_CODE + "\t" + _mContactPhone,
              'status': '',
              'id': reference.documentID,
              'MobileNumber': reference.documentID,
              'user_token': '',
              'businessId': _mBusinessId,
              'businessType' : BUSINESS_TYPE_EMPLOYEE,
              'businessName' : _mBusinessName,
              'businessChatPeriority' : 0,
              'photoUrl' : '',
              'createdAt':
              ((new DateTime.now()
                  .toUtc()
                  .microsecondsSinceEpoch) / 1000).toInt()
            },
          );
        })*/
          reference.setData({
            'name': contacts.displayName,
//      'photoUrl': _mUserPhotoUrl,
            'email': _mContactEmail,
            'nickName': contacts.middleName,
            'phoneNo': COUNTRY_CODE + "\t" + _mContactPhone,
            'status': '',
            'id': reference.documentID,
            'MobileNumber': reference.documentID,
            'user_token': '',
            'businessId': _mBusinessId,
            'businessType': BUSINESS_TYPE_EMPLOYEE,
            'businessName': _mBusinessName,
            'businessChatPeriority': 0,
            'photoUrl': '',
            'createdAt':
            ((new DateTime.now()
                .toUtc()
                .microsecondsSinceEpoch) / 1000).toInt()
          }).whenComplete(() async {
            UserLocation currentLocation = await LocationService('','','')
                .getLocation();
            print(
                'NANDHU AddEmployeeState AddNewEmployee Reference LOCATIon UPDATE${currentLocation}');
            Firestore.instance.collection('users').document(
                reference.documentID).collection(
                'userLocation').document(reference.documentID).setData({
              'userLocation':
              new GeoPoint(currentLocation.latitude, currentLocation.longitude),
              'UpdateTime': ((new DateTime.now()
                  .toUtc()
                  .microsecondsSinceEpoch) / 1000).toInt(),
            }).whenComplete(() {
              print(
                  'NANDHU AddEmployeeState AddNewEmployee Reference load users');
              loadUsers();
            }).whenComplete(() {
              print(
                  'NANDHU AddEmployeeState AddNewEmployee Reference Employee count');
              if (_noOfEmployee == null)
                _noOfEmployee = 0;
              _noOfEmployee = _noOfEmployee + 1;
              Firestore.instance.collection('business')
                  .document(_mBusinessId)
                  .updateData({
                'employeeCount': _noOfEmployee,
              });
              setState(() {
                isLoading = false;
              });
              prefs.setInt('BUSINESS_EMPLOYEES_COUNT', _noOfEmployee);
              Navigator.pop(context);

              String message = "You are added in the " + "business";
              print('NAndhini Ndot addemployee ${COUNTRY_CODE + "\t" +
                  _mContactPhone} _______');
              List<String> recipents = [COUNTRY_CODE + "\t" + _mContactPhone,];
              _sendSMS(message, recipents);


              Fluttertoast.showToast(
                  msg: 'Business employee added successfully');
            });
          });
        } on Exception catch (e) {
          setState(() {
            isLoading = false;
          });
          print(
              'NANDHU AddEmployeeState AddNewEmployee Reference Could not add employee:  ${e
                  .toString()}');
        }
        /* Firestore.instance.runTransaction((
        transaction) async {
      await transaction.set(
        reference,
        {
          'name': contacts.displayName,
//          'photoUrl': _mUserPhotoUrl,
          'email': _mUserEmail,
          'nickName': contacts.middleName,
          'phoneNo': COUNTRY_CODE+"\t"+_mUserPhone,
          'status': '',
          'id': reference.documentID,
          'MobileNumber': reference.documentID,
          'user_token': '',
          'businessId' : _mBusinessId,
          'createdAt':
          ((new DateTime.now()
              .toUtc()
              .microsecondsSinceEpoch) / 1000).toInt()
        },
      );
    });*/

      }
    }else{
      Navigator.pop(context);
    }
  }

  Future AddUserAsEmployee(Contact contacts) async{
    _mContacts = contacts;
    alreadyUserInBusiness = '';
    Iterable<Item> mPhone = contacts.phones;
    avatar = contacts.avatar;
    for (final phone in mPhone) {
      mContactPhone = phone.value;
      mContactPhone = getPhoneValidation(mContactPhone.toString().replaceAll(' ', ''));
    }
    mContactName = contacts.displayName;
      if(documents.length !=0) {
        alreadyUser = false;
        for (int i = 0; i < documents.length; i++) {
          print('NANDHU AddEmployeeState AddUserAsEmployee ___documents phoneNo____${documents[i]['phoneNo']} _____mContactPhone$mContactPhone');
          if(documents[i]['phoneNo'] != '' && documents[i]['phoneNo'] != null) {
            var _mPhone = getPhoneValidation(documents[i]['phoneNo'].toString().replaceAll(' ', ''));
            print('____________________________ $mContactPhone _____________$_mPhone');
            if (mContactPhone == _mPhone) {
              print('NANDHU AddEmployeeState AddUserAsEmployee ___documents mContactPhone____EQUAL}');
              alreadyUser = true;
              alreadyUserId = documents[i]['id'];
              alreadyUserbusinessId = documents[i]['businessId'];
              print('NANDHU AddEmployeeState AddUserAsEmployee ___documents IDDDDDDDDDDDD ___alreadyUserId___ ${alreadyUserId} ___alreadyUserbusinessId ___ ${alreadyUserbusinessId} ____mBusinessId $_mBusinessId');
              if(alreadyUserbusinessId != null && alreadyUserbusinessId == _mBusinessId)
                alreadyUserInBusiness = 'SAME';
              else if(alreadyUserbusinessId != null && alreadyUserbusinessId != '')
                alreadyUserInBusiness = 'DIFF';
              else
                alreadyUserInBusiness ='';
            } else {
              print('NANDHU AddEmployeeState AddUserAsEmployee ___documents mContactPhone____NOT___EQUAL');
            }
          }
        }
    }
    print('NANDHU AddEmployeeState AddUserAsEmployee ___alreadyUserInBusiness  $alreadyUserInBusiness');

    if(alreadyUserInBusiness == 'SAME'){
      Fluttertoast.showToast(msg: 'Already user in this business');
      Navigator.pop(context);
    } else if( alreadyUserInBusiness == 'DIFF'){
      Fluttertoast.showToast(msg: 'Already user in this  some other business');
      Navigator.pop(context);
    }else {
      print('NANDHU AddEmployeeState AddUserAsEmployee ___alreadyUserId $alreadyUserId');
      Firestore.instance.collection('users')
          .document(alreadyUserId)
          .updateData({
        'businessId': _mBusinessId,
        'businessType': BUSINESS_TYPE_EMPLOYEE,
        'businessName' : _mBusinessName
      }).whenComplete((){
        print('NANDHU AddEmployeeState AddUserAsEmployee ___employeeCount');
        if(_noOfEmployee == null )
          _noOfEmployee = 0;
        _noOfEmployee = _noOfEmployee + 1;
        alreadyUserInBusiness = 'SAME';
        Firestore.instance.collection('business')
            .document(_mBusinessId)
            .updateData({
          'employeeCount': _noOfEmployee,
        });
        prefs.setInt('BUSINESS_EMPLOYEES_COUNT', _noOfEmployee);
        Iterable<Item> mPhones = contacts.phones;
        String _mUserPhone = '';
        for (final phone in mPhones) {
          _mUserPhone = phone.value;
        }

        String message = "You are added in the "+"business";
        print('NAndhini Ndot addemployee ${_mUserPhone} _______');
        List<String> recipents = [_mUserPhone,];
        _sendSMS(message, recipents);
        Navigator.pop(context);
      });
    }
  }


  void _sendSMS(String message, List<String> recipents) async {
    print('SEND SMSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS');
    String _result = await FlutterSms
        .sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
 /*   String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
      Fluttertoast.showToast(msg: 'onError $onError');
    });
    print(_result);
    Fluttertoast.showToast(msg: '_result $_result');*/
  }
}