import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:virus_chat_app/UsersList.dart';
import 'package:virus_chat_app/colors.dart';

class FriendRequestScreen extends StatelessWidget {

  String _mcurrentUserId = '';
  String photoUrl ='';

  FriendRequestScreen(String currentUserId,String mphotoUrl) {
    _mcurrentUserId = currentUserId;
    photoUrl = mphotoUrl;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Page',
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
      home: FriendRequestScreenState(
          _mcurrentUserId,photoUrl
      ),
    );
  }

}

class FriendRequestScreenState extends StatefulWidget {

  String _mcurrentUserId = '';
  String photoUrl = '';

  FriendRequestScreenState(String currentUserId,String mphotoUrl) {
    _mcurrentUserId = currentUserId;
    photoUrl = mphotoUrl;
  }

  @override
  State<StatefulWidget> createState() {
    return FriendRequestScreenPage(_mcurrentUserId,photoUrl);
  }
}

class FriendRequestScreenPage extends State<FriendRequestScreenState> {

  String _mcurrentUserId;
  String photoUrl;

  FriendRequestScreenPage(String currentUserId,String mphotoUrl) {
    _mcurrentUserId = currentUserId;
    photoUrl = mphotoUrl;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      new UsersList('google', _mcurrentUserId,photoUrl)));
            },
          ),
          title: Text('Friend Requests'),
        ),
        body:
        Container(
            child: friendlist(_mcurrentUserId)
        )
    );
  }
/*

  Future getFriendsList() async {
    var query11 = await Firestore.instance.collection('users').document(
        _mcurrentUserId).collection('FriendsList').getDocuments();
    query11.documents.forEach((doc) {
      print('Friend Listttttt ${doc.data}');
      print('FRIEND REQUEST ${doc['isAcceptInvitation']}');
    });
  }*/

}

class friendlist extends StatelessWidget {

  String currentUserId = '';

  friendlist(String _mcurrentUserId) {
    currentUserId = _mcurrentUserId;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        new StreamBuilder(
            stream: Firestore.instance.collection('users').document(
                currentUserId).collection('FriendsList').where(
                'IsAcceptInvitation', isEqualTo: false).where(
                'isRequestSent', isEqualTo: false).snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//              if(isLoading == true)   return Center(
//                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)));;
              if (!snapshot.hasData)
                return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
              else
                    return new ListView(
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data.documents.map((document) {
                          print('Document idddd ${document.documentID}');
                          if (document.documentID != currentUserId) {
                            return GestureDetector(
                                onTap: () {
                                  print(
                                      'ON TAPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP');
//                            getFriendList(context, currentUserId, document);
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
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: <Widget>[
                                        Material(
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) => Container(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.0,
                                                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                              ),
                                              width: 35.0,
                                              height: 35.0,
                                              padding: EdgeInsets.all(10.0),
                                            ),
                                            imageUrl: document['friendPhotoUrl'],
                                            width: 35.0,
                                            height: 35.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(18.0),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                        new Container(
                                          margin: EdgeInsets.all(15.0),
                                          width: 100.0,
                                          height: 100.0,
                                          child: Text('requestFrom ::::::: ${document['requestFrom']}'),
                                        ),
                                        new Text('receiver ID :::::: ${document['receiveId']}',
                                            textScaleFactor: 1.0),
                                        RaisedButton(
                                          child: Text('Accept Request'),
                                          onPressed: () {
                                            print('requestFrom ${document['requestFrom']} ___ ${document['receiveId']}');
                                            Firestore.instance.collection(
                                                'users').document(
                                                document['requestFrom']).collection(
                                                'FriendsList')
                                                .document(document['receiveId'])
                                                .updateData(
                                                {'IsAcceptInvitation': true});
                                            Firestore.instance.collection(
                                                'users').document(
                                                document['receiveId'])
                                                .collection('FriendsList')
                                                .document(
                                                document['requestFrom'])
                                                .updateData(
                                                {'IsAcceptInvitation': true});
                                          },
                                        )
                                      ],
                                    )
                                ));
                          } else {
                            return Center(
                              child: Text('No Users'),
                            );
                          }
                        }).toList()
                );
            }
        )
      ],
    );
  }
}