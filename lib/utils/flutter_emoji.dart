//import 'package:flutter/material.dart';
//import 'package:virus_chat_app/utils/emoji_picker.dart';
//
//class MainApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: "Flutter Emoji Picker Example",
//      home: Scaffold(
//        appBar: AppBar(
//          title: Text("Flutter Emoji Picker Example"),
//        ),
//        body: MainPage(),
//      ),
//    );
//  }
//}
//
//class MainPage extends StatefulWidget {
//  @override
//  MainPageState createState() => new MainPageState();
//}
//
//class MainPageState extends State<MainPage> {
//  @override
//  Widget build(BuildContext context) {
//    return EmojiPicker(
//      rows: 3,
//      columns: 7,
//      recommendKeywords: ["racing", "horse"],
//      numRecommended: 10,
//      onEmojiSelected: (emoji, category) {
//        print(emoji);
//      },
//    );
//  }
//}