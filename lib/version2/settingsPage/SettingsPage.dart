import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virus_chat_app/version2/utils/Colors.dart';
import 'package:virus_chat_app/version2/utils/strings.dart';


class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {

  bool isSwitched = false;
  bool isNotificationSwitched = false;
  bool isDNDSwitched = false; //dnd - Do not disturb


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 30.0, left: 0.0),
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 5.0),
                  child: Icon(Icons.arrow_back),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10.0),
                  child: Text(
                    settings_title, style: TextStyle(color: text_color_black),),
                )
              ],
            ),
          ),
          Divider(color: divider_color,),

          Container(
            margin: EdgeInsets.only(left: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 15.0),
                  child: Text(notification_txt),
                ),
                new Switch(
                  value: isNotificationSwitched,
                  onChanged: (value) {
                    setState(() {
                      isNotificationSwitched = value;
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
              ],),
          ),
          Container(
            margin: EdgeInsets.only(left: 20.0, right: 15.0),
            child: Divider(color: divider_color,),
          ),
          Container(
            margin: EdgeInsets.only(left: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 15.0),
                  child: Text(do_not_disturb),
                ),
                new Switch(
                  value: isDNDSwitched,
                  onChanged: (value) {
                    setState(() {
                      isDNDSwitched = value;
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
              ],),
          ),
          Container(
            margin: EdgeInsets.only(left: 20.0, right: 15.0),
            child: Divider(color: divider_color,),
          ),
        ],
      ),
    );
  }

}