import 'dart:convert';
import 'dart:typed_data';

import 'package:drivers_app/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../InfoHandler/app_info.dart';

class RatingsTabPage extends StatefulWidget {
  const RatingsTabPage({Key? key}) : super(key: key);

  @override
  _RatingsTabPageState createState() => _RatingsTabPageState();
}

class _RatingsTabPageState extends State<RatingsTabPage> {
  String titleStarRating = "";
  double driverRating = 0;
  List<Map<String, dynamic>> comments = [];

  get flutter => null;

  @override
  void initState() {
    super.initState();
    getDriverRating();
    loadComments();
  }

  void getDriverRating() {
    setState(() {
      driverRating = double.parse(Provider.of<AppInfo>(context, listen: false).driverAverageRating);
    });

    setUpRatingTitle();
  }

  void setUpRatingTitle() {
    if (driverRating <= 1) {
      setState(() {
        titleStarRating = "Inexperienced";
      });
    } else if (driverRating <= 2) {
      setState(() {
        titleStarRating = "Bad";
      });
    } else if (driverRating <= 3) {
      setState(() {
        titleStarRating = "Moderate";
      });
    } else if (driverRating <= 4) {
      setState(() {
        titleStarRating = "Good";
      });
    } else if (driverRating <= 5) {
      setState(() {
        titleStarRating = "Experienced";
      });
    }
  }

  void loadComments() {
    print("Current User ID: ${currentFirebaseUser!.uid}");
    DatabaseReference commentsRef = FirebaseDatabase.instance
        .ref()
        .child("Drivers")
        .child(currentFirebaseUser!.uid)
        .child("comments");

    commentsRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        print("Comments Data: ${event.snapshot.value}");

        Map<dynamic, dynamic>? values =
            (event.snapshot.value as Map<dynamic, dynamic>?);

        if (values != null) {
          values.forEach((key, value) {
            if (value is Map) {
              comments.add({
                'user': value['user'],
                'comment': value['comment'],
              });
            }
          });

          setState(() {
            // Trigger a rebuild to display comments in the interface
            print("Comments List: $comments");
          });
        } else {
          print("Invalid data structure in comments");
        }
      } else {
        print("No comments data found");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.rateDriver,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        leadingWidth: 50,
        leading: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/main_screen");
          },
       //   style: flutter.styleFrom(backgroundColor: Colors.white),
          child: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.redAccent,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: Colors.white,
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5.0,),

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
              const SizedBox(height: 20.0,),
              Text(
                driverData.name!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15.0,),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.ratingavv,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10.0,),
              SmoothStarRating(
                rating: driverRating,
                allowHalfRating: false,
                starCount: 5,
                color: Colors.orange,
                borderColor: Colors.orange,
                size: 40,
              ),
              const SizedBox(height: 10.0,),
              Text(
                AppLocalizations.of(context)!.rating + driverRating.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                AppLocalizations.of(context)!.drivertype + titleStarRating,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 15.0,),
              SizedBox(
                height: 100,
                child: comments.isEmpty
                    ? const Center(
                        child: Text(
                          'No comments available.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text('Client: ${comments[index]['user']}'),
                            subtitle: Text('Comment: ${comments[index]['comment']}'),
                          );
                        },
                      ),
              ),
            ],
          ),
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
