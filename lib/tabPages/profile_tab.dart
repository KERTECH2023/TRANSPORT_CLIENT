/*
import 'dart:convert';

import 'package:drivers_app/InfoHandler/app_info.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ProfileTabPage extends StatefulWidget {
   String? photoUrl;
   ProfileTabPage({Key? key}) : super(key: key);

  @override
  _ProfileTabPageState createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.center,
          children: [
            
            Column(
              
              children: [
                const SizedBox(
                        height: 30,
                      ),
                // Container(
                //   height: 90,
                //   decoration: const BoxDecoration(
                //     color: Colors.black,
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ Center(
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                            border: Border.all(
                              width: 2,
                              color: Colors.white,
                            ),
                            
                          ),
                          
                          child:   FutureBuilder(
                            future: getImageUrl(), // Function to get the image URL
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                var imageBytes = base64Decode(snapshot.data as String);
                                return CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 60,
                                  child: Image.memory(
                                    imageBytes,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } else {
                                // Show a loading indicator while waiting for the image URL
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                            ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: Text(
                          driverData.name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            //
                          },
                          child: Text(
                            'Total Trips: ${Provider.of<AppInfo>(context, listen: false).countTotalTrips}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      // Name
                      Text(
                         AppLocalizations.of(context)!.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // Name - Value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                driverData.name!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // Email
                      Text(
                        AppLocalizations.of(context)!.email,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // Email - value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                driverData.email!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                         AppLocalizations.of(context)!.phoneNumber,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // Number - value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                driverData.phone!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      //    Text(
                      //   "Day of Birth",
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 15,
                      //       color: Colors.grey[600]),
                      // ),
                      // const SizedBox(
                      //   height: 15,
                      // ),
                      // Number - value
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Row(
                      //       children: [
                      //         Text(
                      //           driverData.DateNaissance!,
                      //           style: const TextStyle(
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 15,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //     Icon(Icons.arrow_forward_ios),
                      //   ],
                      // ),
                      //  SizedBox(
                      //   height: 10,
                      // ),
                      // const Divider(
                      //   thickness: 1,
                      // ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      //   Text(
                      //   "Address",
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 15,
                      //       color: Colors.grey[600]),
                      // ),
                      // const SizedBox(
                      //   height: 15,
                      // ),
                      // Number - value
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Row(
                      //       children: [
                      //         Text(
                      //           driverData.address!,
                      //           style: const TextStyle(
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 15,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //     Icon(Icons.arrow_forward_ios),
                      //   ],
                      // ),
                      //  SizedBox(
                      //   height: 10,
                      // ),
                      // const Divider(
                      //   thickness: 1,
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      //  Text(
                      //   "CnicNo",
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 15,
                      //       color: Colors.grey[600]),
                      // ),
                      // const SizedBox(
                      //   height: 15,
                      // ),
                      // // Number - value
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Row(
                      //       children: [
                      //         Text(
                      //           driverData.Cstatus!,
                      //           style: const TextStyle(
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 15,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //     Icon(Icons.arrow_forward_ios),
                      //   ],
                      // ),
                      //  SizedBox(
                      //   height: 10,
                      // ),
                      // const Divider(
                      //   thickness: 1,
                      // ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // Password
                      Text(
                         AppLocalizations.of(context)!.password,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // Password - value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                ".......",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Positioned(
            //   top: 0,
              // child: Container(
              //   height: 90,
              //   width: 100,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     color: Colors.grey[200],
              //     border: Border.all(
              //       width: 2,
              //       color: Colors.white,
              //     ),
              //   ),
               
              // ),
            // ),
          ],
        ),
      ),
    );
  }
   Future<String> getImageUrl() async {
    if (driverData.photoUrl != null) {
      // If the photoUrl is already provided, use it directly
      return driverData.photoUrl!;

    } else {
      // If not, retrieve the photo URL from Firebase Storage based on user ID
      return"";
    }
  }
}
*/
import 'package:drivers_app/InfoHandler/app_info.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';
import 'dart:typed_data';
class ProfileTabPage extends StatefulWidget {
  ProfileTabPage({Key? key}) : super(key: key);

  @override
  _ProfileTabPageState createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  @override
  Widget build(BuildContext context) {
    print("photo url ${driverData.name}");
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.center,
          children: [

            Column(

              children: [
                const SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          border: Border.all(
                            width: 2,
                            color: Colors.white,
                          ),

                        ),

                        child:
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: driverData.photoUrl != null
                              ? MemoryImage(ImageMemoryWidget())
                              : null,
                          child: driverData.photoUrl == null
                              ? Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          )
                              : null,
                        ),
                      ),
                    ),
                      const SizedBox(
                        height: 30,
                      ),
                      Center(

                        child: Text(
                          driverData.name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            //
                          },
                          child: Text(
                            'Total Trips: ${Provider.of<AppInfo>(context, listen: false).countTotalTrips}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.grey[600],
                            ),
                          ),

                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      // Name
                      Text(
                        AppLocalizations.of(context)!.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // Name - Value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                driverData.name!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // Email
                      Text(
                        AppLocalizations.of(context)!.email,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // Email - value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                driverData.email!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        AppLocalizations.of(context)!.phoneNumber,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // Number - value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                driverData.phone!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Address",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                (driverData.address != null ) ? driverData.address! : "Adresse non rensignée",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Code postal",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                (driverData.postalCode != null ) ? driverData.postalCode! : "Code postal non rensignée",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "CnicNo",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // // Number - value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                (driverData.cnicNo != null)?driverData.cnicNo!.toString(): "Non rensigné",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Immatriculation",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // // Number - value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                (driverData.carNumber != null)?driverData.carNumber!.toString(): "Non rensigné",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Modèle",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // // Number - value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                (driverData.carModel != null)?driverData.carModel!: "Non rensigné",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // Password
                      Text(
                        AppLocalizations.of(context)!.password,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // Password - value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                ".......",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }
  Uint8List ImageMemoryWidget()  {
    String imageData = driverData.photoUrl!.split(',')[1];
    Uint8List bytes = base64.decode(imageData);
    return bytes;
  }
}
