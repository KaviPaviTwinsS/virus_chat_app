import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';

//import 'package:draggable_floating_button/draggable_floating_button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:virus_chat_app/homePage/NearByBusinessList.dart';

import 'package:virus_chat_app/homePage/NearByUsersList.dart';
//import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/FriendRequestScreen.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/SendInviteScreen.dart';
import 'package:virus_chat_app/business/BusinessData.dart';
import 'package:virus_chat_app/business/BusinessDetailPage.dart';
import 'package:virus_chat_app/business/BusinessPage.dart';
import 'package:virus_chat_app/business/UsersData.dart';
import 'package:virus_chat_app/chat/RecentChatsScreen.dart';
import 'package:virus_chat_app/chat/chat.dart';
import 'package:virus_chat_app/profile/ProfilePage.dart';
import 'package:virus_chat_app/rangeSlider/RangeSliderPage.dart';
import 'package:virus_chat_app/tweetPost/MakeTweetPost.dart';
import 'package:virus_chat_app/tweetPost/NewTweetPost.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/constants.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;

/*
class UsersList extends StatelessWidget {
  String currentUser = '';
  String userSignInType = '';
  String mphotoUrl = '';

  UsersList(String signinType, String userId, String photoUrl) {
    currentUser = userId;
    userSignInType = signinType;
    mphotoUrl = photoUrl;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: app_name,
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
      home: UsersListPage(currentUser, userSignInType, mphotoUrl),
    );
  }
}*/

class UsersList extends StatefulWidget {
  String currentUserId = '';
  String signInType = '';
  String mphotoUrl = '';

  UsersList(String currentUser, String userSignInType, String photoUrl) {
    currentUserId = currentUser;
    signInType = userSignInType;
    mphotoUrl = photoUrl;
  }

  @override
  State<StatefulWidget> createState() {
    return UsersListState(currentUserId, signInType, mphotoUrl);
  }
}

class UsersListState extends State<UsersList>
    implements SliderListenerUpdate {
  String currentUserPhotoUrl = '';
  String currentUserName = '';
  String currentUser = '';
  String userSignInType = '';
  SharedPreferences prefs;
  bool sliderChanged = true;
  double _msliderData = 100.0;

  String _currentUserBusinessId = '';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  UsersListState(String currentUserId, String signInType, String mphotoUrl) {
    print('Friend Request Build__________  UsersListState$currentUserId');
    currentUser = currentUserId;
    userSignInType = signInType;
    currentUserPhotoUrl = mphotoUrl;
  }

  @override
  void initState() {
    initialise();
    super.initState();
  }

  Future initialise() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('USERSTATUS', 'LOGIN');
    currentUserName = await prefs.getString('name');
    currentUser = await prefs.getString('userId');
    currentUserPhotoUrl = await prefs.getString('photoUrl');
    _currentUserBusinessId = await prefs.getString('BUSINESS_ID');
    if (userSignInType == '') {
      userSignInType = await prefs.getString('signInType');
    }
    if (currentUserPhotoUrl == '') {
      currentUserPhotoUrl = await prefs.getString('photoUrl');
    }
//    print('USERLIST name_____ $currentUserName');

    if (currentUser != '' && currentUser != null) {
      var query = await Firestore.instance.collection('users')
          .document(currentUser).collection(
          'userLocation').document(currentUser).get();
//      print('User Update status ___ ${currentUser} ___ ${query['UpdateTime']}');
      int currentTime = ((new DateTime.now()
          .toUtc()
          .microsecondsSinceEpoch) / 1000).toInt();

      /*  if (currentUser != '') {
      print(
          'USER STATUS_______________ $currentTime _____ ${query['UpdateTime']}');
      if (currentTime > query['UpdateTime']) {
        Firestore.instance
            .collection('users')
            .document(currentUser)
            .updateData({'status': 'INACTIVE'});
      } else {
        Firestore.instance
            .collection('users')
            .document(currentUser)
            .updateData({'status': 'ACTIVE'});
      }
    }*/
      /*for(int i=5;i<250;i+5){
      spinnerItems.add('$i m');
    }*/
    }
    setState(() {});
  }

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  int _curIndex = 0;

  bool homeClicked = true;

  String dropdownValue = '5m';

  int value = 0;
  List<String> spinnerItems = new List<String>();


  void test() async {
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
//    try {
    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      identifier = build.id.toString();
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      identifier = data.identifierForVendor; //UUID for iOS
    }
    print('IDENTIFIER $identifier');
//    } on PlatformException {
//      print('Failed to get platform version');
//    }
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    firebaseMessaging.getToken().then((token) {
      print('--- Firebase toke here ---');
//      Firestore.instance.collection(currentUser).document(identifier).setData({ 'token': token});
      print(token);
    });
  }

/*


  Future onSelectNotification(String payload) async {
    if(notifyId == '1000'*/ /* && !isOpened*/ /*) {
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
  }*/
