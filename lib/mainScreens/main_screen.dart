import 'dart:async';
import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users_app/assistants/Geofire_assistant.dart';
import 'package:users_app/classesLanguage/language.dart';
import 'package:users_app/classesLanguage/language_constants.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/main.dart';
import 'package:users_app/mainScreens/rate_driver_screen.dart';
import 'package:users_app/mainScreens/select_active_driver_screen.dart';
import 'package:users_app/models/active_nearby_available_drivers.dart';
import 'package:users_app/widgets/Progress.dart';
import 'package:users_app/widgets/dashboard_drawer.dart';
import 'package:users_app/widgets/driver_cancel_message_dialog.dart';
import 'package:users_app/widgets/pay_fare_amount_dialog.dart';
import 'package:http/http.dart' as http;

import '../InfoHandler/app_info.dart';
import '../assistants/assistant_methods.dart';
import '../widgets/progress_dialog.dart';

class MainScreen extends StatefulWidget  {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver{
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newMapController;


  AssistantMethods notificationServices = AssistantMethods();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(36.891696, 10.1815426),
    zoom: 9.4746,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double suggestedRidesConatinerHeight = 0;
  double serchingForDriverContainerHeight = 0;
  double searchLocationContainerHeight = 220;
  double responseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
 var geoLocator = Geolocator();
  LocationPermission? _locationPermission;
  String riderequestid = "";
  List<LatLng> polyLineCoordinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  List<ActiveNearbyAvailableDrivers> onlineAvailableDriversList = [];

  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;
  bool requestPositionInfo = true;
  BitmapDescriptor? activeNearbyIcon;

  DatabaseReference? referenceRideRequest;

  String userName = "";
  String driverRideStatus = "Your driver is comming in";
  double bottomPaddingofMap = 0;
  String rideRequestStatus = "";

  StreamSubscription<DatabaseEvent>? rideRequestInfoStreamSubscription;

  void requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      // You can also customize the message here
      await Permission.notification.request();
    }
  }

  void checkIfPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  // Get Current Location of the user
  locateUserPosition() async {
    userCurrentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 16);
    newMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    userName = currentUserInfo!.name!;
    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoordinates(
            userCurrentPosition!, context);
    initializeGeoFireListener(); // Show Active Drivers
  }

