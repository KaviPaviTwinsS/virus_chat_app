import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:virus_chat_app/FriendRequestScreen.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/ProfilePage.dart';
import 'package:virus_chat_app/SendInviteScreen.dart';
import 'package:virus_chat_app/chat/chat.dart';
import 'package:virus_chat_app/colors.dart';
import 'package:virus_chat_app/rangeSlider/RangeSliderPage.dart';


class UsersList extends StatelessWidget {
  String currentUser = '';
  String userSignInType = '';
  String mphotoUrl= '';

  UsersList(String signinType, String userId,String photoUrl) {
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
      home: UsersListPage(currentUser, userSignInType,mphotoUrl),
    );
  }
}

class UsersListPage extends StatefulWidget {
  String currentUserId = '';
  String signInType = '';
  String mphotoUrl='';

  UsersListPage(String currentUser, String userSignInType,String photoUrl) {
    currentUserId = currentUser;
    signInType = userSignInType;
    mphotoUrl = photoUrl;
  }

  @override
  State<StatefulWidget> createState() {
    return UsersListState(currentUserId, signInType,mphotoUrl);
  }
}

class UsersListState extends State<UsersListPage> {
  String photoUrl = '';
  String currentUser = '';
  String userSignInType = '';

  UsersListState(String currentUserId, String signInType,String mphotoUrl) {
    currentUser = currentUserId;
    userSignInType = signInType;
    photoUrl = mphotoUrl;
  }

  @override
  void initState() {
    LocationService(currentUser).locationStream;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.person_pin, color: Colors.black),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => new ProfilePage(userSignInType,currentUserId: currentUser,)));
          },
        ),
        title: new Text("Active Users List"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            new ActiveUserListRadiusState(currentUser,photoUrl),
            new UsersOnlinePage(currentUser,photoUrl),
            new LoginUsersList(currentUser,photoUrl),
            Row(
              children: <Widget>[
                Container(
                  child: RaisedButton(onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfilePageSetup(
                                  userSignInType,
                                  currentUserId: currentUser,)));
                  },
                    child: Text('GO to profile'),),
                ),
                Container(
                  child: RaisedButton(onPressed: () {
                    print('_mcurrentUserId $currentUser');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FriendRequestScreen(currentUser,photoUrl)));
                  },
                    child: Text('Friend Requests'),),
                )
              ],
            )

          ],
        ),
      ),
//      new LoginUsersList(currentUser),
//      UsersOnlinePage(),
    );
  }


}

class UsersOnlinePage extends StatelessWidget implements SliderListener {
  String currentUserId = '';
  String mphotoUrl ='';

  UsersOnlinePage(String currentUser,String photoUrl) {
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
    ActiveUserListRadiusState(currentUserId,mphotoUrl).userListUpdate(sliderData);
  }


}

abstract class SliderListener {
  void SliderChangeListener(double sliderData);
}

class ActiveUserListRadiusState extends StatefulWidget {

  String _mcurrentUserId = ' ';
  String photoUrl ='';

  ActiveUserListRadiusState(String currentUserId,String mphotoUrl) {
    _mcurrentUserId = currentUserId;
    photoUrl = mphotoUrl;
  }

  @override
  State<StatefulWidget> createState() {
    return ActiveUserListRadius(_mcurrentUserId,photoUrl);
  }

  userListUpdate(double sliderData) {
    ActiveUserListRadius(_mcurrentUserId,photoUrl).userListUpdate(sliderData);
  }
}


class ActiveUserListRadius extends State<ActiveUserListRadiusState> {
  String currentUserId = '';
  String mphotoUrl ='';

  GeoPoint mUserGeoPoint;

  bool isLoading = false;


  ActiveUserListRadius(String currentUser,String photoUrl) {
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
  }


  userListUpdate(double sliderData) {
    isLoading = true;
    getCurrentUserLocation(currentUserId, sliderData);
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
    print('Friend Listttttt queryyyy${query.documents.length }');
    if (query.documents.length != 0) {
      query.documents.forEach((doc) {
        print('Friend Listttttt ${doc.data}');
        if (doc.documentID == friendId &&
            doc.data['IsAcceptInvitation'] == true) {
            isFriend = true;
        }

        if(doc.documentID == friendId ) {
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
                      peerAvatar: mphotoUrl,
                      isFriend: true,
                      isAlreadyRequestSent: isAlreadyRequestSent
                  )));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Chat(
                      currentUserId: currentUserId,
                      peerId: friendId,
                      peerAvatar: mphotoUrl,
                      isFriend: false,
                      isAlreadyRequestSent: isAlreadyRequestSent
                  )));
    }
  }

  final Distance distance = new Distance();

  Future<DocumentSnapshot> getCurrentUserLocation(String userId,
      double sliderData) async {
    DocumentSnapshot doc = await Firestore.instance.collection('users')
        .document(userId).collection(
        'userLocation').document(userId)
        .get();
    DocumentSnapshot map = doc;
    GeoPoint geopoint = map['userLocation'];
    getDocumentNearBy(geopoint.latitude, geopoint.longitude, sliderData);
    print('USERCURRENT  GEO ${geopoint.latitude} ___ ${geopoint.longitude}');
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
    if ((km == 0.0 || sliderData >= km) && userId != currentUserId) {
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
  String mphotoUrl ='';

  LoginUsersList(String currentUser,String photoUrl) {
    currentUserId = currentUser;
    mphotoUrl = photoUrl;
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('users').where(
          'status', isEqualTo: 'ACTIVE').snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return Expanded(
            child: new ListView(
                scrollDirection: Axis.horizontal,
                children: snapshot.data.documents.map((document) {
                  print('Document idddd ${document.documentID}');
                  if (document.documentID != currentUserId) {
                    return GestureDetector(
                        onTap: () {
                          print('ON TAPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP currentUserId $currentUserId');
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
                        child: new Center(
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                    textScaleFactor: 1.0)
                              ],
                            )));
                  } else {
                    return Center(
                      child: Text(''),
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
    bool isAlreadyRequestSent = false;
    String friendId = documentSnapshot.documentID;
    var query = await Firestore.instance.collection('users')
        .document(currentUserId).collection(
        'FriendsList').getDocuments();
    print('Friend Listttttt queryyyy${query.documents.length }');
    if (query.documents.length != 0) {
      query.documents.forEach((doc) {
        print('Friend Listttttt ${doc.data}');
        if (doc.documentID == friendId &&
            doc.data['IsAcceptInvitation'] == true) {
          isFriend = true;
        }

        if(doc.documentID == friendId ) {
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
                      peerAvatar: mphotoUrl,
                      isFriend: true,
                      isAlreadyRequestSent: isAlreadyRequestSent
                  )));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Chat(
                      currentUserId: currentUserId,
                      peerId: friendId,
                      peerAvatar: mphotoUrl,
                      isFriend: false,
                      isAlreadyRequestSent: isAlreadyRequestSent
                  )));
    }
  }
}