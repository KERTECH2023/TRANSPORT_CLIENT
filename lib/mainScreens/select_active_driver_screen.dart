import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:users_app/global/global.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/active_nearby_available_drivers.dart';

class SelectActiveDriverScreen extends StatefulWidget {
  static DatabaseReference? referenceRideRequest;

  @override
  State<SelectActiveDriverScreen> createState() => _SelectActiveDriverScreenState();
}

class _SelectActiveDriverScreenState extends State<SelectActiveDriverScreen> {
  double? fareAmount;

  double? getFareAmountAccordingToVehicleType(ActiveNearbyAvailableDrivers driver) {
    String? vehicleType = driver.carDetails?["carType"];
    return vehicleType != null && tripDirectionDetailsInfo != null
        ? AssistantMethods.calculateFareAmountFromSourceToDestination(tripDirectionDetailsInfo!, vehicleType)
        : null;
  }

  @override
  void initState() {
    super.initState();
    // Set up a stream listener for real-time updates
    DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("Drivers");
driversRef.onValue.listen((event) {
  // Update the driversList when there are changes in the database
  // Make sure to clear the list before updating to avoid duplicates
  driversList.clear();
  if (event.snapshot.value != null) {
    // Use explicit casting to Map<dynamic, dynamic>
    Map<dynamic, dynamic> driversData = event.snapshot.value as Map<dynamic, dynamic>;

    // Print debug information
    driversData.forEach((key, value) {
      print("Driver ID: $key, Status: ${value['status']}");
      print("Driver Name: $key, Name: ${value['name']}");
      if (value is Map<dynamic, dynamic> && value['status'] == 'Online') {
        driversList.add(value);
      }
    });

    // Convert dynamic to String by encoding and decoding as JSON
    driversList.addAll(json.decode(json.encode(driversData.values.toList())));
    // Assuming that each driver object has the structure you expect
  }

  setState(() {
    // Trigger a rebuild to update the UI
  });
});
  }

  @override
  void dispose() {
    // Clear the driversList when leaving the page
    driversList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.selectNearestDriver,
          style: TextStyle(fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black,),
          onPressed: () {
            SelectActiveDriverScreen.referenceRideRequest!.remove();
            Fluttertoast.showToast(msg: AppLocalizations.of(context)!.youhavecancelledtheriderequest);
            SystemNavigator.pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: driversList.length,
        itemBuilder: (BuildContext context, int index) {
          if (driversList[index]?["id"] != null &&
              driversList[index]?["name"] != null &&
              driversList[index]?["carDetails"] != null &&
              driversList[index]?["ratings"] != null) {
            ActiveNearbyAvailableDrivers driver = ActiveNearbyAvailableDrivers(
              id: driversList[index]?["id"]?.toString(),
              name: driversList[index]?["name"]?.toString(),
              carDetails: (driversList[index]?["carDetails"] as Map?)?.cast<String, dynamic>(),
              ratings: double.parse(driversList[index]["ratings"]),
            );

            String? vehicleType = driver.carDetails?["carType"];
            double? fareAmount = getFareAmountAccordingToVehicleType(driver);

            return GestureDetector(
              onTap: () {
                setState(() {
                  chosenDriverId = driver.id ?? "";
                });
                Navigator.pop(context, "Driver chosen");
              },
              child: Card(
                color: Colors.white,
                elevation: 3,
                shadowColor: Colors.black,
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Image.asset(
                      driver.carDetails != null && driver.carDetails!["carType"] != null
                          ? "images/${driver.carDetails!["carType"]}.png"
                          : "images/car-2.png", // Replace with your default image path
                    ),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        driver.name ?? "",
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      Text(
                        vehicleType ?? "",
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      SmoothStarRating(
                        rating: driver.ratings ?? 0.0,
                        allowHalfRating: true,
                        starCount: 5,
                        size: 15.0,
                        color: Colors.black,
                        borderColor: Colors.black,
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dinar + (fareAmount?.toString().substring(0, 3) ?? ""),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        tripDirectionDetailsInfo != null ? (tripDirectionDetailsInfo!.duration_text!).toString() : "",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        tripDirectionDetailsInfo != null ? (tripDirectionDetailsInfo!.distance_text!).toString() : "",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}