void saveRideRequestInformation() {
  // save Ride Request Information
  referenceRideRequest =
      FirebaseDatabase.instance.ref().child("AllRideRequests").push();

  var sourceLocation =
      Provider.of<AppInfo>(context, listen: false).userPickupLocation;
  var destinationLocation =
      Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

  Map sourceLocationMap = {
    "latitude": sourceLocation!.locationLatitude,
    "longitude": sourceLocation.locationLongitude
  };

  Map destinationLocationMap = {
    "latitude": destinationLocation!.locationLatitude,
    "longitude": destinationLocation.locationLongitude
  };

  Map userInformationMap = {
    "source": sourceLocationMap,
    "destination": destinationLocationMap,
    "userName": currentUserInfo!.name,
    "userPhone": currentUserInfo!.phone,
    "sourceAddress": sourceLocation.locationName,
    "destinationAddress": destinationLocation.locationName,
    "HealthStatus": currentUserInfo!.healthStatus,
    "driverId": "waiting",
    "time": DateTime.now().toString(),
  };

  // Saving user Information on database (AllRideRequests)
  referenceRideRequest!.set(userInformationMap);

  // Retrieving ride request information if there is any live changes/ When driver accepts the ride request
  referenceRideRequest!.onValue.listen((eventSnap) async {
    DataSnapshot snapshot = eventSnap.snapshot;
    if (snapshot.value == null) {
      return;
    }

    if ((snapshot.value as Map)["carDetails"] != null) {
      print("snapshot: ${(snapshot.value as Map)["carDetails"]}");
      setState(() {
        carModel =
            (snapshot.value as Map)["carDetails"]["carModel"].toString();
        carNumber = (snapshot.value as Map)["carDetails"]["carNumber"]
            .toString();
      });
    }

    if ((snapshot.value as Map)["driverName"] != null) {
      setState(() {
        driverName = (snapshot.value as Map)["driverName"].toString();
      });

    }
    if ((snapshot.value as Map)["driverPhoto"] != null) {
      setState(() {
        driverPhoto = (snapshot.value as Map)["driverPhoto"].toString();
      });
    }
    if ((snapshot.value as Map)["driverPhone"] != null) {
      setState(() {
        driverPhone = (snapshot.value as Map)["driverPhone"].toString();
      });
    }

    if ((snapshot.value as Map)["status"] != null) {
      rideRequestStatus = (snapshot.value as Map)["status"].toString();
    }

    if ((snapshot.value as Map)["driverLocationData"] != null) {
      double driverLocationLat = double.parse(
          (snapshot.value as Map)["driverLocationData"]["latitude"]
              .toString());
      double driverLocationLng = double.parse(
          (snapshot.value as Map)["driverLocationData"]["longitude"]
              .toString());
      LatLng driverLocationLatLng =
          LatLng(driverLocationLat, driverLocationLng);
      print("kkkkkk$driverLocationLatLng");
   
      // Ride status == Accepted
      if (rideRequestStatus == "Accepted") {
        print("fareamountmk:$fare");
        var requestBody = {
          "source": sourceLocationMap,
          "destination": destinationLocationMap,
          "userName": currentUserInfo!.name,
          "userPhone": currentUserInfo!.phone,
          "HealthStatus": currentUserInfo!.healthStatus,
          "time": DateTime.now().toString(),
          "driverPhone": driverPhone,
          "fareAmount": fare,
          "status": "accepted",
          "driverLocation": driverLocationLatLng
        };

        referenceRideRequest!.update({
          "fareAmount": fare,
        }).then((_) {
          print("Montant du trajet enregistré avec succès: $fare");
        }).catchError((error) {
          print("Erreur lors de l'enregistrement du montant du trajet: $error");
        });
        final response = await http.post(
            Uri.parse("https://backend-admin-iota.vercel.app/Ride/postRide"),
            headers: {"Content-Type": "application/json"},
            body: json.encode(requestBody),          );

          // Check if the request was successful
          if (response.statusCode == 201) {
            print("Ride request information sent successfully.");
          } else {
            print("Failed to send ride request information. Status code: ${response.statusCode}");
          }

        // Estimating time to reach from driver current location to user pickup location
        updateArrivalTimeToUserPickupLocation(driverLocationLatLng);
      }

      // Ride status == Arrived
      else if (rideRequestStatus == "Arrived") {
        setState(() {
          driverRideStatus = "Driver has arrived";
        });
        print("fareamount:$fare");
        referenceRideRequest!.update({
          "fareAmount": fare,
        }).then((_) {
          print("Montant du trajet enregistré avec succès: $fare");
        }).catchError((error) {
          print("Erreur lors de l'enregistrement du montant du trajet: $error");
        });
      }

      // Ride status == On Trip
      else if (rideRequestStatus == "On Trip") {
        // Estimating time to reach from driver current location to user dropoff location
        updateTimeToReachUserDropoffLocation(driverLocationLatLng);
        print("fareamount:$fare");
        referenceRideRequest!.update({
          "fareAmount": fare,
        }).then((_) {
          print("Montant du trajet enregistré avec succès: $fare");
        }).catchError((error) {
          print("Erreur lors de l'enregistrement du montant du trajet: $error");
        });
      }

      // Ride status == Ended
      else if (rideRequestStatus == "Ended") {
        double fareAmount = (snapshot.value as Map)["fareAmount"];
        print("Montantkar: $fareAmount");

        driverName = (snapshot.value as Map)["driverName"].toString();

        var response = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return PayFareDialog(
                fareAmount: fareAmount.toStringAsFixed(1),
                driverName: driverName,
                sourceAddress: sourceLocation.locationName,
                destinationAddress:destinationLocation.locationName,

              );
            });
        print("ress$response");

        if (response == "Cash Paid") {
          if ((snapshot.value as Map)["driverPhone"].toString() != null) {
            String assignedDriverId = chosenDriverId;
            print("assinged:$assignedDriverId");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RateDriverScreen(
                        assignedDriverId: assignedDriverId,
                        driverName: driverName,
                        driverPhoto: driverPhoto)));

            referenceRideRequest!.onDisconnect(); //Stop listening to live changes on the rideRequest
            rideRequestInfoStreamSubscription!.cancel();
          }
        }
      }
    }

    AssistantMethods pushNotificationSystem = AssistantMethods();
    pushNotificationSystem.generateAndGetToken();
  });

  onlineAvailableDriversList = GeoFireAssistant.activeNearbyAvailableDriversList;
  searchNearestOnlineDrivers(context);
}



