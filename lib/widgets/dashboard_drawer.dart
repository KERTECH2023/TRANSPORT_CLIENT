import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/mainScreens/edit_profile_screen.dart';
import 'package:users_app/mainScreens/profile_screen.dart';
import 'package:users_app/mainScreens/reclamation.dart';
import 'package:users_app/mainScreens/trip_history_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

            child:  ListTile(
              leading: Icon(Icons.history, color: Colors.black),
              title: Text(
                AppLocalizations.of(context)!.history,
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

            child:  ListTile(
              leading: Icon(Icons.person, color: Colors.black),
              title: Text(
               AppLocalizations.of(context)!.profil,
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

            child: ListTile(
              leading: Icon(Icons.drive_eta, color: Colors.black),
              title: Text(
                AppLocalizations.of(context)!.wannabedriver,
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

            child:  ListTile(
              leading: Icon(Icons.report_problem, color: Colors.black),
              title: Text(
                AppLocalizations.of(context)!.reclamation,
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



        ],
      ),
    );
  }
}
