import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:virus_chat_app/utils/colors.dart';


class FullPhoto extends StatelessWidget {
  final String url;

  FullPhoto({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      /*appBar: new AppBar(
        title: new Text(
          'Detail View',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),*/
      body: new FullPhotoScreen(url: url),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String url;

  FullPhotoScreen({Key key, @required this.url}) : super(key: key);

  @override
  State createState() => new FullPhotoScreenState(url: url);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;

  FullPhotoScreenState({Key key, @required this.url});

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          Column(
              children: <Widget>[
                Container(
                  color: button_fill_color,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: 150,
                  child:
                  Row(
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
                              top: 20.0, right: 10.0, bottom: 40.0),
                          child: Text('Detail View', style: TextStyle(
                              color: text_color,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),)
                      ),
                    ],
                  ),
                ),
              ]
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
              child: Container(
                margin: EdgeInsets.all(30.0),
//                child: PhotoView(imageProvider: NetworkImage(url)),
                child: CachedNetworkImage(
                  placeholder: (context, url) =>
                      Center(
                        child: Container(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                themeColor),
                          ),
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            color: greyColor2,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                  errorWidget: (context, url, error) =>
                      Material(
                        child: new SvgPicture.asset(
                          'images/user_unavailable.svg', height: 200.0,
                          width:150.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                  imageUrl: url,
                  width: 150.0,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        ]
    );
  }
}