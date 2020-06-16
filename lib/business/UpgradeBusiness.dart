import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

//import 'package:flutter_google_places/flutter_google_places.dart';
//import 'package:google_maps_webservice/places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:virus_chat_app/profile/ProfilePage.dart';
import 'file:///C:/Users/Nandhini%20S/Documents/virus_chat_app/lib/homePage/UsersList.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/constants.dart';
import 'package:virus_chat_app/utils/strings.dart';

class UpgradeBusiness extends StatefulWidget {
  String _mUserId = '';
  String _mCurrentLoginType = '';

  @override
  State<StatefulWidget> createState() {
    return UpgradeBusinessState(_mUserId, _mCurrentLoginType);
  }

  UpgradeBusiness(String userId, String mCurrentLoginType) {
    _mUserId = userId;
    _mCurrentLoginType = mCurrentLoginType;
  }

}

class UpgradeBusinessState extends State<UpgradeBusiness> {
  File avatarImageFile;
  String photoUrl = '';
  bool isLoading = false;
  String userId = '';
  String _signInType = '';
  TextEditingController controllerName;
  TextEditingController controllerAddress;
  TextEditingController controllerNumber;
  TextEditingController controllerInfo;
  String businessName = '';
  String businessAddress = '';
  String businessInfo = '';
  String businessNumber = '';
  String _ownerName = '';

  SharedPreferences preferences;
  String _mCurrentLoginType;

  UpgradeBusinessState(String mUserId, String mCurrentLoginType) {
    userId = mUserId;
    _mCurrentLoginType = mCurrentLoginType;
  }

  @override
  void initState() {
    initialise();
    super.initState();
  }

