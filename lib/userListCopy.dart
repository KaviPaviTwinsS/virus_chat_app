//import 'dart:async';
//import 'dart:io';
//import 'dart:convert';
//
//import 'package:cached_network_image/cached_network_image.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:device_info/device_info.dart';
////import 'package:draggable_floating_button/draggable_floating_button.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
////import 'package:flutter_speed_dial/flutter_speed_dial.dart';
//import 'package:flutter_svg/flutter_svg.dart';
//import 'package:fluttertoast/fluttertoast.dart';
//import 'package:latlong/latlong.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:virus_chat_app/FriendRequestScreen.dart';
//import 'package:virus_chat_app/LocationService.dart';
//import 'package:virus_chat_app/SendInviteScreen.dart';
//import 'package:virus_chat_app/business/BusinessData.dart';
//import 'package:virus_chat_app/business/BusinessDetailPage.dart';
//import 'package:virus_chat_app/business/BusinessPage.dart';
//import 'package:virus_chat_app/chat/RecentChatsScreen.dart';
//import 'package:virus_chat_app/chat/chat.dart';
//import 'package:virus_chat_app/profile/ProfilePage.dart';
//import 'package:virus_chat_app/rangeSlider/RangeSliderPage.dart';
//import 'package:virus_chat_app/tweetPost/MakeTweetPost.dart';
//import 'package:virus_chat_app/tweetPost/NewTweetPost.dart';
//import 'package:virus_chat_app/utils/colors.dart';
//import 'package:virus_chat_app/utils/constants.dart';
//import 'package:virus_chat_app/utils/strings.dart';
//import 'package:async/async.dart';
//import 'package:http/http.dart' as http;
//
///*
//class UsersList extends StatelessWidget {
//  String currentUser = '';
//  String userSignInType = '';
//  String mphotoUrl = '';
//
//  UsersList(String signinType, String userId, String photoUrl) {
//    currentUser = userId;
//    userSignInType = signinType;
//    mphotoUrl = photoUrl;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      debugShowCheckedModeBanner: false,
//      title: app_name,
//      theme: ThemeData(
//        // This is the theme of your application.
//        //
//        // Try running your application with "flutter run". You'll see the
//        // application has a blue toolbar. Then, without quitting the app, try
//        // changing the primarySwatch below to Colors.green and then invoke
//        // "hot reload" (press "r" in the console where you ran "flutter run",
//        // or simply save your changes to "hot reload" in a Flutter IDE).
//        // Notice that the counter didn't reset back to zero; the application
//        // is not restarted.
//        primarySwatch: Colors.blue,
//      ),
//      home: UsersListPage(currentUser, userSignInType, mphotoUrl),
//    );
//  }
//}*/
//
//class UsersList extends StatefulWidget {
//  String currentUserId = '';
//  String signInType = '';
//  String mphotoUrl = '';
//
//  UsersList(String currentUser, String userSignInType, String photoUrl) {
//    currentUserId = currentUser;
//    signInType = userSignInType;
//    mphotoUrl = photoUrl;
//  }
//
//  @override
//  State<StatefulWidget> createState() {
//    return UsersListState(currentUserId, signInType, mphotoUrl);
//  }
//}
//
//class UsersListState extends State<UsersList>
//    implements SliderListenerUpdate {
//  String currentUserPhotoUrl = '';
//  String currentUserName = '';
//  String currentUser = '';
//  String userSignInType = '';
//  SharedPreferences prefs;
//  bool sliderChanged = true;
//  double _msliderData = 100.0;
//
//  String _currentUserBusinessId = '';
//
//  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//
//  UsersListState(String currentUserId, String signInType, String mphotoUrl) {
//    print('Friend Request Build__________  UsersListState$currentUserId');
//    currentUser = currentUserId;
//    userSignInType = signInType;
//    currentUserPhotoUrl = mphotoUrl;
//  }
//
//  @override
//  void initState() {
//    initialise();
//    super.initState();
//  }
//
//  Future initialise() async {
//    prefs = await SharedPreferences.getInstance();
//    await prefs.setString('USERSTATUS', 'LOGIN');
//    currentUserName = await prefs.getString('name');
//    currentUser = await prefs.getString('userId');
//    currentUserPhotoUrl = await prefs.getString('photoUrl');
//    _currentUserBusinessId = await prefs.getString('BUSINESS_ID');
//    if (userSignInType == '') {
//      userSignInType = await prefs.getString('signInType');
//    }
//    if (currentUserPhotoUrl == '') {
//      currentUserPhotoUrl = await prefs.getString('photoUrl');
//    }
////    print('USERLIST name_____ $currentUserName');
//
//    if (currentUser != '' && currentUser != null) {
//      var query = await Firestore.instance.collection('users')
//          .document(currentUser).collection(
//          'userLocation').document(currentUser).get();
////      print('User Update status ___ ${currentUser} ___ ${query['UpdateTime']}');
//      int currentTime = ((new DateTime.now()
//          .toUtc()
//          .microsecondsSinceEpoch) / 1000).toInt();
//
//      /*  if (currentUser != '') {
//      print(
//          'USER STATUS_______________ $currentTime _____ ${query['UpdateTime']}');
//      if (currentTime > query['UpdateTime']) {
//        Firestore.instance
//            .collection('users')
//            .document(currentUser)
//            .updateData({'status': 'INACTIVE'});
//      } else {
//        Firestore.instance
//            .collection('users')
//            .document(currentUser)
//            .updateData({'status': 'ACTIVE'});
//      }
//    }*/
//      /*for(int i=5;i<250;i+5){
//      spinnerItems.add('$i m');
//    }*/
//    }
//    setState(() {});
//  }
//
//  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
//
//  int _curIndex = 0;
//
//  bool homeClicked = true;
//
//  String dropdownValue = '5m';
//
//  int value = 0;
//  List<String> spinnerItems = new List<String>();
//
//
//  void test() async {
//    String identifier;
//    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
////    try {
//    if (Platform.isAndroid) {
//      var build = await deviceInfoPlugin.androidInfo;
//      identifier = build.id.toString();
//    } else if (Platform.isIOS) {
//      var data = await deviceInfoPlugin.iosInfo;
//      identifier = data.identifierForVendor; //UUID for iOS
//    }
//    print('IDENTIFIER $identifier');
////    } on PlatformException {
////      print('Failed to get platform version');
////    }
//    var initializationSettingsAndroid =
//    new AndroidInitializationSettings('app_icon');
//    new AndroidInitializationSettings('app_icon');
//    var initializationSettingsIOS = new IOSInitializationSettings();
//    var initializationSettings = new InitializationSettings(
//        initializationSettingsAndroid, initializationSettingsIOS);
//    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//    firebaseMessaging.onIosSettingsRegistered
//        .listen((IosNotificationSettings settings) {
//      print("Settings registered: $settings");
//    });
//
//    firebaseMessaging.getToken().then((token) {
//      print('--- Firebase toke here ---');
////      Firestore.instance.collection(currentUser).document(identifier).setData({ 'token': token});
//      print(token);
//    });
//  }
///*
//
//
//  Future onSelectNotification(String payload) async {
//    if(notifyId == '1000'*//* && !isOpened*//*) {
//      print('________1000');
////      isOpened = true;
//      Navigator.pushReplacement(
//          context,
//          MaterialPageRoute(
//              builder: (context) =>
//                  BusinessChat(
//                    currentUserId: businessId,
//                    peerId: userId,
//                    peerAvatar: photoUrl,
//                    isFriend: true,
//                    isAlreadyRequestSent: true,
//                    peerName: name,
//                    chatType: CHAT_TYPE_BUSINESS,
//                  )));
//    }
//  }*/
///*
//  void initializeNotify() async{
//    var initializationSettingsAndroid =
//    new AndroidInitializationSettings('app_icon');
//    var initializationSettingsIOS = IOSInitializationSettings(
//        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
//    var initializationSettings = InitializationSettings(
//        initializationSettingsAndroid, initializationSettingsIOS);
//    flutterLocalNotificationsPlugin.initialize(initializationSettings,
//        onSelectNotification: onSelectNotification);
//  }*/
//  Future<void> _showSoundUriNotification() async {
//    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//        'your channel id', 'your channel name', 'your channel description',
//        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
//    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//    var platformChannelSpecifics = NotificationDetails(
//        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
//  }
//
//
//  @override
//  Widget build(BuildContext context) {
//    print('Friend Request Build__________  MAINNNN');
////    initialise();
//    return WillPopScope(
//      onWillPop: () async => Future.value(false),
//      child: new Scaffold(
//        /* floatingActionButton: SpeedDial(
//            animatedIcon: AnimatedIcons.menu_close,
//            animatedIconTheme: IconThemeData(size: 22.0),
//            // this is ignored if animatedIcon is non null
////             child: Icon(Icons.add),
//            visible: false,
//            curve: Curves.easeInCirc,
//            overlayColor: Colors.black,
//            overlayOpacity: 0.5,
//            onOpen: () => print('OPENING DIAL'),
//            onClose: () => print('DIAL CLOSED'),
//            tooltip: 'Speed Dial',
//            heroTag: 'speed-dial-hero-tag',
//            backgroundColor: Colors.white,
//            foregroundColor: Colors.black,
//            elevation: 8.0,
//            shape: CircleBorder(),
//            children: [
//              SpeedDialChild(
//                  child: Icon(Icons.accessibility),
//                  backgroundColor: Colors.red,
//                  label: 'First',
//                  labelStyle: TextStyle(fontSize: 18.0),
//                  onTap: () => print('FIRST CHILD')
//              ),
//              SpeedDialChild(
//                child: Icon(Icons.brush),
//                backgroundColor: Colors.blue,
//                label: 'Second',
//                labelStyle: TextStyle(fontSize: 18.0),
//                onTap: () => print('SECOND CHILD'),
//              ),
//              SpeedDialChild(
//                child: Icon(Icons.keyboard_voice),
//                backgroundColor: Colors.green,
//                label: 'Third',
//                labelStyle: TextStyle(fontSize: 18.0),
//                onTap: () => print('THIRD CHILD'),
//              ),
//            ],
//          ),*/
//          bottomNavigationBar: SizedBox(
//            height: 70,
//            child: BottomNavigationBar(
//              type: BottomNavigationBarType.fixed,
//              currentIndex: _curIndex,
//              backgroundColor: white_color,
//              // this will be set when a new tab is tapped
//              onTap: (index) {
//                setState(() {
//                  print('CURENT IDEX____ $index');
//                  _curIndex = index;
//                  switch (_curIndex) {
//                    case 0:
//                      setState(() {
//                        homeClicked = true;
//                      });
//                      break;
//                    case 1:
//                      Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: (context) =>
//                                  BusinessPage()));
//                      break;
//                    case 2:
//                      Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: (context) =>
//                                  NewTweetPost(
//                                      currentUser, currentUserPhotoUrl)));
//                      break;
//                    case 3:
//                      Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: (context) =>
//                                  MakeTweetPost(
//                                      currentUser, currentUserPhotoUrl)));
//                      break;
//                  }
//                });
//              },
//              items: [
//                BottomNavigationBarItem(
//                  icon: homeClicked ? Container(
//                    margin: EdgeInsets.only(top: 15.0),
//                    child: new SvgPicture.asset(
//                      'images/home_highlight.svg',
//                      height: 20.0,
//                      width: 20.0,
//                    ),
//                  ) : Container(
//                    margin: EdgeInsets.only(top: 15.0),
//                    child: new SvgPicture.asset(
//                      'images/home.svg',
//                      height: 20.0,
//                      width: 20.0,
//                    ),
//                  ),
//                  title: new Text(''),
//                ),
//                BottomNavigationBarItem(
//                    title: new Text(''),
//                    icon: Container(
//                      margin: EdgeInsets.only(top: 15.0),
//                      child: new SvgPicture.asset(
//                        'images/business.svg',
//                        height: 20.0,
//                        width: 20.0,
//                      ),
//                    )
//                ),
//                BottomNavigationBarItem(
//                  icon: Container(
//                    margin: EdgeInsets.only(top: 15.0),
//                    child: new SvgPicture.asset(
//                      'images/post.svg', height: 20.0,
//                      width: 20.0,
//                    ),
//                  ),
//                  title: new Text(''),
//                ),
//                BottomNavigationBarItem(
//                    icon: Container(
//                      margin: EdgeInsets.only(top: 15.0),
//                      child: new SvgPicture.asset(
//                        'images/community.svg', height: 20.0,
//                        width: 20.0,
//                      ),
//                    ),
//                    title: Text('')
//                ),
//
//              ],
//            ),
//          ),
//          body: /*OfflineBuilder(
//              connectivityBuilder: (BuildContext context,
//                  ConnectivityResult connectivity,
//                  Widget child,) {
//                final bool connected = connectivity != ConnectivityResult.none;
//                return new Stack(
//                  fit: StackFit.expand,
//                  children: [
//                    Positioned(
//                      height: 24.0,
//                      left: 0.0,
//                      right: 0.0,
//                      child: Container(
//                        color: connected ? Color(0xFF00EE44) : Color(
//                            0xFFEE4400),
//                        child: Center(
//                          child: Text("${connected ? 'ONLINE' : 'OFFLINE'}"),
//                        ),
//                      ),
//                    ),*/
//          Stack(
//            children: <Widget>[
//
//              SingleChildScrollView(
//                child: Container(
//                    color: button_fill_color,
//                    height: 180,
//                    child: Column(
//                      children: <Widget>[
//                        Row(
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          children: <Widget>[
//                            new Container(
//                              margin: EdgeInsets.only(
//                                  left: 15.0, top: 20.0, right: 10.0),
//                              child:GestureDetector(
//                                onTap: (){
//                                  Navigator.push(
//                                      context,
//                                      MaterialPageRoute(
//                                          builder: (context) =>
//                                          new ProfilePageSetup(
//                                            userSignInType,
//                                            currentUserId: currentUser,)));
//                                },
//                                child:  Align(
//                                    alignment: Alignment.topLeft,
//                                    child: Row(
//                                      crossAxisAlignment: CrossAxisAlignment.start,
//                                      children: <Widget>[
//                                        new Container(
//                                          margin: EdgeInsets.only(
//                                              left: 5.0, top: 20.0, right: 10.0),
//                                          child: Material(
//                                            child: CachedNetworkImage(
//                                              placeholder: (context, url) =>
//                                                  Container(
//                                                    child: CircularProgressIndicator(
//                                                      strokeWidth: 2.0,
//                                                      valueColor: AlwaysStoppedAnimation<
//                                                          Color>(progress_color),
//                                                    ),
//                                                    width: 35.0,
//                                                    height: 35.0,
//                                                    padding: EdgeInsets.all(20.0),
//                                                  ),
//                                              errorWidget: (context, url, error) =>
//                                                  Material(
//                                                    child: new SvgPicture.asset(
//                                                      'images/user_unavailable.svg',
//                                                      height: 35.0,
//                                                      width: 35.0,
//                                                      fit: BoxFit.cover,
//                                                    ),
//                                                    borderRadius: BorderRadius.all(
//                                                      Radius.circular(5.0),
//                                                    ),
//                                                    clipBehavior: Clip.hardEdge,
//                                                  ),
//                                              imageUrl: currentUserPhotoUrl,
//                                              width: 35.0,
//                                              height: 35.0,
//                                              fit: BoxFit.cover,
//                                            ),
//                                            borderRadius: BorderRadius.all(
//                                              Radius.circular(18.0),
//                                            ),
//                                            clipBehavior: Clip.hardEdge,
//                                          ),
//                                          decoration: BoxDecoration(
//                                              borderRadius: BorderRadius.circular(
//                                                  30.0),border: Border.all(color: profile_image_border_color)
//                                          ),
//                                        ),
//                                        Container(
//                                          width : 70,
//                                          margin: EdgeInsets.only(
//                                              top: 30.0, right: 10.0),
//                                          child: Text(
//                                            currentUserName,
//                                            overflow: TextOverflow.ellipsis,
//                                            style: TextStyle(
//                                                color: text_color,
//                                                fontFamily: 'GoogleSansFamily',
//                                                fontWeight: FontWeight.w500),
//                                          ),
//                                        ),
//                                      ],
//                                    )
//                                ),
//                              ),
//                            ),
//
//
//                            Spacer(),
//
//                            Container(
//                              margin: EdgeInsets.only(
//                                  top: 20.0, left: 10.0),
//                              child: Align(
//                                alignment: Alignment.topRight,
//                                child: IconButton(
//                                  icon: new SvgPicture.asset(
//                                    'images/friend_request.svg',
//                                    height: 20.0,
//                                    width: 20.0,
//                                  ),
//                                  onPressed: () {
//                                    print('USER LIST getFriendList');
//                                    Navigator.push(
//                                        context,
//                                        MaterialPageRoute(
//                                            builder: (context) =>
//                                                FriendRequestScreenState(
//                                                    currentUser,
//                                                    currentUserPhotoUrl)));
//                                  },
//                                ),
//                              ),
//                            ),
//
//                            Container(
//                              margin: EdgeInsets.only(
//                                  top: 20.0),
//                              child: Align(
//                                alignment: Alignment.topRight,
//                                child: IconButton(
//                                  icon: new SvgPicture.asset(
//                                    'images/recent_chat.svg', height: 20.0,
//                                    width: 20.0,
//                                  ),
//                                  onPressed: () {
//                                    Navigator.push(
//                                        context,
//                                        MaterialPageRoute(
//                                            builder: (context) =>
//                                                RecentChatsScreen(
//                                                    currentUser,
//                                                    currentUserPhotoUrl)));
//                                  },
//                                ),
//                              ),
//                            ),
//                          ],
//                        ),
//                        Column(
//                          children: <Widget>[
//                            /* Container(
//                              margin: EdgeInsets.only(top: 5.0),
//                              child: Align(
//                                alignment: Alignment.topCenter,
//                                child: new SvgPicture.asset(
//                                  'images/home_chat.svg',
//                                  width: 90.0,
//                                  height: 90.0,
//                                ),
//                              ),
//                            ),
//                            Container(
//                              margin: EdgeInsets.only(
//                                  top: 10.0),
//                              child: Align(
//                                  alignment: Alignment.topCenter,
//                                  child: Text(
//                                    'Chat with people', style: TextStyle(
//                                      color: text_color,
//                                      fontFamily: 'GoogleSansFamily'),)
//                              ),
//                            ),
//                            Container(
//                              margin: EdgeInsets.only(
//                                  top: 5.0, left: 3.0, right: 3.0),
//                              child: UsersOnlinePage(
//                                  currentUser, currentUserPhotoUrl, this),
//                            )
//
//*/
//                            /*Container(
//                              margin: EdgeInsets.only(right: 50.0),
//                              child:Align(
//                              alignment: Alignment.bottomRight,
//                              child: DropdownButton<String>(
//                                value: dropdownValue,
//                                icon: Icon(Icons.arrow_drop_down),
//                                iconSize: 24,
//                                elevation: 16,
//                                style: TextStyle(color: Colors.red, fontSize: 18),
//                                underline: Container(
//                                  height: 2,
//                                  color: Colors.white,
//                                ),
//                                onChanged: (String data) {
//                                  setState(() {
//                                    dropdownValue = data;
//                                  });
//                                },
//                                items: spinnerItems.map<DropdownMenuItem<String>>((String value) {
//                                  return DropdownMenuItem<String>(
//                                    value: value,
//                                    child: Text(value),
//                                  );
//                                }).toList(),
//                              ),
//                            )
//                            )*/
//                          ],
//                        ),
//
//                      ],
//                    )
//                ),
//              ),
//
//              Align(
//                  alignment: Alignment.bottomLeft,
//                  child: Container(
//                      width: MediaQuery
//                          .of(context)
//                          .size
//                          .width,
//                      height: MediaQuery
//                          .of(context)
//                          .size
//                          .height - 180,
//                      decoration: BoxDecoration(
//                          color: text_color,
//                          borderRadius: new BorderRadius.only(
//                            topLeft: const Radius.circular(20.0),
//                            topRight: const Radius.circular(20.0),
//                          )
//                      ),
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.center,
//                        mainAxisAlignment: MainAxisAlignment.start,
//                        children: <Widget>[
//                          /* Container(
//                              width: 40.0,
//                              height: 5.0,
//                              margin: EdgeInsets.only(top: 5.0),
//                              decoration: BoxDecoration(
//                                color: greyColor2,
//                                borderRadius: BorderRadius.all(
//                                  Radius.circular(5.0),
//                                ),
//                              ),
//                              child: new SizedBox(
//                                height: 10.0,
//                                child: Divider(
//                                  color: greyColor2,
//                                  thickness: 2.0,
//                                ),
//                              )
//                          ),*/
//                          Align(
//                            alignment: Alignment.topLeft,
//                            child: Container(
//                                margin: EdgeInsets.only(left: 20.0,
//                                    top: 25.0),
//                                child: Text('Closest to you', style: TextStyle(
//                                    fontSize: 16.0,
//                                    fontFamily: 'GoogleSansFamily',
//                                    fontWeight: FontWeight.w500),)
//                            ),
//                          ),
//                          currentUser != '' && currentUser != null
//                              ? new ActiveUserListRadius(
//                              currentUser, currentUserPhotoUrl,
//                              _msliderData)
//                              : Container(),
//                          /*  new LoginUsersList(
//                              currentUser, currentUserPhotoUrl),*/
//                          Align(
//                            alignment: Alignment.bottomLeft,
//                            child: Container(
//                                margin: EdgeInsets.only(left: 20.0, top: 20.0),
//                                child: Text('Near by stores', style: TextStyle(
//                                    fontSize: 16.0,
//                                    fontFamily: 'GoogleSansFamily',
//                                    fontWeight: FontWeight.w500),)
//                            ),
//                          ),
//                          currentUser != '' && currentUser != null
//                              ?new BusinessListPage(
//                              currentUser, currentUserPhotoUrl,_currentUserBusinessId) : Container(),
//                          /*
//                          Align(
//                            alignment: Alignment.bottomLeft,
//                            child: Container(
//                                margin: EdgeInsets.only(left: 20.0,top: 20.0),
//                                child: Text('Businesses', style: TextStyle(
//                                    fontSize: 19.0,
//                                    fontFamily: 'GoogleSansFamily',
//                                    fontWeight: FontWeight.w500),),
//                            ),
//                          ),
//                      new BusinessListPage(
//                          currentUser, currentUserPhotoUrl),*/
//                        ],
//                      )
//                  )
//              ),
//
//              /*DraggableFloatingActionButton(
//                data: 'dfab_demo',
//                offset: new Offset(100, 100),
//                backgroundColor: Theme.of(context).accentColor,
//                child: new Icon(
//                  Icons.wb_incandescent,
//                  color: Colors.yellow,
//                ),
//                onPressed: () =>  SpeedDial(
//                  animatedIcon: AnimatedIcons.menu_close,
//                  animatedIconTheme: IconThemeData(size: 22.0),
//                  visible: false,
//                  curve: Curves.easeInCirc,
//                  overlayColor: Colors.black,
//                  overlayOpacity: 0.5,
//                  onOpen: () => print('OPENING DIAL'),
//                  onClose: () => print('DIAL CLOSED'),
//                  tooltip: 'Speed Dial',
//                  heroTag: 'speed-dial-hero-tag',
//                  backgroundColor: Colors.white,
//                  foregroundColor: Colors.black,
//                  elevation: 8.0,
//                  shape: CircleBorder(),
//                  children: [
//                    SpeedDialChild(
//                        child: Icon(Icons.accessibility),
//                        backgroundColor: Colors.red,
//                        label: 'First',
//                        labelStyle: TextStyle(fontSize: 18.0),
//                        onTap: () => print('FIRST CHILD')
//                    ),
//                    SpeedDialChild(
//                      child: Icon(Icons.brush),
//                      backgroundColor: Colors.blue,
//                      label: 'Second',
//                      labelStyle: TextStyle(fontSize: 18.0),
//                      onTap: () => print('SECOND CHILD'),
//                    ),
//                    SpeedDialChild(
//                      child: Icon(Icons.keyboard_voice),
//                      backgroundColor: Colors.green,
//                      label: 'Third',
//                      labelStyle: TextStyle(fontSize: 18.0),
//                      onTap: () => print('THIRD CHILD'),
//                    ),
//                  ],
//                ),
//                appContext: context,
//              ),
//*/
//
//            ],
//          )
////                  ],
////                );
////              },
////          );
//      ),
//    );
//  }
//
//
//  Future onBackPress() async {
//    print('USRELIST ONBACKPRESS');
//    Fluttertoast.showToast(msg: 'Please exit the App');
//  }
//
//  @override
//  void SliderChangeListenerACTIVE(double sliderData) {
//    print('USERR LIST NANDHU $sliderData');
//    if (sliderData != 10.0) {
//      setState(() {
//        _msliderData = sliderData;
//        sliderChanged = false;
//      });
//    } else if (_msliderData != null && sliderData == 100.0) {
//      setState(() {
//        _msliderData = sliderData;
//        sliderChanged = true;
//      });
//    }
//  }
//
//}
//
//abstract class SliderListenerUpdate {
//  void SliderChangeListenerACTIVE(double sliderData);
//}
//
//class UsersOnlinePage extends StatelessWidget implements SliderListener {
//  String currentUserId = '';
//  String mphotoUrl = '';
//  SliderListenerUpdate sliderListener;
//  double _msliderData = 0.0;
//
//
//  UsersOnlinePage(String currentUser, String photoUrl,
//      SliderListenerUpdate listState) {
//    currentUserId = currentUser;
//    mphotoUrl = photoUrl;
//    sliderListener = listState;
//  }
//
//
//  @override
//  Widget build(BuildContext context) {
//    return RangeSliderSample(this);
//  }
//
////  ActiveUserListRadiusState myAppState=new ActiveUserListRadiusState('');
//
//  @override
//  void SliderChangeListener(double sliderData) {
//    print('SliderChangeListener $sliderData');
////    myAppState.userListUpdate(sliderData);
//    if (sliderData != 0.0 || sliderData != 100.0) {
//      sliderListener.SliderChangeListenerACTIVE(sliderData);
//    }
//  }
//
//
//}
//
//abstract class SliderListener {
//  void SliderChangeListener(double sliderData);
//}
//
///*class ActiveUserListRadiusState extends StatefulWidget {
//
//  String _mcurrentUserId = ' ';
//  String photoUrl = '';
//
//  ActiveUserListRadiusState(String currentUserId, String mphotoUrl) {
//    _mcurrentUserId = currentUserId;
//    photoUrl = mphotoUrl;
//  }
//
//  @override
//  State<StatefulWidget> createState() {
//    return ActiveUserListRadius(_mcurrentUserId, photoUrl);
//  }
//
//  userListUpdate(double sliderData) {
//    print('userListUpdate  sliderData $sliderData');
//    if(sliderData != null)
//          ActiveUserListRadius(_mcurrentUserId, photoUrl).userListUpdate(sliderData);
//    else
//          LoginUsersList(
//          _mcurrentUserId, photoUrl);
//  }
//}*/
//
//class ActiveUserListRadius extends StatefulWidget{
//  String currentUserId = '';
//  String mphotoUrl = '';
//  double msliderData = 100.0;
//
//  ActiveUserListRadius(String currentUser, String photoUrl, double data) {
//    currentUserId = currentUser;
//    mphotoUrl = photoUrl;
//    msliderData = data;
//  }
//
//  @override
//  State<StatefulWidget> createState() {
//    return ActiveUserListRadiusState(currentUserId,mphotoUrl,msliderData);
//  }
//
//}
//
//
//class ActiveUserListRadiusState extends State<ActiveUserListRadius> {
//  String currentUserId = '';
//  String mphotoUrl = '';
//  double msliderData = 100.0;
//
//  GeoPoint mUserGeoPoint;
//  bool isLoading= false;
//
//
//  SharedPreferences _preferences;
//  String _businessType = '';
//  String _businessId = '';
//  String _userStatus = '';
//
//  ActiveUserListRadiusState(String currentUser, String photoUrl, double data) {
//    print('ActiveUserListRadius initialise $currentUser');
//    currentUserId = currentUser;
//    mphotoUrl = photoUrl;
//    msliderData = data;
//    initialise();
//  }
//
//  void initialise() async {
//    _preferences = await SharedPreferences.getInstance();
//    _businessType = await _preferences.getString('BUSINESS_TYPE');
//    _businessId = await _preferences.getString('BUSINESS_ID');
//    currentUserId = await _preferences.getString('userId');
//    isLoading = true;
//    if (currentUserId != '' && currentUserId != null)
//      getCurrentUserLocation(currentUserId, msliderData);
//
////    await updateUserStatus();
//  }
//
//  Stream<int> timedCounter(Duration interval, [int maxCount]) async* {
//    while (true) {
//      await Future.delayed(interval);
//      currentUserId = _preferences.getString('userId');
////      print('userDistanceISWITHINRADIUS ________________________${new DateTime.now()}________currentUserId __$currentUserId');
//      if (currentUserId != '' && currentUserId != null) {
//        Firestore.instance.collection('users').where(
//            'userDistanceISWITHINRADIUS', isEqualTo: 'YES').where(
//            'businessId', isEqualTo: '').where(
//            'status', isEqualTo: 'ACTIVE').snapshots();
//      }
//    }
//  }
//
//
//  @override
//  Widget build(BuildContext context) {
//
//    if (currentUserId != '' && currentUserId != null)
//      getCurrentUserLocation(currentUserId, msliderData);
//
//    return new StreamBuilder(
//        stream: Firestore.instance.collection('users') /*.where(
//            'userDistanceISWITHINRADIUS', isEqualTo: 'YES')*/ /*.where(
//            'businessId', isEqualTo: '').*/.where(
//            'status', isEqualTo: 'ACTIVE').orderBy('userDistance',descending: false)/*.orderBy(
//            'userDistance', descending: true)*/.snapshots(),
//        builder:
//            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//          if (!snapshot.hasData)
//            return new Container(
//              margin: EdgeInsets.only(left: 20.0, top: 20.0),
//              child: Center(
//                child: Text(no_users,
//                    style: TextStyle(fontFamily: 'GoogleSansFamily',)),),
//            );
//          else
//            return Flexible(
//                child: snapshot.data.documents.length == null ||
//                    snapshot.data.documents.length == 0 ? Center(
//                  child: Text(no_users),
//                ) : new ListView(
//                    scrollDirection: Axis.horizontal,
//                    children: snapshot.data.documents.map((document) {
//                      if (document.documentID != currentUserId) {
//                        return GestureDetector(
//                            onTap: () {
//                              getFriendList(context, currentUserId, document);
//                            },
//                            child: new Column(
//                              children: <Widget>[
//                                new Container(
//                                    margin: EdgeInsets.only(
//                                        left: 20.0, top: 15.0),
//                                    width: 60.0,
//                                    height: 60.0,
//                                    decoration: new BoxDecoration(
//                                        shape: BoxShape.circle,
//                                        border: Border.all(color: profile_image_border_color),
//                                        image: new DecorationImage(
//                                            fit: BoxFit.fill,
//                                            image: new NetworkImage(
//                                                document['photoUrl'])
//                                        )
//                                    )),
//                                new Container(
//                                  margin: EdgeInsets.only(
//                                      left: 20.0, top: 10.0),
//                                  child: Text(capitalize(document['name']),
//                                    style: TextStyle(
//                                        fontFamily: 'GoogleSansFamily',
//                                        fontWeight: FontWeight.w400,
//                                        color: black_color)
//                                    , textScaleFactor: 1.0,),
//                                ),
//                                /*mDistance != '' ? new Container(
//                                  margin: EdgeInsets.only(
//                                      left: 20.0, top: 5.0),
//                                  child: Text(
//                                      mDistance,
//                                      style: TextStyle(
//                                          fontFamily: 'GoogleSansFamily',
//                                          fontWeight: FontWeight.w400,
//                                          fontSize: 12.0,
//                                          color: hint_color_grey_light)
//                                      , textScaleFactor: 1.0),
//                                ) : Container()*/
//                              ],
//                            ));
//                      } else {
//                        if (snapshot.data.documents.length == 1)
//                          return Container(
//                              margin: EdgeInsets.only(left: 20.0, top: 20.0),
//                              child: Center(
//                                child: Text(no_users),
//                              )
//                          );
//                        else
//                          return Container(
//
//                          );
//                      }
//                    }).toList()
//                )
//            );
//        }
//    );
//  }
//
//
//  Widget buildLoading() {
//    return Container(
//        width: 50.0,
//        height: 20.0,
//        child: (CircularProgressIndicator(
//          valueColor: AlwaysStoppedAnimation<Color>(
//            Colors.green,
//          ),
//          backgroundColor: Colors.red,
//          value: 0.2,
//        )));
//  }
//
//  Widget builder(BuildContext context) {
//    return new StreamBuilder(
//        stream: Firestore.instance.collection('users')
//            .document(currentUserId)
//            .collection('FriendsList')
//            .snapshots(),
//        builder: (context, snapshot) {
//          if (!snapshot.hasData) {
//            return new Text("Loading", style: TextStyle(
//              fontFamily: 'GoogleSansFamily',));
//          }
//          var userDocument = snapshot.data;
//          print('FRIEND REQUEST ${userDocument['requestFrom']}');
//          return new Text(userDocument["requestFrom"], style: TextStyle(
//            fontFamily: 'GoogleSansFamily',));
//        }
//    );
//  }
//
//  Future getFriendList(BuildContext context, String currentUserId,
//      DocumentSnapshot documentSnapshot) async {
///*Navigator.push(
//        context,
//        MaterialPageRoute(
//            builder: (context) =>
//                Chat(
//                  currentUserId: currentUserId,
//                  peerId: friendId,
//                  peerAvatar: documentSnapshot['photoUrl'],
//                )));*/
//    bool isFriend = false;
//    bool isAlreadyRequestSent;
//    bool isRequestSent;
//
//    String friendId = documentSnapshot.documentID;
//
//    print(
//        'documentSnapshot _____getFriendList __ ${documentSnapshot['businessType']} ___businessId ${documentSnapshot['businessId']}');
//
//
////    var businessUser = await Firestore.instance.collection('users')
////        .document(friendId).get();
////    var businessData = businessUser.data;
//    var businessUserId = documentSnapshot['businessId'];
//    var businessUserType = documentSnapshot['businessType'];
////    print('Friend Listttttt queryyyy   ${businessUser
////        .data}__________user ${businessUser
////        .documentID} _______ $friendId __________________ ${businessData['id']}');
//    print(
//        'Friend Listttttt queryyyy _____businessUserId ${businessUserId} _____businessType $businessUserType _______ friendId ${friendId}');
///*
//    if ((businessUserId == null || businessUserId == '') &&
//        (businessUserType == '' || businessUserType == null)) {*/
//
//    var query = await Firestore.instance.collection('users')
//        .document(currentUserId).collection(
//        'FriendsList').getDocuments();
//
//    await _preferences.setString(
//        'FRIEND_USER_TOKEN', documentSnapshot.data['user_token']);
//    if (query.documents.length != 0) {
//      query.documents.forEach((doc) {
//        print('Friend Listttttt ${doc.data}');
//        if (doc.documentID == friendId &&
//            doc.data['IsAcceptInvitation'] == true) {
//          isFriend = true;
//        }
//
//        if (doc.documentID == friendId) {
//          isAlreadyRequestSent = doc.data['isAlreadyRequestSent'];
//          isRequestSent = doc.data['isRequestSent'];
//        }
//      });
//    } else {
//      isAlreadyRequestSent = false;
//      /*Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (context) =>
//                  Chat(
//                    currentUserId: currentUserId,
//                    peerId: friendId,
//                    peerAvatar: documentSnapshot['photoUrl'],
//                  )));*/
//    }
//    print(
//        'Friend Listttttt isFriend_______________________________________________${isRequestSent}');
//
//    if (isFriend) {
//      Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (context) =>
//                  Chat(
//                    currentUserId: currentUserId,
//                    peerId: friendId,
//                    peerAvatar: documentSnapshot['photoUrl'],
//                    isFriend: true,
//                    isAlreadyRequestSent: isAlreadyRequestSent,
//                    peerName: documentSnapshot['name'],
//                    chatType: CHAT_TYPE_USER,
//                  )));
//    } else {
//      print('USER lIST__________________________$isAlreadyRequestSent');
//      Navigator.push(
//          context, MaterialPageRoute(builder: (context) =>
//          SendInviteToUser(
//              friendId, currentUserId, documentSnapshot['photoUrl'],
//              isAlreadyRequestSent,
//              isRequestSent, documentSnapshot['name'])));
//      /*   Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (context) =>
//                  Chat(
//                      currentUserId: currentUserId,
//                      peerId: friendId,
//                      peerAvatar: mphotoUrl,
//                      isFriend: false,
//                      isAlreadyRequestSent: isAlreadyRequestSent
//                  )));*/
//    }
//    /* } else {
//      var businessUserName = documentSnapshot['businessName'];
//      Navigator.push(
//          context, MaterialPageRoute(builder: (context) =>
//          BusinessDetailPage(businessUserId, businessUserName)));
//    }*/
//  }
//
//  final Distance distance = new Distance();
//
//  Future<DocumentSnapshot> getCurrentUserLocation(String userId,
//      double sliderData) async {
//    DocumentSnapshot doc = await Firestore.instance.collection('users')
//        .document(userId).collection(
//        'userLocation').document(userId)
//        .get();
//    print('USER getCurrentUserLocation userid _________$userId');
//    if(doc.data != null) {
//      if (doc.data.length != 0) {
//        DocumentSnapshot map = doc;
//        GeoPoint geopoint = map['userLocation'];
//        getDocumentNearBy(geopoint.latitude, geopoint.longitude, sliderData);
//        print(
//            'USERCURRENT  GEO ${geopoint.latitude} ___ ${geopoint.longitude}');
//      }
//    }
//  }
//
//
//  Future<DocumentSnapshot> getUserLocation(double latitude, double longtitude,
//      String userId, double sliderData) async {
//    DocumentSnapshot doc = await Firestore.instance.collection('users')
//        .document(userId).collection(
//        'userLocation').document(userId)
//        .get();
//    DocumentSnapshot map = doc;
//    print('map_______________________________________ ${userId}');
//    isLoading = true;
//
//    if (map != null) {
//      if (map['userLocation'] != null /* &&
//        (_userStatus != '' && _userStatus == 'LOGIN')*/) {
//        GeoPoint geopoint = map['userLocation'];
//        // km = 423 // distance.as(LengthUnit.Kilometer,
//        double km = distance.distance(new LatLng(latitude, longtitude),
//            new LatLng(geopoint.latitude, geopoint.longitude));
//        if (/*(km != 0.0  */ /*sliderData >= km*/ /* */ /*km < 1000*/ /*) &&*/
//        userId != currentUserId) {
//          /* DocumentSnapshot userDocs = await Firestore.instance.collection('users')
//            .document(userId).get();
//        isLoading = false;
//        print('USER DETAILSSS ${userDocs.data.values} ____userId $userId');*/
//          /* Firestore.instance.collection('users').document(userId).updateData({
//            'userDistanceISWITHINRADIUS':
//            'YES',
//            'userDistance': km
//          });*/
//        } else {
//          /* Firestore.instance.collection('users').document(userId).updateData({
//            'userDistanceISWITHINRADIUS':
//            'NO',
//            'userDistance': km
//          });*/
//        }
//      }
//
//      await Future.delayed(Duration(milliseconds: 10000));
//
//      setState(() {
//
//      });
//    }
//  }
//
//
//  Future updateUserStatus() async {
//    _userStatus = await _preferences.getString('USERSTATUS');
//    if (currentUserId != '') {
//      int currentTime = ((new DateTime.now()
//          .toUtc()
//          .microsecondsSinceEpoch) / 1000).toInt();
//
//      var query = await Firestore.instance.collection('users')
//          .document(currentUserId).collection(
//          'userLocation').document(currentUserId).get();
//      print(
//          'USER STATUS_______________ $currentTime _____ ${query['UpdateTime']}______________${(currentTime >
//              query['UpdateTime'])} ___________________________userStatus $_userStatus');
//      if ((_userStatus != '' && _userStatus == 'LOGIN')) {
//        if (currentTime > (query['UpdateTime'] + INACTIVE_TIME)) {
//          Firestore.instance
//              .collection('users')
//              .document(currentUserId)
//              .updateData({'status': 'INACTIVE'});
//          if (_businessId != null && _businessId != '') {
//            await Firestore.instance
//                .collection('business')
//                .document(_businessId)
//                .updateData({'status': 'INACTIVE'});
//          }
//        } else {
//          Firestore.instance
//              .collection('users')
//              .document(currentUserId)
//              .updateData({'status': 'ACTIVE'});
//          if (_businessId != null && _businessId != '') {
//            await Firestore.instance
//                .collection('business')
//                .document(_businessId)
//                .updateData({'status': 'ACTIVE'});
//          }
//        }
//      }
//    }
//  }
//
//
//  Future getDocumentNearBy(double latitude, double longitude,
//      double distance) async {
//    var query = await Firestore.instance.collection('users').getDocuments();
//    query.documents.forEach((doc) {
////      print('User DOCCCCCCCCC' + doc.documentID);
//      if (doc.documentID != currentUserId)
//        getUserLocation(latitude, longitude, doc.documentID, distance);
//    });
//  }
//}
//
//
//class LoginUsersList extends StatelessWidget {
//  String currentUserId = '';
//  String mphotoUrl = '';
//
//  SharedPreferences _preferences;
//  String _businessType = '';
//  String _userStatus = '';
//
//  LoginUsersList(String currentUser, String photoUrl) {
//    currentUserId = currentUser;
//    mphotoUrl = photoUrl;
//    initialise();
//  }
//
//  void initialise() async {
//    _preferences = await SharedPreferences.getInstance();
//    _businessType = await _preferences.getString('BUSINESS_TYPE');
//    _userStatus = await _preferences.getString('USERSTATUS');
//  }
//
//
//  Stream<List<QuerySnapshot>> getData() {
//    Stream<List<QuerySnapshot>> addList = null;
//    Stream<QuerySnapshot> stream1 = Firestore.instance.collection('users')
//        .snapshots();
//    Stream<QuerySnapshot> stream2 = Firestore.instance.collection('business')
//        .snapshots();
//
//    return StreamZip([stream1, stream2]).asBroadcastStream();
//  }
//
//
//  Stream<int> timedCounter(Duration interval, [int maxCount]) async* {
//    while (true) {
//      await Future.delayed(interval);
//      currentUserId = _preferences.getString('userId');
//      print('LoginUsersList Stream ________________________${new DateTime
//          .now()}________currentUserId __$currentUserId');
//      if (currentUserId != '' && currentUserId != null) {
//        Firestore.instance.collection('users').snapshots();
//      }
//    }
//  }
//
//
//  Future sendInvite(String name, String photoUrl, String id,
//      String token) async {
//    print('sendInvite____________');
//    try {
//      /* var documentReference = Firestore.instance
//          .collection('users')
//          .document(_mCurrentUserId)
//          .collection('FriendsList')
//          .document(_mPeerId);*/
//      // Update data to server if new user
//
//      /*Firestore.instance.runTransaction((transaction) async {
//        await transaction.set(
//          documentReference,
//          {
//            'requestFrom': _mCurrentUserId,
//            'receiveId': _mPeerId,
//            'IsAcceptInvitation': false,
//            'isRequestSent': true,
//            'friendPhotoUrl': _userPhotoUrl,
//            'friendName': _userName,
//            'isAlreadyRequestSent': true,
//            'timestamp': DateTime
//                .now()
//                .millisecondsSinceEpoch
//                .toString(),
//          },
//        ).catchError((error){
//          error.toString();
//        });
//      })*/
//      /*   var documentReference1 = Firestore.instance
//            .collection('users')
//            .document(_mPeerId)
//            .collection('FriendsList')
//            .document(_mCurrentUserId);
//        Firestore.instance.runTransaction((transaction) async {
//          await transaction.set(
//            documentReference1,
//            {
//              'requestFrom': _mCurrentUserId,
//              'receiveId': _mPeerId,
//              'IsAcceptInvitation': false,
//              'isRequestSent': false,
//              'friendPhotoUrl': _userPhotoUrl,
//              'friendName': _userName,
//              'isAlreadyRequestSent': true,
//              'timestamp': DateTime
//                  .now()
//                  .millisecondsSinceEpoch
//                  .toString(),
//            },
//          ).catchError((error){
//            error.toString();
//          });
//        });*/
//
//      Firestore.instance
//          .collection('users')
//          .document(currentUserId)
//          .collection('FriendsList')
//          .document(id).setData({
//        'requestFrom': currentUserId,
//        'receiveId': id,
//        'IsAcceptInvitation': false,
//        'isRequestSent': true,
//        'friendPhotoUrl': photoUrl,
//        'friendName': name,
//        'isAlreadyRequestSent': true,
//        'timestamp': DateTime
//            .now()
//            .millisecondsSinceEpoch
//            .toString(),
//      }).whenComplete(() {
//        Firestore.instance
//            .collection('users')
//            .document(id)
//            .collection('FriendsList')
//            .document(currentUserId).setData({
//          'requestFrom': currentUserId,
//          'receiveId': id,
//          'IsAcceptInvitation': false,
//          'isRequestSent': false,
//          'friendPhotoUrl': photoUrl,
//          'friendName': name,
//          'isAlreadyRequestSent': true,
//          'timestamp': DateTime
//              .now()
//              .millisecondsSinceEpoch
//              .toString(),
//        });
//      }).whenComplete(() {
//        sendAndRetrieveMessage(name, token);
//      });
//    } on Exception catch (e) {
//      e.toString();
//    }
//  }
//
//  final String serverToken = SERVER_KEY;
//  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
//
//  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//
//  String _message = '';
//
//  Future<Map<String, dynamic>> sendAndRetrieveMessage(String name,
//      String _friendToken) async {
//    await firebaseMessaging.requestNotificationPermissions(
//      const IosNotificationSettings(sound: true, badge: true, alert: true),
//    );
//
//    await http.post(
//      'https://fcm.googleapis.com/fcm/send',
//      headers: <String, String>{
//        'Content-Type': 'application/json',
//        'Authorization': 'key=$serverToken',
//      },
//      body: jsonEncode(
//        <String, dynamic>{
//          'notification': <String, dynamic>{
//            'body': 'Friend Request from $name',
//            'title': 'Friend Request'
//          },
//          'priority': 'high',
//          'data': <String, dynamic>{
//            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//            'id': '1',
//            'status': 'done'
//          },
//          'to': _friendToken,
//        },
//      ),
//    );
//
//    final Completer<Map<String, dynamic>> completer =
//    Completer<Map<String, dynamic>>();
//    getMessage();
//    return completer.future;
//  }
//
//  Future _showNotificationWithDefaultSound(Map<String, dynamic> message) async {
//    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
//        'your channel id', 'your channel name', 'your channel description',
//        importance: Importance.Max, priority: Priority.High);
//    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
//    var platformChannelSpecifics = new NotificationDetails(
//        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//    await flutterLocalNotificationsPlugin.show(
//      0,
//      message["notification"]["title"],
//      message["notification"]["body"],
//      platformChannelSpecifics,
//      payload: 'Default_Sound',
//    );
//  }
//
//  void getMessage() {
//    firebaseMessaging.configure(
//        onMessage: (Map<String, dynamic> message) async {
//          print('on message $message');
//          _showNotificationWithDefaultSound(message);
//          _message = message["notification"]["title"];
//        }, onResume: (Map<String, dynamic> message) async {
//      print('on resume $message');
//      _showNotificationWithDefaultSound(message);
//      _message = message["notification"]["title"];
//    }, onLaunch: (Map<String, dynamic> message) async {
//      print('on launch $message');
//      _message = message["notification"]["title"];
//    });
//  }
//
//
//  @override
//  Widget build(BuildContext context) {
//    return new StreamBuilder(
////      stream: getData(),
//      stream: Firestore.instance.collection('users').snapshots(),
//      /*.where(
//          'status', isEqualTo: 'ACTIVE')*/ /*.snapshots(),
////      stream: timedCounter(Duration(seconds: 3000)),*/
//      builder:
//          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
////            print('LoginUsersList _________________ ${snapshot.data.documents.length}');
//
////      builder:
////          (BuildContext context,snapshot) {
//        if (!snapshot.hasData) return new Container(
//            margin: EdgeInsets.only(left: 20.0, top: 20.0),
//            child: new Text('Loading...', style: TextStyle(
//              fontFamily: 'GoogleSansFamily',)));
////        var documents = snapshot.data.length;
//        return Flexible(
//            child: snapshot.data.documents.length == null ||
//                snapshot.data.documents.length == 0 ||
//                snapshot.data.documents.length == 1 ? Center(
//              child: Text(no_users),
//            ) : new ListView(
//                scrollDirection: Axis.horizontal,
//                /* GridView.builder(
//              itemCount: snapshot.data.documents.length,
//              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4,mainAxisSpacing: 1,crossAxisSpacing:3),
//              itemBuilder: (BuildContext context, int index){
//                List<DocumentSnapshot> mList = snapshot.data.documents;
//                    if (mList[index].documentID != currentUserId) {
////                    updateUserStatus();
//                  if (mList[index]['businessType'] == BUSINESS_TYPE_OWNER ||
//                      mList[index]['businessType'] == '') {
//                    return GestureDetector(
//                        onTap: () {
//                          print(
//                              'ON TAPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP currentUserId $currentUserId');
//                          getFriendList(context, currentUserId, mList[index]);
//                        },
//                        child: new Column(
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          mainAxisAlignment: MainAxisAlignment.start,
//                          children: <Widget>[
//                            Stack(
//                                children: <Widget>[
//                                  mList[index]['photoUrl'] != null &&
//                                      mList[index]['photoUrl'] != ''
//                                      ? new Container(
//                                      margin: EdgeInsets.only(
//                                          left: 20.0, top: 10.0),
//                                      width: 60.0,
//                                      height: 60.0,
//                                      decoration: new BoxDecoration(
//                                          shape: BoxShape.circle,
//                                          image: new DecorationImage(
//                                              fit: BoxFit.fill,
//                                              image: new NetworkImage(
//                                                  mList[index]['photoUrl'])
//                                          )
//                                      ))
//                                      : mList[index]['photoUrl'] == ''
//                                      ? new Container(
//                                      margin: EdgeInsets.only(
//                                          left: 20.0, top: 10.0),
//                                      width: 60.0,
//                                      height: 60.0,
//                                      child: new SvgPicture.asset(
//                                        'images/user_unavailable.svg',
//                                        height: 10.0,
//                                        width: 10.0,
////                                          color: primaryColor,
//                                      ),
//                                      decoration: new BoxDecoration(
//                                        shape: BoxShape.circle,
//                                      ))
//                                      : Text(''),
//                                  mList[index]['status'] == 'ACTIVE' ? Container(
//                                      child: new SvgPicture.asset(
//                                        'images/online_active.svg',
//                                        height: 10.0,
//                                        width: 10.0,
////                                          color: primaryColor,
//                                      ),
//                                      margin: EdgeInsets.only(left: 70.0,
//                                          bottom: 30.0,
//                                          top: 10.0,
//                                          right: 5.0)) : mList[index]['status'] ==
//                                      'LoggedOut' ? Container(
//                                    child: new SvgPicture.asset(
//                                      'images/online_inactive.svg',
//                                      height: 10.0,
//                                      width: 10.0,
////                                        color: primaryColor,
//                                    ),
//                                    margin: EdgeInsets.only(left: 70.0,
//                                        bottom: 30.0,
//                                        top: 10.0,
//                                        right: 5.0),
//                                  ) : Container(
//                                    child: new SvgPicture.asset(
//                                      'images/online_idle.svg', height: 10.0,
//                                      width: 10.0,
////                                        color: primaryColor,
//                                    ),
//                                    margin: EdgeInsets.only(left: 70.0,
//                                        bottom: 30.0,
//                                        top: 10.0,
//                                        right: 5.0),
//                                  )
//                                ]
//                            ),
//                            new Container(
//                              margin: EdgeInsets.only(
//                                  left: 10.0, top: 10.0),
//                              child: Center(
//                                child: Text(capitalize(mList[index]['name']),
//                                    textScaleFactor: 1.0),
//                              ),
//                            )
//                          ],
//                        ));
//                  } else {
//                    return Container(
//                        margin: EdgeInsets.only(left: 20.0, top: 20.0),
//                        child: Center(
//                          child: Text(''),
//                        )
//                    );
//                  }
//                } else {
//                  return Container(
//                      margin: EdgeInsets.only(left: 20.0, top: 20.0),
//                      child: Center(
//                        child: Text(''),
//                      )
//                  );
//                }
//              },
//            ));*/
//                children: snapshot.data.documents.map((document) {
////                  print('Document idddd ${document.documentID}');
//                  if (document.documentID != currentUserId) {
////                    updateUserStatus();
////                    if (document['businessType'] == BUSINESS_TYPE_OWNER ||
////                        document['businessType'] == '') {
//                    return GestureDetector(
//                        onTap: () {
//                          print(
//                              'ON TAPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP currentUserId $currentUserId');
//                          getFriendList(context, currentUserId, document);
//                          /* Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                  builder: (context) =>
//                                      Chat(
//                                        currentUserId: currentUserId,
//                                        peerId: document.documentID,
//                                        peerAvatar: document['photoUrl'],
//                                        isFriend: null,
//                                          isAlreadyRequestSent  :null
//                                      )));*/
//                        },
//                        child: new Column(
//                          children: <Widget>[
//                            Stack(
//                                children: <Widget>[
//                                  document['photoUrl'] != null &&
//                                      document['photoUrl'] != ''
//                                      ? new Container(
//                                      margin: EdgeInsets.only(
//                                          left: 30.0, top: 20.0),
//                                      width: 60.0,
//                                      height: 60.0,
//                                      decoration: new BoxDecoration(
//                                          shape: BoxShape.circle,
//                                          border: Border.all(color: profile_image_border_color),
//                                          image: new DecorationImage(
//                                              fit: BoxFit.fill,
//                                              image: new NetworkImage(
//                                                  document['photoUrl'])
//                                          )
//                                      ))
//                                      : document['photoUrl'] == ''
//                                      ? new Container(
//                                      margin: EdgeInsets.only(
//                                          left: 30.0, top: 20.0),
//                                      width: 60.0,
//                                      height: 60.0,
//                                      child: new SvgPicture.asset(
//                                        'images/user_unavailable.svg',
//                                        height: 10.0,
//                                        width: 10.0,
////                                          color: primaryColor,
//                                      ),
//                                      decoration: new BoxDecoration(
//                                        shape: BoxShape.circle,
//                                      ))
//                                      : Text(''),
//                                  document['status'] == 'ACTIVE' ? Container(
//                                      child: new SvgPicture.asset(
//                                        'images/online_active.svg',
//                                        height: 15.0,
//                                        width: 15.0,
////                                          color: primaryColor,
//                                      ),
//                                      margin: EdgeInsets.only(left: 70.0,
//                                          bottom: 30.0,
//                                          top: 20.0,
//                                          right: 5.0)) : document['status'] ==
//                                      'LoggedOut' ? Container(
//                                    child: new SvgPicture.asset(
//                                      'images/online_inactive.svg',
//                                      height: 15.0,
//                                      width: 15.0,
////                                        color: primaryColor,
//                                    ),
//                                    margin: EdgeInsets.only(left: 70.0,
//                                        bottom: 30.0,
//                                        top: 20.0,
//                                        right: 5.0),
//                                  ) : Container(
//                                    child: new SvgPicture.asset(
//                                      'images/online_idle.svg', height: 15.0,
//                                      width: 15.0,
////                                        color: primaryColor,
//                                    ),
//                                    margin: EdgeInsets.only(left: 70.0,
//                                        bottom: 30.0,
//                                        top: 20.0,
//                                        right: 5.0),
//                                  )
//                                ]
//                            ),
//                            new Container(
//                              margin: EdgeInsets.only(left: 20.0, top: 10.0),
//                              child: Text(capitalize(document['name']),
//                                  textScaleFactor: 1.0, style: TextStyle(
//                                    fontFamily: 'GoogleSansFamily',)),
//                            )
//                          ],
//                        ));
//                    /* } else {
//                      return Container(
//                         */ /* margin: EdgeInsets.only(left: 20.0, top: 20.0),
//                          child: Center(
//                            child: Text(''),
//                          )*/ /*
//                      );
//                    }*/
//                  } else {
//                    return Container(
//                      /*   margin: EdgeInsets.only(left: 20.0, top: 20.0),
//                        child: Center(
//                          child: Text(''),
//                        )*/
//                    );
//                  }
////                  return new ListTile(
////                      title: new Text(document['name']),
////                      subtitle: new Text(document['status']));
//                }).toList()
//            )
//        );
//      },
//    );
//  }
//
//
//  Future getFriendList(BuildContext context, String currentUserId,
//      DocumentSnapshot documentSnapshot) async {
//    print('Login getFriendList');
//    bool isFriend = false;
//    bool isAlreadyRequestSent = false;
//    String friendId = documentSnapshot.documentID;
//    bool isRequestSent;
//    print(
//        'documentSnapshot _____getFriendList __ ${documentSnapshot['businessType']} ___businessId ${documentSnapshot['businessId']}');
//    var businessUserId = documentSnapshot['businessId'];
//    var businessUserType = documentSnapshot['businessType'];
//    print(
//        'Friend Listttttt queryyyy _____businessUserId ${businessUserId} _____businessType $businessUserType _______ friendId ${friendId}');
//    var query = await Firestore.instance.collection('users')
//        .document(currentUserId).collection(
//        'FriendsList').getDocuments();
//
//    await _preferences.setString(
//        'FRIEND_USER_TOKEN', documentSnapshot.data['user_token']);
//    if (query.documents.length != 0) {
//      query.documents.forEach((doc) {
//        print('Friend Listttttt ${doc.data}');
//        if (doc.documentID == friendId &&
//            doc.data['IsAcceptInvitation'] == true) {
//          isFriend = true;
//        }
//
//        if (doc.documentID == friendId) {
//          isAlreadyRequestSent = doc.data['isAlreadyRequestSent'];
//          isRequestSent = doc.data['isRequestSent'];
//        }
//      });
//    } else {
//      isAlreadyRequestSent = false;
//    }
//    print(
//        'Friend Listttttt isFriend_______________________________________________${isRequestSent}');
//
//    if (isFriend) {
//      Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (context) =>
//                  Chat(
//                    currentUserId: currentUserId,
//                    peerId: friendId,
//                    peerAvatar: documentSnapshot['photoUrl'],
//                    isFriend: true,
//                    isAlreadyRequestSent: isAlreadyRequestSent,
//                    peerName: documentSnapshot['name'],
//                    chatType: CHAT_TYPE_USER,
//                  )));
//    } else {
//      print('USER lIST__________________________$isAlreadyRequestSent');
//      /* await sendInvite(
//          documentSnapshot['name'], documentSnapshot['photoUrl'], friendId,
//          documentSnapshot.data['user_token']).whenComplete(() =>
//      {*/
//      Navigator.push(
//          context, MaterialPageRoute(builder: (context) =>
//          SendInviteToUser(
//              friendId, currentUserId, documentSnapshot['photoUrl'],
//              isAlreadyRequestSent,
//              isRequestSent, documentSnapshot['name'])));
////      });
//    }
//  }
//
//}
//
//
//class BusinessListPage extends StatefulWidget{
//  String currentUserId = '';
//  String mphotoUrl = '';
//  String _currentUserBusinessId= '';
//
//  BusinessListPage(String currentUser, String photoUrl,String currentUserBusinessId) {
//    currentUserId = currentUser;
//    mphotoUrl = photoUrl;
//    _currentUserBusinessId = currentUserBusinessId;
//  }
//  @override
//  State<StatefulWidget> createState() {
//    return BusinessListPageState(currentUserId,mphotoUrl,_currentUserBusinessId);
//  }
//}
//
//class BusinessListPageState extends State<BusinessListPage> {
//  String currentUserId = '';
//  String mphotoUrl = '';
//
//  SharedPreferences _preferences;
//  String _userStatus = '';
//  String _currentUserBusinessType = '';
//  String _currentUserBusinessId= '';
//
//  List<BusinessData> _mBusinessData = new List<BusinessData>();
//  final ScrollController listScrollController = new ScrollController();
//
//
//  BusinessListPageState(String currentUser, String photoUrl,String currentUserBusinessId) {
//    currentUserId = currentUser;
//    mphotoUrl = photoUrl;
//    _currentUserBusinessId = currentUserBusinessId;
//    initialise();
//  }
//
//  void initialise() async {
//    _preferences = await SharedPreferences.getInstance();
//    _userStatus = await _preferences.getString('USERSTATUS');
//    _currentUserBusinessType = await _preferences.getString('BUSINESS_TYPE');
//
//
//    /*  var query = await Firestore.instance.collection('business').getDocuments();
//
//    if (query.documents.length != 0) {
//      query.documents.forEach((doc) {
//        if( doc.data['businessId'] ==_currentUserBusinessId && (_currentUserBusinessType == BUSINESS_TYPE_OWNER || _currentUserBusinessType == BUSINESS_TYPE_EMPLOYEE)){
//
//        }else {
//          _mBusinessData.add(BusinessData(businessId: doc.data['businessId'],
//              businessName: doc.data['businessName'],
//              businessDistance: doc.data['businessDistance'],
//              businessPhotoUrl: doc.data['photoUrl'],
//              businessStatus: doc.data['status']));
//        }
//      });
//    } else {
//
//    }*/
//    if (currentUserId != '' && currentUserId != null)
//      getCurrentUserLocation(currentUserId);
//  }
//
//  final Distance distance = new Distance();
//
//  Future<DocumentSnapshot> getCurrentUserLocation(String userId) async {
//    print('BUSINESS_________________________CURRENT USER LOCATION');
//    DocumentSnapshot doc = await Firestore.instance.collection('users')
//        .document(userId).collection(
//        'userLocation').document(userId)
//        .get();
//    if (doc.data != null && doc.data.length != 0) {
//      DocumentSnapshot map = doc;
//      GeoPoint geopoint = map['userLocation'];
//      print('BUSINESS_________________________CURRENT USER LOCATION ___geopoint $geopoint ');
//      getDocumentNearBy(geopoint.latitude, geopoint.longitude);
//    }else{
//      print('BUSINESS_________________________CURRENT USER LOCATION ___geopoint DATA NULL LENGTH 0 ');
//    }
//  }
//
//
//  Future getDocumentNearBy(double latitude, double longitude) async {
//    print('BUSINESS_________________________CURRENT USER LOCATION getDocumentNearBy');
//    var query = await Firestore.instance.collection('business').where('status',isEqualTo: 'ACTIVE').getDocuments();
//    query.documents.forEach((doc) {
//      getBusinessLocation(latitude, longitude, doc.documentID);
//    });
//  }
//
//
//  Future<DocumentSnapshot> getBusinessLocation(double latitude, double longtitude,
//      String businesssId) async {
//    print('BUSINESS_________________________CURRENT USER LOCATION getBusinessLocation businesssId___$businesssId');
//    DocumentSnapshot doc = await Firestore.instance.collection('business')
//        .document(businesssId).collection(
//        'businessLocation').document(businesssId)
//        .get();
//    DocumentSnapshot map = doc;
//    print('BUSINESS_________________________CURRENT USER LOCATION getBusinessLocation DocumentSnapshot ${map['businessLocation']}');
//    if (map['businessLocation'] != null /*&&
//        (_userStatus != '' && _userStatus == 'LOGIN')*/) {
//      GeoPoint geopoint = map['businessLocation'];
//      double km = distance.distance(new LatLng(latitude, longtitude),
//          new LatLng(geopoint.latitude, geopoint.longitude));
//      print('BUSINESS_________________________CURRENT USER LOCATION getBusinessLocation USER DISTANCE $km');
//
//      print('BUSINESS_________________________CURRENT USER LOCATION getBusinessLocation USER mDistance $km');
//
//      print('BUSINESS_________________________CURRENT USER LOCATION getBusinessLocation BUSINESS id __$businesssId ___currentBusinessId $_currentUserBusinessId');
//
//      /*  if ((km != 0.0   sliderData >= km   km < 1000 ) &&
//      userId != _currentUserBusinessId) {*/
//      if(businesssId != _currentUserBusinessId){
//        /* DocumentSnapshot userDocs = await Firestore.instance.collection('users')
//            .document(userId).get();
////        isLoading = false;
//        print('USER DETAILSSS ${userDocs.data.values} ____userId $userId');*/
//
//
//
//        /*Firestore.instance.collection('business').document(businesssId).updateData({
//          'businessDistanceISWITHINRADIUS':
//          'YES',
//          'businessDistance': km.toString()
//        });*/
//      } else {
//        /* Firestore.instance.collection('business').document(businesssId).updateData({
//          'businessDistanceISWITHINRADIUS':
//          'NO',
//          'businessDistance': km.toString()
//        });*/
//      }
//      await Future.delayed(Duration(milliseconds: 10000));
//      setState(() {
//
//      });
//    }else{
//      print('BUSINESS_________________________CURRENT USER LOCATION getBusinessLocation DocumentSnapshot MAP NULL');
//    }
//
//  }
//
//
//  @override
//  Widget build(BuildContext context) {
//    print('LoginUsersList _________________BUSINEDS ${new DateTime.now()}');
//    if (currentUserId != '' && currentUserId != null)
//      getCurrentUserLocation(currentUserId);
//
//    return new StreamBuilder(
//      stream: Firestore.instance.collection('business') /*.where(
//          'businessDistanceISWITHINRADIUS', isEqualTo: 'YES')*/ /*.where(
//            'businessId', isEqualTo: '').*/ .where(
//          'status', isEqualTo: 'ACTIVE')/*.orderBy('businessDistance',descending: false)*//*.orderBy('businessDistance',descending: true)*/
//          .snapshots(),
//      builder:
//          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//
//        if (!snapshot.hasData) return new Container(
//            margin: EdgeInsets.only(left: 20.0, top: 20.0),
//            child: new Text('Loading...', style: TextStyle(
//              fontFamily: 'GoogleSansFamily',)));
//        return Flexible(
//            child: snapshot.data.documents.length == null ||
//                snapshot.data.documents.length == 0 ? Center(
//              child: Text(noBusiness),
//            ) : new ListView(
//                scrollDirection: Axis.horizontal,
//                children: snapshot.data.documents.map((document) {
//                  /* var mDistance ='';
//                  var km;
//                  if(document['businessDistance'] != null ) {
//                    if (document['businessDistance'] > 1000) {
//                      km = (document['businessDistance'].toInt()) / 1000;
//                      mDistance = km.toString() + '\t' + 'km';
//                    } else {
//                      mDistance = document['businessDistance'].toInt().toString() + '\t' + 'm';
//                    }
//                  }*/
//
//                  /*    var mDistance ='';
//                  var km;
//                  if(document['businessDistance'] != null ) {
//                    var mtest = document['businessDistance'];
////                    mtest = mtest.replaceAll('m', '');
////                    mtest = mtest.replaceAll('km', '');
////                    mtest = mtest.replaceAll(' ','');
//                    if (int.parse(mtest) > 1000) {
//                      km = (int.parse(mtest)) / 1000;
//                      mDistance = km.toString() + '\t' + 'km';
//                    } else {
//                      mDistance = int.parse(mtest).toString() + '\t' + 'm';
//                    }
//                  }*/
//                  print('Document idddd ${_currentUserBusinessId}');
//                  if (document['businessId'] != _currentUserBusinessId) {
////                    updateUserStatus();
////                    if (document['businessType'] == BUSINESS_TYPE_OWNER ||
////                        document['businessType'] == '') {
//                    return GestureDetector(
//                        onTap: () {
//                          print(
//                              'ON TAPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP currentUserId $currentUserId');
//                          getFriendList(context, currentUserId, document);
//                        },
//                        child: new Column(
//                          children: <Widget>[
//                            Stack(
//                                children: <Widget>[
//                                  document['photoUrl'] != null &&
//                                      document['photoUrl'] != ''
//                                      ? new Container(
//                                      margin: EdgeInsets.only(
//                                          left: 20.0, top: 20.0),
//                                      width: 60.0,
//                                      height: 60.0,
//                                      decoration: new BoxDecoration(
//                                          shape: BoxShape.circle,
//                                          border: Border.all(color: profile_image_border_color),
//                                          image: new DecorationImage(
//                                            fit: BoxFit.fill,
//                                            image: new NetworkImage(
//                                                document['photoUrl']),
//                                          )
//                                      )
//                                  )
//                                      : document['photoUrl'] == ''
//                                      ? new Container(
//                                      margin: EdgeInsets.only(
//                                          left: 20.0, top: 10.0),
//                                      width: 60.0,
//                                      height: 60.0,
//                                      child: new SvgPicture.asset(
//                                        'images/user_unavailable.svg',
//                                        height: 10.0,
//                                        width: 10.0,
////                                          color: primaryColor,
//                                      ),
//                                      decoration: new BoxDecoration(
//                                        shape: BoxShape.circle,
//                                      ))
//                                      : Text(''),
//                                  /*document['status'] == 'ACTIVE' ? Container(
//                                      child: new SvgPicture.asset(
//                                        'images/online_active.svg',
//                                        height: 15.0,
//                                        width: 15.0,
////                                          color: primaryColor,
//                                      ),
//                                      margin: EdgeInsets.only(left: 60.0,
//                                          bottom: 30.0,
//                                          top: 10.0,
//                                          right: 10.0)) : document['status'] ==
//                                      'LoggedOut' ? Container(
//                                    child: new SvgPicture.asset(
//                                      'images/online_inactive.svg',
//                                      height: 15.0,
//                                      width: 15.0,
////                                        color: primaryColor,
//                                    ),
//                                    margin: EdgeInsets.only(left: 60.0,
//                                        bottom: 30.0,
//                                        top: 10.0,
//                                        right: 10.0),
//                                  ) : Container(
//                                    child: new SvgPicture.asset(
//                                      'images/online_idle.svg', height: 15.0,
//                                      width: 15.0,
////                                        color: primaryColor,
//                                    ),
//                                    margin: EdgeInsets.only(left: 60.0,
//                                        bottom: 30.0,
//                                        top: 10.0,
//                                        right: 10.0),
//                                  )*/
//                                ]
//                            ),
//                            new Container(
//                              width : 70,
//                              margin: EdgeInsets.only(left: 20.0, top: 10.0),
//                              child: Text(capitalize(document['businessName']),
//                                  overflow: TextOverflow.ellipsis,
//                                  textAlign: TextAlign.center,
//                                  textScaleFactor: 1.0, style: TextStyle(
//                                      fontFamily: 'GoogleSansFamily',color: black_color,fontWeight: FontWeight.w400)),
//                            ),
//                            /*  mDistance != '' ? new Container(
//                                margin: EdgeInsets.only(left: 20.0, top: 10.0),
//                                child: Text(mDistance,
//                                    textScaleFactor: 1.0, style: TextStyle(
//                                        fontSize: 12.0,
//                                        fontFamily: 'GoogleSansFamily',color: hint_color_grey_light,fontWeight: FontWeight.w400)),
//                              ) : Container()*/
//                          ],
//                        ));
//                    /* } else {
//                      return Container(
//                         */ /* margin: EdgeInsets.only(left: 20.0, top: 20.0),
//                          child: Center(
//                            child: Text(''),
//                          )*/ /*
//                      );
//                    }*/
//                  } else {
//                    return Container(
////                        margin: EdgeInsets.only(left: 20.0, top: 20.0),
////                        child: Center(
////                          child: Text(''),
////                        )
//                    );
//                  }
//                }).toList()
//            )
//        );
//      },
//    );
//  }
//
//
//  Widget buildListBusinesses(BuildContext context) {
//    return Container(
//        child:
//        (_mBusinessData != null && _mBusinessData.length != 0) ? ListView
//            .builder(
//          itemBuilder: (context, index) =>
//              buildBusiness(index, _mBusinessData, context),
//          itemCount: _mBusinessData.length,
//          scrollDirection: Axis.horizontal,
//          controller: listScrollController,
//        ) : Center(
//          child: Text('No recent chats'),
//        )
//    );
//  }
//
//  Widget buildBusiness(int index, List<BusinessData> mBusinessData,
//      BuildContext context,) {
//    if (mBusinessData.length == 0) {
//      return Center(
//          child: Text(no_business));
//    } else if (mBusinessData.length > 0 && mBusinessData.length != 0) {
//      return GestureDetector(
//          onTap: () {
//            print(
//                'ON TAPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP currentUserId $currentUserId');
//            getFriendListNew(context, currentUserId, mBusinessData[index]);
//          },
//          child: new Column(
//            children: <Widget>[
//              Stack(
//                  children: <Widget>[
//                    mBusinessData[index].businessPhotoUrl != null &&
//                        mBusinessData[index].businessPhotoUrl != ''
//                        ? new Container(
//                        margin: EdgeInsets.only(
//                            left: 20.0, top: 15.0),
//                        width: 60.0,
//                        height: 60.0,
//                        decoration: new BoxDecoration(
//                            shape: BoxShape.circle,
//                            border: Border.all(color: profile_image_border_color),
//                            image: new DecorationImage(
//                                fit: BoxFit.fill,
//                                image: new NetworkImage(
//                                    mBusinessData[index].businessPhotoUrl)
//                            )
//                        ))
//                        : mBusinessData[index].businessPhotoUrl == ''
//                        ? new Container(
//                        margin: EdgeInsets.only(
//                            left: 20.0, top: 10.0),
//                        width: 60.0,
//                        height: 60.0,
//                        child: new SvgPicture.asset(
//                          'images/user_unavailable.svg',
//                          height: 10.0,
//                          width: 10.0,
////                                          color: primaryColor,
//                        ),
//                        decoration: new BoxDecoration(
//                          shape: BoxShape.circle,
//                        ))
//                        : Text(''),
//                    mBusinessData[index].businessStatus == 'ACTIVE' ? Container(
//                        child: new SvgPicture.asset(
//                          'images/online_active.svg',
//                          height: 15.0,
//                          width: 15.0,
////                                          color: primaryColor,
//                        ),
//                        margin: EdgeInsets.only(left: 60.0,
//                            bottom: 30.0,
//                            top: 10.0,
//                            right: 10.0)) : mBusinessData[index]
//                        .businessStatus ==
//                        'LoggedOut' ? Container(
//                      child: new SvgPicture.asset(
//                        'images/online_inactive.svg',
//                        height: 15.0,
//                        width: 15.0,
////                                        color: primaryColor,
//                      ),
//                      margin: EdgeInsets.only(left: 60.0,
//                          bottom: 30.0,
//                          top: 10.0,
//                          right: 10.0),
//                    ) : Container(
//                      child: new SvgPicture.asset(
//                        'images/online_idle.svg', height: 15.0,
//                        width: 15.0,
////                                        color: primaryColor,
//                      ),
//                      margin: EdgeInsets.only(left: 60.0,
//                          bottom: 30.0,
//                          top: 10.0,
//                          right: 10.0),
//                    )
//                  ]
//              ),
//              new Container(
//                margin: EdgeInsets.only(left: 20.0, top: 10.0),
//                child: Text(capitalize(mBusinessData[index].businessName),
//                    textScaleFactor: 1.0, style: TextStyle(
//                      fontFamily: 'GoogleSansFamily',)),
//              )
//            ],
//          ));
//    }
//  }
//
//  Future getFriendList(BuildContext context, String currentUserId,
//      DocumentSnapshot documentSnapshot) async {
//    var businessUserName = documentSnapshot['businessName'];
//    Navigator.push(
//        context, MaterialPageRoute(builder: (context) =>
//        BusinessDetailPage(documentSnapshot['businessId'], businessUserName)));
//  }
//
//
//  Future getFriendListNew(BuildContext context, String currentUserId,
//      BusinessData businessData) async {
//    var businessUserName = businessData.businessName;
//    Navigator.push(
//        context, MaterialPageRoute(builder: (context) =>
//        BusinessDetailPage(businessData.businessId, businessUserName)));
//  }
//}