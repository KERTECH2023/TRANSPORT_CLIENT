
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/InfoHandler/app_info.dart';
import 'package:users_app/global/map_key.dart';
import 'package:users_app/models/directions.dart';
import 'package:users_app/models/predicted_places.dart';
import 'package:users_app/widgets/progress_dialog.dart';

import '../assistants/request_assistant.dart';

class PlacesPredictionTileDesign extends StatelessWidget {
  final PredictedPlaces? predictedPlaces;
  final bool from;

  const PlacesPredictionTileDesign({super.key, this.predictedPlaces, required this.from});

  void getPlaceDirectionDetails(String? placeId, context, bool from) async {
     showDialog(
        context: context,
         builder: (BuildContext context) =>
            const ProgressDialog(message: "Setting up Dropoff"));

    // Create connection of api to fetch places Details
    String placesDirectionDetailUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    // Close the dialog
    Navigator.pop(context);

    var responseApi = await RequestAssistant.ReceiveRequest(
        placesDirectionDetailUrl); // Receiving api Response

    if (responseApi == "Error fetching the request") {
      return;
    }
    if (responseApi["status"] == "OK") {
      Directions adress = Directions();
      adress.locationId = placeId;
      adress.locationName = responseApi["result"]["name"];
      adress.locationLatitude =
          responseApi["result"]["geometry"]["location"]["lat"];
      adress.locationLongitude =
          responseApi["result"]["geometry"]["location"]["lng"];
      if (from) {
        Provider.of<AppInfo>(context, listen: false)
            .updatePickupLocationAddress(adress);
      } else {
        Provider.of<AppInfo>(context, listen: false)
            .updateDropOffLocationAddress(adress);
      }

      Navigator.pop(context, "Obtained");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        getPlaceDirectionDetails(predictedPlaces!.place_id, context, from);
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Icon(
              Icons.add_location,
              color: Colors.black,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    predictedPlaces!.main_text!,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                 
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
