import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/FriendRequestScreen.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/ProfilePage.dart';
import 'package:virus_chat_app/SendInviteScreen.dart';
import 'package:virus_chat_app/audiop/MyAudioEx.dart';
import 'package:virus_chat_app/chat/AudioChatsss.dart';
import 'package:virus_chat_app/chat/chat.dart';
import 'package:virus_chat_app/tweetPost/NewTweetPost.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/rangeSlider/RangeSliderPage.dart';
import 'package:virus_chat_app/tweetPost/MakeTweetPost.dart';
import 'package:http/http.dart' as http;


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

class UsersListState extends State<UsersListPage> {
  String currentUserPhotoUrl = '';
  String currentUserName = '';
  String currentUser = '';
  String userSignInType = '';
  SharedPreferences prefs;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  UsersListState(String currentUserId, String signInType, String mphotoUrl) {
    currentUser = currentUserId;
    userSignInType = signInType;
    currentUserPhotoUrl = mphotoUrl;
  }

  @override
  void initState() {
//    test();
    super.initState();
    initialise();
    setState(() {});
  }

  Future initialise() async {
    prefs = await SharedPreferences.getInstance();
    currentUserName = prefs.getString('name');
    print('USERLIST name_____ $currentUserName');
    LocationService(currentUser).locationStream;
  }

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  int _curIndex = 0;

  bool homeClicked = true;

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
    return new Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _curIndex, // this will be set when a new tab is tapped
          onTap: (index) {
            setState(() {
              print('CURENT IDEX____ $index');
              _curIndex = index;
              switch (_curIndex) {
                case 0:
//                  contents = "Home";
                  setState(() {
                    print('CICKEDDDDDDDDDDDDDDDDDDDDD');
                    homeClicked = true;
                  });
                  break;
                case 1:
//                  contents = "Articles";
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              NewTweetPost(currentUser, currentUserPhotoUrl)));
                  break;
                case 2:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MakeTweetPost(currentUser, currentUserPhotoUrl)));
//                  contents = "User";
                  break;
              }
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: new IconButton(
                icon: new SvgPicture.asset(
                  homeClicked ? 'images/home_highlight.svg' : 'images/home.svg',
                  height: 15.0,
                  width: 15.0,
                ), onPressed: () {

              },
              ),
              title: new Text(''),
            ),
            BottomNavigationBarItem(
              icon: new IconButton(
                icon: new SvgPicture.asset(
                  'images/post.svg', height: 15.0,
                  width: 15.0,
                ), onPressed: () {

              },
              ),
              title: new Text(''),
            ),
            BottomNavigationBarItem(
                icon: new IconButton(
                  icon: new SvgPicture.asset(
                    'images/community.svg', height: 15.0,
                    width: 15.0,
                  ),
                  onPressed: () {

                  },
                ),
                title: Text('')
            ),
          ],
        ),
        body: WillPopScope(
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                    child: Container(
                        color: facebook_color,
                        height: MediaQuery
                            .of(context)
                            .size
                            .height - 350,
                        child: Column(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Container(
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
                                              width: 55.0,
                                              height: 55.0,
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
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 40.0, right: 10.0),
                                  child: Text(
                                    currentUserName, style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: text_color),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 20.0, right: 15.0, left: 10.0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.person_pin,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                new ProfilePage(
                                                  userSignInType,
                                                  currentUserId: currentUser,)));
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 30.0),
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
                                      bottom: 50.0, top: 5.0),
                                  child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        'Chat with people', style: TextStyle(
                                          color: text_color),)
                                  ),
                                )
                              ],
                            ),

                          ],
                        )
                    )
                ),


                Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: 300,
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
                                      top: 30.0),
                                  child: Text('People', style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19.0),)
                              ),
                            ),
                            Expanded(
                              child : new LoginUsersList(
                                    currentUser, currentUserPhotoUrl),
                            )
                          ],
                        )
                    )
                ),
              ],
            ), onWillPop: null)
    );
  }

  Future onBackPress() async {
    Fluttertoast.showToast(msg: 'Please exit the App');
  }

}

class UsersOnlinePage extends StatelessWidget implements SliderListener {
  String currentUserId = '';
  String mphotoUrl = '';

  UsersOnlinePage(String currentUser, String photoUrl) {
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
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
    ActiveUserListRadiusState(currentUserId, mphotoUrl).userListUpdate(
        sliderData);
  }


}

abstract class SliderListener {
  void SliderChangeListener(double sliderData);
}

class ActiveUserListRadiusState extends StatefulWidget {

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
    ActiveUserListRadius(_mcurrentUserId, photoUrl).userListUpdate(sliderData);
  }
}


class ActiveUserListRadius extends State<ActiveUserListRadiusState> {
  String currentUserId = '';
  String mphotoUrl = '';

