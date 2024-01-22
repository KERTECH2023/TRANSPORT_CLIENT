import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../global/global.dart';
import '../widgets/progress_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Registersignin extends StatefulWidget {
  const Registersignin({Key? key}) : super(key: key);

  @override
  State<Registersignin> createState() => _RegistersigninState();
}

class _RegistersigninState extends State<Registersignin> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
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

    phoneTextEditingController.addListener(() => setState(() {}));
  }

  Future<void> saveUserInfo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(message: AppLocalizations.of(context)!.processingPleasewait);
      },
    );

    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      String? imageUrl;

      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('client_images/${firebaseUser.uid}.jpg');
        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }

      Map<String, dynamic> userMap = {
        'id': firebaseUser.uid,
        'email': firebaseUser.email,
        'name': nameTextEditingController.text.trim(),
        'phone': phoneTextEditingController.text.trim(),
        'HealthStatus': SelectHealthStatus,
        'imageUrl': imageUrl,
      };

      DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('Users');
      databaseReference.child(firebaseUser.uid).set(userMap);

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
                        saveUserInfo();
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
