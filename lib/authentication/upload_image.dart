import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, File?> imageFiles = {
    'image1.jpg': null,
    'image2.jpg': null,
    'image3.jpg': null,
    'image4.jpg': null,
    'image5.jpg': null,
  };

  Future<void> uploadImage(File imageFile, String imageName) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;
        Reference storageRef = _storage.ref().child('user_images/$userId/$imageName');
        await storageRef.putFile(imageFile);
        print('Image uploaded successfully: $imageName');
      } else {
        print('User is not authenticated');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> pickAndUploadImage(String imageName) async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        imageFiles[imageName] = imageFile;
      });
      uploadImage(imageFile, imageName);
    }
  }

  Widget buildUploadButton(String buttonText, String imageName) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          child: imageFiles[imageName] != null
              ? ClipOval(
                  child: Image.file(
                    imageFiles[imageName]!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              : null,
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => pickAndUploadImage(imageName),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Set the button color to black
          ),
          child: Text(
            buttonText,
            style: TextStyle(color: Colors.white), // Set text color to white for contrast
          ),
        ),
      ],
    );
  }

  void _showUploadErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.pleaseupload),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.imageUpload),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.uploadyourpapiers,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.addYourCIN,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  buildUploadButton('Upload Image 1', 'image1.jpg'),
                ],
              ),
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.addYourCINv,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  buildUploadButton('Upload Image 2', 'image2.jpg'),
                ],
              ),
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.addyourpermit,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  buildUploadButton('Upload Image 3', 'image3.jpg'),
                ],
              ),
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.addyourInsurance,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  buildUploadButton('Upload Image 4', 'image4.jpg'),
                ],
              ),
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.addyourgraycard,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  buildUploadButton('Upload Image 5', 'image5.jpg'),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  bool allImagesUploaded = imageFiles.values.every((file) => file != null);

                  if (allImagesUploaded) {
                    Navigator.pushNamed(context, "/main_screen");
                  } else {
                    _showUploadErrorSnackbar();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  AppLocalizations.of(context)!.submit,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
