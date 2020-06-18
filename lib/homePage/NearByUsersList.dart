import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:virus_chat_app/business/UsersData.dart';
import 'package:virus_chat_app/chat/chat.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'package:virus_chat_app/utils/constants.dart';


class NearByUsersList extends StatefulWidget {

  String _currentUserId ='';
  List<UsersData> _mNearByUsersData;
  NearByUsersList(String currentUserId, List<UsersData> mNearByUsersData){
    _currentUserId = currentUserId;
    _mNearByUsersData = mNearByUsersData;
  }
  @override
  State<StatefulWidget> createState() {
    return NearByUsersListState(_currentUserId,_mNearByUsersData);
  }

}

class NearByUsersListState extends State<NearByUsersList> {

  final ScrollController listScrollController = new ScrollController();
  var listMessage;
  bool isLoading = false;
  List<UsersData> _mNearByUsersData;

  String _currentUserId;
  NearByUsersListState(String currentUserId, List<UsersData> mNearByUsersData){
    _currentUserId = currentUserId;
    _mNearByUsersData = mNearByUsersData;
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
                      child: Text(business_header, style: TextStyle(
                          color: black_color,
                          fontSize: TOOL_BAR_TITLE_SIZE,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'GoogleSansFamily'),)
                  ),
                ],
              ),
              Divider(color: divider_color, thickness: 1.0,),
              buildListUsers(),
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

  Widget buildListUsers() {
     return Flexible(
       child: Container(
           width: MediaQuery
               .of(context)
               .size
               .width,
           height: MediaQuery
               .of(context)
               .size
               .height,
           child:
           (_mNearByUsersData != null && _mNearByUsersData.length != 0)? ListView.builder(
             itemBuilder: (context, index) =>
                 buildItem(index, _mNearByUsersData),
             itemCount: _mNearByUsersData.length,
             controller: listScrollController,
           ) : Center(
             child: Text('No recent chats'),
           )
       ),
     );
  }

  Widget buildItem(int index, List<UsersData> mNearbyUsersData) {
    print('Buisness __________index__$index');
    UsersData usersData = mNearbyUsersData[index];
    return Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Chat(
                            currentUserId: _currentUserId,
                            peerId: usersData.id,
                            peerAvatar: usersData.photoUrl,
                            isFriend: true,
                            isAlreadyRequestSent: true,
                            peerName: usersData.name,
                          )));
            },
            child: Row(
              children: <Widget>[
                usersData.photoUrl != '' ? Container(
                  margin: EdgeInsets.only(bottom: index == 0 ? 10.0 : 10.0,top: index == 0 ? 0.0 : 15.0),
                  child:  usersData.photoUrl != null &&
                      usersData.photoUrl!= ''
                            ? new Container(
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
                                imageUrl:  usersData.photoUrl,
                                width: 60.0,
                                height: 60.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  30.0),border: Border.all(color: profile_image_border_color)
                          ),
                        )
                            :  usersData.photoUrl == ''
                            ? new Container(
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
                            ))
                            : Text(''),
                )
                    : Text(''),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    usersData.name != ''
                        ? Container(
                        margin: EdgeInsets.only(left: 0.0, bottom: index == 10 ? 0.0 : 10.0,top: index == 0? 10.0 :15.0),
                        child: Text(capitalize( usersData.name),
                          style: TextStyle(fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                              fontFamily: 'GoogleSansFamily',color: black_color),)
                    )
                        : Text(''),
                    usersData.userDistance != ''
                        ? Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                          width: MediaQuery.of(context).size.width - 120,
                          margin: EdgeInsets.only(left: 0.0, bottom: index == 10 ? 0.0 : 10.0,right: 10.0),
                          child: Text(usersData.userDistance.toString()+'\t'+usersData.distanceMetric,
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
    );
  }

}