/*
  void initializeNotify() async{
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }*/
  Future<void> _showSoundUriNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }


  @override
  Widget build(BuildContext context) {
    print('Friend Request Build__________  MAINNNN');
//    initialise();
    return WillPopScope(
      onWillPop: () async => Future.value(false),
      child: new Scaffold(
        /* floatingActionButton: SpeedDial(
            animatedIcon: AnimatedIcons.menu_close,
            animatedIconTheme: IconThemeData(size: 22.0),
            // this is ignored if animatedIcon is non null
//             child: Icon(Icons.add),
            visible: false,
            curve: Curves.easeInCirc,
            overlayColor: Colors.black,
            overlayOpacity: 0.5,
            onOpen: () => print('OPENING DIAL'),
            onClose: () => print('DIAL CLOSED'),
            tooltip: 'Speed Dial',
            heroTag: 'speed-dial-hero-tag',
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 8.0,
            shape: CircleBorder(),
            children: [
              SpeedDialChild(
                  child: Icon(Icons.accessibility),
                  backgroundColor: Colors.red,
                  label: 'First',
                  labelStyle: TextStyle(fontSize: 18.0),
                  onTap: () => print('FIRST CHILD')
              ),
              SpeedDialChild(
                child: Icon(Icons.brush),
                backgroundColor: Colors.blue,
                label: 'Second',
                labelStyle: TextStyle(fontSize: 18.0),
                onTap: () => print('SECOND CHILD'),
              ),
              SpeedDialChild(
                child: Icon(Icons.keyboard_voice),
                backgroundColor: Colors.green,
                label: 'Third',
                labelStyle: TextStyle(fontSize: 18.0),
                onTap: () => print('THIRD CHILD'),
              ),
            ],
          ),*/
          bottomNavigationBar: SizedBox(
            height: 70,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _curIndex,
              backgroundColor: white_color,
              // this will be set when a new tab is tapped
              onTap: (index) {
                setState(() {
                  print('CURENT IDEX____ $index');
                  _curIndex = index;
                  switch (_curIndex) {
                    case 0:
                      setState(() {
                        homeClicked = true;
                      });
                      break;
                    case 1:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BusinessPage()));
                      break;
                    case 2:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NewTweetPost(
                                      currentUser, currentUserPhotoUrl)));
                      break;
                    case 3:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MakeTweetPost(
                                      currentUser, currentUserPhotoUrl)));
                      break;
                  }
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: homeClicked ? Container(
                    margin: EdgeInsets.only(top: 15.0),
                    child: new SvgPicture.asset(
                      'images/home_highlight.svg',
                      height: 20.0,
                      width: 20.0,
                    ),
                  ) : Container(
                    margin: EdgeInsets.only(top: 15.0),
                    child: new SvgPicture.asset(
                      'images/home.svg',
                      height: 20.0,
                      width: 20.0,
                    ),
                  ),
                  title: new Text(''),
                ),
                BottomNavigationBarItem(
                    title: new Text(''),
                    icon: Container(
                      margin: EdgeInsets.only(top: 15.0),
                      child: new SvgPicture.asset(
                        'images/business.svg',
                        height: 20.0,
                        width: 20.0,
                      ),
                    )
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    margin: EdgeInsets.only(top: 15.0),
                    child: new SvgPicture.asset(
                      'images/post.svg', height: 20.0,
                      width: 20.0,
                    ),
                  ),
                  title: new Text(''),
                ),
                BottomNavigationBarItem(
                    icon: Container(
                      margin: EdgeInsets.only(top: 15.0),
                      child: new SvgPicture.asset(
                        'images/community.svg', height: 20.0,
                        width: 20.0,
                      ),
                    ),
                    title: Text('')
                ),

              ],
            ),
          ),
          body: /*OfflineBuilder(
              connectivityBuilder: (BuildContext context,
                  ConnectivityResult connectivity,
                  Widget child,) {
                final bool connected = connectivity != ConnectivityResult.none;
                return new Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      height: 24.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        color: connected ? Color(0xFF00EE44) : Color(
                            0xFFEE4400),
                        child: Center(
                          child: Text("${connected ? 'ONLINE' : 'OFFLINE'}"),
                        ),
                      ),
                    ),*/
          Stack(
            children: <Widget>[

              SingleChildScrollView(
                child: Container(
                    color: button_fill_color,
                    height: 180,
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.only(
                                  left: 15.0, top: 20.0, right: 10.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          new ProfilePageSetup(
                                            userSignInType,
                                            currentUserId: currentUser,)));
                                },
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        new Container(
                                          margin: EdgeInsets.only(
                                              left: 5.0,
                                              top: 20.0,
                                              right: 10.0),
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
                                                    width: 35.0,
                                                    height: 35.0,
                                                    padding: EdgeInsets.all(
                                                        20.0),
                                                  ),
                                              errorWidget: (context, url,
                                                  error) =>
                                                  Material(
                                                    child: new SvgPicture.asset(
                                                      'images/user_unavailable.svg',
                                                      height: 35.0,
                                                      width: 35.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    borderRadius: BorderRadius
                                                        .all(
                                                      Radius.circular(5.0),
                                                    ),
                                                    clipBehavior: Clip.hardEdge,
                                                  ),
                                              imageUrl: currentUserPhotoUrl,
                                              width: 35.0,
                                              height: 35.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(18.0),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius
                                                  .circular(
                                                  30.0),
                                              border: Border.all(
                                                  color: profile_image_border_color)
                                          ),
                                        ),
                                        Container(
                                          width: 70,
                                          margin: EdgeInsets.only(
                                              top: 30.0, right: 10.0),
                                          child: Text(
                                            currentUserName,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: text_color,
                                                fontFamily: 'GoogleSansFamily',
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                              ),
                            ),


                            Spacer(),

                            Container(
                              margin: EdgeInsets.only(
                                  top: 20.0, left: 10.0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: new SvgPicture.asset(
                                    'images/friend_request.svg',
                                    height: 20.0,
                                    width: 20.0,
                                  ),
                                  onPressed: () {
                                    print('USER LIST getFriendList');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FriendRequestScreenState(
                                                    currentUser,
                                                    currentUserPhotoUrl)));
                                  },
                                ),
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(
                                  top: 20.0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: new SvgPicture.asset(
                                    'images/recent_chat.svg', height: 20.0,
                                    width: 20.0,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RecentChatsScreen(
                                                    currentUser,
                                                    currentUserPhotoUrl)));
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            /* Container(
                              margin: EdgeInsets.only(top: 5.0),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: new SvgPicture.asset(
                                  'images/home_chat.svg',
                                  width: 90.0,
                                  height: 90.0,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 10.0),
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    'Chat with people', style: TextStyle(
                                      color: text_color,
                                      fontFamily: 'GoogleSansFamily'),)
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 5.0, left: 3.0, right: 3.0),
                              child: UsersOnlinePage(
                                  currentUser, currentUserPhotoUrl, this),
                            )

*/
                            /*Container(
                              margin: EdgeInsets.only(right: 50.0),
                              child:Align(
                              alignment: Alignment.bottomRight,
                              child: DropdownButton<String>(
                                value: dropdownValue,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Colors.red, fontSize: 18),
                                underline: Container(
                                  height: 2,
                                  color: Colors.white,
                                ),
                                onChanged: (String data) {
                                  setState(() {
                                    dropdownValue = data;
                                  });
                                },
                                items: spinnerItems.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            )
                            )*/
                          ],
                        ),

                      ],
                    )
                ),
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
                          .height - 180,
                      decoration: BoxDecoration(
                          color: text_color,
                          borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(20.0),
                            topRight: const Radius.circular(20.0),
                          )
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            /* Container(
                              width: 40.0,
                              height: 5.0,
                              margin: EdgeInsets.only(top: 5.0),
                              decoration: BoxDecoration(
                                color: greyColor2,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              child: new SizedBox(
                                height: 10.0,
                                child: Divider(
                                  color: greyColor2,
                                  thickness: 2.0,
                                ),
                              )
                          ),*/
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                  margin: EdgeInsets.only(left: 20.0,
                                      top: 25.0),
                                  child: Text('Closest to you', style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: 'GoogleSansFamily',
                                      fontWeight: FontWeight.w500),)
                              ),
                            ),
                            /*  currentUser != '' && currentUser != null
                              ? new ActiveUserListRadius(
                              currentUser, currentUserPhotoUrl,
                              _msliderData)
                              : Container(),*/
                            new LoginUsersList(
                                currentUser, currentUserPhotoUrl),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                  margin: EdgeInsets.only(left: 20.0, top: 20.0),
                                  child: Text('Near by stores', style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: 'GoogleSansFamily',
                                      fontWeight: FontWeight.w500),)
                              ),
                            ),
                           new BusinessListPage(
                                currentUser, currentUserPhotoUrl,
                                _currentUserBusinessId),
                            /*
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                                margin: EdgeInsets.only(left: 20.0,top: 20.0),
                                child: Text('Businesses', style: TextStyle(
                                    fontSize: 19.0,
                                    fontFamily: 'GoogleSansFamily',
                                    fontWeight: FontWeight.w500),),
                            ),
                          ),
                      new BusinessListPage(
                          currentUser, currentUserPhotoUrl),*/
                          ],
                        ),
                      )
                  )
              ),

              /*DraggableFloatingActionButton(
                data: 'dfab_demo',
                offset: new Offset(100, 100),
                backgroundColor: Theme.of(context).accentColor,
                child: new Icon(
                  Icons.wb_incandescent,
                  color: Colors.yellow,
                ),
                onPressed: () =>  SpeedDial(
                  animatedIcon: AnimatedIcons.menu_close,
                  animatedIconTheme: IconThemeData(size: 22.0),
                  visible: false,
                  curve: Curves.easeInCirc,
                  overlayColor: Colors.black,
                  overlayOpacity: 0.5,
                  onOpen: () => print('OPENING DIAL'),
                  onClose: () => print('DIAL CLOSED'),
                  tooltip: 'Speed Dial',
                  heroTag: 'speed-dial-hero-tag',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 8.0,
                  shape: CircleBorder(),
                  children: [
                    SpeedDialChild(
                        child: Icon(Icons.accessibility),
                        backgroundColor: Colors.red,
                        label: 'First',
                        labelStyle: TextStyle(fontSize: 18.0),
                        onTap: () => print('FIRST CHILD')
                    ),
                    SpeedDialChild(
                      child: Icon(Icons.brush),
                      backgroundColor: Colors.blue,
                      label: 'Second',
                      labelStyle: TextStyle(fontSize: 18.0),
                      onTap: () => print('SECOND CHILD'),
                    ),
                    SpeedDialChild(
                      child: Icon(Icons.keyboard_voice),
                      backgroundColor: Colors.green,
                      label: 'Third',
                      labelStyle: TextStyle(fontSize: 18.0),
                      onTap: () => print('THIRD CHILD'),
                    ),
                  ],
                ),
                appContext: context,
              ),
*/

            ],
          )
