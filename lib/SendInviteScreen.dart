import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SendInviteToUser extends StatefulWidget{
  String _mPeerId, _mCurrentUserId;
  String _mPhotoUrl;
  bool _misAlreadyRequestSent;
  SendInviteToUser(String peerId, String currentUserId,String friendPhotoUrl,bool isAlreadyRequestSent) {
    _mPeerId = peerId;
    _mCurrentUserId = currentUserId;
    _mPhotoUrl = friendPhotoUrl;
    _misAlreadyRequestSent= isAlreadyRequestSent;
  }
  @override
  State<StatefulWidget> createState() {
    return SendInviteToUserState(_mPeerId,_mCurrentUserId,_mPhotoUrl,_misAlreadyRequestSent);
  }

}
class SendInviteToUserState extends State<SendInviteToUser> {
  String _mPeerId, _mCurrentUserId;
  String _mPhotoUrl;
  bool _misAlreadyRequestSent;
  SharedPreferences prefs;

  String _userName,_userPhotoUrl;

  SendInviteToUserState(String peerId, String currentUserId,String friendPhotoUrl,bool isAlreadyRequestSent) {
    print('PERRRR IDD $peerId');
    _mPeerId = peerId;
    _mCurrentUserId = currentUserId;
    _mPhotoUrl = friendPhotoUrl;
    _misAlreadyRequestSent= isAlreadyRequestSent;
  }
  bool isButtonPressed = false;

  @override
  void initState() {
    initial();
    super.initState();
  }

  void initial() async{
    prefs = await SharedPreferences.getInstance();
    if(_misAlreadyRequestSent){
      setState(() {
        isButtonPressed =!isButtonPressed;
      });
    }
    _userName =  await prefs.getString('name');
    _userPhotoUrl =await prefs.getString('photoUrl');
  }
  @override
  Widget build(BuildContext context) {
    return  Flexible(
              child : Center(
                child: RaisedButton(
                  child: Text( isButtonPressed ? 'Invitation sent Successfully Waiting for accept' : ' Sent Invitation' ,),
                  onPressed: () {
                    if (!_misAlreadyRequestSent) {
                      setState(() {
                        isButtonPressed = !isButtonPressed;
                      });
                      var documentReference = Firestore.instance
                          .collection('users')
                          .document(_mCurrentUserId)
                          .collection('FriendsList')
                          .document(_mPeerId);
                      Firestore.instance.runTransaction((transaction) async {
                        await transaction.set(
                          documentReference,
                          {
                            'requestFrom': _mCurrentUserId,
                            'receiveId': _mPeerId,
                            'IsAcceptInvitation': false,
                            'isRequestSent': true,
                            'friendPhotoUrl': _userPhotoUrl,
                            'friendName': _userName,
                            'isAlreadyRequestSent': true,
                            'timestamp': DateTime
                                .now()
                                .millisecondsSinceEpoch
                                .toString(),
                          },
                        );
                      });
                      var documentReference1 = Firestore.instance
                          .collection('users')
                          .document(_mPeerId)
                          .collection('FriendsList')
                          .document(_mCurrentUserId);
                      Firestore.instance.runTransaction((transaction) async {
                        await transaction.set(
                          documentReference1,
                          {
                            'requestFrom': _mCurrentUserId,
                            'receiveId': _mPeerId,
                            'IsAcceptInvitation': false,
                            'isRequestSent': false,
                            'friendPhotoUrl': _userPhotoUrl,
                            'friendName': _userName,
                            'isAlreadyRequestSent': true,
                            'timestamp': DateTime
                                .now()
                                .millisecondsSinceEpoch
                                .toString(),
                          },
                        );
                      });
                    }
                  }
                ),
              )
    );
  }

}