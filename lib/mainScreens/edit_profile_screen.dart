import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/InfoHandler/app_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../global/global.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
 Future<void> updateProfilePhoto(String? currentPhotoUrl, PickedFile newPhoto) async {
    try {
      String userId = firebaseAuth.currentUser?.uid ?? "";
      String path = 'client_images/$userId.jpg'; // Adjust the path based on your storage structure

      // Upload the new photo to Firebase Storage
      Reference ref = FirebaseStorage.instance.ref(path);
      await ref.putFile(File(newPhoto.path));

      // Get the updated photo URL
      String newPhotoUrl = await ref.getDownloadURL();

      // Update the user's photo URL in Firestore
    

      // Update the displayed user information in the interface
      setState(() {
        currentUserInfo?.photoUrl = newPhotoUrl;
         currentUserInfo?.photoUrl = newPhotoUrl;
      });

      // Refresh the UI to reflect the changes
      updateDisplayedUserInfo({'imageUrl': newPhotoUrl});
      print('Profile photo updated successfully');
    } catch (error) {
      print('Error updating profile photo: $error');
    }
  }

  // Function to update the user information in the interface
  void updateDisplayedUserInfo(Map<String, dynamic> updatedInfo) {
    setState(() {
      // Update the relevant fields with the new information
      currentUserInfo?.name = updatedInfo['name'] ??  currentUserInfo?.name;
       currentUserInfo?.email = updatedInfo['email'] ??  currentUserInfo?.email;
       currentUserInfo?.phone = updatedInfo['phone'] ??  currentUserInfo?.phone;
       currentUserInfo?.photoUrl = updatedInfo['imageUrl'] ??  currentUserInfo?.photoUrl;
      // Update other fields as needed
    });
  }

  Future<void> updateRealtimeDatabase(String userId, Map<String, dynamic> dataToUpdate) async {
    try {
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('Users').child(userId);
      await userRef.update(dataToUpdate);
      print('Realtime Database updated successfully');
    } catch (error) {
      print('Error updating Realtime Database: $error');
    }
  }

  Future<void> updateUserInfoDialog() async {
    String updatedName = '';
    String updatedEmail = '';
    String updatedPhone = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update User Information'),
          content: Column(
            children: [
              TextField(
                onChanged: (value) {
                  updatedName = value;
                },
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                onChanged: (value) {
                  updatedEmail = value;
                },
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                onChanged: (value) {
                  updatedPhone = value;
                },
                decoration: InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String userId = firebaseAuth.currentUser?.uid ?? "";
                Map<String, dynamic> dataToUpdate = {};

                // Only include fields with updated information
                if (updatedName.isNotEmpty) {
                  dataToUpdate['name'] = updatedName;
                }
                if (updatedEmail.isNotEmpty) {
                  dataToUpdate['email'] = updatedEmail;
                }
                if (updatedPhone.isNotEmpty) {
                  dataToUpdate['phone'] = updatedPhone;
                }

                // Check if any fields are updated before calling Firestore and Realtime Database
                if (dataToUpdate.isNotEmpty) {
                  await updateRealtimeDatabase(userId, dataToUpdate); // Update Realtime Database

                  // Update the displayed user information in the interface
                  updateDisplayedUserInfo(dataToUpdate);
                }

                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateProfilePhotoDialog() async {
    XFile? newPhoto = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (newPhoto != null) {
      await updateProfilePhoto(currentUserInfo?.photoUrl, PickedFile(newPhoto.path));
    }
  }

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
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Call the method to update the user's photo
                            updateProfilePhotoDialog();
                          },
                          child: Stack(
                            children: [
                                
                       
                         Container(
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
                          child: currentUserInfo?.photoUrl != null
                              ? CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(currentUserInfo!.photoUrl!),
                                )
                              : const Icon(Icons.person),
                        ),
                          Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 18,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      
                            
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: Text(
                          currentUserInfo!.name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Center(
                        // child: TextButton(
                        //   onPressed: () {
                           
                        //   },
                        //   // child: Text(
                        //   //   'Total Trips: ${Provider.of<AppInfo>(context, listen: false).countTotalTrips}',
                        //   //   style: TextStyle(
                        //   //     fontWeight: FontWeight.bold,
                        //   //     fontSize: 15,
                        //   //     color: Colors.grey[600],
                        //   //   ),
                        //   // ),
                        // ),
                      ),
                      const SizedBox(
                        height: 70,
                      ),
                      Text(
                        AppLocalizations.of(context)!.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
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
                                currentUserInfo!.name!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          
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
                                currentUserInfo!.email!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          
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
                                currentUserInfo!.phone!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          
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
                          
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                             updateUserInfoDialog(); // Call the function to show the dialog
                          },
                           style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Set the background color to black
    ),
                          child: Text(AppLocalizations.of(context)!.modify,
                             style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color.fromARGB(255, 255, 255, 255)),),
                        ),
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
}