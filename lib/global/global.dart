import 'package:firebase_auth/firebase_auth.dart';

import '../models/active_nearby_available_drivers.dart';
import '../models/direction_details_info.dart';
import '../models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? currentUserInfo;
List driversList = [];
DirectionDetailsInfo? tripDirectionDetailsInfo;
String chosenDriverId = "";
String cloudMessagingServerToken = "ya29.a0AbVbY6OvWgt_h7jZeQOQ4qIN-8Pkpdd7_Co_oKA2NfjxYH2jwJJFsExeidDbj8DiqBY3jSFgjE6IGms0mbqN8QqDPHmEnzgWJmWyqTlWKks4MXEtUjtTp9KiiW3Qear9-ClQd3iv5hr2hjSpMhPUvGox0e_waCgYKASESARASFQFWKvPlcV90jEHpGgbMKhjalu095Q0163";
String driverCarDetails = "";
String carModel = "";
String carNumber = "";
String carType = "";
String driverName = "";
String driverPhone = "";
double countRatingStars = 0.0;
String titleStarsRating = "";