  Future initialise() async {
    preferences = await SharedPreferences.getInstance();
    _ownerName = await preferences.getString('name');
    _signInType = await preferences.getString('signInType');
    controllerName = new TextEditingController(text: businessName);
    controllerInfo = new TextEditingController(text: businessInfo);
    controllerAddress = new TextEditingController(text: businessAddress);
    controllerNumber = new TextEditingController(text: businessNumber);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          /*    decoration: BoxDecoration(
                      color: text_color,
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(20.0),
                        topRight: const Radius.circular(20.0),
                      )
                  ),*/
          SingleChildScrollView(
              child: Container(
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment
                                .start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 42.0,
                                    bottom: 10.0),
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
                                      top: 55.0, right: 10.0, bottom: 10.0),
                                  child: Text(upgrade_business,
                                    style: TextStyle(
                                        color: black_color,
                                        fontSize: TOOL_BAR_TITLE_SIZE,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'GoogleSansFamily'),)
                              ),
                            ],
                          ),
                          Divider(color: divider_color, thickness: 1.0,),
                        ],
                      ),
                      Container(
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              (avatarImageFile == null)
                                  ? (photoUrl != null &&
                                  photoUrl != ''
                                  ? Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        45.0),border: Border.all(color: profile_image_border_color)
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    print('getImage');
                                  },
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
                                            padding: EdgeInsets.all(
                                                20.0),
                                          ),
                                      imageUrl: photoUrl,
                                      width: 70.0,
                                      height: 70.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(45.0)),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                ),
                              )
                                  : Container(
                                  width: 100.0,
                                  height: 100.0,
                                  child: IconButton(
                                    icon: new SvgPicture.asset(
                                      'images/user_unavailable.svg',
                                      height: 70.0,
                                      width: 70.0,
                                      fit: BoxFit.cover,
                                    ),
                                    onPressed: () {
                                      getImage();
                                    },))

                              ) : GestureDetector(
                                onTap: () {
                                  print('getImage');
                                  getImage();
                                },
                                child: Material(
                                  child: Image.file(
                                    avatarImageFile,
                                    width: 70.0,
                                    height: 70.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          45.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                              ),
                              photoUrl == '' || photoUrl != '' ? IconButton(
                                icon: new SvgPicture.asset(
                                  'images/camera.svg',
                                  height: 35.0,
                                  width: 35.0,
                                  fit: BoxFit.cover,
                                ),
                                onPressed: getImage,
                                padding: EdgeInsets.all(photoUrl == '' ?40.0 : 30.0),
                                splashColor: Colors.transparent,
                                highlightColor: greyColor,
                                iconSize: 15.0,
                              ) : Text('')
                            ],
                          ),
                        ),
                        width: double.infinity,
                        margin: EdgeInsets.all(20.0),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          /*Container(
                                  margin: EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                  ),
                                  child: Text(business_name.toUpperCase(),
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansFamily',
                                        color: text_color_grey,
                                        fontSize: 12.0),),
                                ),*/
                          Container(
                            child: TextField(
                              decoration: new InputDecoration(
                                contentPadding: new EdgeInsets.all(
                                    15.0),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: focused_border_color,
                                      width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: greyColor, width: 0.5),
                                ),
                                labelText: 'Business name',
                                hintStyle: TextStyle(
                                    fontSize: HINT_TEXT_SIZE,
                                    fontFamily: 'GoogleSansFamily',
                                    color: text_color_grey),
                              ),
                              controller: controllerName,
                              onChanged: (value) {
                                businessName = value;
                              },
                            ),
                            margin: EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 5.0),
                          ),
                          /* Container(
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      right: 10.0,
                                      top: 30.0),
                                  child: Text(business_address.toUpperCase(),
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansFamily',
                                        color: text_color_grey,
                                        fontSize: 12.0),),
                                ),*/
                          GestureDetector(
                            onTap: () {

                            },
                            child: Container(
                              child: TextField(
                                decoration: new InputDecoration(
                                  contentPadding: new EdgeInsets.all(
                                      15.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: focused_border_color,
                                        width: 0.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: greyColor, width: 0.5),
                                  ),
                                  labelText: 'Business address',
                                  hintStyle: TextStyle(
                                      fontSize: HINT_TEXT_SIZE,
                                      fontFamily: 'GoogleSansFamily',
                                      color: text_color_grey),
                                ),
                                controller: controllerAddress,
                                onChanged: (value) {
                                  businessAddress = value;
                                },
                              ),
                              margin: EdgeInsets.only(
                                  left: 20.0, right: 20.0, top: 30.0),
                            ),
                          ),
                          /*Container(
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      right: 10.0,
                                      top: 30.0),
                                  child: Text(business_number.toUpperCase(),
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansFamily',
                                        color: text_color_grey,
                                        fontSize: 12.0),),
                                ),*/
                          Container(
                            child: TextField(
                              decoration: new InputDecoration(
                                contentPadding: new EdgeInsets.all(
                                    15.0),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: focused_border_color,
                                      width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: greyColor, width: 0.5),
                                ),
                                labelText: 'Business number',
                                hintStyle: TextStyle(
                                    fontSize: HINT_TEXT_SIZE,
                                    fontFamily: 'GoogleSansFamily',
                                    color: text_color_grey),
                              ),
                              controller: controllerNumber,
                              onChanged: (value) {
                                businessNumber = value;
                              },
                              keyboardType: TextInputType.phone,
                            ),
                            margin: EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 30.0),
                          ),
                          Container(
                            child: TextField(
                              decoration: new InputDecoration(
                                contentPadding: new EdgeInsets.all(
                                    15.0),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: focused_border_color,
                                      width: 0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: greyColor, width: 0.5),
                                ),
                                labelText: 'Business description',
                                hintStyle: TextStyle(
                                    fontSize: HINT_TEXT_SIZE,
                                    fontFamily: 'GoogleSansFamily',
                                    color: text_color_grey),
                              ),
                              controller: controllerInfo,
                              onChanged: (value) {
                                businessInfo = value;
                              },
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                            ),
                            margin: EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 30.0),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 30.0, bottom: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment
                              .spaceEvenly,
                          children: <Widget>[
                          GestureDetector(
                                onTap: (){
                                  Navigator.of(context).pop();
                                },
                                child:Container(
//                                  color: white_color,
                                  height: 45.0,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width / 2 - 20,
                                  decoration: BoxDecoration(
                                      color: white_color, borderRadius: BorderRadius.circular(
                                      30.0),border: Border.all(color: button_fill_color)
                                  ),
                                  child:
                                  Container(
                                    margin: EdgeInsets.only(top: 13.0),
                                    child: Text(business_cancel,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400,color: button_fill_color),),
                                    ), /* Text(business_cancel,
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400),),*/
                                )
                              ),

                              /*RaisedButton(
                                  color: white_color,
                                  textColor: button_fill_color,
                                  highlightColor: button_fill_color,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: new BorderRadius
                                        .circular(
                                        30.0),
                                  ),
                                  child: Text(business_cancel,
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansFamily'),),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }
                              ),*/
                         /*   SizedBox(
                                height: 45.0,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 2 - 40,
                                child: RaisedButton(
                                    color: button_fill_color,
                                    textColor: text_color,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius
                                          .circular(
                                          30.0),
                                    ),
                                    child: Text(business_upgrade,
                                      style: TextStyle(
                                          fontFamily: 'GoogleSansFamily'),),
                                    onPressed: () {
                                      businessValidation();
                                    }
                                )
                            )*/
                            GestureDetector(
                                onTap: (){
                                  businessValidation();
                                },
                                child:Container(
//                                  color: white_color,
                                  height: 45.0,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width / 2 - 20,
                                  decoration: BoxDecoration(
                                      color: button_fill_color, borderRadius: BorderRadius.circular(
                                      30.0),border: Border.all(color: button_fill_color)
                                  ),
                                  child:
                                  Container(
                                    margin: EdgeInsets.only(top: 13.0),
                                    child: Text(business_upgrade,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400,color: white_color),),
                                  ), /* Text(business_cancel,
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400),),*/
                                )
                            ),
                          ],
                        ),
                      )
                    ],
                  )
              )
          ),
          Positioned(
            child: isLoading
                ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(progress_color)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
                : Container(),
          ),
        ],
      ),
    );
  }


  Future addBusiness() async {
    isLoading = true;
    if ((businessNumber != '') ||
        (businessName != '' && businessAddress != '' && photoUrl != '')) {
      int currTime = ((new DateTime.now()
          .toUtc()
          .microsecondsSinceEpoch) / 1000).toInt();
      DocumentReference reference = Firestore.instance.collection('business')
          .document();
      print('_______________________________addBusiness');
      try {
        /*  Firestore.instance.runTransaction((
           transaction) async {
         await transaction.set(
           reference,
           {
             'businessName': businessName,
             'photoUrl': photoUrl,
             'businessNumber': COUNTRY_CODE+businessNumber,
             'businessAddress': businessAddress,
             'businessId': reference.documentID,
             'ownerName' :_ownerName,
             'createdAt':currTime
           },
         );
       });*/

        reference.setData({
          'businessName': businessName,
          'photoUrl': photoUrl,
          'businessNumber': COUNTRY_CODE + businessNumber,
          'businessAddress': businessAddress,
          'businessId': reference.documentID,
          'businessDescription': businessInfo,
          'ownerName': _ownerName,
          'createdAt': currTime,
          'businessChatPeriority': 0,
          'employeeCount': 0,
          'businessDistance' :'0',
          'status':'ACTIVE'
        }).whenComplete(() =>
        {
          Firestore.instance.collection('users').document(userId).updateData({
            'businessId': reference.documentID,
            'businessType': BUSINESS_TYPE_OWNER,
            'businessName':businessName
          })
        }).whenComplete(() =>
        {
          isLoading = false,
//            Navigator.pop(context, true)
        });
      } on Exception catch (e) {
        isLoading = false;
        print('Could not get Add businesss: ${e.toString()}');
      }
      /*reference.setData({
        'businessName': businessName,
        'photoUrl': photoUrl,
        'businessNumber': businessNumber,
        'businessAddress': businessAddress,
        'businessId': reference.documentID,
        'createdAt':currTime
      });*/
      UserLocation currentLocation = await LocationService(
          reference.documentID, BUSINESS_TYPE_OWNER, reference.documentID)
          .getLocation();
      Firestore.instance.collection('business').document(reference.documentID)
          .collection('businessLocation').document(reference.documentID)
          .setData({
        'businessLocation': new GeoPoint(
            currentLocation.latitude, currentLocation.longitude),
      });
      await preferences.setString('BUSINESS_ID', reference.documentID);
      await preferences.setString('BUSINESS_NAME', businessName);
      await preferences.setString('BUSINESS_ADDRESS', businessAddress);
      await preferences.setString(
          'BUSINESS_NUMBER', COUNTRY_CODE + businessNumber);
      await preferences.setString(
          'BUSINESS_INFO', businessInfo);
      await preferences.setString('BUSINESS_IMAGE', photoUrl);
      await preferences.setString('BUSINESS_TYPE', BUSINESS_TYPE_OWNER);
      await preferences.setInt('BUSINESS_EMPLOYEES_COUNT', 0);
      await preferences.setString('BUSINESS_CREATED_AT', currTime.toString());

      if (_mCurrentLoginType == 'business') {
        LocationService(userId, '', '');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    UsersList(_signInType,
                        userId, photoUrl)));
      } else {
        LocationService(userId, '', '');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProfilePageSetup(_signInType, currentUserId: userId,)));
      }
    }
  }

  Future businessValidation() async {
    if (photoUrl == '') {
      Fluttertoast.showToast(msg: 'Enter business profile image');
    } else if (businessName == '') {
      Fluttertoast.showToast(msg: 'Enter business name');
    } else if (businessAddress == '') {
      Fluttertoast.showToast(msg: 'Enter business address');
    } else if (businessInfo == '') {
      Fluttertoast.showToast(msg: 'Enter business description');
    }
    else if (businessNumber == '') {
      Fluttertoast.showToast(msg: 'Enter business number');
    } else {
      await addBusiness();
    }
  }

  Future showPlaces() async {
    print('showPlaces');
//   await _handlePressButton();
  }

/*

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  Mode _mode = Mode.overlay;
  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _handlePressButton() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: _mode,
      language: "in",
      components: [Component(Component.country, "in")],
    );

    displayPrediction(p, homeScaffoldKey.currentState);
  }


  void onError(PlacesAutocompleteResponse response) {
    print('showPlaces error Res ${response.errorMessage}');
    */
/*homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );*/ /*

  }

Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
  print('showPlaces Prediction ${p.placeId}');

  if (p != null) {
    // get detail (lat/lng)
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;
    print('showPlaces correct Res ${p.description} ____lat ${lat} ___ lng $lng');

//    businessAddress = p.description;
    controllerAddress.text = businessAddress;
//    controllerAddress = new TextEditingController(text: businessAddress);
  */
/*  scaffold.showSnackBar(
      SnackBar(content: Text("${p.description} - $lat/$lng")),
    );*/ /*

  }
}
*/

  Future getImage() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 20);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = userId + 'business';
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          print('DOWNLOAD URL PROFILE $photoUrl');
          Fluttertoast.showToast(msg: "Profile picture updated successfully");
          setState(() {
            isLoading = false;
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

}
