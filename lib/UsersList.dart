import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/FriendRequestScreen.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/business/BusinessDetailPage.dart';
import 'package:virus_chat_app/profile/ProfilePage.dart';
import 'package:virus_chat_app/SendInviteScreen.dart';
import 'package:virus_chat_app/audiop/MyAudioEx.dart';
import 'package:virus_chat_app/business/BusinessPage.dart';
import 'package:virus_chat_app/chat/AudioChatsss.dart';
import 'package:virus_chat_app/chat/RecentChatsScreen.dart';
import 'package:virus_chat_app/chat/chat.dart';
import 'package:virus_chat_app/tweetPost/NewTweetPost.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/rangeSlider/RangeSliderPage.dart';
import 'package:virus_chat_app/tweetPost/MakeTweetPost.dart';
import 'package:http/http.dart' as http;
import 'package:virus_chat_app/utils/const.dart';
import 'package:virus_chat_app/utils/strings.dart';


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
      title: 'Flutter Demo',
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
}

class UsersListPage extends StatefulWidget {
  String currentUserId = '';
  String signInType = '';
  String mphotoUrl = '';

  UsersListPage(String currentUser, String userSignInType, String photoUrl) {
    currentUserId = currentUser;
    signInType = userSignInType;
    mphotoUrl = photoUrl;
  }

  @override
  State<StatefulWidget> createState() {
    return UsersListState(currentUserId, signInType, mphotoUrl);
  }
}

class UsersListState extends State<UsersListPage>
    implements SliderListenerUpdate {
  String currentUserPhotoUrl = '';
  String currentUserName = '';
  String currentUser = '';
  String userSignInType = '';
  SharedPreferences prefs;
  bool sliderChanged = true;
  double _msliderData = 100.0;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  UsersListState(String currentUserId, String signInType, String mphotoUrl) {
    currentUser = currentUserId;
    userSignInType = signInType;
    currentUserPhotoUrl = mphotoUrl;
  }

  @override
  void initState() {
//    test();
    initialise();
    setState(() {});
    super.initState();
  }

  Future initialise() async {
    prefs = await SharedPreferences.getInstance();
    currentUserName = await prefs.getString('name');
    if (userSignInType == '') {
      userSignInType = await prefs.getString('signInType');
    }
    if (currentUserPhotoUrl == '') {
      currentUserPhotoUrl = await prefs.getString('photoUrl');
    }
    print('USERLIST name_____ $currentUserName');

    var query = await Firestore.instance.collection('users')
        .document(currentUser).collection(
        'userLocation').document(currentUser).get();
    print('User Update status ___ ${currentUser} ___ ${query['UpdateTime']}');
    int currentTime = ((new DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch) / 1000).toInt();

    if (currentUser != '') {
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
    }
    LocationService(currentUser).locationStream;
    /*for(int i=5;i<250;i+5){
      spinnerItems.add('$i m');
    }*/
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
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
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
    initialise();
    return WillPopScope(
      onWillPop: () async => false,
      child: new Scaffold(
          bottomNavigationBar: SizedBox(
            height: 70,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _curIndex,
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
                        color: facebook_color,
                        height: MediaQuery
                            .of(context)
                            .size
                            .height - 260,
                        child: Column(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            new ProfilePage(
                                              userSignInType,
                                              currentUserId: currentUser,)));
                                  },
                                  child: new Container(
                                    margin: EdgeInsets.only(
                                        left: 15.0, top: 30.0, right: 10.0),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Container(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 1.0,
                                                  valueColor: AlwaysStoppedAnimation<
                                                      Color>(themeColor),
                                                ),
                                                width: 35.0,
                                                height: 35.0,
                                                padding: EdgeInsets.all(10.0),
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
                                    ),
                                  ),
                                ),

                                Container(
                                  margin: EdgeInsets.only(
                                      top: 40.0, right: 10.0),
                                  child: Text(
                                    currentUserName, style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: text_color),
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
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 20.0, right: 15.0),
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
                                )
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Container(
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
                                          color: text_color),)
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 5.0, left: 3.0, right: 3.0),
                                  child: UsersOnlinePage(
                                      currentUser, currentUserPhotoUrl, this),
                                )


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
                          height: 260,
                          decoration: BoxDecoration(
                              color: text_color,
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(30.0),
                                topRight: const Radius.circular(30.0),
                              )
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                    margin: EdgeInsets.only(left: 20.0,
                                        top: 5.0),
                                    child: Text('People', style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19.0),)
                                ),
                              ),
                              new LoginUsersList(
                                  currentUser, currentUserPhotoUrl),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                    margin: EdgeInsets.only(left: 20.0,),
                                    child: Text('Active', style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19.0),)
                                ),
                              ),
                              new ActiveUserListRadius(
                                  currentUser, currentUserPhotoUrl,
                                  _msliderData)

                            ],
                          )
                      )
                  ),
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


}

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


