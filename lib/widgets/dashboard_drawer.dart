import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/mainScreens/edit_profile_screen.dart';
import 'package:users_app/mainScreens/profile_screen.dart';
import 'package:users_app/mainScreens/reclamation.dart';
import 'package:users_app/mainScreens/trip_history_screen.dart';

class DashboardDrawer extends StatefulWidget {
  String? name;

  DashboardDrawer({this.name});

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
                children: [
                  const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),

                  const SizedBox(width: 16),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),

                    ],
                  )
                ],
              ),

            ),
          ),

          const SizedBox(height: 12),

          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TripHistoryScreen()));
            },

            child: const ListTile(
              leading: Icon(Icons.history, color: Colors.black),
              title: Text(
                "History",
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
            },

            child: const ListTile(
              leading: Icon(Icons.person, color: Colors.black),
              title: Text(
                "Profile",
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
              //Signout
              firebaseAuth.signOut();
              Navigator.pushNamed(context, '/');
            },

            child: const ListTile(
              leading: Icon(Icons.logout, color: Colors.black),
              title: Text(
                "Sign Out",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
    final Uri _url = Uri.parse('https://frontwebpfe.vercel.app/Conducteur');
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url);
    } else {
      throw "Could not launch $_url";
    }
            },

            child: const ListTile(
              leading: Icon(Icons.drive_eta, color: Colors.black),
              title: Text(
                "Wanna be driver?...",
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const reclamation()));
            },

            child: const ListTile(
              leading: Icon(Icons.report_problem, color: Colors.black),
              title: Text(
                "Aide/Reclamation??",
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
}
