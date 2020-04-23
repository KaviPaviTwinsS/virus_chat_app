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
                  child: Text('Businesss page')
              )
          )
        ],
      ),
    );
  }

}