//                  ],
//                );
//              },
//          );
      ),
    );
  }


  Future onBackPress() async {
    print('USRELIST ONBACKPRESS');
    Fluttertoast.showToast(msg: 'Please exit the App');
  }

  @override
  void SliderChangeListenerACTIVE(double sliderData) {
    print('USERR LIST NANDHU $sliderData');
    if (sliderData != 10.0) {
      setState(() {
        _msliderData = sliderData;
        sliderChanged = false;
      });
    } else if (_msliderData != null && sliderData == 100.0) {
      setState(() {
        _msliderData = sliderData;
        sliderChanged = true;
      });
    }
  }

}

abstract class SliderListenerUpdate {
  void SliderChangeListenerACTIVE(double sliderData);
}
/*
class UsersOnlinePage extends StatelessWidget implements SliderListener {
  String currentUserId = '';
  String mphotoUrl = '';
  SliderListenerUpdate sliderListener;
  double _msliderData = 0.0;


  UsersOnlinePage(String currentUser, String photoUrl,
      SliderListenerUpdate listState) {
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
    sliderListener = listState;
  }


  @override
  Widget build(BuildContext context) {
    return RangeSliderSample(this);
  }

//  ActiveUserListRadiusState myAppState=new ActiveUserListRadiusState('');

  @override
  void SliderChangeListener(double sliderData) {
    print('SliderChangeListener $sliderData');
//    myAppState.userListUpdate(sliderData);
    if (sliderData != 0.0 || sliderData != 100.0) {
      sliderListener.SliderChangeListenerACTIVE(sliderData);
    }
  }


}*/

abstract class SliderListener {
  void SliderChangeListener(double sliderData);
}

/*class ActiveUserListRadiusState extends StatefulWidget {

  String _mcurrentUserId = ' ';
  String photoUrl = '';

  ActiveUserListRadiusState(String currentUserId, String mphotoUrl) {
    _mcurrentUserId = currentUserId;
    photoUrl = mphotoUrl;
  }

  @override
  State<StatefulWidget> createState() {
    return ActiveUserListRadius(_mcurrentUserId, photoUrl);
  }

  userListUpdate(double sliderData) {
    print('userListUpdate  sliderData $sliderData');
    if(sliderData != null)
          ActiveUserListRadius(_mcurrentUserId, photoUrl).userListUpdate(sliderData);
    else
          LoginUsersList(
          _mcurrentUserId, photoUrl);
  }
}*/

class ActiveUserListRadius extends StatefulWidget {
  String currentUserId = '';
  String mphotoUrl = '';
  double msliderData = 100.0;

  ActiveUserListRadius(String currentUser, String photoUrl, double data) {
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
    msliderData = data;
  }

  @override
  State<StatefulWidget> createState() {
    return ActiveUserListRadiusState(currentUserId, mphotoUrl, msliderData);
  }

}


class ActiveUserListRadiusState extends State<ActiveUserListRadius> {
  String currentUserId = '';
  String mphotoUrl = '';
  double msliderData = 100.0;

  GeoPoint mUserGeoPoint;
  bool isLoading = false;


  SharedPreferences _preferences;
  String _businessType = '';
  String _businessId = '';
  String _userStatus = '';

  ActiveUserListRadiusState(String currentUser, String photoUrl, double data) {
    print('ActiveUserListRadius initialise $currentUser');
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
    msliderData = data;
    initialise();
  }

  void initialise() async {
    _preferences = await SharedPreferences.getInstance();
    _businessType = await _preferences.getString('BUSINESS_TYPE');
    _businessId = await _preferences.getString('BUSINESS_ID');
    currentUserId = await _preferences.getString('userId');
    isLoading = true;
    if (currentUserId != '' && currentUserId != null)
      getCurrentUserLocation(currentUserId, msliderData);

//    await updateUserStatus();
  }