updateArrivalTimeToUserPickupLocation(driverLocationLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      LatLng userLocationLatLng =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      var directionDetailsInfo =
          await AssistantMethods.getOriginToDestinationDirectionDetails(
              driverLocationLatLng, userLocationLatLng);
      print ("fffffffff$driverLocationLatLng");

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        driverRideStatus =
            "Your driver is coming in ${directionDetailsInfo.duration_text}";
      });

      requestPositionInfo = true;
    }
  }

  updateTimeToReachUserDropoffLocation(driverLocationLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var userDropOffLocation =
          Provider.of<AppInfo>(context, listen: false).userDropOffLocation;
      LatLng userDropoffLocationLatLng = LatLng(
          userDropOffLocation!.locationLatitude!,
          userDropOffLocation.locationLongitude!);

      var directionDetailsInfo =
          await AssistantMethods.getOriginToDestinationDirectionDetails(
              driverLocationLatLng, userDropoffLocationLatLng);

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        Fluttertoast.showToast(
            msg: directionDetailsInfo.duration_text.toString());
        driverRideStatus = "Time to destination: " +
            directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

 void searchNearestOnlineDrivers(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      
         return  buildProgressDialog();
          
      
    },
  );

///  await Future.delayed(Duration(seconds: 5));

  // After 10 seconds, close the dialog and proceed
  

    try {
    if (onlineAvailableDriversList.isEmpty) {
      // Remove user Information for ride request from database
      referenceRideRequest!.remove();

     
        setState(() {
          markersSet.clear();
          circlesSet.clear();
          polyLineSet.clear();
          polyLineCoordinatesList.clear();
        });
      

      Fluttertoast.showToast(msg: "No drivers Available");
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushNamed(context, "/main_screen");
      });

      return;
    }

    await retrieveOnlineDriversInformation(onlineAvailableDriversList);
    SelectActiveDriverScreen.referenceRideRequest = referenceRideRequest;
    var response = await Navigator.pushNamed(context, '/select_active_driver_screen');

    if (response == "Driver chosen") {
      FirebaseDatabase.instance
          .ref()
          .child("Drivers")
          .child(chosenDriverId)
          .once()
          .then((snapData) {
        DataSnapshot snapshot = snapData.snapshot;
        print(snapshot.value);
        if (snapshot.exists) {
          setRideStatusAndGetRegToken(chosenDriverId);
        } else {
          Fluttertoast.showToast(
              msg: "This driver does not exist! Please try again");
        }
      });
    }
  } finally {
    if (mounted) {
      Navigator.pop(context); // Fermez le dialogue de progression
    }
  }

  print("on${onlineAvailableDriversList.toString()}");
}
  retrieveOnlineDriversInformation(List onlineAvailableDriversList) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("Drivers");

    for (int i = 0; i < onlineAvailableDriversList.length; i++) {
String driverId=onlineAvailableDriversList[i].driverId;
    double driverLat = onlineAvailableDriversList[i].locationLatitude;
    double driverLng = onlineAvailableDriversList[i].locationLongitude;

      await ref
          .child(onlineAvailableDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
        Map<dynamic, dynamic> driversData =
        dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
        Map<String, dynamic> driver ={
          'id':driverId,
          
            'driverLat': driverLat,
            'driverLng': driverLng,
          
          ...driversData,

        };
         print("this is driver info" + driversData.toString());
       // var response =  http.get('https://maps.googleapis.com/maps/api/distancematrix/json?destinations=,-73.933783&origins=40.6655101,-73.89188969999998&key=AIzaSyCATDsiH6Q7CAACXb47qDJhOuCUuQjs4lg' as Uri);
       // print(response)7
       print("tesss${driversList.any((driverInList) => driverInList['id'] == driverId)}");

if (!driversList.any((driverInList) => driverInList['id'] == driverId)) {
  driversList.add(driver);
}
      });
    }
  }

  setRideStatusAndGetRegToken(chosenDriverId) {
    FirebaseDatabase.instance
        .ref()
        .child("Drivers")
        .child(chosenDriverId)
        .child("newRideStatus")
        .set(referenceRideRequest!.key);
    riderequestid = referenceRideRequest!.key!;
    // automate the push notifications
    FirebaseDatabase.instance
        .ref()
        .child("Drivers")
        .child(chosenDriverId)
        .child("token")
        .once()
        .then((SnapData) {
      DataSnapshot snapshot = SnapData.snapshot;

      if (snapshot.exists) {
        showWaitingResponseFromDriversUI(); // Waiting UI Container
        String deviceRegistrationToken = snapshot.value
            .toString(); // Fetching the reg token of current driver
        AssistantMethods.sendNotificationToDriver(
            context, referenceRideRequest!.key, deviceRegistrationToken);

        FirebaseDatabase.instance
            .ref()
            .child("Drivers")
            .child(chosenDriverId)
            .child("newRideStatus")
            .onValue
            .listen((eventSnapShoot) // Listen to changes of newRideStatus
                {
          DataSnapshot dataSnap = eventSnapShoot.snapshot;
          print('dataSnap...........${dataSnap.value}');
          // newRideStatus == "idle", Driver Cancelled the trip
       
            if (dataSnap.value == "idle") {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const DriverCancelMessageDialog();
                });
          }


          // newRideStatus == "Accepted", Driver Cancelled the trip
          if (dataSnap.value == "Accepted") {
            showUIForAssignedDriverInfo();

          }
        });
      }
    });
  }

  showUIForAssignedDriverInfo() {
    setState(() {
      searchLocationContainerHeight = 0;
      responseFromDriverContainerHeight = 0;
      assignedDriverInfoContainerHeight = 240;
      suggestedRidesConatinerHeight = 0;
      bottomPaddingofMap = 200;
    });
  }

  showWaitingResponseFromDriversUI() {
    setState(() {
      searchLocationContainerHeight = 0;
      responseFromDriverContainerHeight = 220;
    });
  }
 @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    checkIfPermissionAllowed();
    requestNotificationPermission();
    AssistantMethods pushNotificationSystem = AssistantMethods();
    pushNotificationSystem.generateAndGetToken();
    AssistantMethods.readRideRequestKeys(context);
  }
