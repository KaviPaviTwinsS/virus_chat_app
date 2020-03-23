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
    print('LocationService  ___ getLocation');

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

  LocationService(String currentUser) {
    print('LocationService  ___ $currentUser');
    currentUserId = currentUser;
    if(currentUserId == ''){
      locationController.close();
    }
      // Request permission to use location
      location.requestPermission().then((granted) {
        print('Location data granted $_currentLocation  ___ $currentUserId');
        if (granted != null) {
          // If granted listen to the onLocationChanged stream and emit over our controller
          locationSubcription = location.onLocationChanged().listen((locationData) {
            if (locationData != null && !locationController.isClosed) {
              locationController.add(UserLocation(
                latitude: locationData.latitude,
                longitude: locationData.longitude,
              ));
              /* _currentLocation = UserLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
            );*/
              print('currentUserId $currentUserId');
              if (_currentLocation == null) {
                print('Location data $locationData');
//              _addGeoPoint(locationData);
                updateLocation(locationData);
              } else {
                if (currentUserId != '') {
                  updateLocation(locationData);
                }
              }
            }
          });
        }
      });
  }
  final databaseReference = Firestore.instance;

  void insertLocation(LocationData locationData) async {
    DocumentReference ref = await databaseReference.collection("users").add({
      'lattitude': locationData.latitude,
      'longtitude': locationData.longitude
    });
    print('Document ID ${ref.documentID}');
  }

  Future<DocumentReference> _addGeoPoint(LocationData locationData) async {
    print('NAN _addGeoPoint $currentUserId  ___locationData $locationData');
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
    print('NAN updateLocation $currentUserId  ___ ${locationData}');
    GeoFirePoint point = geo.point(
        latitude: locationData.latitude, longitude: locationData.longitude);
   /* databaseReference.collection('users').document(currentUserId).updateData({
      'userLocation':
          new GeoPoint(locationData.latitude, locationData.longitude)
    });*/
    databaseReference.collection('users').document(currentUserId).collection('userLocation').document(currentUserId).updateData({
      'userLocation':
      new GeoPoint(locationData.latitude, locationData.longitude)
    });
  }
}