  Stream<int> timedCounter(Duration interval, [int maxCount]) async* {
    while (true) {
      await Future.delayed(interval);
      currentUserId = _preferences.getString('userId');
//      print('userDistanceISWITHINRADIUS ________________________${new DateTime.now()}________currentUserId __$currentUserId');
      if (currentUserId != '' && currentUserId != null) {
        Firestore.instance.collection('users').where(
            'userDistanceISWITHINRADIUS', isEqualTo: 'YES').where(
            'businessId', isEqualTo: '').where(
            'status', isEqualTo: 'ACTIVE').snapshots();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (currentUserId != '' && currentUserId != null)
      getCurrentUserLocation(currentUserId, msliderData);

    return new StreamBuilder(
        stream: Firestore.instance.collection('users') /*.where(
            'userDistanceISWITHINRADIUS', isEqualTo: 'YES')*/ /*.where(
            'businessId', isEqualTo: '').*/.where(
            'status', isEqualTo: 'ACTIVE').orderBy(
            'userDistance', descending: false) /*.orderBy(
            'userDistance', descending: true)*/.snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return new Container(
              margin: EdgeInsets.only(left: 20.0, top: 20.0),
              child: Center(
                child: Text(no_users,
                    style: TextStyle(fontFamily: 'GoogleSansFamily',)),),
            );
          else
            return Flexible(
                child: snapshot.data.documents.length == null ||
                    snapshot.data.documents.length == 0 ? Center(
                  child: Text(no_users),
                ) : new ListView(
                    scrollDirection: Axis.horizontal,
                    children: snapshot.data.documents.map((document) {
                      if (document.documentID != currentUserId) {
                        return GestureDetector(
                            onTap: () {
                              getFriendList(context, currentUserId, document);
                            },
                            child: new Column(
                              children: <Widget>[
                                new Container(
                                    margin: EdgeInsets.only(
                                        left: 20.0, top: 15.0),
                                    width: 60.0,
                                    height: 60.0,
                                    decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: profile_image_border_color),
                                        image: new DecorationImage(
                                            fit: BoxFit.fill,
                                            image: new NetworkImage(
                                                document['photoUrl'])
                                        )
                                    )),
                                new Container(
                                  margin: EdgeInsets.only(
                                      left: 20.0, top: 10.0),
                                  child: Text(capitalize(document['name']),
                                    style: TextStyle(
                                        fontFamily: 'GoogleSansFamily',
                                        fontWeight: FontWeight.w400,
                                        color: black_color)
                                    , textScaleFactor: 1.0,),
                                ),
                                /*mDistance != '' ? new Container(
                                  margin: EdgeInsets.only(
                                      left: 20.0, top: 5.0),
                                  child: Text(
                                      mDistance,
                                      style: TextStyle(
                                          fontFamily: 'GoogleSansFamily',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.0,
                                          color: hint_color_grey_light)
                                      , textScaleFactor: 1.0),
                                ) : Container()*/
                              ],
                            ));
                      } else {
                        if (snapshot.data.documents.length == 1)
                          return Container(
                              margin: EdgeInsets.only(left: 20.0, top: 20.0),
                              child: Center(
                                child: Text(no_users),
                              )
                          );
                        else
                          return Container(

                          );
                      }
                    }).toList()
                )
            );
        }
    );
  }


  Widget buildLoading() {
    return Container(
        width: 50.0,
        height: 20.0,
        child: (CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.green,
          ),
          backgroundColor: Colors.red,
          value: 0.2,
        )));
  }

  Widget builder(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance.collection('users')
            .document(currentUserId)
            .collection('FriendsList')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text("Loading", style: TextStyle(
              fontFamily: 'GoogleSansFamily',));
          }
          var userDocument = snapshot.data;
          print('FRIEND REQUEST ${userDocument['requestFrom']}');
          return new Text(userDocument["requestFrom"], style: TextStyle(
            fontFamily: 'GoogleSansFamily',));
        }
    );
  }

  Future getFriendList(BuildContext context, String currentUserId,
      DocumentSnapshot documentSnapshot) async {
/*Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Chat(
                  currentUserId: currentUserId,
                  peerId: friendId,
                  peerAvatar: documentSnapshot['photoUrl'],
                )));*/
    bool isFriend = false;
    bool isAlreadyRequestSent;
    bool isRequestSent;

    String friendId = documentSnapshot.documentID;

    print(
        'documentSnapshot _____getFriendList __ ${documentSnapshot['businessType']} ___businessId ${documentSnapshot['businessId']}');


//    var businessUser = await Firestore.instance.collection('users')
//        .document(friendId).get();
//    var businessData = businessUser.data;
    var businessUserId = documentSnapshot['businessId'];
    var businessUserType = documentSnapshot['businessType'];
//    print('Friend Listttttt queryyyy   ${businessUser
//        .data}__________user ${businessUser
//        .documentID} _______ $friendId __________________ ${businessData['id']}');
    print(
        'Friend Listttttt queryyyy _____businessUserId ${businessUserId} _____businessType $businessUserType _______ friendId ${friendId}');
/*
    if ((businessUserId == null || businessUserId == '') &&
        (businessUserType == '' || businessUserType == null)) {*/

    var query = await Firestore.instance.collection('users')
        .document(currentUserId).collection(
        'FriendsList').getDocuments();

    await _preferences.setString(
        'FRIEND_USER_TOKEN', documentSnapshot.data['user_token']);
    if (query.documents.length != 0) {
      query.documents.forEach((doc) {
        print('Friend Listttttt ${doc.data}');
        if (doc.documentID == friendId &&
            doc.data['IsAcceptInvitation'] == true) {
          isFriend = true;
        }

        if (doc.documentID == friendId) {
          isAlreadyRequestSent = doc.data['isAlreadyRequestSent'];
          isRequestSent = doc.data['isRequestSent'];
        }
      });
    } else {
      isAlreadyRequestSent = false;
      /*Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Chat(
                    currentUserId: currentUserId,
                    peerId: friendId,
                    peerAvatar: documentSnapshot['photoUrl'],
                  )));*/
    }
    print(
        'Friend Listttttt isFriend_______________________________________________${isRequestSent}');

    if (isFriend) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Chat(
                    currentUserId: currentUserId,
                    peerId: friendId,
                    peerAvatar: documentSnapshot['photoUrl'],
                    isFriend: true,
                    isAlreadyRequestSent: isAlreadyRequestSent,
                    peerName: documentSnapshot['name'],
                    chatType: CHAT_TYPE_USER,
                  )));
    } else {
      print('USER lIST__________________________$isAlreadyRequestSent');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>
          SendInviteToUser(
              friendId, currentUserId, documentSnapshot['photoUrl'],
              isAlreadyRequestSent,
              isRequestSent, documentSnapshot['name'])));
      /*   Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Chat(
                      currentUserId: currentUserId,
                      peerId: friendId,
                      peerAvatar: mphotoUrl,
                      isFriend: false,
                      isAlreadyRequestSent: isAlreadyRequestSent
                  )));*/
    }
    /* } else {
      var businessUserName = documentSnapshot['businessName'];
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>
          BusinessDetailPage(businessUserId, businessUserName)));
    }*/
  }

  final Distance distance = new Distance();

  Future<DocumentSnapshot> getCurrentUserLocation(String userId,
      double sliderData) async {
    DocumentSnapshot doc = await Firestore.instance.collection('users')
        .document(userId).collection(
        'userLocation').document(userId)
        .get();
    print('USER getCurrentUserLocation userid _________$userId');
    if (doc.data != null) {
      if (doc.data.length != 0) {
        DocumentSnapshot map = doc;
        GeoPoint geopoint = map['userLocation'];
        getDocumentNearBy(geopoint.latitude, geopoint.longitude, sliderData);
        print(
            'USERCURRENT  GEO ${geopoint.latitude} ___ ${geopoint.longitude}');
      }
    }
  }


  Future<DocumentSnapshot> getUserLocation(double latitude, double longtitude,
      String userId, double sliderData) async {
    DocumentSnapshot doc = await Firestore.instance.collection('users')
        .document(userId).collection(
        'userLocation').document(userId)
        .get();
    DocumentSnapshot map = doc;
    print('map_______________________________________ ${userId}');
    isLoading = true;

    if (map != null) {
      if (map['userLocation'] != null /* &&
        (_userStatus != '' && _userStatus == 'LOGIN')*/) {
        GeoPoint geopoint = map['userLocation'];
        // km = 423 // distance.as(LengthUnit.Kilometer,
        double km = distance.distance(new LatLng(latitude, longtitude),
            new LatLng(geopoint.latitude, geopoint.longitude));
        if (/*(km != 0.0  */ /*sliderData >= km*/ /* */ /*km < 1000*/ /*) &&*/
        userId != currentUserId) {
          /* DocumentSnapshot userDocs = await Firestore.instance.collection('users')
            .document(userId).get();
        isLoading = false;
        print('USER DETAILSSS ${userDocs.data.values} ____userId $userId');*/
          /* Firestore.instance.collection('users').document(userId).updateData({
            'userDistanceISWITHINRADIUS':
            'YES',
            'userDistance': km
          });*/
        } else {
          /* Firestore.instance.collection('users').document(userId).updateData({
            'userDistanceISWITHINRADIUS':
            'NO',
            'userDistance': km
          });*/
        }
      }

      await Future.delayed(Duration(milliseconds: 10000));

      setState(() {

      });
    }
  }


  Future updateUserStatus() async {
    _userStatus = await _preferences.getString('USERSTATUS');
    if (currentUserId != '') {
      int currentTime = ((new DateTime.now()
          .toUtc()
          .microsecondsSinceEpoch) / 1000).toInt();

      var query = await Firestore.instance.collection('users')
          .document(currentUserId).collection(
          'userLocation').document(currentUserId).get();
      print(
          'USER STATUS_______________ $currentTime _____ ${query['UpdateTime']}______________${(currentTime >
              query['UpdateTime'])} ___________________________userStatus $_userStatus');
      if ((_userStatus != '' && _userStatus == 'LOGIN')) {
        if (currentTime > (query['UpdateTime'] + INACTIVE_TIME)) {
          Firestore.instance
              .collection('users')
              .document(currentUserId)
              .updateData({'status': 'INACTIVE'});
          if (_businessId != null && _businessId != '') {
            await Firestore.instance
                .collection('business')
                .document(_businessId)
                .updateData({'status': 'INACTIVE'});
          }
        } else {
          Firestore.instance
              .collection('users')
              .document(currentUserId)
              .updateData({'status': 'ACTIVE'});
          if (_businessId != null && _businessId != '') {
            await Firestore.instance
                .collection('business')
                .document(_businessId)
                .updateData({'status': 'ACTIVE'});
          }
        }
      }
    }
  }


  Future getDocumentNearBy(double latitude, double longitude,
      double distance) async {
    var query = await Firestore.instance.collection('users').getDocuments();
    query.documents.forEach((doc) {
//      print('User DOCCCCCCCCC' + doc.documentID);
      if (doc.documentID != currentUserId)
        getUserLocation(latitude, longitude, doc.documentID, distance);
    });
  }
}


