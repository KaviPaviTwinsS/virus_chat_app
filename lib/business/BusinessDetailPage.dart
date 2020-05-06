import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/utils/colors.dart';

class BusinessDetailPage extends StatefulWidget {

  String _businessId = '';
  String _businessName = '';

  BusinessDetailPage(String mBusinessId, String mBusinessName) {
    _businessId = mBusinessId;
    _businessName = mBusinessName;
  }

  @override
  State<StatefulWidget> createState() {
    return BusinessDetailPageState(_businessId, _businessName);
  }

}

class BusinessDetailPageState extends State<BusinessDetailPage> {
  String _businessId = '';
  String _businessName = '';
  String _businessImage = '';
  String _businessAddress= '';
  String _businessOwnerName = '';
  String _businessNumber = '';

  SharedPreferences preferences ;
  List<DocumentSnapshot> documents = new List<DocumentSnapshot>();

  bool isLoading = false;

  BusinessDetailPageState(String businessId, String businessName) {
    _businessId = businessId;
    _businessName = businessName;
  }

  @override
  void initState() {
    initialise();
    super.initState();
  }


  void initialise() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    Firestore.instance
        .collection('business')
        .document(_businessId).get().then((DocumentSnapshot documentReference) {
      if(documentReference.documentID.isNotEmpty) {
        print('Business detail___________ ${documentReference
            .documentID} _______${documentReference.data['photoUrl']} __________');
        _businessAddress =documentReference.data['businessAddress'];
        _businessNumber =documentReference.data['businessNumber'];
        _businessImage = documentReference.data['photoUrl'];
        print('BUSINESS IMAGE ___${_businessImage != null && _businessImage != ''}');
      }else{
      }
      setState(() {
        isLoading = false;
      });
    });

  }


  @override
  Widget build(BuildContext context) {
    print('BUSINESS IMAGE ___build${_businessImage != null && _businessImage != ''}');
    return Scaffold(
        body: Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                color: facebook_color,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: 150,
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only( left: 0.0,bottom: 25.0),
                      child: new IconButton(
                          icon: Icon(Icons.arrow_back_ios,
                            color: white_color,),
                          onPressed: () {
                            Navigator.pop(context);
//                                  navigationPage();
                          }),
                    ),
                    new Container(
                        margin: EdgeInsets.only(
                          left: 0.0,bottom: 25.0),
                        child: Text(_businessName, style: TextStyle(
                            color: text_color,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),)
                    ),
                  ],
                )
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
                      child:Stack(
                        children: <Widget>[
                          Positioned(
                              child: isLoading
                                  ? Container(
                                child: Center(
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          themeColor)),
                                ),
                                color: Colors.white.withOpacity(0.8),
                              ) : Container()
                          ),
                          Stack(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  (_businessImage != null && _businessImage != '') ? Center(
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 15.0,top: 15.0),
                                        child: Material(
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                                  child: CircularProgressIndicator(
                                                    valueColor: AlwaysStoppedAnimation<
                                                        Color>(
                                                        themeColor),
                                                  ),
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: greyColor2,
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(5.0),
                                                    ),
                                                  ),
                                                ),
                                            errorWidget: (context, url, error) =>
                                                Material(
                                                  child: Image.asset(
                                                    'images/img_not_available.jpeg',
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width - 30,
                                                    height: 200.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0),
                                                  ),
                                                  clipBehavior: Clip.hardEdge,
                                                ),
                                            imageUrl: _businessImage,
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width - 30,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                      )
                                  ) : Text(''),
                                  _businessName != null && _businessName != '' ? Container(
                                    margin: EdgeInsets.only(left: 15.0,bottom: 10.0),
                                    child: Text(_businessName,style: TextStyle(fontWeight: FontWeight.bold),),
                                  ) : Text(''),
                                  _businessAddress != null && _businessAddress != '' ? Container(
                                    margin: EdgeInsets.only(left: 15.0,bottom: 15.0),
                                    child: Text(_businessAddress,),
                                  ) : Text(''),
                                ],
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  child: IconButton(
                                    icon: new SvgPicture.asset(
                                      'images/business_chat.svg', height: 500.0,
                                      width: 500.0,
                                    ),
                                    onPressed: () {
                                      getBusinessUsers();
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),

                        ],
                      )
                  )
              )
            ],
          ),
        )
    );
  }

  Future getBusinessUsers() async{
    print('Business Detail document list');

    try{
      QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('businessId',isEqualTo: _businessId)
          .getDocuments();
      print('Business Detail document list ${result.documents.length}');
      result.documents.forEach((doc) {
//        if(doc.documentID)
      print('Business Detail document ____________' + doc.documentID);
    });
      return result.documents;
    }on Exception catch (e) {
      print('NANDHU BusinessDetail loadUsers Exception ${e.toString()}');
    }
  }
}