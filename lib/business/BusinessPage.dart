import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';

class BusinessPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BusinessPageState();
  }

}

class BusinessPageState extends State<BusinessPage> {

  final ScrollController listScrollController = new ScrollController();
  var listMessage;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: facebook_color,
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: 150,
            child: new Container(
                 margin: EdgeInsets.only(
                     top: 50.0, left: 20.0,),
                 child: Text(business_header, style: TextStyle(
                     color: text_color,
                     fontSize: 20.0,
                     fontWeight: FontWeight.bold),)
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
                      .height - 100,
                  decoration: BoxDecoration(
                      color: text_color,
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(30.0),
                        topRight: const Radius.circular(30.0),
                      )
                  ),
                  child:buildListBusinesses(),
              )
          )
        ],
      ),
    );
  }



  Widget buildListBusinesses() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('business')
            .snapshots(),
        builder: (context, snapshot) {
          print('snapshot ____________${snapshot.hasData}');
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            listMessage = snapshot.data.documents;
            return ListView.builder(
              itemBuilder: (context, index) =>
                  buildItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
//              reverse: true,
              controller: listScrollController,
            );
          }
        },
    );
  }


  Widget buildItem(int index, DocumentSnapshot document) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            document['photoUrl'] != '' ? Container(
                margin: EdgeInsets.only(left : 10.0,bottom: 10.0),
                child: Material(
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                        Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                themeColor),
                          ),
                          width: 35.0,
                          height: 35.0,
                        ),
                    imageUrl: document['photoUrl'],
                    width: 35.0,
                    height: 35.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(45.0)),
                  clipBehavior: Clip.hardEdge,
                )
            )
                : Text(''),
            document['businessName'] != '' ? Text(document['businessName'],style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0),) : Text('')


          ],
        ),
        Divider()
      ],
    );
  }

}