class LoginUsersList extends StatefulWidget {
  String currentUserId = '';
  String mphotoUrl = '';


  @override
  State<StatefulWidget> createState() {
    return LoginUsersListState(currentUserId, mphotoUrl);
  }

  LoginUsersList(String currentUser, String photoUrl) {
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
  }
}


class LoginUsersListState extends State<LoginUsersList> {
  String currentUserId = '';
  String mphotoUrl = '';

  SharedPreferences _preferences;
  String _businessType = '';
  String _userStatus = '';

  final Distance distance = new Distance();
  List<UsersData> _mNearByUsersData = new List<UsersData>();


  LoginUsersListState(String currentUser, String photoUrl) {
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
    initialise();
  }

  void initialise() async {
    _preferences = await SharedPreferences.getInstance();
    _businessType = await _preferences.getString('BUSINESS_TYPE');
    _userStatus = await _preferences.getString('USERSTATUS');
    if (currentUserId != '' && currentUserId != null) {
      mGetCurrentUserLocation();
    }
  }


  Future mGetCurrentUserLocation() async {
    DocumentSnapshot doc = await Firestore.instance.collection('users')
        .document(currentUserId).collection(
        'userLocation').document(currentUserId)
        .get();
    DocumentSnapshot map = doc;
    if (map != null) {
      if (map['userLocation'] != null) {
        GeoPoint geopoint = map['userLocation'];
        var currentUserLat = geopoint.latitude;
        var currentUserLng = geopoint.longitude;
        findNearByUsersForCurrentUser(currentUserLat, currentUserLng);
      }
    } else {

    }
  }


  var mTempNearByUserListkm = new List<UsersData>();
  var mTempNearByUserListm = new List<UsersData>();

  Future findNearByUsersForCurrentUser(double currentUserLat,
      double currentUserLng) async {
    _mNearByUsersData.clear();
    var query = await Firestore.instance.collection('users').where(
        'status', isEqualTo: 'ACTIVE').getDocuments();
    query.documents.forEach((doc){
      if (doc.documentID != currentUserId) {
       Firestore.instance.collection('users')
            .document(doc.documentID).collection(
            'userLocation').document(doc.documentID)
            .get().then((DocumentSnapshot documentSnapshot) {
         findNearbyUsersList(
              documentSnapshot, currentUserLat, currentUserLng, doc);
        }).whenComplete(() {
         print('findNearbyUsersList whenComplete _mNearByUsersData________${mTempNearByUserListm.length} _____${mTempNearByUserListkm.length}');

         _mNearByUsersData.clear();
         print('findNearbyUsersList whenComplete clear___________${mTempNearByUserListm.length} _____${mTempNearByUserListkm.length}');

         mTempNearByUserListm.sort((a, b) {
           print('METRICUSER_________________M ${a.userDistance} __${b
               .userDistance}');
           return a.userDistance.compareTo(b.userDistance);
         });
         mTempNearByUserListkm.sort((a, b) {
           print('METRICUSER________________KM${a.userDistance} __${b
               .userDistance}');
           return a.userDistance.compareTo(b.userDistance);
         });
         _mNearByUsersData.addAll(mTempNearByUserListm);
         _mNearByUsersData.addAll(mTempNearByUserListkm);
         setState(() {
           print('findNearbyUsersList whenComplete setState___________${_mNearByUsersData.length}');
           this._mNearByUsersData = _mNearByUsersData;
         });
         Future.delayed(Duration(milliseconds: 20000));
         setState(() {

         });
        });
      }
    });
  }



