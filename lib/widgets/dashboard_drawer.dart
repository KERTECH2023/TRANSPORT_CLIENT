import 'dart:convert';
import 'dart:typed_data';

import 'package:drivers_app/authentication/delete_account.dart';
import 'package:drivers_app/mainScreens/edit_profile_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/mainScreens/profile_screen.dart';
import 'package:drivers_app/mainScreens/trip_history_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
class DashboardDrawer extends StatefulWidget {
 final String? name;
 String? photoUrl; 
  DashboardDrawer({this.name , this.photoUrl});
  

  @override
  State<DashboardDrawer> createState() => _DashboardDrawerState();
}

class _DashboardDrawerState extends State<DashboardDrawer> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 165,
            color: Colors.black,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: driverData.photoUrl != null
                        ? MemoryImage(ImageMemoryWidget())
                        : null,
                    child: driverData.photoUrl == null
                        ? Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    )
                        : null,
                  ),

                  const SizedBox(width: 16),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(

                        driverData.name!,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255)
                        ),
                      ),

                    ],
                  )
                ],
              ),

            ),
          ),

          const SizedBox(height: 12),

          // GestureDetector(
          //   onTap: (){
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => const TripHistoryScreen()));
          //   },

          //   child: const ListTile(
          //     leading: Icon(Icons.history, color: Colors.black),
          //     title: Text(
          //       "History",
          //       style: TextStyle(
          //         color: Colors.black,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 16
          //       ),
          //     ),
          //   ),
          // ),



          GestureDetector(
            onTap: (){
              //Signout
              firebaseAuth.signOut();
              Geofire.removeLocation(currentFirebaseUser!.uid); // ActiveDrivers child with this id deleted from Realtime Firebase

              Navigator.pushNamed(context, '/');
            },

            child:  ListTile(
              leading: Icon(Icons.logout, color: Colors.black),
              title: Text(
                AppLocalizations.of(context)!.signout,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              //diactiver
              Navigator.push(context, MaterialPageRoute(builder: (context) =>  AccountDeletionScreen()));
            },

            child:  ListTile(
              leading: Icon(Icons.delete, color: Colors.black),
              title: Text(
                 AppLocalizations.of(context)!.deleteaccount,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }

  Uint8List ImageMemoryWidget()  {
    String imageData = driverData.photoUrl!.split(',')[1];
    Uint8List bytes = base64.decode(imageData);
    return bytes;
  }
  }
