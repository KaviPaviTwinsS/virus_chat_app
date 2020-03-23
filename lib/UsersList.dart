import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/ProfilePage.dart';
import 'package:virus_chat_app/rangeSlider/RangeSliderPage.dart';


class UsersList extends StatelessWidget {
  String currentUser = '';
  String userSignInType = '';

  UsersList(String signinType, String userId) {
    currentUser = userId;
    userSignInType = signinType;
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
      home: UsersListPage(currentUser, userSignInType),
    );
  }
}

class UsersListPage extends StatefulWidget {
  String currentUserId = '';
  String signInType = '';

  UsersListPage(String currentUser, String userSignInType) {
    currentUserId = currentUser;
    signInType = userSignInType;
  }

  @override
  State<StatefulWidget> createState() {
    return UsersListState(currentUserId, signInType);
  }
}

class UsersListState extends State<UsersListPage> {
  String photoUrl = '';
  String currentUser = '';
  String userSignInType = '';

  UsersListState(String currentUserId, String signInType) {
    currentUser = currentUserId;
    userSignInType = signInType;
  }

  @override
  void initState() {
    super.initState();
    LocationService(currentUser).locationStream;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Users Listtttttttt"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            new ActiveUserListRadius(currentUser),
            new UsersOnlinePage(currentUser),
            new LoginUsersList(currentUser),
            Container(
              child: RaisedButton(onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfilePageSetup(
                              userSignInType, currentUserId: currentUser,)));
              },
                child: Text('GO to profile'),),
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

  UsersOnlinePage(String currentUser) {
    currentUserId = currentUser;
  }


  @override
  Widget build(BuildContext context) {
    return RangeSliderSample(this);
  }

  @override
  void SliderChangeListener(double sliderData) {
    print('SliderChangeListener $sliderData');
    ActiveUserListRadius(currentUserId).userListUpdate(sliderData);
  }
}

abstract class SliderListener {
  void SliderChangeListener(double sliderData);
}


class ActiveUserListRadius extends StatelessWidget {
  String currentUserId = '';

  GeoPoint mUserGeoPoint;

  ActiveUserListRadius(String currentUser) {
    currentUserId = currentUser;
  }


  userListUpdate(double sliderData) {
    getCurrentUserLocation(currentUserId, sliderData);
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('users').where(
          'userDistanceISWITHINRADIUS', isEqualTo: 'YES').snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        print('locationStream');
        if (!snapshot.hasData) return new Text('Loading...');
        return Expanded(
            child: new ListView(
                scrollDirection: Axis.horizontal,
                children: snapshot.data.documents.map((document) {
                  print('Document idddd ${document.documentID}');
                  if (document.documentID != currentUserId) {
                    return new Center(
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
            )
        );
      },
    );
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
    GeoPoint geopoint = map['userLocation'];
    // km = 423 // distance.as(LengthUnit.Kilometer,
    final double km = distance.distance(new LatLng(latitude, longtitude),
        new LatLng(geopoint.latitude, geopoint.longitude));
    print('USER DISTANCE $km');
    print('USER GEO ${geopoint.latitude} ___ ${geopoint.longitude}');
    if ((km == 0.0 || sliderData >= km) && userId != currentUserId) {
      DocumentSnapshot userDocs = await Firestore.instance.collection('users')
          .document(userId).get();
      print('USER DETAILSSS ${userDocs.data.values} ____userId $userId');
      Firestore.instance.collection('users').document(userId).updateData({
        'userDistanceISWITHINRADIUS':
        'YES'
      });
    }else{
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

  LoginUsersList(String currentUser) {
    currentUserId = currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('users').where(
          'status', isEqualTo: 'ACTIVE').snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        print('locationStream');
        if (!snapshot.hasData) return new Text('Loading...');
        return Expanded(
            child: new ListView(
                scrollDirection: Axis.horizontal,
                children: snapshot.data.documents.map((document) {
                  print('Document idddd ${document.documentID}');
                  if (document.documentID != currentUserId) {
                    return new Center(
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
            )
        );
      },
    );
  }
}