  void findNearbyUsersList(DocumentSnapshot businessLocation, double currentUserLat,double currentUserLng, DocumentSnapshot businessDetail)  {
    print(
        'BusinessListPage____________map_findNearByBusinessForCurrentUserdocs_________${businessDetail.data['id']}');
    DocumentSnapshot map = businessLocation;
    var doc = businessDetail;
    if (map != null && map['userLocation'] != null) {
      GeoPoint geopoint = map['userLocation'];
      var myDistance;
      double km = distance.distance(
          new LatLng(currentUserLat, currentUserLng),
          new LatLng(geopoint.latitude, geopoint.longitude));
      var mkm = km.toInt();
//          print('METRIC________NearBY Business _____METRIC_${mkm} _____');
      if (mkm != 0) {
        if (mkm == 1000) {
          print('METRIC_________________KM__________NN1');
          myDistance = (mkm / 1000).toInt();
          mTempNearByUserListkm.add(
              UsersData(businessId: doc.data['businessId'],
                  businessName: doc.data['businessName'],
                  businessType: doc.data['businessType'],
                  createdAt: doc.data['createdAt'],
                  email: doc.data['email'],
                  id: doc.data['id'],
                  name: doc.data['name'],
                  nickName: doc.data['nickName'],
                  phoneNo: doc.data['phoneNo'],
                  photoUrl: doc.data['photoUrl'],
                  status: doc.data['status'],
                  userDistance:myDistance,
                  distanceMetric: 'km',
                  user_token: doc.data['user_token']));
        } else if (mkm < 1000) {
          print('METRIC_________________M__________NN1');
          myDistance = (mkm).toInt();
          mTempNearByUserListm.add(
              UsersData(businessId: doc.data['businessId'],
                  businessName: doc.data['businessName'],
                  businessType: doc.data['businessType'],
                  createdAt: doc.data['createdAt'],
                  email: doc.data['email'],
                  id: doc.data['id'],
                  name: doc.data['name'],
                  nickName: doc.data['nickName'],
                  phoneNo: doc.data['phoneNo'],
                  photoUrl: doc.data['photoUrl'],
                  status: doc.data['status'],
                  userDistance:myDistance,
                  distanceMetric: 'm',
                  user_token: doc.data['user_token']));
        } else {
          print('METRIC_________________KM__________NN0');
          myDistance = (mkm / 1000).toInt();
          mTempNearByUserListkm.add(
              UsersData(businessId: doc.data['businessId'],
                  businessName: doc.data['businessName'],
                  businessType: doc.data['businessType'],
                  createdAt: doc.data['createdAt'],
                  email: doc.data['email'],
                  id: doc.data['id'],
                  name: doc.data['name'],
                  nickName: doc.data['nickName'],
                  phoneNo: doc.data['phoneNo'],
                  photoUrl: doc.data['photoUrl'],
                  status: doc.data['status'],
                  userDistance:myDistance,
                  distanceMetric: 'km',
                  user_token: doc.data['user_token']));
        }
      } else {
        print('METRIC_________________M__________NN0');
        myDistance = (mkm).toInt();
        mTempNearByUserListm.add(
            UsersData(businessId: doc.data['businessId'],
                businessName: doc.data['businessName'],
                businessType: doc.data['businessType'],
                createdAt: doc.data['createdAt'],
                email: doc.data['email'],
                id: doc.data['id'],
                name: doc.data['name'],
                nickName: doc.data['nickName'],
                phoneNo: doc.data['phoneNo'],
                photoUrl: doc.data['photoUrl'],
                status: doc.data['status'],
                userDistance:myDistance,
                distanceMetric: 'm',
                user_token: doc.data['user_token']));
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    print('LOGIN USER LIST');
    return Container(
          width:( MediaQuery
              .of(context)
              .size
              .width),
          height: (MediaQuery
              .of(context)
              .size
              .height - 200) / 2,
//          margin: EdgeInsets.only(top: 10.0),
          child:
          (_mNearByUsersData != null && _mNearByUsersData.length != 0) &&
              (_mNearByUsersData != null && _mNearByUsersData.length != 0) ?
          GridView.builder(
            itemBuilder: (context, index) =>
                buildUsersList(index, _mNearByUsersData),
            itemCount:8,
            shrinkWrap: true,
            primary: true,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,childAspectRatio:0.6,
            ),
//            scrollDirection: Axis.vertical,
          ) : Center(
            child: Text('No users'),
          )
    );
  }


  Widget buildUsersList(int index, List<UsersData> _mUserList) {
//    print('buildRecentUsers index $index _____________${_mNearByUsersData
//        .length } __________${(_mUserList[index])}');
    if (_mNearByUsersData.length == 0) {
      return Center(
          child: Text('No users'));
    } else if (_mNearByUsersData.length > 0 && _mNearByUsersData.length != 0 && _mNearByUsersData.length > index) {
//      print('Recent chat _mChatList ${_mNearByUsersData[index].name}');
      UsersData usersData = _mNearByUsersData[index];
      return usersData != null ?  index+1 == 8 &&  _mNearByUsersData.length >8 ?  GestureDetector(
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NearByUsersList(currentUserId,_mNearByUsersData)));
            },
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Container(
                  margin: EdgeInsets.only(
                      left: 10.0, top: 0.0,bottom: 0.0),
                  width: 70.0,
                  height: 70.0,
                  child: new SvgPicture.asset(
                    'images/show_more.svg',
                  ),
                ),
                new Container(
                  margin: EdgeInsets.only(left: 15.0, top: 0.0,bottom: 0.0),
                  child: Text('Show more',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500,
                      fontFamily: 'GoogleSansFamily',
                      color: black_color,
                      fontSize: 12.0,),),
                )
              ],
            )
          ): GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Chat(
                              currentUserId: currentUserId,
                              peerId: usersData.id,
                              peerAvatar: usersData.photoUrl,
                              isFriend: true,
                              isAlreadyRequestSent: true,
                              peerName: usersData.name,
                            )));
              },
              child: Container(
                width: 100.0,
                height: 100.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .start,
                  mainAxisAlignment: MainAxisAlignment
                      .start,
                  children: <Widget>[
                    usersData.photoUrl != null &&
                        usersData.photoUrl != ''
                        ? new Container(
                        margin: EdgeInsets.only(
                            left: 20.0, top: 0.0,bottom: 10.0),
                        width: 60.0,
                        height: 60.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: profile_image_border_color),
                            image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(
                                  usersData.photoUrl),
                            )
                        )
                    )
                        : usersData.photoUrl == ''
                        ? new Container(
                        margin: EdgeInsets.only(
                            left: 20.0, top: 10.0),
                        width: 60.0,
                        height: 60.0,
                        child: new SvgPicture.asset(
                          'images/user_unavailable.svg',
                          height: 10.0,
                          width: 10.0,
//                                          color: primaryColor,
                        ),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                        ))
                        : Text(''),
                    usersData != null && usersData.name != '' ? new Container(
                      width: 70,
                      margin: EdgeInsets.only(left: 15.0, top: 0.0,bottom: 0.0),
                      child: Text(capitalize(usersData.name),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.0, style: TextStyle(
                              fontFamily: 'GoogleSansFamily',
                              color: black_color,
                              fontWeight: FontWeight.w400)),
                    ) : Text(''),
                    usersData != null && usersData.userDistance != ''
                        ? new Container(
                      width: 70,
                      margin: EdgeInsets.only(left: 15.0, top: 0.0,bottom: 0.0),
                      child: Text(
                        usersData.userDistance.toString() +'\t'+usersData.distanceMetric,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w500,
                          fontFamily: 'GoogleSansFamily',
                          color: hint_color_grey_light,
                          fontSize: 12.0,),),
                    )
                        : Text(''),
                  ],
                ),
              )
      ) : Center(child: Text('No users'),);
    }else{
      return Container();
    }
  }

  Future getFriendList(BuildContext context, String currentUserId,
      DocumentSnapshot documentSnapshot) async {
    bool isFriend = false;
    bool isAlreadyRequestSent = false;
    String friendId = documentSnapshot.documentID;
    bool isRequestSent;
    var businessUserId = documentSnapshot['businessId'];
    var businessUserType = documentSnapshot['businessType'];
    var query = await Firestore.instance.collection('users')
        .document(currentUserId).collection(
        'FriendsList').getDocuments();

    await _preferences.setString(
        'FRIEND_USER_TOKEN', documentSnapshot.data['user_token']);
    if (query.documents.length != 0) {
      query.documents.forEach((doc) {
        if (doc.documentID == friendId &&
            doc.data['IsAcceptInvitation'] == true) {
          isFriend = true;
        }

        if (doc.documentID == friendId) {
          isAlreadyRequestSent = doc.data['isAlreadyRequestSent'];
          isRequestSent = doc.data['isRequestSent'];
        }
      });
    } else {
      isAlreadyRequestSent = false;
    }

    if (isFriend) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Chat(
                    currentUserId: currentUserId,
                    peerId: friendId,
                    peerAvatar: documentSnapshot['photoUrl'],
                    isFriend: true,
                    isAlreadyRequestSent: isAlreadyRequestSent,
                    peerName: documentSnapshot['name'],
                    chatType: CHAT_TYPE_USER,
                  )));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>
          SendInviteToUser(
              friendId, currentUserId, documentSnapshot['photoUrl'],
              isAlreadyRequestSent,
              isRequestSent, documentSnapshot['name'])));
    }
  }
}


