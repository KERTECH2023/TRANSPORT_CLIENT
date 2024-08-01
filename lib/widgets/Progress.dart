import 'package:flutter/material.dart';

Widget buildProgressDialog() {
  return Align(
    alignment: FractionalOffset.bottomCenter,
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nous contactons des chauffeurs...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("Nous regardons qui est disponible :"),
              SizedBox(height: 8),
              LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                backgroundColor: Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
