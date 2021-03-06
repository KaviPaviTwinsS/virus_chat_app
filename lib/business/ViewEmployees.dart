import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:virus_chat_app/business/BusinessDetailPage.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'package:virus_chat_app/utils/constants.dart';


class ViewEmployeesPage extends StatefulWidget {

  String _mBusinessId = '';

  ViewEmployeesPage(String businessId){
    _mBusinessId = businessId;
  }
  @override
  State<StatefulWidget> createState() {
    return ViewEmployeesPageState(_mBusinessId);
  }

}

class ViewEmployeesPageState extends State<ViewEmployeesPage> {

  final ScrollController listScrollController = new ScrollController();
  var listMessage;
  bool isLoading = false;

  String _mBusinessId ='';
  ViewEmployeesPageState(String mBusinessId){
    _mBusinessId = mBusinessId;
  }


  @override
  void initState() {
//    isLoading = true;
    setState(() {

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment
                    .center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 40.0, bottom: 10.0),
                    child: new IconButton(
                        icon: new SvgPicture.asset(
                          'images/back_icon.svg',
                          width: 20.0,
                          height: 20.0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  new Container(
                      margin: EdgeInsets.only(
                          top: 40.0, bottom: 10.0),
                      child: Text(view_employees, style: TextStyle(
                          color: black_color,
                          fontSize: TOOL_BAR_TITLE_SIZE,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoogleSansFamily'),)
                  ),
                ],
              ),
              Divider(color: divider_color, thickness: 1.0,),
              buildListBusinesses(),
            ],
          ),
          buildLoading()
        ],
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(progress_color)),
        ),
        color: Colors.white.withOpacity(0.8),
      )
          : Container(),
    );
  }

  Widget buildListBusinesses() {
    return Flexible(
        child: StreamBuilder(
          stream: Firestore.instance.collection('users') .where(
          'businessId', isEqualTo: _mBusinessId).where('businessType',isEqualTo: BUSINESS_TYPE_EMPLOYEE).snapshots(),
          builder: (context, snapshot) {
            print(
                'snapshot ____________${snapshot.hasData} ___isLoading $isLoading');
            if (snapshot.data == null || !snapshot.hasData) {
              isLoading = false;
              /* return Center(
              child: Text('sssssssssssss'));*/
              return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(progress_color)));
            } else {
              isLoading = false;
              listMessage = snapshot.data.documents;
              print('snapshot ____________${listMessage
                  .length}___isLoading $isLoading');
              return (listMessage.length == 0) ? Center(
                child: Text(no_business_employees),
              ) : ListView.builder(
                itemBuilder: (context, index) =>
                    buildItem(index, snapshot.data.documents[index]),
                itemCount: snapshot.data.documents.length,
//              reverse: true,
                controller: listScrollController,
              );
            }
          },
        )
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    print('Buisness __________index__$index');
    return SingleChildScrollView(
      child:  Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {

            },
            child: Row(
              children: <Widget>[
               /* document['photoUrl'] != '' ? */Container(
                  margin: EdgeInsets.only(bottom: index == 0 ? 10.0 : 10.0,top: index == 0 ? 0.0 : 15.0),
                  child: Stack(
                      children: <Widget>[
                       /* document['photoUrl'] != null &&
                            document['photoUrl'] != ''
                            ? */new Container(
                          margin: EdgeInsets.all(10.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) =>
                                    Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.0,
                                        valueColor: AlwaysStoppedAnimation<
                                            Color>(progress_color),
                                      ),
                                      width: 30.0,
                                      height: 30.0,
                                      padding: EdgeInsets.all(10.0),
                                    ),
                                imageUrl: document['photoUrl'],
                                width: 60.0,
                                height: 60.0,
                                fit: BoxFit.cover,
                                errorWidget: (context, url,
                                    error) =>
                                    Material(
                                      child: /* Image.asset(
                                                      'images/img_not_available.jpeg',
                                                      width: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width - 30,
                                                      height: 200.0,
                                                      fit: BoxFit.cover,
                                                    ),*/
                                      new SvgPicture.asset(
                                        'images/user_unavailable.svg',
                                        height: 60.0,
                                        width: 60.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius
                                          .all(
                                        Radius.circular(5.0),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                          ),
                        ),
                        /*    : new Container(
                            margin: EdgeInsets.all(10.0),
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
                            )),*/
                        document['status'] == 'ACTIVE'  && document['status']  != ''? Container(
                            child: new SvgPicture.asset(
                              'images/online_active.svg',
                              height: 15.0,
                              width: 15.0,
//                                          color: primaryColor,
                            ),
                            margin: EdgeInsets.only(left: 53.0,
                                bottom: 40.0,
                                top: 10.0,
                                right: 15.0)) : document['status'] ==
                            'LoggedOut' && document['status'] !='' ? Container(
                          child: new SvgPicture.asset(
                            'images/online_inactive.svg',
                            height: 15.0,
                            width: 15.0,
//                                        color: primaryColor,
                          ),
                          margin: EdgeInsets.only(left: 53.0,
                              bottom: 40.0,
                              top: 10.0,
                              right: 15.0),
                        ) :  document['status'] ==
                            'INACTIVE' && document['status'] !=''  ? Container(
                          child: new SvgPicture.asset(
                            'images/online_idle.svg', height: 15.0,
                            width: 15.0,
//                                        color: primaryColor,
                          ),
                          margin: EdgeInsets.only(left: 53.0,
                              bottom: 40.0,
                              top: 10.0,
                              right: 15.0),
                        ): Container()
                      ]
                  ),
                ),
                   /* : Text(''),*/
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    document['name'] != ''
                        ? Container(
                        margin: EdgeInsets.only(left: 0.0, bottom: index == 10 ? 0.0 : 10.0,top: 10.0),
                        child: Text(capitalize(document['name']),
                          style: TextStyle(fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                              fontFamily: 'GoogleSansFamily',color: black_color),)
                    )
                        : Text(''),
                    document['phoneNo'] != ''
                        ? Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                          width: MediaQuery.of(context).size.width - 120,
                          margin: EdgeInsets.only(left: 0.0, bottom: index == 10 ? 0.0 : 10.0,right: 10.0),
                          child: Text(capitalize(document['phoneNo'],),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w400,
                                fontSize: 12.0,
                                fontFamily: 'GoogleSansFamily',color:hint_color_grey_dark ),
                          )
                      ),
                    )
                        : Text('')
                  ],
                )
              ],
            ),),
//          Divider()
        ],
      ),
    );
  }

}