class BusinessListPage extends StatefulWidget {
  String currentUserId = '';
  String mphotoUrl = '';
  String _currentUserBusinessId = '';

  BusinessListPage(String currentUser, String photoUrl,
      String currentUserBusinessId) {
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
    _currentUserBusinessId = currentUserBusinessId;
  }

  @override
  State<StatefulWidget> createState() {
    return BusinessListPageState(
        currentUserId, mphotoUrl, _currentUserBusinessId);
  }
}

class BusinessListPageState extends State<BusinessListPage> {
  String currentUserId = '';
  String mphotoUrl = '';

  SharedPreferences _preferences;
  String _userStatus = '';
  String _currentUserBusinessType = '';
  String _currentUserBusinessId = '';

  List<BusinessData> _mBusinessData = new List<BusinessData>();
  final ScrollController listScrollController = new ScrollController();
  final Distance distance = new Distance();



  BusinessListPageState(String currentUser, String photoUrl,
      String currentUserBusinessId) {
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
    _currentUserBusinessId = currentUserBusinessId;
    initialise();
  }

  void initialise() async {
    _preferences = await SharedPreferences.getInstance();
    _userStatus = await _preferences.getString('USERSTATUS');
    _currentUserBusinessType = await _preferences.getString('BUSINESS_TYPE');
    if (currentUserId != '' && currentUserId != null) {
      print('BUSINESSS_________________${currentUserId}');
      mGetCurrentUserLocation();
    }
  }



  Future mGetCurrentUserLocation() async {
    DocumentSnapshot doc = await Firestore.instance.collection('users')
        .document(currentUserId).collection(
        'userLocation').document(currentUserId)
        .get();
    DocumentSnapshot map = doc;

    if (map != null) {
      if (map['userLocation'] != null) {
        GeoPoint geopoint = map['userLocation'];
        var currentUserLat = geopoint.latitude;
        var currentUserLng = geopoint.longitude;
        findNearByBusinessForCurrentUser(currentUserLat, currentUserLng);
      }
    } else {

    }
  }
  var mTempNearByBusinessListkm = new List<BusinessData>();
  var mTempNearByBusinessListm = new List<BusinessData>();

  Future findNearByBusinessForCurrentUser(double currentUserLat,
      double currentUserLng) async {
    _mBusinessData.clear();

    var query = await Firestore.instance.collection('business').where(
        'status', isEqualTo: 'ACTIVE').getDocuments();
    query.documents.forEach((doc) {
      if (doc.documentID != _currentUserBusinessId) {
       Firestore.instance.collection('business')
            .document(doc.documentID).collection(
            'businessLocation').document(doc.documentID)
            .get().then((DocumentSnapshot documentSnapshot){
         findNearbyBusinessList(documentSnapshot,currentUserLat,currentUserLng,doc);
       }).whenComplete((){
         _mBusinessData.clear();
         mTempNearByBusinessListm.sort((a, b) {
           print('METRIC_________________M ${a.businessDistance} __${b.businessDistance}');
           return a.businessDistance.compareTo(b.businessDistance);
         });
         mTempNearByBusinessListkm.sort((a, b) {
           print('METRIC________________KM${a.businessDistance} __${b.businessDistance}');
           return a.businessDistance.compareTo(b.businessDistance);
         });
         print('METRIC________________KM  BEFORE${_mBusinessData.length} _______m ${mTempNearByBusinessListm.length}_______km ${mTempNearByBusinessListkm.length}');
         _mBusinessData.addAll(mTempNearByBusinessListm);
         print('METRIC________________KM AFTERRRR${_mBusinessData.length}');
         _mBusinessData.addAll(mTempNearByBusinessListkm);
         setState(() {
           this._mBusinessData = _mBusinessData;
         });
         Future.delayed(Duration(milliseconds: 20000));
         setState(() {

         });
       });
      }
    });

  }


  Future findNearbyBusinessList(DocumentSnapshot businessLocation, double currentUserLat,double currentUserLng, DocumentSnapshot businessDetail) async {
    print(
        'BusinessListPage____________map_findNearByBusinessForCurrentUserdocs');
    DocumentSnapshot map = businessLocation;
    var doc = businessDetail;
    if (map != null && map['businessLocation'] != null) {
      GeoPoint geopoint = map['businessLocation'];
      var myDistance;
      double km = distance.distance(
          new LatLng(currentUserLat, currentUserLng),
          new LatLng(geopoint.latitude, geopoint.longitude));
      var mkm = km.toInt();
//          print('METRIC________NearBY Business _____METRIC_${mkm} _____');
      if (mkm != 0) {
        if (mkm == 1000) {
          print('METRIC_________________KM__________NN1');

          myDistance = (mkm / 1000).toInt();
          mTempNearByBusinessListkm.add(
              BusinessData(businessId: doc.data['businessId'],
                  businessName: doc.data['businessName'],
                  businessPhotoUrl: doc.data['photoUrl'],
                  businessStatus: doc.data['status'],
                  businessDistance: myDistance,
                  distanceMetric: 'km'));
        } else if (mkm < 1000) {
          print('METRIC_________________M__________NN1');
          myDistance = (mkm).toInt();
          mTempNearByBusinessListm.add(
              BusinessData(businessId: doc.data['businessId'],
                  businessName: doc.data['businessName'],
                  businessPhotoUrl: doc.data['photoUrl'],
                  businessStatus: doc.data['status'],
                  businessDistance: myDistance,
                  distanceMetric: 'm'));
        } else {
          print('METRIC_________________KM__________NN0');
          myDistance = (mkm / 1000).toInt();
          mTempNearByBusinessListkm.add(
              BusinessData(businessId: doc.data['businessId'],
                  businessName: doc.data['businessName'],
                  businessPhotoUrl: doc.data['photoUrl'],
                  businessStatus: doc.data['status'],
                  businessDistance: myDistance,
                  distanceMetric: 'km'));
        }
      } else {
        print('METRIC_________________M__________NN0');
        myDistance = (mkm).toInt();
        mTempNearByBusinessListm.add(
            BusinessData(businessId: doc.data['businessId'],
                businessName: doc.data['businessName'],
                businessPhotoUrl: doc.data['photoUrl'],
                businessStatus: doc.data['status'],
                businessDistance: myDistance,
                distanceMetric: 'm'));
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
        width:( MediaQuery
            .of(context)
            .size
            .width),
        height: (MediaQuery
            .of(context)
            .size
            .height - 200) / 2,
        margin: EdgeInsets.only(top: 10.0),
        child:
        (_mBusinessData != null && _mBusinessData.length != 0) &&
            (_mBusinessData != null && _mBusinessData.length != 0) ?
        GridView.builder(
          itemBuilder: (context, index) =>
              buildBusinessList(index, _mBusinessData),
          itemCount:8,
          shrinkWrap: true,
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,crossAxisSpacing: 2,childAspectRatio:0.6,
          ),
          scrollDirection: Axis.vertical,
        ) : Center(
          child: Text('No Business'),
        )
    );
  }


