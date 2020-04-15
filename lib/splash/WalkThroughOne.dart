import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:virus_chat_app/splash/WalkThroughTwo.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';


class WalkThroughOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Column(
            children: <Widget>[
              SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height - 50,
                child: Image(
                    image: AssetImage(
                      'images/walkthrough_step1_new.png',
                    ),
                    fit: BoxFit.cover,
                )
              ),
              SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: 40.0,
                child:Container(
                  margin: EdgeInsets.only(right: 30.0,bottom: 20.0),
                  child:  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => new WalkThroughTwo()));
                      },
                      child: Text(skip, style: TextStyle(color: facebook_color),),
                    ),
                  ),
                )
              )
            ],
        )
    );
  }

}