@override
void dispose() {

  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    // createActiveDriverIconMarker();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          title: Text(AppLocalizations.of(context)!.homePage),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<Language>(
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.language,
                  color: Colors.white,
                ),
                onChanged: (Language? language) async {
                  if (language != null) {
                    Locale _locale = await setLocale(language.languageCode);
                    MyApp.setLocale(context, _locale);
                  }
                },
                items: Language.languageList()
                    .map<DropdownMenuItem<Language>>(
                      (e) => DropdownMenuItem<Language>(
                        value: e,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[

                           Text(
                              e.flag,
                              style: const TextStyle(fontSize: 30),

                            ),
                            Text(e.name)



                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
        key: sKey,
        drawer: DashboardDrawer(name: userName),
        body: Builder(
          builder: (BuildContext context) {
            createActiveDriverIconMarker();
            return Stack(children: [
              GoogleMap(
                key: ValueKey('google_map'),

                padding: EdgeInsets.only(bottom: bottomPaddingofMap),
                mapType: MapType.normal,
                polylines: polyLineSet,
                markers: markersSet,
                circles: circlesSet,
                myLocationEnabled: true,
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,

                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controllerGoogleMap.complete(controller);
                  newMapController = controller;
                  locateUserPosition();
                
                },
              ),

              // Button for Drawer
              Positioned(
                top: 35,
                left: 15,
                child: GestureDetector(
                  onTap: () {
                    if (openNavigationDrawer) {
                      sKey.currentState!.openDrawer();
                    } else {
                      // Restart - Refresh - Minimize App Programmatically
                      SystemNavigator.pop();
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white70,
                    child: Icon(
                      openNavigationDrawer ? Icons.menu : Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              //UI to search location
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedSize(
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 120),
                  child: Container(
                    height: searchLocationContainerHeight,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: Column(
                        children: [
                          //From
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.pushNamed(
                                  context, '/search_places_screen');
                              if (result == null) return;
                              if (result == "Obtained") {
                                setState(() {
                                  openNavigationDrawer = false;
                                });

                               await drawPolylineFromSourceToDestination();
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.add_location_alt_outlined,
                                    color: Colors.black),
                                const SizedBox(width: 12.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.from,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                    Text(
                                      Provider.of<AppInfo>(context)
                                                  .userPickupLocation !=
                                              null
                                          ? Provider.of<AppInfo>(context)
                                              .userPickupLocation!
                                              .locationName!
                                              .substring(
                                                  0,
                                                  Provider.of<AppInfo>(context)
                                                      .userPickupLocation!
                                                      .locationName!
                                                      .length)
                                          : AppLocalizations.of(context)!
                                              .noaddr,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.black,
                          ),

                          const SizedBox(height: 16),

                          // To
                          GestureDetector(
                            onTap: () async {
                              var response = await Navigator.pushNamed(
                                  context, '/search_places_screen');
                              if (response == "Obtained") {
                                setState(() {
                                  openNavigationDrawer = false;
                                });

                                await drawPolylineFromSourceToDestination();
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.add_location_alt_outlined,
                                    color: Colors.black),
                                const SizedBox(width: 12.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.to,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                    Text(
                                      Provider.of<AppInfo>(context)
                                                  .userDropOffLocation !=
                                              null
                                          ? Provider.of<AppInfo>(context)
                                              .userDropOffLocation!
                                              .locationName!
                                              .substring(
                                                  0,
                                                  Provider.of<AppInfo>(context)
                                                      .userDropOffLocation!
                                                      .locationName!
                                                      .length)
                                          : AppLocalizations.of(context)!
                                              .whereto,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.black,
                          ),

                          const SizedBox(height: 16),

                          ElevatedButton(
                            onPressed: () {
                              if (Provider.of<AppInfo>(context, listen: false)
                                      .userDropOffLocation !=
                                  null) {
                                saveRideRequestInformation();
                              } else {
                                Fluttertoast.showToast(
                                    msg: AppLocalizations.of(context)!
                                        .selectyourdes);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 235, 219, 7),
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            child: Text(
                                AppLocalizations.of(context)!.requestaride),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              //UI of driver response waiting
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: responseFromDriverContainerHeight,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: AnimatedTextKit(
                        animatedTexts: [
                          FadeAnimatedText(
                            (AppLocalizations.of(context)!.waitingd),
                            duration: const Duration(seconds: 10),
                            textAlign: TextAlign.center,
                            textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold),
                          ),
                          ScaleAnimatedText(
                            (AppLocalizations.of(context)!.please),
                            duration: const Duration(seconds: 10),
                            textAlign: TextAlign.center,
                            textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 35.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Canterbury'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              //ui for waiting response from driver
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: assignedDriverInfoContainerHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10.0,
                          ),

                          Text(
                            driverRideStatus,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black),
                          ),

                          const SizedBox(
                            height: 10.0,
                          ),

                          const Divider(
                            height: 0.5,
                            thickness: 0.5,
                            color: Colors.grey,
                          ),

                          const SizedBox(
                            height: 10.0,
                          ),

                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  minRadius: 30,
                                  maxRadius: 40,
                                
                                   backgroundImage: NetworkImage(driverPhoto),
  


                                ),

                                const SizedBox(
                                  width: 3.0,
                                ),

                                // driverName,Duration and Rating
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driverName,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),

                                    const SizedBox(
                                      height: 10.0,
                                    ),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.car_rental),
                                        const SizedBox(width: 5),
                                        Text(
                                          carModel,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15),
                                        )
                                      ],
                                    ),

                                    const SizedBox(
                                      height: 5.0,
                                    ),

                                    // Driver rating
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: CupertinoColors.systemYellow,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "5",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  width: 40.0,
                                ),

                                //driver information
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 35,
                                        child: Image.asset("images/car.png"),
                                      ),

                                      //driver vehicle details
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            carNumber,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ]),
                              ]),

                          const SizedBox(
                            height: 12.0,
                          ),

                          const Divider(
                            height: 0.5,
                            thickness: 0.5,
                            color: Colors.grey,
                          ),

                          const SizedBox(
                            height: 15.0,
                          ),

                          //call driver button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),

                              //call button
                              TextButton(
                                onPressed: () async {
                                  Uri url =
                                      Uri(scheme: "tel", path: driverPhone);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    print("Can't open dial pad.");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: Colors.lightBlue,
                                          width: 2,
                                          style: BorderStyle.solid),
                                      borderRadius: BorderRadius.circular(10)),
                                  backgroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                ),
                                child: const Icon(
                                  Icons.phone_android,
                                  color: Colors.lightBlue,
                                  size: 25,
                                ),
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              //text button
                              // TextButton(
                              //   onPressed: () {
                              //     //
                              //   },
                              //   style: ElevatedButton.styleFrom(
                              //     shape: RoundedRectangleBorder(
                              //         side: const BorderSide(
                              //             color: Colors.lightBlue,
                              //             width: 2,
                              //             style: BorderStyle.solid),
                              //         borderRadius: BorderRadius.circular(10)), backgroundColor: Colors.white,
                              //     padding:
                              //         const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              //   ),
                              //   child: const Icon(
                              //     Icons.chat_outlined,
                              //     color: Colors.lightBlue,
                              //     size: 25,
                              //   ),
                              // ),

                              const SizedBox(
                                width: 10,
                              ),

                              ElevatedButton(
                                onPressed: () {
                                  FirebaseDatabase.instance
                                      .ref()
                                      .child("AllRideRequests")
                                      .child(riderequestid)
                                      .child("status")
                                      .set("Cancelled");
                                  Provider.of<AppInfo>(context, listen: false)
                                      .updateriderequeststatus("Cancelled");
                                  Navigator.pushNamed(context, "/main_screen");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  padding:
                                      const EdgeInsets.fromLTRB(60, 15, 60, 15),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 10.0,
                          ),
                        ]),
                  ),
                ),
              ),
              // Positioned(
              //   bottom: 0,
              //   left: 0,
              //   right: 0,
              //   child: Container(
              //     height: assignedDriverInfoContainerHeight,
              //     decoration: BoxDecoration(color: Colors.white,
              //     borderRadius: BorderRadius.circular(10)),
              //     child: Padding(
              //       padding: EdgeInsets.all(10),
              //       child: Column(
              //         children: [
              //           Text(driverRideStatus,style: TextStyle(fontWeight: FontWeight.bold ),),
              //           SizedBox(height: 5,),
              //           Divider(thickness: 1,)
              //         ],

              // ))))
            ]);
          },
        ));
  }

  Future<void> drawPolylineFromSourceToDestination() async {
    var sourcePosition =
        Provider.of<AppInfo>(context, listen: false).userPickupLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var sourceLatLng = LatLng(
        sourcePosition!.locationLatitude!, sourcePosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: (AppLocalizations.of(context)!.waitingd),
            ));

    var directionDetailsInfo =
        await AssistantMethods.getOriginToDestinationDirectionDetails(
            sourceLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    print(directionDetailsInfo!.e_points);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsList =
        polylinePoints.decodePolyline(directionDetailsInfo.e_points!);

    polyLineCoordinatesList.clear();

    if (decodedPolyLinePointsList.isNotEmpty) {
      decodedPolyLinePointsList.forEach((PointLatLng pointLatLng) {
        polyLineCoordinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.black,
        polylineId: const PolylineId("PolyLineID"),
        jointType: JointType.bevel,
        points: polyLineCoordinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.squareCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (sourceLatLng.latitude > destinationLatLng.latitude &&
        sourceLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: sourceLatLng);
    } else if (sourceLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(sourceLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, sourceLatLng.longitude),
      );
    } else if (sourceLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, sourceLatLng.longitude),
        northeast: LatLng(sourceLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: sourceLatLng, northeast: destinationLatLng);
    }

    newMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("sourceID"),
      infoWindow:
          InfoWindow(title: sourcePosition.locationName, snippet: "Pickup"),
      position: sourceLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.black,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: sourceLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.black,
      radius: 12,
      strokeWidth: 15,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  initializeGeoFireListener() {
    Geofire.initialize('ActiveDrivers');
    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 15)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];
        switch (callBack) {
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
                ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.activeNearbyAvailableDriversList
                .add(activeNearbyAvailableDriver);
            if (activeNearbyDriverKeysLoaded == true) {
              displayActiveDriversOnUsersMap();
            }
            break;
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineDriverFromList(map["key"]);
            displayActiveDriversOnUsersMap();
            break;

          case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
                ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(
                activeNearbyAvailableDriver);
            break;
          case Geofire.onGeoQueryReady:
            displayActiveDriversOnUsersMap();
            break;
        }
      }
      setState(() {});
    });
