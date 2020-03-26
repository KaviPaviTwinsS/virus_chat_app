import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget customTextSpan(String mainText, String spanText) {
  return Text.rich(
    TextSpan(
      text: mainText,
      style: TextStyle(fontSize: 15),
      children: <TextSpan>[
        TextSpan(
            text: spanText,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,color: Colors.blue,)
        )
        // can add more TextSpans here...
      ],
    ),);
}