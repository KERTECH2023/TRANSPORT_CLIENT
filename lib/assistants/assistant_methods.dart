import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth_platform_interface/src/id_token_result.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    as firebase_messaging;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:users_app/assistants/request_assistant.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/global/map_key.dart';
import 'package:users_app/models/direction_details_info.dart';
import 'package:users_app/models/directions.dart';
import 'package:users_app/models/trip_history_model.dart';

import '../InfoHandler/app_info.dart';
import '../models/user_model.dart';

class AssistantMethods {
  void requestNotificationPermission() async {
    firebase_messaging.NotificationSettings settings =
        await firebase_messaging.FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus ==
        firebase_messaging.AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        firebase_messaging.AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

//  static Future<void> fetchAccessToken() async {
//   final IdTokenResult? tokenResult = await firebaseAuth.currentUser?.getIdTokenResult();
//   final String? idToken = tokenResult?.token;
//   print("Access Token: $idToken");
// }
  static Future<String> getAccessToken() async {
    final ServiceAccountCredentials credentials =
        ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "transport-app-36443",
      "private_key_id": "889793038ab1f54274b33d616240b40e090200bb",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCpksWC7Z/K3Wp7\nbogMe4TIuq07L6PLz5zbsEHfrvEHaWsgzVxX7Jz64UTfXBMlYeyPylvUYlcEHxQg\nd5BoXAnrTTbNGz6XWcOevx6irp9GXokIjxJX6bZ1kib7rbz7YqUrhRRo7cBCjbCy\noRyHj4kbN4kyYqzsVMh6SkaFMTtCWIvaHmjsHfocEMvgj5helXLqNY6kd9CZWDv/\nf2mpca5uUSuEKqGqcAjuw4qyAsmb8gbUwO9wQMWSQip85duMDz7l8uZnpO1wNu7L\nKCegQcwbKSCa8YFMxVJHupvMhr+kywaONyld/0b5eyvDaHNfGdhoT0gJA+p1yKJa\naBui3ITdAgMBAAECggEADLlIG7Zjzo+FnWRiTfl4sa0cMXw2IKVf4jYcA0I3sLQu\nxyPRoYFOGB8OEWpxv1TVMMbg1BNa7yK72mHOUp5RWjgNfB9mt2mTXZZ+oHtU1S1j\nv+IoYLNXLwQ765eSPhSdSyItsV/hlLzX/NdM8jkJcyLcJw0zZ3pHHrHzD6xtg2FN\nOhUOqsQtfckcujTwGSwtDlqBxBiaylEUYjASxOCez5UbKtTsPn2+0E+AqCO5a8Re\nP/HLbTXpTIweVGzcevy2fx0/P04Qc9RbkfkkDcU7DwCfEN9SfonceWgDysbsqayF\nHJAycV4STcUa7rEXXlhQIBWkS9EnmDD2zEAH+FYnWwKBgQDVrfPi7z7JTxovT8qS\nTE2ZsHZEpMIeBJzS8lWSiT8ZS9D9OvMZJd5Qe9kPI5s2Memi9MuqoUpDkrA/gKQL\nf1CIqn/87YDO93gQM0XjhNW8j8JlBtJqvBjXjQcDr5CijcvwivggzWAMbLYuwVie\noU+DT1F+SGvygiImsxESyqIKtwKBgQDLKIiAvS+OZ5K1sYGQwDIGH/mJbWedcvqF\nfNuzum2U49N2UBWCP8zD+h9m/E6pl33Blzq436gAm579uW3wBZpSzv9SgN3TddBr\nKUyy/1JM6PEgwWsnOzNPvZ4OttzKQkYhshH54YVYs0WW56qtY1q+3FrS3WKCM89Z\nkeaMt4dpCwKBgCr2e9gAFJazUed7WpaJwvyIz27D1cflU4bSdMQu1kIGzXFs/d3r\nkESMcjsqBJYj+P7ry1t2bJEjmE5cVh99rLqd1XgMZN64QSq4tG+nkLYGDab0dTBC\nu5fzYhqqnSEh84Rc3MDzqkE1RngmJeRXOL6FHzSN6S5sXeN8E428slIHAoGBAKn0\njM12d1RgnUFW8BdSUgcBtNYdKnNzftUxcPLYYVgPiBYQRQ4jpX/FvYOAS6Zgz5mm\nlD+ZC4kGp2mHOMt1RHdGKB6zI+AFTYh4kmukYQtqTF6ksKmvQuvQq2uP2wFxlA4Y\nVCWBXvancu4dfJF07rOA0JJbFk/qW+qIviC2YJelAoGAHumB+nmF5YlynYu2Y8zg\n+lIJE01ZcAEKLvh7/2XwADFik/PBwnSoMzd/+J6XXZnJH5+G5pgAwKw1PU9dIUYZ\nJQeoD3YQCFY+RiAAXw+4fPtT9R6dQQunGTmGuRcFlqSqg+451ucIioN2Pl81f8LF\n7RoNVX6e05U4GWo8SnG3rmk=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-4c10y@transport-app-36443.iam.gserviceaccount.com",
      "client_id": "101907917733769173323",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-4c10y%40transport-app-36443.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    });

