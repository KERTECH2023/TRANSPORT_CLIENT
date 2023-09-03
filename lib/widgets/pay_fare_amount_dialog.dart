import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class PayFareDialog extends StatefulWidget {

  double? fareAmount;
  String? driverName;
  String? destinationAddress;
  String? sourceAddress;
  PayFareDialog({this.fareAmount, this.driverName,this.destinationAddress,this.sourceAddress});

  @override
  State<PayFareDialog> createState() => _PayFareDialogState();
}

class _PayFareDialogState extends State<PayFareDialog> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> sendTripEmail(String userEmail, String tripDetails) async {
    final smtpServer = gmail("testrapide45@gmail.com", "vtvtceruhzparthg");

    final message = Message()
      ..from = Address("testrapide45@gmail.com")
      ..recipients.add(userEmail)
      ..subject = "Your Trip Details"
      ..text = tripDetails;

    try {
      final sendReport = await send(message, smtpServer);
      print("Message sent: ${sendReport.toString()}");
    } catch (e) {
      print("Error sending email: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5)
      ),
      backgroundColor: Color.fromRGBO(0 , 177 , 118, 1),
      child: Container(
        margin: EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromRGBO(0 , 177 , 118, 1),
          borderRadius: BorderRadius.circular(6)
        ),

        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Trip Fare Amount",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Pay Driver",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.fareAmount.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 60,
                    color: Colors.white
                ),
              ),
              const SizedBox(height: 40),

              const Divider(
                height: 1,
                thickness: 1,
                color: Colors.white,
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // If the pay cash button is pressed
                    
                    Navigator.pop(context,"Cash Paid");
                    Navigator.pushNamed(context, "/main_screen");
                     User? user = _auth.currentUser;
                    if (user != null) {
                      // Retrieve user's email
                      String userEmail = user.email ?? "user@example.com";

                      // Construct trip details
                      String tripDetails =
                          "Your Trip Details:\nFare: \DT${widget.fareAmount}\n... ,\nDestination: \.${widget.destinationAddress}\n... ,\nDriverName: \.${widget.driverName}\n... ,\nSource: \.${widget.sourceAddress}\n... ";

                      // Send trip email
                      await sendTripEmail(userEmail, tripDetails);
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent
                  ),

                  child: const Text(
                    "Pay cash",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                ),
              )

            ],
          ),
        ),

      ),
    );
  }
}
