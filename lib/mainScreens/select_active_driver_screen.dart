import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:users_app/InfoHandler/app_info.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:users_app/global/global.dart';
import 'package:geolocator/geolocator.dart';

import '../models/active_nearby_available_drivers.dart';

class SelectActiveDriverScreen extends StatefulWidget {
  static DatabaseReference? referenceRideRequest;

  @override
  State<SelectActiveDriverScreen> createState() =>
      _SelectActiveDriverScreenState();
}

class _SelectActiveDriverScreenState extends State<SelectActiveDriverScreen> {
  List<double?> fareAmounts = [];

  double? getFareAmountAccordingToVehicleType(ActiveNearbyAvailableDrivers driver, double distance) {
    // Montant de base calculé selon le type de véhicule
    String? vehicleType = driver.carDetails?["modelle"];
    double baseFare = vehicleType != null && tripDirectionDetailsInfo != null
        ? AssistantMethods.calculateFareAmountFromSourceToDestination(tripDirectionDetailsInfo!)
        : 0.0;
    
    // Montant calculé en fonction de la distance
    double distanceFare = distance * 0.650;
    
    // Montant total
    double montant = baseFare + distanceFare / 1000;
    return double.parse(montant.toStringAsFixed(1));
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  @override
  void initState() {
    super.initState();
    // Initialize driversList and other relevant data
  }

  @override
  void dispose() {
    // Clear the driversList when leaving the page
    driversList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userPosition = Provider.of<AppInfo>(context, listen: false).userPickupLocation;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.selectNearestDriver,
          style: TextStyle(fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            SelectActiveDriverScreen.referenceRideRequest!.remove();
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.youhavecancelledtheriderequest);
            SystemNavigator.pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: driversList.length,
        itemBuilder: (BuildContext context, int index) {
          if (driversList.toList()[index]?["name"] != null &&
              driversList.toList()[index]?["carDetails"] != null 
            ) {

            ActiveNearbyAvailableDrivers driver = ActiveNearbyAvailableDrivers(
              id: driversList.toList()[index]?["id"]?.toString(),
              locationLatitude: driversList.toList()[index]?["driverLat"],
              locationLongitude: driversList.toList()[index]?["driverLng"],
              name: driversList.toList()[index]?["name"]?.toString(),
              carDetails: (driversList.toList()[index]?["carDetails"] as Map?)?.cast<String, dynamic>(),
            );

            double distance = calculateDistance(
              userPosition!.locationLatitude!,
              userPosition.locationLongitude!,
              driver.locationLatitude!,
              driver.locationLongitude!,
            );

            double? fareAmount = getFareAmountAccordingToVehicleType(driver, distance);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  chosenDriverId = driver.id ?? "";
                  fare=fareAmount ?? 0.0;
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
                      "images/car-2.png",
                      width: 50,
                      height: 50,
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name ?? "",
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        driver.carDetails?["modelle"] ?? "",
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.dinar + (fareAmount?.toString() ?? ""),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Flexible(
                        child: Text(
                          "${(distance / 1000).toStringAsFixed(2)} km", // Display distance in kilometers
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (tripDirectionDetailsInfo != null) ...[
                        Flexible(
                          child: Text(
                            tripDirectionDetailsInfo!.duration_text!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            tripDirectionDetailsInfo!.distance_text!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