    final client = await clientViaServiceAccount(
        credentials, ['https://www.googleapis.com/auth/firebase.messaging']);
    final AccessCredentials accessCredentials = await client.credentials;

    return accessCredentials.accessToken.data;
  }

  static final _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
  }

  static Future<String?> fetchAccessToken() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      final IdTokenResult tokenResult = await user.getIdTokenResult();
      return tokenResult.token;
    }
    return null;
  }

  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String humanReadableAddress = "Error";

    // Creating connection to Geocode / Geolocation Api
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    // Sending the api Url to the static method to use the url to fetch the Readable Address
    var requestResponse = await RequestAssistant.ReceiveRequest(apiUrl);

    if (requestResponse != "Error fetching the request") {
      humanReadableAddress = requestResponse["results"][0]
          ["formatted_address"]; // Human Readable Address

      // Creating instance of Direction and assigning the values
      Directions userPickupAddress = Directions();
      userPickupAddress.locationLatitude = position.latitude;
      userPickupAddress.locationLongitude = position.longitude;
      userPickupAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickupLocationAddress(userPickupAddress);
    }

    return humanReadableAddress;
  }

  static void readOnlineUserCurrentInfo() {
    currentFirebaseUser = firebaseAuth.currentUser;
    DatabaseReference reference = FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child(currentFirebaseUser!.uid);

    reference.once().then((snap) {
      final DataSnapshot snapshot = snap.snapshot;
      if (snapshot.exists) {
        currentUserInfo = UserModel.fromSnapshot(snapshot);
      }
    });
  }

  static Future<DirectionDetailsInfo?> getOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    // Create connection to direction Api
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    // Sending the api Url to the static method to use the url to fetch the driving directions in Json format.
    var response = await RequestAssistant.ReceiveRequest(
        urlOriginToDestinationDirectionDetails);
