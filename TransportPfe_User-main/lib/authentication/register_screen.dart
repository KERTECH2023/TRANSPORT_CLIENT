import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../global/global.dart';
import '../widgets/progress_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  List<String> HealthStatus = ["Physical Illness", "None"];
  String? SelectHealthStatus;
    final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = true;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    nameTextEditingController.addListener(() => setState(() {}));
    emailTextEditingController.addListener(() => setState(() {}));
    phoneTextEditingController.addListener(() => setState(() {}));
  }
// void saveRegistrationData() {
//   // Get the user's UID from Firebase Auth
//   String userUid = FirebaseAuth.instance.currentUser!.uid;

//   // Save email and photo to Firebase Realtime Database
//   DatabaseReference reference = FirebaseDatabase.instance.ref().child('Users');
//   Map<String, dynamic> userData = {
//     'email': emailTextEditingController.text,
//     'photoUrl': '', // You may want to allow the user to upload a profile photo in the registration screen
//     // Add other fields as needed
//   };

//   reference.child(userUid).set(userData).then((_) {
//     // Data saved successfully
//     // You can navigate to the home screen or perform other actions
//     Navigator.pushNamed(context, '/');
//   }).catchError((error) {
//     // Handle errors while saving data
//     print('Error saving data: $error');
//     // You may want to display an error message to the user
//   });
// }
  Future<void> saveUserInfo(String email) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(message: AppLocalizations.of(context)!.processingPleasewait);
      },
    );
 
    final User? firebaseUser = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    ).catchError((message) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: AppLocalizations.of(context)!.error + message);
    })).user;

    if (firebaseUser != null) {
      String? imageUrl;

      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('client_images/${firebaseUser.uid}.jpg');
        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }

      Map<String, dynamic> userMap = {
        'id': firebaseUser.uid,
        'name': nameTextEditingController.text.trim(),
        'email': emailTextEditingController.text.trim(),
        'phone': phoneTextEditingController.text.trim(),
        'HealthStatus': SelectHealthStatus,
        'imageUrl': imageUrl,
      };

      DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('Users');
      databaseReference.child(firebaseUser.uid).set(userMap);

      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg: AppLocalizations.of(context)!.accounthasbeencreated);
      Navigator.pushNamed(context, '/');
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: AppLocalizations.of(context)!.accounthasnotbeencreated);
    }
  }

  @override
  Widget build(BuildContext context) {
  
   
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    
                    radius: 60,
                    backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                    child: InkWell(
                      onTap: () async {
                         final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

                        if (pickedFile != null) {
                          setState(() {
                            _imageFile = File(pickedFile.path);
                          });
                        }
                      },
                      child: _imageFile == null
                          ? Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.loggingin,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameTextEditingController,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.name,
                      hintText: AppLocalizations.of(context)!.name,
                      prefixIcon: const Icon(Icons.person),
                      suffixIcon: nameTextEditingController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => nameTextEditingController.clear(),
                            ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 10),
                      labelStyle: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.fieldIsEmpty;
                      } else
                        return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
                      hintText: AppLocalizations.of(context)!.emailHint,
                      prefixIcon: Icon(Icons.email),
                      suffixIcon: emailTextEditingController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => emailTextEditingController.clear(),
                            ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 10),
                      labelStyle: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.fieldIsEmpty;
                      } else if (!value.contains('@')) {
                        return AppLocalizations.of(context)!.invalidEmailAddress;
                      } else
                        return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: phoneTextEditingController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.hint,
                      hintText: AppLocalizations.of(context)!.hint,
                      prefixIcon: Icon(Icons.phone),
                      suffixIcon: phoneTextEditingController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => phoneTextEditingController.clear(),
                            ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 10),
                      labelStyle: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.fieldIsEmpty;
                      } else if (value.length != 12) {
                        return AppLocalizations.of(context)!.correctnum;
                      } else
                        return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordTextEditingController,
                    keyboardType: TextInputType.text,
                    obscureText: isPasswordVisible,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      hintText: AppLocalizations.of(context)!.password,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: isPasswordVisible
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility),
                        onPressed: () {
                          if (isPasswordVisible == true) {
                            setState(() {
                              isPasswordVisible = false;
                            });
                          } else {
                            setState(() {
                              isPasswordVisible = true;
                            });
                          }
                        },
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 10),
                      labelStyle: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.fieldIsEmpty;
                      } else if (value.length < 6) {
                        return AppLocalizations.of(context)!.passwordtooshort;
                      } else
                        return null;
                    },
                  ),
                  DropdownButton(
                    iconSize: 26,
                    dropdownColor: Colors.white,
                    hint: Text(
                      AppLocalizations.of(context)!.pleaseSelectYourHealthStatus,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                    value: SelectHealthStatus,
                    onChanged: (newValue) {
                      setState(() {
                        SelectHealthStatus = newValue.toString();
                      });
                    },
                    items: HealthStatus.map((health) {
                      return DropdownMenuItem(
                        child: Text(
                          health,
                          style: const TextStyle(color: Colors.black),
                        ),
                        value: health,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.black),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveUserInfo(emailTextEditingController.text);
                        // saveRegistrationData();
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.next,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login_screen');
                    },
                    child: Text(
                      AppLocalizations.of(context)!.alreadyhaveanaccountLoginNow,
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
