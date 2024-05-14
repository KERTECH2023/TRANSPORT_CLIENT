
import 'dart:async';
import 'dart:ffi';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:drivers_app/push_notifications/push_notifications_system.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_settings/app_settings.dart';
import '../widgets/dashboard_drawer.dart';


class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);
  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}


class _HomeTabPageState extends State<HomeTabPage> {
  
  GoogleMapController? newMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(36.891696, 10.1815426),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;
  String userName = "";
  bool openNavigationDrawer = true;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

void requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      // You can also customize the message here
      await Permission.notification.request();
    }
  }

  checkIfLocationPermissionAllowed() async
  {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  // Get Current Location of the driver
  locateDriverPosition() async{
    driverCurrentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng latLngPosition = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target:latLngPosition, zoom: 16);
    newMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    userName = currentUserInfo!.name!;

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoordinates(driverCurrentPosition!,context);
    print("this is your address = " + humanReadableAddress);
  }

  // Enable Push Notifications
  readCurrentDriverInformation() async {
    currentFirebaseUser = firebaseAuth.currentUser;

    await FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((snapData) {
         DataSnapshot snapshot = snapData.snapshot;
         if(snapshot.exists){
           driverData.id = (snapshot.value as Map)["id"];
           driverData.name = (snapshot.value as Map)["name"];
           driverData.email = (snapshot.value as Map)["email"];
           driverData.phone = (snapshot.value as Map)["phone"];
         //  driverData.carColor = (snapshot.value as Map)["carDetails"]["carColor"];
           driverData.carModel = (snapshot.value as Map)["carDetails"]["carModel"];
           driverData.carNumber = (snapshot.value as Map)["carDetails"]["carNumber"];
         //  driverData.carType = (snapshot.value as Map)["carDetails"]["carType"];
           driverData.lastTripId = (snapshot.value as Map)["lastTripId"];
           driverData.totalEarnings = (snapshot.value as Map)["totalEarnings"];
        //   driverData.cstatus = (snapshot.value as Map)["Cstatus"];
           driverData.dateNaissance = (snapshot.value as Map)["DateNaissance"];
           driverData.address = (snapshot.value as Map)["address"];
           driverData.cnicNo = (snapshot.value as Map)["cnicNo"];
           driverData.gender = (snapshot.value as Map)["gender"];
           driverData.licence = (snapshot.value as Map)["licence"];
           driverData.postalCode = (snapshot.value as Map)["postalCode"];
           driverData.photoUrl = (snapshot.value as Map)["imageUrl"];
           

         }

    });

    //AssistantMethods.getLastTripInformation(context);

    currentFirebaseUser = firebaseAuth.currentUser;
    // PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    // pushNotificationSystem.initializeCloudMessaging(context);
    // pushNotificationSystem.generateRegistrationToken();

    // Get Driver Ratings
    AssistantMethods.getDriverRating(context);
  }

  @override
  void initState() {
    super.initState();
    print("usssssssssssssssserr" + userName.toString());
    requestNotificationPermission();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
    // PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    // pushNotificationSystem.initializeCloudMessaging(context);
    //  pushNotificationSystem.generateRegistrationToken();
    AssistantMethods.readRideRequestKeys(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: DashboardDrawer(name: userName),
      body: Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newMapController = controller;
            locateDriverPosition();
          },
        ),
        // Button for Drawer
          Positioned(
            top: 35,
            left: 15,
            child: GestureDetector(
              onTap: (){
                if(openNavigationDrawer){
                  sKey.currentState!.openDrawer();
                }

                else{
                  // Restart - Refresh - Minimize App Programmatically
                  SystemNavigator.pop();
                }
              },

              child:  CircleAvatar(
                backgroundColor: Colors.white70,
                child: Icon(
                  openNavigationDrawer ? Icons.menu : Icons.close,
                  color: Colors.black,
                ),
              ),
            ),
          ),

        statusText != "Online"
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black54,
              )
            : Container(),

        Positioned(
          top: statusText != "Online"
              ? MediaQuery.of(context).size.height * 0.46
              : 35,
          left: 0,
          right: 0,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (){
                  if(statusText != "Online"){ // Offline
                    driverIsOnlineNow();
                    updateDriversLocationAtRealTime();

                    setState(() {
                      statusText = "Online";
                      isDriverActive = true;
                      buttonColor = Colors.black;
                    });

                    Fluttertoast.showToast(msg: "You are online now");
                  }

                  else{
                    driverIsOfflineNow();
                    setState(() {
                      statusText = "Offline";
                      isDriverActive = false;
                      buttonColor = Colors.black;
                    });

                    Fluttertoast.showToast(msg: "You are offline now");
                  }

                },

                style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26)
                  )
                ),

                child: statusText != "Online"
                    ? Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      )
                    : const Icon(
                       Icons.phonelink_ring,
                       color: Colors.white,
                       size: 30,
                      )
              )
            ],
          ),
        )
      ],
    )
    );
    
  }

  driverIsOnlineNow() async{
    driverCurrentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    Geofire.initialize("ActiveDrivers"); // Setting up a new node in realtime database
    Geofire.setLocation(currentFirebaseUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    
    DatabaseReference reference = FirebaseDatabase.instance.ref()
        .child("Drivers").child(currentFirebaseUser!.uid).child("newRideStatus");

    reference.set("Idle");
    reference.onValue.listen((event) { });


  }

  driverIsOfflineNow() async{
    Geofire.removeLocation(currentFirebaseUser!.uid); // ActiveDrivers child with this id deleted from Realtime Firebase

    DatabaseReference? reference = FirebaseDatabase.instance.ref()
        .child("Drivers").child(currentFirebaseUser!.uid).child("newRideStatus");

    reference.onDisconnect();
    reference.remove(); // child newRideStatus removed
    reference = null;

  }

  updateDriversLocationAtRealTime()
  {
    streamSubscriptionPosition = Geolocator.getPositionStream() // Get Updated position of the driver
        .listen((Position position)
    {
      driverCurrentPosition = position;

      if(isDriverActive == true)
      {
        Geofire.setLocation  // Updating live location in realtime database
        (
            currentFirebaseUser!.uid,
            driverCurrentPosition!.latitude,
            driverCurrentPosition!.longitude
        );
      }

      LatLng latLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      newMapController!.animateCamera(CameraUpdate.newLatLng(latLng)); // Animating camera in google map according to LatLng
    });
  }


}

