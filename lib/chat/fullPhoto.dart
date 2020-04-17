import 'package:flutter/material.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/const.dart';
import 'package:photo_view/photo_view.dart';

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
                  color: facebook_color,
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
          Container(
            child: PhotoView(imageProvider: NetworkImage(url)),
          ),
        ]
    );
  }
}