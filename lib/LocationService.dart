import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:location/location.dart';
import 'package:virus_chat_app/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  UserLocation _currentLocation = null;
  LocationData _mCurrentLocation = null;

  var location = Location();
  String currentUserId = '';
  String businessType = '';

//  Geoflutterfire geo = Geoflutterfire();

  Future<UserLocation> getLocation() async {
    print('LocationService  ___ getLocation');
    location.changeSettings(interval: 30000);
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
    return _currentLocation;
  }

  StreamController<UserLocation> locationController =
  StreamController<UserLocation>();

  Stream<UserLocation> get locationStream => locationController.stream;
  StreamSubscription<LocationData> locationSubcription;


  bool mUserCancelListen = false;

  void initialise() async {
    preferences = await SharedPreferences.getInstance();
  }

  LocationService(String currentUser,String businessUserType, String businessId) {
    businessType = businessUserType;

    location.changeSettings(interval: 30000);

    print(
        'LocationService NANDHUuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu ___ $currentUser');
    if (preferences == null) {
      initialise();
    }
    if (currentUser != '') {
      currentUserId = currentUser;

      if (currentUserId != '') {} else {
//      location = null;
        locationController.close();
        if (locationSubcription != null)
          locationSubcription.cancel();
      }

      // Request permission to use location
      location.requestPermission().then((granted) {
        if (granted != null) {
        print('LocationService  ___granted__ $currentUser');
          // If granted listen to the onLocationChanged stream and emit over our controller
          if (location != null) {
                locationSubcription = location.onLocationChanged().listen((locationData) async {
//                print(
//                    'LocationService  isClosed NOWWWWWWWW ${new DateTime.now()} ____________NANDHU ${locationController
//                        .isClosed}');
//                  if (locationController.isClosed) {
//                    mUserCancelListen = locationController.isClosed;
//                  print('mUserCancelListen_____condition $mUserCancelListen');
//                  }
                 /* if (mUserCancelListen) {
//                  print(
//                      'LocationService  locationSubcription $locationData');
                    locationSubcription.cancel();
                    locationController.close();
                    currentUserId = '';
                  }*/
//                print('mUserCancelListen_____ $mUserCancelListen');
                  if (locationData != null && !mUserCancelListen) {
              print('LocationService  locationData ______ $currentUser');
                    locationController.add(UserLocation(
                      latitude: locationData.latitude,
                      longitude: locationData.longitude,
                    ));
                    /* _currentLocation = UserLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
            );*/
//                  print('_currentLocation $_currentLocation');
//                    Timer timer = Timer.periodic(Duration(minutes: 1), (Timer _) {
//                      print('NANDHU Location service Update ____Now ____${new DateTime.now()}');
//                });

                    _mCurrentLocation = locationData;
                    await Future.delayed(Duration(milliseconds: 30000));
                    if (_currentLocation == null) {
//              _addGeoPoint(locationData);
                        updateLocation(locationData);
                    } else {
                      if (currentUser != '') {
                            updateLocation(locationData);
                      }
                    }
                  } else {
                    locationController.close();
                    locationSubcription.cancel();
//                  print('LocationService  NOT LOCATIONNULL $locationData');

//              print('LocationService  locationDataNULL ______ $currentUser');
                    /*    Firestore.instance
                  .collection('users')
                  .document(currentUserId)
                  .updateData({'status': 'INACTIVE'});*/
                  }
                });
          } else {
//          print('LocationService  ___NOTgranted__ $location');
          }
        } else {
          Fluttertoast.showToast(
              msg: 'Please enable location service');
//        print('LocationService  ___NOTgranted__ $currentUser');
          /* Firestore.instance_currentLocation
              .collection('users')
              .document(currentUserId)
              .updateData({'status': 'INACTIVE'});*/
        }
      });
    }
  }

  final databaseReference = Firestore.instance;
  SharedPreferences preferences = null;
  String _userStatus = '';

  void insertLocation(LocationData locationData) async {
    DocumentReference ref = await databaseReference.collection("users").add({
      'lattitude': locationData.latitude,
      'longtitude': locationData.longitude
    });
//    print('Document ID ${ref.documentID}');
  }

  Future<DocumentReference> _addGeoPoint(LocationData locationData) async {
//    print('NAN _addGeoPoint $currentUserId  ___locationData $locationData');
    var pos = locationData;
//    GeoFirePoint point =
//    geo.point(latitude: pos.latitude, longitude: pos.longitude);
//    databaseReference.collection('users').document(currentUserId).updateData({'position': point.data});
/* return databaseReference.collection('users').add({
      'position': point.data,
    });*/
  }

  Future<void> updateLocation(LocationData locationData)  async {
    print('______________________________________updateLocation ${new DateTime.now()}');
//    GeoFirePoint point = geo.point(
//        latitude: locationData.latitude, longitude: locationData.longitude);
    /* databaseReference.collection('users').document(currentUserId).updateData({
      'userLocation':
          new GeoPoint(locationData.latitude, locationData.longitude)
    });*/


    await Future.delayed(Duration(milliseconds: 30000));
//    await Future.delayed(Duration(seconds: 30));

    /*requestContactsPermission(
        onPermissionDenied: () {
          Fluttertoast.showToast(
              msg: 'Please enable location service');
        });*/
    print('______________________________________Delay ${new DateTime.now()}');
//    Timer(Duration(seconds: 10),(){
      databaseReference.collection('users').document(currentUserId).collection(
          'userLocation').document(currentUserId).updateData({
        'userLocation':
        new GeoPoint(locationData.latitude, locationData.longitude),
        'UpdateTime': ((new DateTime.now()
            .toUtc()
            .microsecondsSinceEpoch) / 1000).toInt(),
      });

    /*  if(businessType != '' || businessType == BUSINESS_TYPE_OWNER){
        databaseReference.collection('business').document(currentUserId).collection(
            'businessLocation').document(currentUserId).updateData({
          'businessLocation':
          new GeoPoint(locationData.latitude, locationData.longitude),
          'UpdateTime': ((new DateTime.now()
              .toUtc()
              .microsecondsSinceEpoch) / 1000).toInt(),
        });
      }*/
//    });

//    Timer(Duration(seconds: 5), () {
//      print('NAN LocationService $currentUserId  ___ ${locationData}');
      /*databaseReference.collection('users').document(currentUserId).collection(
          'userLocation').document(currentUserId).updateData({
        'userLocation':
        new GeoPoint(locationData.latitude, locationData.longitude),
        'UpdateTime': ((new DateTime.now()
            .toUtc()
            .microsecondsSinceEpoch) / 1000).toInt(),
      });*/
//    });

   /*Timer.periodic(Duration(milliseconds: 60000), (Timer _) {
//      print("MY Timer_________$currentUserId _____Now __${new DateTime.now()}");
      databaseReference.collection('users').document(currentUserId).collection(
          'userLocation').document(currentUserId).updateData({
        'userLocation':
        new GeoPoint(locationData.latitude, locationData.longitude),
        'UpdateTime': ((new DateTime.now()
            .toUtc()
            .microsecondsSinceEpoch) / 1000).toInt(),
      });
    });*/

   /* Timer(Duration(seconds: 60), () {
      print("Timer_________$currentUserId _____Now __${new DateTime.now()}");
    });*/
  }
 /* final PermissionHandler _permissionHandler = PermissionHandler();

  /// Requests the users permission to read their contacts.
  Future<bool> requestContactsPermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.contacts);
    if (!granted) {
      onPermissionDenied();
    }
    return granted;
  }

  Future<bool> _requestPermission(PermissionGroup permission) async {
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }

    return false;
  }*/
  void updateLocationOfNewUser(String UserId) async {
    if (_currentLocation == null) {
      print('NAN updateLocationOfNewUser ______________$_mCurrentLocation');
      databaseReference.collection('users').document(UserId).collection(
          'userLocation').document(UserId).updateData({
        'userLocation':
        new GeoPoint(_mCurrentLocation.latitude, _mCurrentLocation.longitude),
        'UpdateTime': ((new DateTime.now()
            .toUtc()
            .microsecondsSinceEpoch) / 1000).toInt(),
      });
    } else {
      await getLocation();
    }
//    GeoFirePoint point = geo.point(
//        latitude: locationData.latitude, longitude: locationData.longitude);
    /* databaseReference.collection('users').document(currentUserId).updateData({
      'userLocation':
          new GeoPoint(locationData.latitude, locationData.longitude)
    });*/

  }
}