//     GeoFireAssistant geoFireAssistant =
//         Provider.of<GeoFireAssistant>(context, listen: false);
//     Geofire.initialize("ActiveDrivers");
//     Geofire.queryAtLocation(
//             userCurrentPosition!.latitude, userCurrentPosition!.longitude, 5)!
//         .listen((map) async {
//       // Search for active drivers from user's location upto 10km radius
// //       if (map != null) {
// //         var callBack = map['callBack'];
// //
// //         //latitude will be retrieved from map['latitude']
// //         //longitude will be retrieved from map['longitude']
// //
// //         switch (callBack) {
// //           //whenever any driver become active/online
// //           case Geofire.onKeyEntered:
// //             //          var url = Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json?destinations='+map['latitude'].toString() +', '+map['longitude'].toString()+  '&origins='+userCurrentPosition!.latitude.toString()+', '+userCurrentPosition!.longitude.toString()+ '&key=AIzaSyCATDsiH6Q7CAACXb47qDJhOuCUuQjs4lg');
// //             //   var response = await http.get(url);
// //             //  Map<String , dynamic> m = jsonDecode(response.body);
// //             //  var distanceUserChauff = int.parse(m['rows']['elements']['distance']['value']);
// //             //  if (distanceUserChauff < 5000){
// //             // ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
// //             //     ActiveNearbyAvailableDrivers();
// //             // activeNearbyAvailableDriver.locationLatitude = map['latitude'];
// //             // activeNearbyAvailableDriver.locationLongitude = map['longitude'];
// //             // activeNearbyAvailableDriver.driverId = map['key'];
// //             // GeoFireAssistant.activeNearbyAvailableDriversList
// //             //     .add(activeNearbyAvailableDriver);
// //             // if (activeNearbyDriverKeysLoaded == true) {
// //             //   displayActiveDriversOnUsersMap();
// //             // }
// //
// //             ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
// //                 ActiveNearbyAvailableDrivers();
// //             activeNearbyAvailableDriver.locationLatitude = map['latitude'];
// //             activeNearbyAvailableDriver.locationLongitude = map['longitude'];
// //             activeNearbyAvailableDriver.driverId = map['key'];
// //             geoFireAssistant.activeNearbyAvailableDriversList
// //                 .add(activeNearbyAvailableDriver);
// //
// // // Vérifiez si les clés des chauffeurs disponibles à proximité sont chargées
// //             if (activeNearbyDriverKeysLoaded == true) {
// //               // Affichez les conducteurs disponibles sur la carte des utilisateurs
// //               displayActiveDriversOnUsersMap();
// //             }
// //
// //             break;
// //
// //           //whenever any driver become non-active/offline
// //
// //           case Geofire.onKeyExited:
// //             GeoFireAssistant geoFireAssistant =
// //                 Provider.of<GeoFireAssistant>(context, listen: false);
// //             geoFireAssistant.deleteOfflineDriverFromList(map['key']);
// //             displayActiveDriversOnUsersMap();
// //             break;
// //
// //           //whenever driver moves - update driver location
// //           case Geofire.onKeyMoved:
// //             ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
// //                 ActiveNearbyAvailableDrivers();
// //             activeNearbyAvailableDriver.locationLatitude = map['latitude'];
// //             activeNearbyAvailableDriver.locationLongitude = map['longitude'];
// //             activeNearbyAvailableDriver.driverId = map['key'];
// //             GeoFireAssistant geoFireAssistant =
// //                 Provider.of<GeoFireAssistant>(context, listen: false);
// //             geoFireAssistant.updateActiveNearbyAvailableDriverLocation(
// //                 activeNearbyAvailableDriver);
// //             displayActiveDriversOnUsersMap();
// //             break;
// //
// //           //display those online/active drivers on user's map
// //           case Geofire.onGeoQueryReady:
// //             displayActiveDriversOnUsersMap();
// //             break;
// //         }
// //       }
//
//       setState(() {});
//     });
  }
