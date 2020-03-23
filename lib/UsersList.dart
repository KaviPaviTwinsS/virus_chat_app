import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virus_chat_app/LocationService.dart';
import 'package:virus_chat_app/UserLocation.dart';

class UsersList extends StatelessWidget {
  String currentUser = '';

  UsersList(String userId) {
    currentUser = userId;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: UsersListPage(currentUser),
    );
  }
}

class UsersListPage extends StatefulWidget {
  String currentUserId = '';

  UsersListPage(String currentUser) {
    currentUserId = currentUser;
  }

  @override
  State<StatefulWidget> createState() {
    return UsersListState(currentUserId);
  }
}

class UsersListState extends State<UsersListPage> {
  String photoUrl = '';
  String currentUser = '';

  UsersListState(String currentUserId) {
    currentUser = currentUserId;
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
      body: new LoginUsersList(currentUser),
    );
  }
}

class LoginUsersList extends StatelessWidget {
  String currentUserId = '';

  LoginUsersList(String currentUser) {
    currentUserId = currentUser;
  }

  @override
  Widget build(BuildContext context) {
   /* return Scaffold(
        body: Column(
          children: <Widget>[
            *//*StreamProvider<UserLocation>(
              // ignore: missing_return
              create: (BuildContext context) {
                    (context) => LocationService(currentUserId).locationStream;
              },
            ),*//*
            new StreamBuilder(
              stream: Firestore.instance.collection('users').snapshots(),
              builder:
                  (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {

                print('locationStream');
                if (!snapshot.hasData) return new Text('Loading...');
                return new ListView(
                  children: snapshot.data.documents.map((document) {
                    return new ListTile(
                        title: new Text(document['name']),
                        subtitle: new Text(document['status']));
                  }).toList(),
                );
              },
            )
          ],
        )
    );*/
     return new StreamBuilder(
          stream: Firestore.instance.collection('users').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            print('locationStream');
            if (!snapshot.hasData) return new Text('Loading...');
            return new ListView(
              children: snapshot.data.documents.map((document) {
                return new ListTile(
                    title: new Text(document['name']),
                    subtitle: new Text(document['status']));
              }).toList(),
            );
          },
        );
//    );
  }
}