class ActiveUserListRadius extends StatelessWidget {
  String currentUserId = '';
  String mphotoUrl = '';
  double msliderData = 100.0;

  GeoPoint mUserGeoPoint;

  bool isLoading = false;


  SharedPreferences _preferences;
  String _businessType = '';

  ActiveUserListRadius(String currentUser, String photoUrl, double data) {
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
    msliderData = data;
    initialise();
  }

  void initialise() async {
    _preferences = await SharedPreferences.getInstance();
    _businessType = await _preferences.getString('BUSINESS_TYPE');
    print('ActiveUserListRadius initialise $msliderData');
    isLoading = true;
    getCurrentUserLocation(currentUserId, msliderData);
  }

  @override
  Widget build(BuildContext context) {
    print('userDistanceISWITHINRADIUS BUILDDDDDDDDDDD');
    return new StreamBuilder(
        stream: Firestore.instance.collection('users').where(
            'userDistanceISWITHINRADIUS', isEqualTo: 'YES').where(
            'businessId', isEqualTo: '').where(
            'status', isEqualTo: 'ACTIVE').snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//              if(isLoading == true)   return Center(
//                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)));;
          if (!snapshot.hasData)
            return new Container(
                margin: EdgeInsets.only(left: 20.0, top: 20.0),
                child: new Text('Loading...'));
          else
            return Expanded(
                child: new ListView(
                    scrollDirection: Axis.horizontal,
                    children: snapshot.data.documents.map((document) {
                      print(
                          'Document idddd ACTIVEEEEEEEEEEEEEEEEE${currentUserId}');
                      if (document.documentID != currentUserId) {
                        return GestureDetector(
                            onTap: () {
                              print(
                                  'ON TAPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP currentUserId $currentUserId');
                              getFriendList(context, currentUserId, document);
                              /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Chat(
                                        currentUserId: currentUserId,
                                        peerId: document.documentID,
                                        peerAvatar: document['photoUrl'],
                                        isFriend: null,
                                          isAlreadyRequestSent  :null
                                      )));*/
                            },
                            child: new Column(

                              children: <Widget>[
                                new Container(
                                    margin: EdgeInsets.only(
                                        left: 20.0, top: 10.0),
                                    width: 60.0,
                                    height: 60.0,
                                    decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
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
                                      textScaleFactor: 1.0),
                                )
                              ],
                            ));
                      } else {
                        return Container(
                            margin: EdgeInsets.only(left: 20.0, top: 20.0),
                            child: Center(
                              child: Text(''),
                            )
                        );
                      }
                      /*  return new ListTile(
                title: new Text(document['name']),
                subtitle: new Text(document['status']));*/
                    }).toList()
                )
            );
        }
    );
    /*  return Column(
      children: <Widget>[
      */ /*  new StreamBuilder(
            stream: Firestore.instance.collection('users').document(currentUserId).collection('FriendsList').documen().where(
                'userDistanceISWITHINRADIUS', isEqualTo: 'YES').where(
                'status', isEqualTo: 'ACTIVE').snapshots(),
            builder:
                (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              print('locationStream');
              if (!snapshot.hasData) return new Text('Loading...');
              return
            }
        ),*/ /*

      ],
    );*/
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
            return new Text("Loading");
          }
          var userDocument = snapshot.data;
          print('FRIEND REQUEST ${userDocument['requestFrom']}');
          return new Text(userDocument["requestFrom"]);
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

    var businessUser = await Firestore.instance.collection('users')
        .document(friendId).get();
    var businessData = businessUser.data;
    var businessUserId = businessUser['businessId'];
    print('Friend Listttttt queryyyy   ${businessUser
        .data}__________user ${businessUser
        .documentID} _______ $friendId __________________ ${businessData['id']}');

    if ((businessUserId == null || businessUserId == '') &&
        (_businessType == '' || _businessType == null)) {
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
                      peerAvatar: mphotoUrl,
                      isFriend: true,
                      isAlreadyRequestSent: isAlreadyRequestSent,
                      peerName: documentSnapshot['name'],
                    )));
      } else {
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
    } else {
      var businessUserName = businessUser['businessName'];
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>
          BusinessDetailPage(businessUserId, businessUserName)));
    }
  }

  final Distance distance = new Distance();

  Future<DocumentSnapshot> getCurrentUserLocation(String userId,
      double sliderData) async {
    DocumentSnapshot doc = await Firestore.instance.collection('users')
        .document(userId).collection(
        'userLocation').document(userId)
        .get();
    if (doc.data.length != 0) {
      DocumentSnapshot map = doc;
      GeoPoint geopoint = map['userLocation'];
      getDocumentNearBy(geopoint.latitude, geopoint.longitude, sliderData);
      print('USERCURRENT  GEO ${geopoint.latitude} ___ ${geopoint.longitude}');
    }
  }


  Future<DocumentSnapshot> getUserLocation(double latitude, double longtitude,
      String userId, double sliderData) async {
    DocumentSnapshot doc = await Firestore.instance.collection('users')
        .document(userId).collection(
        'userLocation').document(userId)
        .get();
    DocumentSnapshot map = doc;
    print('map_______________________________________ ${map.exists}');
    isLoading = true;
    if (map['userLocation'] != null) {
      GeoPoint geopoint = map['userLocation'];
      // km = 423 // distance.as(LengthUnit.Kilometer,
      final double km = distance.distance(new LatLng(latitude, longtitude),
          new LatLng(geopoint.latitude, geopoint.longitude));
      print('USER DISTANCE $km');
      print('USER GEO ${geopoint.latitude} ___ ${geopoint.longitude}');
      if ((km == 0.0 || /*sliderData >= km*/ km < sliderData) &&
          userId != currentUserId) {
        DocumentSnapshot userDocs = await Firestore.instance.collection('users')
            .document(userId).get();
        isLoading = false;
        print('USER DETAILSSS ${userDocs.data.values} ____userId $userId');
        Firestore.instance.collection('users').document(userId).updateData({
          'userDistanceISWITHINRADIUS':
          'YES'
        });
      } else {
        Firestore.instance.collection('users').document(userId).updateData({
          'userDistanceISWITHINRADIUS':
          'NO'
        });
      }
    }
  }

  Future getDocumentNearBy(double latitude, double longitude,
      double distance) async {
    var query = await Firestore.instance.collection('users').getDocuments();
    query.documents.forEach((doc) {
      print('User DOCCCCCCCCC' + doc.documentID);
      if (doc.documentID != currentUserId)
        getUserLocation(latitude, longitude, doc.documentID, distance);
    });
  }
}