/*
   initializeGeoFireListener() {
  GeoFireAssistant geoFireAssistant =
  Provider.of<GeoFireAssistant>(context, listen: false);
    Geofire.initialize("ActiveDrivers");
    Geofire.queryAtLocation(
           userCurrentPosition!.latitude, userCurrentPosition!.longitude, 5)!
        .listen((map) async {
      if (map != null) {
         var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
         ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
  ActiveNearbyAvailableDrivers();
         activeNearbyAvailableDriver.locationLatitude = map['latitude'];
           activeNearbyAvailableDriver.locationLongitude = map['longitude'];
           activeNearbyAvailableDriver.driverId = map['key'];
            geoFireAssistant.activeNearbyAvailableDriversList
                .add(activeNearbyAvailableDriver);

            if (activeNearbyDriverKeysLoaded == true) {
            displayActiveDriversOnUsersMap();
           }
             break;

         case Geofire.onKeyExited:
           geoFireAssistant.deleteOfflineDriverFromList(map['key']);
           displayActiveDriversOnUsersMap();
            break;

        case Geofire.onKeyMoved:
         ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
               ActiveNearbyAvailableDrivers();
     activeNearbyAvailableDriver.locationLatitude = map['latitude'];
       activeNearbyAvailableDriver.locationLongitude = map['longitude'];
          activeNearbyAvailableDriver.driverId = map['key'];
         geoFireAssistant.updateActiveNearbyAvailableDriverLocation(
             activeNearbyAvailableDriver);
          displayActiveDriversOnUsersMap();
             break;
         case Geofire.onGeoQueryReady:
           displayActiveDriversOnUsersMap();
            break;
        }
       }

       setState(() {});
    });
  }*/
  displayActiveDriversOnUsersMap() {
    setState(() {
      markersSet.clear();
      circlesSet.clear();
    });

    Set<Marker> driversMarkerSet = Set<Marker>();

    GeoFireAssistant geoFireAssistant = GeoFireAssistant();

    for (ActiveNearbyAvailableDrivers eachDriver
        in GeoFireAssistant.activeNearbyAvailableDriversList) {
      LatLng eachDriverPosition =
          LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);
      Marker marker = Marker(
        markerId: MarkerId(eachDriver.driverId!),
        position: eachDriverPosition,
        icon: activeNearbyIcon!,
        rotation: 360,
      );

      driversMarkerSet.add(marker);
    }

    setState(() {
      markersSet = driversMarkerSet;
    });
  }

  createActiveDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car-2.png")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }


}