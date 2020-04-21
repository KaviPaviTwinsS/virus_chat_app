import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:virus_chat_app/UserLocation.dart';
import 'package:location/location.dart';

class LocationService {
  UserLocation _currentLocation = null;
  var location = Location();
  String currentUserId = '';

  Geoflutterfire geo = Geoflutterfire();

  Future<UserLocation> getLocation() async {
//    print('LocationService  ___ getLocation');

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

  LocationService(String currentUser) {
    currentUserId = currentUser;
//    print(
//        'LocationService NANDHUuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu ___ $currentUserId');
    if (currentUserId != '') {} else {
//      location = null;
      locationController.close();
      if (locationSubcription != null)
        locationSubcription.cancel();
    }
    // Request permission to use location
    location.requestPermission().then((granted) {
      if (granted != null) {
//        print('LocationService  ___granted__ $currentUser');
        // If granted listen to the onLocationChanged stream and emit over our controller
        if (location != null) {
          locationSubcription =
              location.onLocationChanged.listen((locationData) {
//                print(
//                    'LocationService  isClosed currentUser $currentUserId ____________NANDHU ${locationController
//                        .isClosed}');
                if (locationController.isClosed) {
                  mUserCancelListen = locationController.isClosed;
//                  print('mUserCancelListen_____condition $mUserCancelListen');
                }
                if (mUserCancelListen) {
//                  print(
//                      'LocationService  locationSubcription $locationData');
                  locationSubcription.cancel();
                  locationController.close();
                  currentUserId = '';
                }
//                print('mUserCancelListen_____ $mUserCancelListen');
                if (locationData != null && !mUserCancelListen) {
//              print('LocationService  locationData ______ $currentUser');
                  locationController.add(UserLocation(
                    latitude: locationData.latitude,
                    longitude: locationData.longitude,
                  ));
                  /* _currentLocation = UserLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
            );*/
//                  print('_currentLocation $_currentLocation');
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
//        print('LocationService  ___NOTgranted__ $currentUser');
        /* Firestore.instance_currentLocation
              .collection('users')
              .document(currentUserId)
              .updateData({'status': 'INACTIVE'});*/
      }
    });
  }

  final databaseReference = Firestore.instance;

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
    GeoFirePoint point =
    geo.point(latitude: pos.latitude, longitude: pos.longitude);
//    databaseReference.collection('users').document(currentUserId).updateData({'position': point.data});
/*
    return databaseReference.collection('users').add({
      'position': point.data,
    });*/
  }

  void updateLocation(LocationData locationData) async {
    print('NAN LocationService $currentUserId  ___ ${locationData}');
//    GeoFirePoint point = geo.point(
//        latitude: locationData.latitude, longitude: locationData.longitude);
    /* databaseReference.collection('users').document(currentUserId).updateData({
      'userLocation':
          new GeoPoint(locationData.latitude, locationData.longitude)
    });*/
    databaseReference.collection('users').document(currentUserId).collection(
        'userLocation').document(currentUserId).updateData({
      'userLocation':
      new GeoPoint(locationData.latitude, locationData.longitude),
      'UpdateTime': ((new DateTime.now()
          .toUtc()
          .microsecondsSinceEpoch) / 1000).toInt(),
    });
  }
}
