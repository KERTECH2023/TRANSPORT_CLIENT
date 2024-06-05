// ignore: file_names
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users_app/models/trip_history_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class HistoryDesignUI extends StatefulWidget {
  final  TripHistoryModel? tripHistoryModel;

  const HistoryDesignUI({super.key, this.tripHistoryModel});

  @override
  State<HistoryDesignUI> createState() => _HistoryDesignUIState();
}

class _HistoryDesignUIState extends State<HistoryDesignUI> {

  String formatDateAndTime(String dateTimeFromDB){
    DateTime dateTime = DateTime.parse(dateTimeFromDB);
    String formattedDate = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} , ${DateFormat.jm().format(dateTime)}";
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("images/Map snippet new.png"),

            const SizedBox(height: 20),

            // Trip Date
            Text(
              formatDateAndTime(widget.tripHistoryModel!.time!),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),

            const SizedBox(height: 5),

            // Car details
            Text(
              "${widget.tripHistoryModel!.carModel!} - ${widget.tripHistoryModel!.carNumber!}",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400]
              ),
            ),

            const SizedBox(height: 5),

            // " - "
             Text(
             widget.tripHistoryModel!.driverName! ,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Trip Distance
                Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text(
                      AppLocalizations.of(context)!.distance,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                    "${widget.tripHistoryModel!.sourceAddress!} - ${widget.tripHistoryModel!.destinationAddress!}",
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // Trip Duration
             

                const SizedBox(width: 20),

                // Trip Fare
                Column(
                  children: [
                     Text(
                      AppLocalizations.of(context)!.fare,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.tripHistoryModel!.fareAmount! +  AppLocalizations.of(context)!.dinar,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),
                  ],
                ),
              ],

            ),

            const SizedBox(height: 2),

          ]
        )
      ),
    );
  }
}
