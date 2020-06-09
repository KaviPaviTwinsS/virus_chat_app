import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virus_chat_app/utils/colors.dart';

Widget customTextSpan(String mainText, String spanText) {
  return Text.rich(
    TextSpan(
      text: mainText,
      style: TextStyle(fontSize: 15,fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400,color: hint_color_grey_light),
      children: <TextSpan>[
        TextSpan(
            text: spanText,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13,color: text_color_blue,fontFamily: 'GoogleSansFamily')
        )
        // can add more TextSpans here...
      ],
    ),);
}