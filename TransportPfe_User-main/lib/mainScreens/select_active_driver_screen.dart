import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:users_app/global/global.dart';

import '../models/active_nearby_available_drivers.dart';

class SelectActiveDriverScreen extends StatefulWidget {
  static DatabaseReference? referenceRideRequest;

  @override
  State<SelectActiveDriverScreen> createState() =>
      _SelectActiveDriverScreenState();
}

class _SelectActiveDriverScreenState extends State<SelectActiveDriverScreen> {
  double? fareAmount;
  List<double?> fareAmounts = [];

  // double? getFareAmountAccordingToVehicleType(
  //     ActiveNearbyAvailableDrivers driver) {
  //   String? vehicleType = driver.carDetails?["modelle"];
  //   return vehicleType != null && tripDirectionDetailsInfo != null
  //       ? AssistantMethods.calculateFareAmountFromSourceToDestination(
  //           tripDirectionDetailsInfo!, vehicleType)
  //       : null;
  // }*

  getFareAmountAccordingToVehicleType(ActiveNearbyAvailableDrivers driver) {
    String? vehicleType = driver.carDetails?["modelle"];

    if (vehicleType != null && tripDirectionDetailsInfo != null) {
      // Attendre la résolution du calcul du tarif
      double fareAmount =
          AssistantMethods.calculateFareAmountFromSourceToDestination(
              tripDirectionDetailsInfo!, vehicleType) as double;
      print("fareAmount2 $fareAmount");

      // Renvoyer le montant du tarif une fois qu'il est calculé
      return fareAmount;
    } else {}
    // return null;
  }

  // Future<double> getFareAmountAccordingToVehicleType(
  //     ActiveNearbyAvailableDrivers driver) async {
  //   String? vehicleType = driver.carDetails?["modelle"];
  //
  //   // Vérifier si vehicleType et tripDirectionDetailsInfo sont tous deux non null
  //   if (vehicleType != null && tripDirectionDetailsInfo != null) {
  //     // Appel de la fonction asynchrone et attendre sa résolution
  //     double fareAmount =
  //         await AssistantMethods.calculateFareAmountFromSourceToDestination(
  //             tripDirectionDetailsInfo!, vehicleType);
  //     print("fareAmount2 $fareAmount");
  //     // Retourner le montant du tarif
  //     return fareAmount;
  //   } else {
  //     // Gérer le cas où l'une des conditions échoue
  //     print("Erreur: vehicleType ou tripDirectionDetailsInfo est null.");
  //     // Vous devez gérer ce cas en renvoyant soit une valeur par défaut, soit en lançant une exception, ou autre
  //     throw Exception("vehicleType ou tripDirectionDetailsInfo est null.");
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // Set up a stream listener for real-time updates
    DatabaseReference driversRef =
        FirebaseDatabase.instance.ref().child("Drivers");

    driversRef.onValue.listen((event) {
      // Update the driversList when there are changes in the database
      // Make sure to clear the list before updating to avoid duplicates
      driversList.clear();

      if (event.snapshot.value != null) {
        // Use explicit casting to Map<dynamic, dynamic>
        Map<dynamic, dynamic> driversData =
            event.snapshot.value as Map<dynamic, dynamic>;

        // Print debug information
        driversData.forEach((key, value) {
          if (value is Map<dynamic, dynamic> &&
              value['Cstatus'] == true &&
              value['newRideStatus'] == "Idle") {
            // Créer un nouvel objet chauffeur avec les détails nécessaires
            Map<String, dynamic> driver = {
              'id': key,
              'carDetails': value['carDetails'],
              'name': value['name'],
              'Cstatus': value['Cstatus'],
              'newRideStatus': value['newRideStatus'],
              'address': value['address'],
              'gender': value['gender'],
              'phone': value['phone'],
              'imageUrl': value['imageUrl'],
              'cnicNo': value['cnicNo'],
              'postalCode': value['postalCode'],
            };

            driversList.add(driver);
          }
        });
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
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            SelectActiveDriverScreen.referenceRideRequest!.remove();
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!
                    .youhavecancelledtheriderequest);
            SystemNavigator.pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: driversList.length,
        itemBuilder: (BuildContext context, int index) {
          print(" builde ${driversList}");
          if (driversList[index]?["id"] != null &&
              driversList[index]?["name"] != null &&
              driversList[index]?["carDetails"] != null) {
            ActiveNearbyAvailableDrivers driver = ActiveNearbyAvailableDrivers(
              id: driversList[index]?["id"]?.toString(),
              name: driversList[index]?["name"]?.toString(),
              carDetails: (driversList[index]?["carDetails"] as Map?)
                  ?.cast<String, dynamic>(),
            );

            String? vehicleType = driver.carDetails?["modelle"];
            fareAmount = getFareAmountAccordingToVehicleType(driver);
            print("fareAmount ${fareAmount.runtimeType}");

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
                      "images/car-2.png", // Replace with your default image path
                    ),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        driver.name ?? "",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      Text(
                        vehicleType ?? "",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dinar +
                            (fareAmount?.toString() ?? ""),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        tripDirectionDetailsInfo != null
                            ? (tripDirectionDetailsInfo!.duration_text!)
                                .toString()
                            : "",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        tripDirectionDetailsInfo != null
                            ? (tripDirectionDetailsInfo!.distance_text!)
                                .toString()
                            : "",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
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
