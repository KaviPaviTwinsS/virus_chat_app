import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:virus_chat_app/business/BusinessDetailPage.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'package:virus_chat_app/utils/constants.dart';


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
            color: button_fill_color,
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: 150,
           child :  Row(
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
                       top: 20.0,bottom: 40.0),
                   child: Text(business_header, style: TextStyle(
                       color: text_color,
                       fontSize: TOOL_BAR_TITLE_SIZE,
                       fontWeight: FontWeight.w700,fontFamily: 'GoogleSansFamily'),)
               ),
             ],
           ),
           /* child: new Container(
                margin: EdgeInsets.only(
                  top: 50.0, left: 20.0,),
                child: Text(business_header, style: TextStyle(
                    color: text_color,
                    fontSize: TOOL_BAR_TITLE_SIZE,
                    fontWeight: FontWeight.w700,fontFamily: 'GoogleSansFamily'),)
            ),*/
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
                child: buildListBusinesses(),
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
                  valueColor: AlwaysStoppedAnimation<Color>(progress_color)));
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
        GestureDetector(
          onTap: (){
            Navigator.push(
                context, MaterialPageRoute(builder: (context) =>
                BusinessDetailPage(document['businessId'], document['businessName'])));
          },
          child:     Row(
          children: <Widget>[
            document['photoUrl'] != '' ? Container(
                margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
                child:  Stack(
                    children: <Widget>[
                      document['photoUrl'] != null &&
                          document['photoUrl'] != ''
                          ? new Container(
                          margin: EdgeInsets.only(
                              left: 20.0, top: 10.0),
                          width: 50.0,
                          height: 50.0,
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
                          width: 50.0,
                          height: 50.0,
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
                          margin: EdgeInsets.only(left: 60.0,
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
                        margin: EdgeInsets.only(left: 60.0,
                            bottom: 30.0,
                            top: 10.0,
                            right: 5.0),
                      ) : Container(
                        child: new SvgPicture.asset(
                          'images/online_idle.svg', height: 10.0,
                          width: 10.0,
//                                        color: primaryColor,
                        ),
                        margin: EdgeInsets.only(left: 60.0,
                            bottom: 30.0,
                            top: 10.0,
                            right: 5.0),
                      )
                    ]
                ),
            )
                : Text(''),
            document['businessName'] != ''
                ? Container(
                margin: EdgeInsets.only(left: 10.0, bottom: 5.0),
                child : Text(capitalize(document['businessName']),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0,fontFamily: 'GoogleSansFamily'),)
            )
                : Text('')
          ],
        ),),
        Divider()
      ],
    );
  }

}