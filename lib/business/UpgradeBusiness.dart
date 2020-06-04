import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/constants.dart';
import 'package:virus_chat_app/utils/strings.dart';

class UpgradeBusiness extends StatefulWidget {
  String _mUserId = '';

  @override
  State<StatefulWidget> createState() {
    return UpgradeBusinessState(_mUserId);
  }

  UpgradeBusiness(String userId) {
    _mUserId = userId;
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
  String businessName = '';
  String businessAddress = '';
  String businessNumber = '';
  String _ownerName = '';

  SharedPreferences preferences;

  UpgradeBusinessState(String mUserId) {
    userId = mUserId;
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
    controllerAddress = new TextEditingController(text: businessAddress);
    controllerNumber = new TextEditingController(text: businessNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
              children: <Widget>[
                Container(
                  color: button_fill_color,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: 150,
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
                          child: Text(upgrade_business, style: TextStyle(
                              color: text_color,
                              fontSize: TOOL_BAR_TITLE_SIZE,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'GoogleSansFamily'),)
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
                      .height - 100,
                  decoration: BoxDecoration(
                      color: text_color,
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(20.0),
                        topRight: const Radius.circular(20.0),
                      )
                  ),
                  child: SingleChildScrollView(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Center(
                                child: Stack(
                                  children: <Widget>[
                                    (avatarImageFile == null)
                                        ? (photoUrl != null &&
                                        photoUrl != ''
                                        ? GestureDetector(
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
                                    photoUrl == '' ? IconButton(
                                      icon: new SvgPicture.asset(
                                        'images/camera.svg',
                                        height: 35.0,
                                        width: 35.0,
                                        fit: BoxFit.cover,
                                      ),
                                      onPressed: getImage,
                                      padding: EdgeInsets.all(40.0),
                                      splashColor: Colors.transparent,
                                      highlightColor: greyColor,
                                      iconSize: 20.0,
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
                                Container(
                                  margin: EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                  ),
                                  child: Text(business_name.toUpperCase(),
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansFamily',
                                        color: text_color_grey,
                                        fontSize: 12.0),),
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
                                      hintText: 'Enter business name',
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
                                      left: 10.0, right: 10.0, top: 5.0),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      right: 10.0,
                                      top: 30.0),
                                  child: Text(business_address.toUpperCase(),
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansFamily',
                                        color: text_color_grey,
                                        fontSize: 12.0),),
                                ),
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
                                        hintText: 'Enter business address',
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
                                        left: 10.0, right: 10.0, top: 5.0),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 10.0,
                                      right: 10.0,
                                      top: 30.0),
                                  child: Text(business_number.toUpperCase(),
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansFamily',
                                        color: text_color_grey,
                                        fontSize: 12.0),),
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
                                      hintText: 'Enter business Number',
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
                                      left: 10.0, right: 10.0, top: 5.0),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                children: <Widget>[
                                  SizedBox(
                                    height: 45.0,
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width / 2 - 20,
                                    child: RaisedButton(
                                        color: white_color,
                                        textColor: button_fill_color,
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
                                    ),
                                  ),
                                  SizedBox(
                                      height: 45.0,
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width / 2 - 20,
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
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )
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
          'ownerName': _ownerName,
          'createdAt': currTime
        }).whenComplete(() =>
        {
          Firestore.instance.collection('users').document(userId).updateData({
            'businessId': reference.documentID,
            'businessType': BUSINESS_TYPE_OWNER
          })
        }).whenComplete(() => {
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

    /*  UserLocation currentLocation = await LocationService(reference.documentID)
          .getLocation();*/
     /* Firestore.instance.collection('users').document(reference.documentID)
          .collection('userLocation').document(reference.documentID)
          .setData({
        'userLocation': new GeoPoint(
            currentLocation.latitude, currentLocation.longitude),
      });*/
      await preferences.setString('BUSINESS_ID', reference.documentID);
      await preferences.setString('BUSINESS_NAME', businessName);
      await preferences.setString('BUSINESS_ADDRESS', businessAddress);
      await preferences.setString(
          'BUSINESS_NUMBER', COUNTRY_CODE + businessNumber);
      await preferences.setString('BUSINESS_IMAGE', photoUrl);
      await preferences.setString('BUSINESS_TYPE', BUSINESS_TYPE_OWNER);
      await preferences.setInt('BUSINESS_EMPLOYEES_COUNT', 0);
      await preferences.setString('BUSINESS_CREATED_AT', currTime.toString());

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProfilePageSetup(_signInType,currentUserId: userId,)));
    }
  }

  Future businessValidation() async {
    if (photoUrl == '') {
      Fluttertoast.showToast(msg: 'Enter business profile image');
    } else if (businessName == '') {
      Fluttertoast.showToast(msg: 'Enter business name');
    } else if (businessAddress == '') {
      Fluttertoast.showToast(msg: 'Enter business address');
    }
    /*else if(businessNumber == ''){
      Fluttertoast.showToast(msg: 'Enter business number');
    }*/ else {
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
