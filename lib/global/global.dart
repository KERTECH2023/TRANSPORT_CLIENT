import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/active_nearby_available_drivers.dart';
import '../models/direction_details_info.dart';
import '../models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? currentUserInfo;
Set driversList = {};
DirectionDetailsInfo? tripDirectionDetailsInfo;
String chosenDriverId = "";
double fare= 0.0;
String cloudMessagingServerToken = "ya29.a0AbVbY6OvWgt_h7jZeQOQ4qIN-8Pkpdd7_Co_oKA2NfjxYH2jwJJFsExeidDbj8DiqBY3jSFgjE6IGms0mbqN8QqDPHmEnzgWJmWyqTlWKks4MXEtUjtTp9KiiW3Qear9-ClQd3iv5hr2hjSpMhPUvGox0e_waCgYKASESARASFQFWKvPlcV90jEHpGgbMKhjalu095Q0163";
String driverCarDetails = "";
String carModel = "";
String carNumber = "";
String carType = "";
String driverName = "";
String driverPhoto="";
String driverPhone = "";
double countRatingStars = 0.0;
String titleStarsRating = "";
LatLng driverpos=LatLng(0.0, 0.0);
LatLng destinationpos=LatLng(0.0, 0.0);
LatLng clientpos=LatLng(0.0, 0.0);
