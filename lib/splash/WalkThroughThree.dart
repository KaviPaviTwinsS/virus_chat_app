import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:virus_chat_app/Login/PhoneNumberSelection.dart';
import 'package:virus_chat_app/splash/WalkThroughThree.dart';
import 'package:virus_chat_app/splash/WalkThroughTwo.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';


class WalkThroughThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Column(
          children: <Widget>[
            Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height - 50,
                color: background_white_color,
                child: Image(
                  image: AssetImage(
                    'images/walkthrough_step3_new.png',
                  ),
                  fit: BoxFit.cover,
                )
            ),
            Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: 50.0,
                color: background_white_color,
                child:Container(
                  margin: EdgeInsets.only(right: 20.0,bottom: 10.0),
                  padding: EdgeInsets.all(10.0),
                  child:  Align(
                    heightFactor:50.0,
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => new PhoneNumberSelectionPage('phone')));
                      },
                      child: Text(skip, style: TextStyle(color: text_color_blue,fontSize: 17.0,fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w600,),),
                    ),
                  ),
                )
            )
          ],
        )
    );
  }

}