  GeoPoint mUserGeoPoint;

  bool isLoading = false;


  SharedPreferences _preferences;

  ActiveUserListRadius(String currentUser, String photoUrl) {
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
  }


  userListUpdate(double sliderData) {
    isLoading = true;
    getCurrentUserLocation(currentUserId, sliderData);
  }

  @override
  void initState() {
    initialise();
    super.initState();
  }

  void initialise() async {
    _preferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance.collection('users').where(
            'userDistanceISWITHINRADIUS', isEqualTo: 'YES').where(
            'status', isEqualTo: 'ACTIVE').snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//              if(isLoading == true)   return Center(
//                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)));;
          if (!snapshot.hasData)
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          else
            return Expanded(
                child: new ListView(
                    scrollDirection: Axis.horizontal,
                    children: snapshot.data.documents.map((document) {
                      print('Document idddd ${document.documentID}');
                      if (document.documentID != currentUserId) {
                        return GestureDetector(
                            onTap: () {
                              print(
                                  'ON TAPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP ACTIVE USERSSS');
                              getFriendList(context, currentUserId, document);
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Chat(
                                          currentUserId: currentUserId,
                                          peerId: document.documentID,
                                          peerAvatar: document['photoUrl'],
                                        )));*/
                            },
                            child: new Center(
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Container(
                                        margin: EdgeInsets.all(15.0),
                                        width: 100.0,
                                        height: 100.0,
                                        decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: new DecorationImage(
                                                fit: BoxFit.fill,
                                                image: new NetworkImage(
                                                    document['photoUrl'])
                                            )
                                        )),
                                    new Text(document['name'],
                                        textScaleFactor: 1.0),
                                  ],
                                )
                            ));
                      } else {
                        return Center(
                          child: Text('No Users'),
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
    bool isAlreadyRequestSent = false;
    String friendId = documentSnapshot.documentID;
    var query = await Firestore.instance.collection('users')
        .document(currentUserId).collection(
        'FriendsList').getDocuments();
    print('Friend Listttttt queryyyy${documentSnapshot.data['user_token']}');
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
    print('Friend Listttttt isFriend${documentSnapshot['photoUrl']}');

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
                      isAlreadyRequestSent: isAlreadyRequestSent
                  )));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) =>
          SendInviteToUser(
              friendId, currentUserId, mphotoUrl, isAlreadyRequestSent)));
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
    isLoading = true;
    GeoPoint geopoint = map['userLocation'];
    // km = 423 // distance.as(LengthUnit.Kilometer,
    final double km = distance.distance(new LatLng(latitude, longtitude),
        new LatLng(geopoint.latitude, geopoint.longitude));
    print('USER DISTANCE $km');
    print('USER GEO ${geopoint.latitude} ___ ${geopoint.longitude}');
    if ((km == 0.0 || /*sliderData >= km*/ km < 1000.0) &&
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

  Future getDocumentNearBy(double latitude, double longitude,
      double distance) async {
    var query = await Firestore.instance.collection('users').getDocuments();
    query.documents.forEach((doc) {
      print('User DOCCCCCCCCC' + doc.documentID);
      getUserLocation(latitude, longitude, doc.documentID, distance);
    });
  }
}

class LoginUsersList extends StatelessWidget {
  String currentUserId = '';
  String mphotoUrl = '';

  SharedPreferences _preferences;

  LoginUsersList(String currentUser, String photoUrl) {
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
    initialise();
  }

  void initialise() async {
    _preferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('users').where(
          'status', isEqualTo: 'ACTIVE').snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return new ListView(
            scrollDirection: Axis.horizontal,
            children: snapshot.data.documents.map((document) {
              print('Document idddd ${document.documentID}');
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
                    child:new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.only(left: 20.0),
                                width: 80.0,
                                height: 80.0,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: new NetworkImage(
                                            document['photoUrl'])
                                    )
                                )),
                            new Text(document['name'],
                                textScaleFactor: 1.0)
                          ],
                        ));
              } else {
                return Center(
                  child: Text(''),
                );
              }
              /*  return new ListTile(
                title: new Text(document['name']),
                subtitle: new Text(document['status']));*/
            }).toList()
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
    bool isAlreadyRequestSent = false;
    String friendId = documentSnapshot.documentID;
    var query = await Firestore.instance.collection('users')
        .document(currentUserId).collection(
        'FriendsList').getDocuments();
    print('Friend Listttttt queryyyy${documentSnapshot.data['user_token']}');
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
    print('Friend Listttttt isFriend${documentSnapshot['photoUrl']}');
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
                      isAlreadyRequestSent: isAlreadyRequestSent
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
              friendId, currentUserId, documentSnapshot['photoUrl'], isAlreadyRequestSent)));
    }
  }
}
