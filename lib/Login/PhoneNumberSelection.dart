import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virus_chat_app/Login/LoginSelection.dart';
import 'package:virus_chat_app/Login/OtpScreenPage.dart';
import 'package:virus_chat_app/Login/otpPage.dart';
import 'package:virus_chat_app/utils/colors.dart';
import 'package:virus_chat_app/utils/strings.dart';
import 'package:virus_chat_app/utils/constants.dart';


class PhoneNumberSelectionPage extends StatelessWidget {

  String _mCurrentLoginType = '';
  PhoneNumberSelectionPage(String loginType){
    _mCurrentLoginType = loginType;
  }
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
//        primarySwatch: Colors.blue,
        fontFamily: 'GoogleSansFamily'
      ),
      home: PhoneNumberSelection(_mCurrentLoginType),
    );
  }
}


class PhoneNumberSelection extends StatefulWidget {
  String _mCurrentLoginType = '';
  PhoneNumberSelection(String mCurrentLoginType){
    _mCurrentLoginType = mCurrentLoginType;
  }


  @override
  State<StatefulWidget> createState() {
    return PhoneNumberSelectionState(_mCurrentLoginType);
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
String _mCurrentLoginType = 'phone';
  SharedPreferences prefs;


  PhoneNumberSelectionState(String mCurrentLoginType){
    _mCurrentLoginType = mCurrentLoginType;
  }

  @override
  void initState() {
    super.initState();
    initialise();

  }


  void initialise() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(WALK_THROUGH, 'YES');
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body:  WillPopScope(
            onWillPop: () async => false,
            child: new GestureDetector(
            onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                 _mCurrentLoginType == 'business' ? Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 5.0, top: 40.0, right: 20.0),
                        child: new IconButton(
                          icon: new Icon(
                              Icons.arrow_back_ios, color: Colors.black),
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (
                                        context) => new PhoneNumberSelectionPage('phone')));
                          },
                        ),
                      )
                  ) : Container(),
                  Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(
                              top: _mCurrentLoginType == 'business' ? 10.0 : 70.0,left: 20.0, right: 20.0),
                          child: Text( _mCurrentLoginType== 'phone' ? phone_no : phone_number_business,
                            style: TextStyle(
                                fontSize: 27,fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w500,color: black_color),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(
                              left: 20.0, top: 30.0, right: 0.0),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment
                                .start,
                            children: <Widget>[
                            Text('Tap \"Get started\" to get an SMS confirmation to',
                              style: TextStyle(fontSize: 15,fontFamily: 'GoogleSansFamily',color : hint_color_grey_dark,fontWeight: FontWeight.w400,),
                            ),
                            Text('help you use Chat.We would like your phone',
                              style: TextStyle(fontSize: 15,fontFamily: 'GoogleSansFamily',color : hint_color_grey_dark,fontWeight: FontWeight.w400,),
                            ),
                            Text('number.',
                              style: TextStyle(fontSize: 15,fontFamily: 'GoogleSansFamily',color : hint_color_grey_dark,fontWeight: FontWeight.w400,),
                            ),
                          ],)
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(
                                top: 40.0, right: 5.0),
                            child: Text(country_code,style: TextStyle(color: hint_color_grey_light,fontWeight: FontWeight.w400),),
                          ),
                          Container(
                              decoration: new BoxDecoration(
                                border: Border.all(color: greyColor2,width: 0.5),
                                borderRadius: BorderRadius.all( Radius.circular(5.0),)
                              ),
                              /* decoration: new BoxDecoration(
                        color: greyColor2,
                      ),*/
                              padding: EdgeInsets.all(5.0),
                              margin: const EdgeInsets.only(
                                  left: 20.0, top: 10.0, right: 5.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: <Widget>[
                                  new CountryCodePicker(
                                    onChanged: (prints) {
                                      print('COUNTRY CODE ${prints.dialCode}');
                                      _userCountryCode = prints.dialCode;
                                    },
                                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                    initialSelection: 'IN',
                                    textStyle: TextStyle(color: hint_color_grey_light,fontWeight: FontWeight.w400),
                                    favorite: ['+91', 'IN'],
                                    // optional. Shows only country name and flag
                                    showCountryOnly: true,
                                    showFlagDialog: true,
//                            showFlag: false,
                                  ),
                                  new Icon(
                                      Icons.keyboard_arrow_down, color: Colors.black),
                                ],
                              )
                          ),

                        ],
                      ),
                      Expanded(child: Container(
                        margin: const EdgeInsets.only(
                            left: 10.0, top: 65.0, right: 20.0),
                        child: TextField(
                          obscureText: false,
                          controller: userPhoneNumberController,
                          onChanged: (userPhoneNumber) {
                            _userPhoneNumber = userPhoneNumber;
                          },
                          autofocus: false,
                          decoration: new InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: focused_border_color, width: 0.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: greyColor2, width:0.5),
                            ),
                            hintStyle: TextStyle(fontSize: HINT_TEXT_SIZE,fontFamily: 'GoogleSansFamily',color: hint_color_grey_light,fontWeight: FontWeight.w400),
                            hintText:'Phone number',
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
                      margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
//                    padding: EdgeInsets.all(30.0),
                      width: double.infinity,
                      child: SizedBox(
                        height: 45, // specific value
                        child: RaisedButton(
                          onPressed: () {
                            if(_userPhoneNumber == ''){
                              Fluttertoast.showToast(msg: enter_phone_number);
                            }else if(_userPhoneNumber.length != MOBILE_NUMBER_LENGTH) {
                              Fluttertoast.showToast(msg: enter_valid_phone_number);
                            }else{
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) =>
                                  new OTPScreen(
                                    mobileNumber: _userCountryCode + _userPhoneNumber,
                                    mobileNumWithoutCountryCode: _userPhoneNumber,mCurrentLoginType: _mCurrentLoginType,)));
                            }
                          },
                          color: button_fill_color,
                          textColor: text_color,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          child: Text(continue_txt,
                              style: TextStyle(fontSize: BUTTON_TEXT_SIZE,fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400)),
                        ),
                      ),
                    ),
                  ),
                  _mCurrentLoginType == 'phone'|| _mCurrentLoginType == '' ?Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      child: Text(are_busines,style: TextStyle(fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400,color: hint_color_grey_dark),),
                    ),
                   GestureDetector(
                     onTap: (){
                       Navigator.pushReplacement(
                           context,
                           MaterialPageRoute(
                               builder: (context) {
                                 return PhoneNumberSelectionPage('business');
                               }
                           ));
                     },
                     child:Container(
                       margin: EdgeInsets.only(top: 30.0),
                       child: Text('\t'+sign_up,style: TextStyle(fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400,color: button_fill_color),),
                     ),
                   )
                  ],
                )
              ) : Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 30.0),
                            child: Text(are_user,style: TextStyle(fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400,color: hint_color_grey_dark),),
                          ),
                          GestureDetector(
                            onTap: (){
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) {
                                        return PhoneNumberSelectionPage('phone');
                                      }
                                  ));
                            },
                            child:Container(
                              margin: EdgeInsets.only(top: 30.0),
                              child: Text('\t'+login,style: TextStyle(fontFamily: 'GoogleSansFamily',fontWeight: FontWeight.w400,color: button_fill_color),),
                            ),
                          )
                        ],
                      )
                  )
                ],
              ),
            ),)
        )
    );
  }


  Future<bool> onBackPress() async {
    print('onBackPress');
//    Navigator.pop(context);
  /*  Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new LoginSelection()));*/
    return Future.value(false);
  }
}