  Widget buildBusinessList(int index, List<BusinessData> _mUserList) {
    print('buildRecentUsers index  Business$index _____________${_mBusinessData
        .length } __________');
    if (_mBusinessData.length == 0) {
      return Center(
          child: Text('No Business'));
    } else if (_mBusinessData.length > 0 && _mBusinessData.length != 0 && _mBusinessData.length > index) {
      BusinessData businessData = _mBusinessData[index];
      return businessData != null ? index+1 == 8 &&  _mBusinessData.length >8? GestureDetector(
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NearByBusinessList(currentUserId,_mBusinessData)));
            },
            child: Container(
                height: 100.0,
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Container(
                  margin: EdgeInsets.only(
                      left: 10.0, top: 0.0,bottom: 0.0),
                  width: 70.0,
                  height: 70.0,
                  child: new SvgPicture.asset(
                    'images/show_more.svg',
                  ),
                ),
                new Container(
                  margin: EdgeInsets.only(left: 15.0, top: 0.0,bottom: 0.0),
                  child: Text('Show more',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500,
                      fontFamily: 'GoogleSansFamily',
                      color: black_color,
                      fontSize: 12.0,),),
                )
              ],
            )
            )
      ):GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) =>
                  BusinessDetailPage(businessData.businessId, businessData.businessName)));
            },
            child: Container(
              height: 100.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .start,
                mainAxisAlignment: MainAxisAlignment
                    .start,
                children: <Widget>[
                  businessData.businessPhotoUrl != null &&
                      businessData.businessPhotoUrl != ''
                      ? new Container(
                      margin: EdgeInsets.only(
                          left: 20.0, top: 0.0,bottom: 0.0),
                      width: 60.0,
                      height: 60.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: profile_image_border_color),
                          image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(
                                businessData.businessPhotoUrl),
                          )
                      )
                  )
                      : businessData.businessPhotoUrl == ''
                      ? new Container(
                      margin: EdgeInsets.only(
                          left: 20.0, top: 10.0),
                      width: 60.0,
                      height: 60.0,
                      child: new SvgPicture.asset(
                        'images/user_unavailable.svg',
                        height: 10.0,
                        width: 10.0,
//                                          color: primaryColor,
                      ),
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                      ))
                      : Text(''),
                  businessData != null && businessData.businessName != '' ? new Container(
                    width: 70,
                    margin: EdgeInsets.only(left: 15.0, top: 0.0,bottom: 0.0),
                    child: Text(capitalize(businessData.businessName),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.0, style: TextStyle(
                            fontFamily: 'GoogleSansFamily',
                            color: black_color,
                            fontWeight: FontWeight.w400)),
                  ) : Text(''),
                  businessData != null && businessData.businessDistance != ''
                      ? new Container(
                    width: 70,
                    margin: EdgeInsets.only(left: 15.0, top: 0.0,bottom: 0.0),
                    child: Text(
                      businessData.businessDistance.toString() + '\t'+businessData.distanceMetric,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500,
                        fontFamily: 'GoogleSansFamily',
                        color: hint_color_grey_light,
                        fontSize: 12.0,),),
                  )
                      : Text(''),
                ],
              ),
            )
      ): Center(child: Text('No Business'),
      );
    }else{
      return Container();
    }
  }


  Widget buildListBusinesses(BuildContext context) {
    return Container(
        child:
        (_mBusinessData != null && _mBusinessData.length != 0) ? ListView
            .builder(
          itemBuilder: (context, index) =>
              buildBusiness(index, _mBusinessData, context),
          itemCount: _mBusinessData.length,
          scrollDirection: Axis.horizontal,
          controller: listScrollController,
        ) : Center(
          child: Text('No recent chats'),
        )
    );
  }

  Widget buildBusiness(int index, List<BusinessData> mBusinessData,
      BuildContext context,) {
    if (mBusinessData.length == 0) {
      return Center(
          child: Text(no_business));
    } else if (mBusinessData.length > 0 && mBusinessData.length != 0) {
      return GestureDetector(
          onTap: () {
            print(
                'ON TAPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP currentUserId $currentUserId');
            getFriendListNew(context, currentUserId, mBusinessData[index]);
          },
          child: new Column(
            children: <Widget>[
              Stack(
                  children: <Widget>[
                    mBusinessData[index].businessPhotoUrl != null &&
                        mBusinessData[index].businessPhotoUrl != ''
                        ? new Container(
                        margin: EdgeInsets.only(
                            left: 20.0, top: 15.0),
                        width: 60.0,
                        height: 60.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: profile_image_border_color),
                            image: new DecorationImage(
                                fit: BoxFit.fill,
                                image: new NetworkImage(
                                    mBusinessData[index].businessPhotoUrl)
                            )
                        ))
                        : mBusinessData[index].businessPhotoUrl == ''
                        ? new Container(
                        margin: EdgeInsets.only(
                            left: 20.0, top: 10.0),
                        width: 60.0,
                        height: 60.0,
                        child: new SvgPicture.asset(
                          'images/user_unavailable.svg',
                          height: 10.0,
                          width: 10.0,
//                                          color: primaryColor,
                        ),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                        ))
                        : Text(''),
                    mBusinessData[index].businessStatus == 'ACTIVE' ? Container(
                        child: new SvgPicture.asset(
                          'images/online_active.svg',
                          height: 15.0,
                          width: 15.0,
//                                          color: primaryColor,
                        ),
                        margin: EdgeInsets.only(left: 60.0,
                            bottom: 30.0,
                            top: 10.0,
                            right: 10.0)) : mBusinessData[index]
                        .businessStatus ==
                        'LoggedOut' ? Container(
                      child: new SvgPicture.asset(
                        'images/online_inactive.svg',
                        height: 15.0,
                        width: 15.0,
//                                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(left: 60.0,
                          bottom: 30.0,
                          top: 10.0,
                          right: 10.0),
                    ) : Container(
                      child: new SvgPicture.asset(
                        'images/online_idle.svg', height: 15.0,
                        width: 15.0,
//                                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(left: 60.0,
                          bottom: 30.0,
                          top: 10.0,
                          right: 10.0),
                    )
                  ]
              ),
              new Container(
                margin: EdgeInsets.only(left: 20.0, top: 10.0),
                child: Text(capitalize(mBusinessData[index].businessName),
                    textScaleFactor: 1.0, style: TextStyle(
                      fontFamily: 'GoogleSansFamily',)),
              )
            ],
          ));
    }
  }

  Future getFriendList(BuildContext context, String currentUserId,
      DocumentSnapshot documentSnapshot) async {
    var businessUserName = documentSnapshot['businessName'];
    Navigator.push(
        context, MaterialPageRoute(builder: (context) =>
        BusinessDetailPage(documentSnapshot['businessId'], businessUserName)));
  }


  Future getFriendListNew(BuildContext context, String currentUserId,
      BusinessData businessData) async {
    var businessUserName = businessData.businessName;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) =>
        BusinessDetailPage(businessData.businessId, businessUserName)));
  }
}
