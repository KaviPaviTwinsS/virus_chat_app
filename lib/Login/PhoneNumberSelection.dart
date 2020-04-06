import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';
import 'package:virus_chat_app/Login/OtpScreenPage.dart';
import 'package:virus_chat_app/Login/otpPage.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';

class PhoneNumberSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale('en'),
        Locale('it'),
        Locale('en'),
      ],
      localizationsDelegates: [
        CountryLocalizations.delegate,
//        GlobalMaterialLocalizations.delegate,
//        GlobalWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: PhoneNumberSelection(),
    );
  }
}


class PhoneNumberSelection extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return PhoneNumberSelectionState();
  }

}

class PhoneNumberSelectionState extends State<PhoneNumberSelection> {
  TextEditingController userPhoneNumberController = new TextEditingController();
  String _userPhoneNumber = '';
  String _userCountryCode = '+91';


  String verificationId;
  String errorMessage = '';
  String phoneNo = '+91 7540011847';
  String smsOTP;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: WillPopScope(
            onWillPop: (){
              onBackPress();
            },
            child: Column(
              children: <Widget>[
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 5.0, top: 40.0, right: 20.0),
                      child: new IconButton(
                        icon: new Icon(
                            Icons.arrow_back_ios, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (
                                      context) => new LoginSelectionPage()));
                        },
                      ),
                    )
                ),
                Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 20.0, top: 20.0, right: 20.0),
                        child: Text(phone_no,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 20.0, top: 10.0, right: 20.0),
                        child: Text(phone_no_sub,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(

                      decoration: new BoxDecoration(
                        color: greyColor2,
                      ),
                      padding: EdgeInsets.all(5.0),
                      margin: const EdgeInsets.only(
                          left: 20.0, top: 20.0, right: 5.0),
                      child: new CountryCodePicker(
                        onChanged: (prints) {
                          print('COUNTRY CODE ${prints.dialCode}');
                          _userCountryCode = prints.dialCode;
                        },
                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                        initialSelection: 'IN',
                        favorite: ['+91', 'IN'],
                        // optional. Shows only country name and flag
                        showCountryOnly: true,
                      ),
                    ),

                    Expanded(child: Container(
                      margin: const EdgeInsets.only(
                          left: 10.0, top: 20.0, right: 20.0),
                      child: TextField(
                        obscureText: false,
                        controller: userPhoneNumberController,
                        onChanged: (userPhoneNumber) {
                          _userPhoneNumber = userPhoneNumber;
                        },
                        autofocus: true,
                        decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: focused_border_color, width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: greyColor2, width: 2.0),
                          ),
                          hintText: 'Phone Number',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    ),

                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0),
                    padding: EdgeInsets.all(30.0),
                    width: double.infinity,
                    child: SizedBox(
                      height: 45, // specific value
                      child: RaisedButton(
                        onPressed: () {
                          if (_userPhoneNumber != '') {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                new OTPScreen(
                                    mobileNumber: _userCountryCode +
                                        _userPhoneNumber,
                                    mobileNumWithoutCountryCode: _userPhoneNumber)));
                          } else {
                            Fluttertoast.showToast(msg: enter_phone_number);
                          }
                        },
                        color: facebook_color,
                        textColor: text_color,
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                        ),
                        child: Text('CONTINUE',
                          style: TextStyle(fontSize: 17),),
                      ),
                    ),
                  ),
                )
              ],
            ),)
    );
  }


  Future<bool> onBackPress() async {
    print('onBackPress');
    Navigator.pop(context);
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//            builder: (context) => new LoginSelectionPage()));
//    return Future.value(true);
  }
}
