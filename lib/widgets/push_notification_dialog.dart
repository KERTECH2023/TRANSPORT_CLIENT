import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/mainScreens/new_trip_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../global/global.dart';
import '../models/ride_request_information.dart';

class NotificationDialogBox extends StatefulWidget {
 

  RideRequestInformation? rideRequestInformation;

  NotificationDialogBox({super.key, this.rideRequestInformation});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  @override
  Widget build(BuildContext context) {
    print("heremk");

    print("sourrceeeeee" +  widget.rideRequestInformation!.sourceAddress!);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,  // Resizes the layout according to the need
          children: [
            const SizedBox(height: 15),
          
            // image
            Image.asset('images/car_logo.png',width: 160),

            const SizedBox(height: 10),
            // New Ride Request Text
             Text(
               AppLocalizations.of(context)!.newRideequest,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),

            const SizedBox(height: 15),

            // Pickup/Destination Address
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Pickup Details
                  Row(
                    children: [
                      Image.asset(
                        'images/source.png',
                        width: 25,
                        height: 25,
                      ),

                      const SizedBox(width: 22),

                      Expanded(
                        child: Container(
                          child: Text(
                            widget.rideRequestInformation!.sourceAddress!,
                        
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                          ),
                        ),
                        
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Destination Details
                  Row(
                    children: [
                      Image.asset(
                        'images/destination.png',
                        width: 25,
                        height: 25,
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: Container(
                          child: Text(
                            widget.rideRequestInformation!.destinationAddress!,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Image.asset(
                        'images/Handicapped.png',
                        width: 25,
                        height: 25,
                      ),

                      const SizedBox(width: 20),

                    Expanded(
                        child: Container(
                          child: Text(
                            widget.rideRequestInformation!.healthStatus!,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
              ),
            ),

            // buttons
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red
                      ),

                      onPressed: (){
                        // Cancel the ride request
                        // audioPlayer.pause();
                        // audioPlayer.stop();
                        // audioPlayer = AssetsAudioPlayer();
                        // Navigator.pushNamed(context, "/main_screen");
                        // Navigator.pop(context);
                        print("bwwwwwwwwwwwww "+FirebaseDatabase.instance.toString());
                        // Then ensures that all after the first firebase query, next one is executed
                        FirebaseDatabase.instance.ref()
                            .child("AllRideRequests")
                            .child(widget.rideRequestInformation!.rideRequestId!)
                            .remove().then((value) {
                              
                              FirebaseDatabase.instance.ref()
                                  .child("Drivers")
                                  .child(currentFirebaseUser!.uid)
                                  .child("newRideStatus")
                                  .set("idle");
                        }).then((value) => {

                          FirebaseDatabase.instance.ref()
                            .child("Drivers")
                            .child(currentFirebaseUser!.uid)
                            .child("tripHistory")
                            .child(widget.rideRequestInformation!.rideRequestId!)
                            .remove()

                        }).then((value) => {
                          Navigator.popAndPushNamed(context, "/main_screen"),
                          Fluttertoast.showToast(msg: "Ride request is cancelled, restarting app"),
                          
                        });
                        

                        Navigator.pop(context);

                      },
                      child:  Text(
                        AppLocalizations.of(context)!.cancel,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      )
                  ),

                  const SizedBox(width: 20),

                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue
                      ),

                      onPressed: () {
                        // // Accept the ride request
                        // audioPlayer.pause();
                        // audioPlayer.stop();
                        // audioPlayer = AssetsAudioPlayer();

                        // Driver has accepted the ride request
                         acceptRideRequest(context);
                        Navigator.push(context, MaterialPageRoute(builder: (c)=> NewTripScreen(rideRequestInformation: widget.rideRequestInformation,)));

                      },
                      child:  Text(
                        AppLocalizations.of(context)!.accept,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      )
                  )

                ],
              ),
            )
        ],

         )

        ),

      );

  }

  acceptRideRequest(BuildContext context){
    String rideRequestId = "";
    FirebaseDatabase.instance.ref()
        .child("Drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snapData)  {

          DataSnapshot snapshot = snapData.snapshot;
          if(snapshot.exists){
            rideRequestId = snapshot.value.toString();
          }

          else{
            Fluttertoast.showToast(msg: "Ride request does not exist");
          }
print("ffffffffff"+snapData.snapshot.value.toString());
          if(rideRequestId == widget.rideRequestInformation!.rideRequestId!){
            FirebaseDatabase.instance.ref()
                .child("Drivers")
                .child(currentFirebaseUser!.uid)
                .child("newRideStatus")
                .set("Accepted");

            AssistantMethods.pauseLiveLocationUpdates();
            Fluttertoast.showToast(msg: "Paused live location updates");

           

          }


          else{

            Fluttertoast.showToast(msg: "This Ride Request do not exist.");
            
          }

       });


  }

  // Future generateAndGetToken() async {
  //   String? registrationToken = await FirebaseMessaging.instance.getToken();
  //   print("FCM regetration token : ${registrationToken}");

  //   FirebaseDatabase.instance.ref().child("Drivers").child(firebaseAuth.currentUser!.uid).child("token").set(registrationToken);
  //    firebaseMessaging.subscribeToTopic("allDrivers");
  //   firebaseMessaging.subscribeToTopic("allUsers");


  // }
  
}
