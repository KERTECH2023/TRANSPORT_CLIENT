import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:users_app/models/user_model.dart';
import '../global/global.dart';

class RateDriverScreen extends StatefulWidget {
  final String? assignedDriverId;
  final String? driverName;
  final String? driverPhoto;

  RateDriverScreen({this.assignedDriverId, this.driverName, this.driverPhoto});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController commentController = TextEditingController();
  double countRatingStars = 0;
  String titleStarsRating = "Excellent";
  String? currentUserDisplayName;

  @override
  void initState() {
    super.initState();
    _getCurrentUserDisplayName();
  }

  Future<void> _getCurrentUserDisplayName() async {
    UserModel? currentUser = currentUserInfo;

    if (currentUser != null) {
      setState(() {
        currentUserDisplayName = currentUser.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.rateDriver,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        leadingWidth: 75,
        leading: TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/main_screen");
          },
        
          child: Text(
            AppLocalizations.of(context)!.skip,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.redAccent),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Dialog(
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
                const SizedBox(height: 5.0),
               CircleAvatar(
  backgroundColor: Colors.white,
  backgroundImage: NetworkImage(driverPhoto),
  radius: 60,
),

                const SizedBox(height: 20.0,),
                Text(
                  widget.driverName!,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15.0,),
                Text(
                  AppLocalizations.of(context)!.yourfeedbackwillimproveyourridenexperience,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10.0,),
                SmoothStarRating(
                  rating: countRatingStars,
                  allowHalfRating: false,
                  starCount: 5,
                  color: Colors.orange,
                  borderColor: Colors.orange,
                  size: 40,
                  onRatingChanged: (starsChosen) {
                    setState(() {
                      countRatingStars = starsChosen;
                      switch (countRatingStars.toInt()) {
                        case 1:
                          titleStarsRating = "Very Bad";
                          break;
                        case 2:
                          titleStarsRating = "Bad";
                          break;
                        case 3:
                          titleStarsRating = "Good";
                          break;
                        case 4:
                          titleStarsRating = "Very Good";
                          break;
                        case 5:
                          titleStarsRating = "Excellent";
                          break;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10.0,),
                Text(
                  titleStarsRating,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 15.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      labelText:  AppLocalizations.of(context)!.addaCommentoptional,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                ElevatedButton(
                  onPressed: () {
                    DatabaseReference rateDriverRef =
                        FirebaseDatabase.instance.ref()
                            .child("Drivers")
                            .child(widget.assignedDriverId!)
                            .child("ratings");

                    rateDriverRef.once().then((snap) {
                      if (snap.snapshot.value == null) {
                        rateDriverRef.set(countRatingStars.toString());
                      } else {
                        double pastRatings =
                            double.parse(snap.snapshot.value.toString());
                        double newAverageRatings =
                            (pastRatings + countRatingStars) / 2;
                        rateDriverRef.set(newAverageRatings.toString());
                      }

                      // Save the comment to Firebase with the user's name
                      String comment = commentController.text;
                      if (comment.isNotEmpty && currentUserDisplayName != null) {
                        DatabaseReference commentRef =
                            FirebaseDatabase.instance.ref()
                                .child("Drivers")
                                .child(widget.assignedDriverId!)
                                .child("comments")
                                .push();
                        commentRef.set({
                          'comment': comment,
                          'user': currentUserDisplayName,
                        });
                      }

                      Navigator.pushNamed(context, "/main_screen");
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.submit,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