/*import 'dart:async';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:drivers_app/push_notifications/push_notifications_system.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_settings/app_settings.dart';
import '../widgets/dashboard_drawer.dart';


class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);
  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}


class _HomeTabPageState extends State<HomeTabPage> {

  GoogleMapController? newMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(36.891696, 10.1815426),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;
  String userName = "";
  bool openNavigationDrawer = true;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  void requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      // You can also customize the message here
      await Permission.notification.request();
    }
  }

  checkIfLocationPermissionAllowed() async
  {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  // Get Current Location of the driver
  locateDriverPosition() async{
    driverCurrentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng latLngPosition = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target:latLngPosition, zoom: 16);
    newMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    userName = currentUserInfo!.name!;
    print('currentUserInfo ${currentUserInfo}');

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoordinates(driverCurrentPosition!,context);
    print("this is your address = " + humanReadableAddress);
  }

  // Enable Push Notifications
  readCurrentDriverInformation() async {
    currentFirebaseUser = firebaseAuth.currentUser;

    await FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((snapData) {
      DataSnapshot snapshot = snapData.snapshot;
      print(snapshot.value as Map);
      if(snapshot.exists){
        driverData.id = (snapshot.value as Map)["id"];
        driverData.name = (snapshot.value as Map)["name"];

        driverData.email = (snapshot.value as Map)["email"];
        driverData.phone = (snapshot.value as Map)["phone"];
        driverData.carNumber = (snapshot.value as Map)["carDetails"]["immatriculation"];
        driverData.carModel = (snapshot.value as Map)["carDetails"]["modelle"];
        driverData.cnicNo = (snapshot.value as Map)["cnicNo"];
        driverData.address = (snapshot.value as Map)["address"];
        driverData.cstatus = (snapshot.value as Map)["Cstatus"].toString();
        driverData.postalCode = (snapshot.value as Map)["postalCode"];
        driverData.photoUrl = (snapshot.value as Map)["imageUrl"].toString();
        driverData.gender = (snapshot.value as Map)["gender"];
        driverData.newRideStatus = (snapshot.value as Map)["newRideStatus"];

      }

    });

    AssistantMethods.getLastTripInformation(context);

    currentFirebaseUser = firebaseAuth.currentUser;
    // PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    // pushNotificationSystem.initializeCloudMessaging(context);
    // pushNotificationSystem.generateRegistrationToken();

    // Get Driver Ratings
    AssistantMethods.getDriverRating(context);
  }

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
    // PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    // pushNotificationSystem.initializeCloudMessaging(context);
    //  pushNotificationSystem.generateRegistrationToken();
    AssistantMethods.readRideRequestKeys(context);
  }

  @override
  Widget build(BuildContext context) {
    print('snapshot: ${driverData}');
    return Scaffold(

        key: sKey,
        drawer: DashboardDrawer(name: driverData.name, photoUrl: driverData.photoUrl, ),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newMapController = controller;
                locateDriverPosition();
              },
            ),
            // Button for Drawer
            Positioned(
              top: 35,
              left: 15,
              child: GestureDetector(
                onTap: (){
                  if(openNavigationDrawer){
                    sKey.currentState!.openDrawer();
                  }

                  else{
                    // Restart - Refresh - Minimize App Programmatically
                    SystemNavigator.pop();
                  }
                },

                child:  CircleAvatar(
                  backgroundColor: Colors.white70,
                  child: Icon(
                    openNavigationDrawer ? Icons.menu : Icons.close,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            statusText != "Online"
                ? Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              color: Colors.black54,
            )
                : Container(),

            Positioned(
              top: statusText != "Online"
                  ? MediaQuery.of(context).size.height * 0.46
                  : 35,
              left: 0,
              right: 0,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: (){
                        if(statusText != "Online"){ // Offline
                          driverIsOnlineNow();
                          updateDriversLocationAtRealTime();

                          setState(() {
                            statusText = "Online";
                            isDriverActive = true;
                            buttonColor = Colors.black;
                          });

                          Fluttertoast.showToast(msg: "You are online now");
                        }

                        else{
                          driverIsOfflineNow();
                          setState(() {
                            statusText = "Offline";
                            isDriverActive = false;
                            buttonColor = Colors.black;
                          });

                          Fluttertoast.showToast(msg: "You are offline now");
                        }

                      },

                      style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26)
                          )
                      ),

                      child: statusText != "Online"
                          ? Text(
                        statusText,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      )
                          : const Icon(
                        Icons.phonelink_ring,
                        color: Colors.white,
                        size: 30,
                      )
                  )
                ],
              ),
            )
          ],
        )
    );

  }

  driverIsOnlineNow() async{
    driverCurrentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    Geofire.initialize("ActiveDrivers"); // Setting up a new node in realtime database
    Geofire.setLocation(currentFirebaseUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    DatabaseReference reference = FirebaseDatabase.instance.ref()
        .child("Drivers").child(currentFirebaseUser!.uid).child("newRideStatus");

    reference.set("Idle");
    reference.onValue.listen((event) { });


  }

  driverIsOfflineNow() async{
    Geofire.removeLocation(currentFirebaseUser!.uid); // ActiveDrivers child with this id deleted from Realtime Firebase

    DatabaseReference? reference = FirebaseDatabase.instance.ref()
        .child("Drivers").child(currentFirebaseUser!.uid).child("newRideStatus");

    reference.onDisconnect();
    reference.remove(); // child newRideStatus removed
    reference = null;

  }

  updateDriversLocationAtRealTime()
  {
    streamSubscriptionPosition = Geolocator.getPositionStream() // Get Updated position of the driver
        .listen((Position position)
    {
      driverCurrentPosition = position;

      if(isDriverActive == true)
      {
        Geofire.setLocation  // Updating live location in realtime database
          (
            currentFirebaseUser!.uid,
            driverCurrentPosition!.latitude,
            driverCurrentPosition!.longitude
        );
      }

      LatLng latLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      newMapController!.animateCamera(CameraUpdate.newLatLng(latLng)); // Animating camera in google map according to LatLng
    });
  }


}*/