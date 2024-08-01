import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  final String code;
  final String name;
  final String phone;
  final String? healthStatus;
  final File? imageFile;

  VerifyCodeScreen({
    required this.email,
    required this.code,
    required this.name,
    required this.phone,
    this.healthStatus,
    this.imageFile,
  });

  @override
  _VerifyCodeScreenState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  TextEditingController codeTextEditingController = TextEditingController();
  bool isVerifying = false;

  Future<void> verifyCode() async {
    setState(() {
      isVerifying = true;
    });

    if (codeTextEditingController.text.trim() == widget.code) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.email,
          password: 'TemporaryPassword123',
        );

        String? imageUrl;
        if (widget.imageFile != null) {
          final storageRef = FirebaseStorage.instance.ref().child('client_images/${userCredential.user!.uid}.jpg');
          await storageRef.putFile(widget.imageFile!);
          imageUrl = await storageRef.getDownloadURL();
          print('Image URL: $imageUrl');
        }

        Map<String, dynamic> userMap = {
          'id': userCredential.user!.uid,
          'name': widget.name,
          'email': widget.email,
          'phone': widget.phone,
          'HealthStatus': widget.healthStatus,
          'imageUrl': imageUrl,
        };

        DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('Users');
        await databaseReference.child(userCredential.user!.uid).set(userMap);

        Fluttertoast.showToast(msg: AppLocalizations.of(context)!.accounthasbeencreated);
        Navigator.pushNamed(context, '/');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error: $e');
      }
    } else {
      Fluttertoast.showToast(msg: "invalidVerificationCode");
    }

    setState(() {
      isVerifying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("email Verification"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isVerifying
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                     "Enter Verification Code",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: codeTextEditingController,
                      
                      decoration: InputDecoration(
                        hintText: "verification Code",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: verifyCode,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text("verify"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