class LoginUsersList extends StatelessWidget {
  String currentUserId = '';
  String mphotoUrl = '';

  SharedPreferences _preferences;
  String _businessType = '';

  LoginUsersList(String currentUser, String photoUrl) {
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
    initialise();
  }

  void initialise() async {
    _preferences = await SharedPreferences.getInstance();
    _businessType = await _preferences.getString('BUSINESS_TYPE');
  }

  Future updateUserStatus() async {
    if (currentUserId != '') {
      int currentTime = ((new DateTime.now()
          .toUtc()
          .microsecondsSinceEpoch) / 1000).toInt();

      var query = await Firestore.instance.collection('users')
          .document(currentUserId).collection(
          'userLocation').document(currentUserId).get();
      print(
          'USER STATUS_______________ $currentTime _____ ${query['UpdateTime']}');
      if (currentTime > query['UpdateTime']) {
        Firestore.instance
            .collection('users')
            .document(currentUserId)
            .updateData({'status': 'INACTIVE'});
      } else {
        Firestore.instance
            .collection('users')
            .document(currentUserId)
            .updateData({'status': 'ACTIVE'});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('users') /*.where(
          'status', isEqualTo: 'ACTIVE')*/.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Container(
            margin: EdgeInsets.only(left: 20.0, top: 20.0),
            child: new Text('Loading...'));
        return Flexible(
            child: new ListView(
                scrollDirection: Axis.horizontal,
                children: snapshot.data.documents.map((document) {
                  print('Document idddd ${document.documentID}');
                  if (document.documentID != currentUserId) {
                    updateUserStatus();
                    if(document['businessType'] == BUSINESS_TYPE_OWNER || document['businessType'] == '') {
                      return GestureDetector(
                          onTap: () {
                            print(
                                'ON TAPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP currentUserId $currentUserId');
                            getFriendList(context, currentUserId, document);
                            /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Chat(
                                        currentUserId: currentUserId,
                                        peerId: document.documentID,
                                        peerAvatar: document['photoUrl'],
                                        isFriend: null,
                                          isAlreadyRequestSent  :null
                                      )));*/
                          },
                          child: new Column(
                            children: <Widget>[
                              Stack(
                                  children: <Widget>[
                                    document['photoUrl'] != null &&
                                        document['photoUrl'] != ''
                                        ? new Container(
                                        margin: EdgeInsets.only(
                                            left: 20.0, top: 10.0),
                                        width: 60.0,
                                        height: 60.0,
                                        decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: new DecorationImage(
                                                fit: BoxFit.fill,
                                                image: new NetworkImage(
                                                    document['photoUrl'])
                                            )
                                        ))
                                        : document['photoUrl'] == ''
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
                                    document['status'] == 'ACTIVE' ? Container(
                                        child: new SvgPicture.asset(
                                          'images/online_active.svg',
                                          height: 10.0,
                                          width: 10.0,
//                                          color: primaryColor,
                                        ),
                                        margin: EdgeInsets.only(left: 70.0,
                                            bottom: 30.0,
                                            top: 10.0,
                                            right: 5.0)) : document['status'] ==
                                        'LoggedOut' ? Container(
                                      child: new SvgPicture.asset(
                                        'images/online_inactive.svg',
                                        height: 10.0,
                                        width: 10.0,
//                                        color: primaryColor,
                                      ),
                                      margin: EdgeInsets.only(left: 70.0,
                                          bottom: 30.0,
                                          top: 10.0,
                                          right: 5.0),
                                    ) : Container(
                                      child: new SvgPicture.asset(
                                        'images/online_idle.svg', height: 10.0,
                                        width: 10.0,
//                                        color: primaryColor,
                                      ),
                                      margin: EdgeInsets.only(left: 70.0,
                                          bottom: 30.0,
                                          top: 10.0,
                                          right: 5.0),
                                    )
                                  ]
                              ),
                              new Container(
                                margin: EdgeInsets.only(left: 20.0, top: 10.0),
                                child: Text(capitalize(document['name']),
                                    textScaleFactor: 1.0),
                              )
                            ],
                          ));
                    }else{
                      return Container(
                          margin: EdgeInsets.only(left: 20.0, top: 20.0),
                          child: Center(
                            child: Text(''),
                          )
                      );
                    }
                  } else {
                    return Container(
                        margin: EdgeInsets.only(left: 20.0, top: 20.0),
                        child: Center(
                          child: Text(''),
                        )
                    );
                  }
                  /*  return new ListTile(
                title: new Text(document['name']),
                subtitle: new Text(document['status']));*/
                }).toList()
            )
        );
      },
    );
  }

  Future getFriendList(BuildContext context, String currentUserId,
      DocumentSnapshot documentSnapshot) async {
/*
    Navigator.push(
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
    String friendId = documentSnapshot.documentID;
    bool isRequestSent;
    var businessUser = await Firestore.instance.collection('users')
        .document(friendId).get();
    var businessData = businessUser.data;

    var businessUserId = businessUser['businessId'];
    print('Friend Listttttt queryyyy   ${businessUser
        .data}__________user ${businessUser
        .documentID} _______ $friendId __________________ ${businessData['businessId']}______businessType$_businessType');

    if ((businessUserId == null || businessUserId == '') &&
        (_businessType == '' || _businessType == null)) {
      var query = await Firestore.instance.collection('users')
          .document(currentUserId).collection(
          'FriendsList').getDocuments();
//    print('Friend Listttttt queryyyy${isRequestSent}');
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
                    )));
      } else {
        /*Navigator.push(
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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) =>
            SendInviteToUser(
                friendId, currentUserId, documentSnapshot['photoUrl'],
                isAlreadyRequestSent, isRequestSent,
                documentSnapshot['name'])));
      }
    } else {
      var businessUserName = businessUser['businessName'];
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>
          BusinessDetailPage(businessUserId, businessUserName)));
    }
  }
}