print("response:$response");
    if (response == "Error fetching the request") {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = response["routes"][0]["overview_polyline"]
        ["points"]; // Poly/Encoded points from Current Location to destination

    directionDetailsInfo.distance_value =
        response["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailsInfo.distance_text =
        response["routes"][0]["legs"][0]["distance"]["text"];

    directionDetailsInfo.duration_value =
        response["routes"][0]["legs"][0]["duration"]["value"];
    directionDetailsInfo.duration_text =
        response["routes"][0]["legs"][0]["duration"]["text"];

    return directionDetailsInfo;
  }

  static Future<double> getTarifs() async {
    double fareBase=0.0;
    String placesDirectionDetailUrl =
        "https://backend-admin-iota.vercel.app/Tar/show";

    var responseApi = await RequestAssistant.ReceiveRequest(
        placesDirectionDetailUrl); // Receiving api Response

    print("responseApi, $responseApi");
     fareBase =
        double.parse(responseApi[0]["tarif"])  ;// Accédez à la valeur dans la liste
    print("fareBase $fareBase");
    return fareBase;
  }

  static double calculateFareAmountFromSourceToDestination(
      DirectionDetailsInfo directionDetailsInfo)  {
    double baseFare, fareAmountPerKilometer;

    print("distance_text, ${directionDetailsInfo.distance_text}");
    print("distance_value, ${directionDetailsInfo.distance_value}");
    baseFare = 2.4; // Attendez que la future se résolve


      fareAmountPerKilometer = directionDetailsInfo.distance_value! * baseFare;

print("fareAmountPerKilometer $fareAmountPerKilometer");

    double totalFareAmount = fareAmountPerKilometer / 1000;
    print("totalFareAmount: $totalFareAmount");
    return double.parse(totalFareAmount.toStringAsFixed(1));;
  }

  // static Future<double> getTarifs() async {
  //   String placesDirectionDetailUrl =
  //       "https://backend-admin-iota.vercel.app/Tar/show";
  //
  //   var responseApi =
  //       await RequestAssistant.ReceiveRequest(placesDirectionDetailUrl);
  //
  //   print("responseApi, $responseApi");
  //
  //   // Si responseApi est une liste avec des tarifs, prenez le premier élément et récupérez le tarif
  //   if (responseApi is List && responseApi.isNotEmpty) {
  //     double fareBase = double.parse(responseApi[0]["tarif"]);
  //     print("fareBase $fareBase");
  //     return fareBase;
  //   } else {
  //     // Si la réponse n'est pas conforme à ce que vous attendez, vous pouvez lancer une exception ou renvoyer une valeur par défaut
  //     throw Exception("Erreur lors de la récupération des tarifs.");
  //   }
  // }
  //
  // static Future<double> calculateFareAmountFromSourceToDestination(
  //     DirectionDetailsInfo directionDetailsInfo, String vehicleType) async {
  //   double baseFare, fareAmountPerKilometer;
  //   double tarif = await getTarifs();
  //
  //   print("distance_text, ${directionDetailsInfo.distance_text}");
  //   print("distance_value, ${directionDetailsInfo.distance_value}");
  //
  //   if (vehicleType == "UberX" || vehicleType == "Uber Premier") {
  //     baseFare = tarif;
  //     fareAmountPerKilometer = directionDetailsInfo.distance_value! * baseFare;
  //   } else {
  //     // Traiter le cas où le type de véhicule n'est pas spécifié
  //     throw Exception("Type de véhicule non reconnu.");
  //   }
  //
  //   double totalFareAmount = fareAmountPerKilometer / 1000;
  //   return double.parse(totalFareAmount.toStringAsFixed(1));
  // }

  // static Future<double> getTarifs() async {
  //   String placesDirectionDetailUrl =
  //       "https://backend-admin-iota.vercel.app/Tar/show";
  //
  //   var responseApi = await RequestAssistant.ReceiveRequest(
  //       placesDirectionDetailUrl); // Receiving api Response
  //
  //   print("responseApi, $responseApi");
  //   double fareBase = responseApi("tarif");
  //   print("fareBase $fareBase");
  //   return fareBase;
  // }
  //
  // static double calculateFareAmountFromSourceToDestination(
  //     DirectionDetailsInfo directionDetailsInfo, String vehicleType) {
  //   double baseFare, fareAmountPerKilometer;
  //   print("distance_text, ${directionDetailsInfo.distance_text}");
  //   print("distance_value, ${directionDetailsInfo.distance_value}");
  //   if (vehicleType == "UberX") {
  //     baseFare = getTarifs() as double;
  //
  //     fareAmountPerKilometer = directionDetailsInfo.distance_value! * baseFare;
  //   } else if (vehicleType == "Uber Premier") {
  //     baseFare = getTarifs() as double;
  //
  //     fareAmountPerKilometer = directionDetailsInfo.distance_value! * baseFare;
  //   } else {
  //     baseFare = getTarifs() as double;
  //
  //     fareAmountPerKilometer = directionDetailsInfo.distance_value! * baseFare;
  //   }
  //
  //   double totalFareAmount = fareAmountPerKilometer / 1000;
  //   return double.parse(totalFareAmount.toStringAsFixed(1));
  // }

  // Postman work
  static sendNotificationToDriver(
      context, String? rideRequestID, String deviceRegistrationToken) async {
    //  final FCMToken= await _firebaseMessaging.getToken();
    // print('Token : $FCMToken');
    //  final idToken = await fetchAccessToken();
    //   if (idToken != null) {
    //     print("tokennnauthh "+ idToken.toString());
    final accessToken = await getAccessToken();
    print('Access Token: $accessToken');

    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    Map<String, dynamic> bodyNotification = {
      "body": "You have a new ride request!",
      "title": "New Ride Request"
    };
    Map<String, dynamic> android = {
      "priority": "high",
    };
    Map<String, dynamic> dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "rideRequestId": rideRequestID
    };
    Map<String, dynamic> message = {
      "token": deviceRegistrationToken,
      "data": dataMap,
      "notification": bodyNotification,
      "android": android,
    };

    Map<String, dynamic> officielNotificationFormat = {
      "notification": bodyNotification,
    };

    Map<String, dynamic> fcm = {
      "message": message,
    };
    var responseNotification = await post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/transport-app-36443/messages:send'),
      headers: headerNotification,
      body: jsonEncode(fcm),
    );
    print("ssssssssssssssssssssssssssssssssssssssssss");
    

    // Work of postman to send notification
    
 
  }

  // For Trip history
 static  void readRideRequestKeys(context) {

 // print("mahdi${currentUserInfo!.name}");
    FirebaseDatabase.instance
        .ref()
        .child("AllRideRequests")
        .orderByChild("userName")
        .equalTo(currentUserInfo!.name)
        .once()
        .then((snapData) {
      DataSnapshot snapshot = snapData.snapshot;
      if (snapshot.exists) {
        // Total trips taken by this user
        Map rideRequestKeys = snapshot.value as Map;
        int totalTripsCount = rideRequestKeys.length;

        // Updating total trips taken by this user
        Provider.of<AppInfo>(context, listen: false)
            .updateTotalTrips(totalTripsCount);

        // Store all the rideRequest key/id in this list
        List<String> allRideRequestKeyList = [];
        rideRequestKeys.forEach((key, value) {
          allRideRequestKeyList.add(key);
        });

        // Storing the total trips taken list in provider
        Provider.of<AppInfo>(context, listen: false)
            .updateTotalTripsList(allRideRequestKeyList);

        readTripHistoryInformation(context);
      }
    });
  }

  static void readTripHistoryInformation(context) {
    var historyTripsKeyList =
        Provider.of<AppInfo>(context, listen: false).historyTripsKeyList;
    for (String eachKey in historyTripsKeyList) {
      FirebaseDatabase.instance
          .ref()
          .child("AllRideRequests")
          .child(eachKey)
          .once()
          .then((snapData) {
        // convert each ride request information to TripHistoryModel
        var eachTripHistoryInformation =
            TripHistoryModel.fromSnapshot(snapData.snapshot);

        if ((snapData.snapshot.value as Map)["status"] == "Ended") {
          // Add each TripHistoryModel to a  historyInformationList in AppInfo class
          Provider.of<AppInfo>(context, listen: false)
              .updateTotalHistoryInformation(eachTripHistoryInformation);
        }
      });
    }
  }

  Future generateAndGetToken() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? registrationToken = await FirebaseMessaging.instance.getToken();

    FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child(firebaseAuth.currentUser!.uid)
        .child("token")
        .set(registrationToken);
    firebaseMessaging.subscribeToTopic("allDrivers");
    firebaseMessaging.subscribeToTopic("allUsers");
  }
}
