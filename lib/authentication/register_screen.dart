import 'dart:io';

import 'package:drivers_app/localization/language_constants.dart';
import 'package:drivers_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../global/global.dart';
import '../localization/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/progress_dialog.dart';
import 'package:http/http.dart' as http;

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
  TextEditingController dateNaissanceController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController cStatusController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController licenceController = TextEditingController();
  TextEditingController cnicNoController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = true;
  DateTime? selectedDate;
   bool cStatus = false; 
  String? selectedGender;
   File? _imageFile;
  List<String> genderOptions = ["Homme", "Femme"];

  @override
  void initState() {
    super.initState();
    nameTextEditingController.addListener(() => setState(() {}));
    emailTextEditingController.addListener(() => setState(() {}));
    phoneTextEditingController.addListener(() => setState(() {}));
    dateNaissanceController.addListener(() => setState(() {}));
    genderController.addListener(() => setState(() {}));
    cStatusController.addListener(() => setState(() {}));
    addressController.addListener(() => setState(() {}));
    postalCodeController.addListener(() => setState(() {}));
    licenceController.addListener(() => setState(() {}));
    cnicNoController.addListener(() => setState(() {}));
  }

  saveUserInfo() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: AppLocalizations.of(context)!.processingPleasewait);
        });

    final User? firebaseUser = (await firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text.trim(),
                password: passwordTextEditingController.text.trim())
            .catchError((message) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error" + message.toString());
        }))
        .user;
       if (firebaseUser != null) {
      String? imageUrl;

      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('chauffeur_images/${firebaseUser.uid}.jpg');
        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }
    if (firebaseUser != null) {
      Map userMap = {
        'id': firebaseUser.uid,
        'name': nameTextEditingController.text.trim(),
        'email': emailTextEditingController.text.trim(),
        'phone': phoneTextEditingController.text.trim(),
        'DateNaissance': dateNaissanceController.text.trim(),
        'gender': selectedGender,
        'Cstatus': false,
        'address': addressController.text.trim(),
        'postalCode': postalCodeController.text.trim(),
        'licence': licenceController.text.trim(),
        'cnicNo': cnicNoController.text.trim(),
        'imageUrl': imageUrl,
      };

      DatabaseReference databaseReference =
          FirebaseDatabase.instance.ref().child('Drivers');
      databaseReference.child(firebaseUser.uid).set(userMap);

      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg: AppLocalizations.of(context)!.accounthasbeencreated);
      Navigator.pushNamed(context, '/car_info_screen');
    }} else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: AppLocalizations.of(context)!.accounthasnotbeencreated);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateNaissanceController.text =
            "${selectedDate!.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
               backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text(AppLocalizations.of(context)!.homePage),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<Language>(
              underline: const SizedBox(),
              icon: const Icon(
                Icons.language,
                color: Colors.white,
              ),
              onChanged: (Language? language) async {
                if (language != null) {
                  Locale _locale = await setLocale(language.languageCode);
                  MyApp.setLocale(context, _locale);
                }
              },
              items: Language.languageList().map<DropdownMenuItem<Language>>(
                (e) => DropdownMenuItem<Language>(
                  value: e,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        e.flag,
                        style: const TextStyle(fontSize: 30),
                      ),
                      Text(e.name)
                    ],
                  ),
                ),
              ).toList(),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                   const SizedBox(height: 20),
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

                  TextFormField(
                    controller: nameTextEditingController,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                     labelText:  AppLocalizations.of(context)!.name,
                      hintText:  AppLocalizations.of(context)!.name,
                      prefixIcon: const Icon(Icons.person),
                      suffixIcon: nameTextEditingController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () =>
                                  nameTextEditingController.clear(),
                            ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontSize: 15),
                      labelStyle: const TextStyle(
                          color: Colors.black, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return  AppLocalizations.of(context)!.fieldIsEmpty;
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
                     labelText:  AppLocalizations.of(context)!.email,
                      hintText:  AppLocalizations.of(context)!.emailHint,
                      prefixIcon: Icon(Icons.email),
                      suffixIcon:
                          emailTextEditingController.text.isEmpty
                              ? Container(width: 0)
                              : IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () =>
                                      emailTextEditingController.clear(),
                                ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontSize: 15),
                      labelStyle: const TextStyle(
                          color: Colors.black, fontSize: 15),
                    ),
                    validator: (value){
                      if(value!.isEmpty){
                        return  AppLocalizations.of(context)!.fieldIsEmpty;
                      }

                      else if (!value.contains('@')) {
                        return  AppLocalizations.of(context)!.invalidEmailAddress;
                      }

                      else
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
                  labelText:  AppLocalizations.of(context)!.hint,
                      hintText:  AppLocalizations.of(context)!.hint,
                      prefixIcon: Icon(Icons.phone),
                      suffixIcon: phoneTextEditingController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () =>
                                  phoneTextEditingController.clear(),
                            ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontSize: 15),
                      labelStyle: const TextStyle(
                          color: Colors.black, fontSize: 15),
                    ),
                     validator: (value){
                      if (value!.isEmpty) {
                        return  AppLocalizations.of(context)!.fieldIsEmpty;
                      }

                      else if (value.length != 12) {
                        return AppLocalizations.of(context)!.correctnum;
                      }

                      else
                        return null;
                    },
                  ),

                 

                  // const SizedBox(height: 20),

                  // TextFormField(
                  //   controller: cStatusController,
                  //   style: const TextStyle(
                  //     color: Colors.black,
                  //   ),
                  //   decoration: InputDecoration(
                  //     labelText: "Cstatus",
                  //     hintText: "Cstatus",
                  //   prefixIcon: Icon(Icons.topic),
                  //     suffixIcon: cStatusController.text.isEmpty
                  //         ? Container(width: 0)
                  //         : IconButton(
                  //             icon: Icon(Icons.close),
                  //             onPressed: () =>
                  //                 cStatusController.clear(),
                  //           ),
                  //     enabledBorder: const OutlineInputBorder(
                  //       borderSide: BorderSide(color: Colors.black),
                  //     ),
                  //     focusedBorder: const UnderlineInputBorder(
                  //       borderSide: BorderSide(color: Colors.black),
                  //     ),
                  //     hintStyle: const TextStyle(
                  //         color: Colors.grey, fontSize: 15),
                  //     labelStyle: const TextStyle(
                  //         color: Colors.black, fontSize: 15),
                  //   ),
                  //   validator: (value) {
                  //     if (value!.isEmpty) {
                  //       return "The field is empty";
                  //     } else if (value.length != 5) {
                  //       return "Invalid number";
                  //     } else
                  //       return null;
                  //   },
                  // ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: addressController,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.address,
                      hintText: AppLocalizations.of(context)!.address,
                    prefixIcon: Icon(Icons.streetview),
                      suffixIcon: addressController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () =>
                                  addressController.clear(),
                            ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontSize: 15),
                      labelStyle: const TextStyle(
                          color: Colors.black, fontSize: 15),
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
                    controller: postalCodeController,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.postalCode,
                      hintText: AppLocalizations.of(context)!.postalCode,
                    prefixIcon: Icon(Icons.post_add),
                      suffixIcon: postalCodeController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () =>
                                  postalCodeController.clear(),
                            ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontSize: 15),
                      labelStyle: const TextStyle(
                          color: Colors.black, fontSize: 15),
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
                    controller: licenceController,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.licence,
                      hintText: AppLocalizations.of(context)!.licence,
                  prefixIcon: Icon(Icons.numbers),
                      suffixIcon: licenceController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () =>
                                  licenceController.clear(),
                            ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontSize: 15),
                      labelStyle: const TextStyle(
                          color: Colors.black, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.fieldIsEmpty;
                      } else if (value.length != 5) {
                        return AppLocalizations.of(context)!.correctnum;
                      } else
                        return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: cnicNoController,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.cNICNumber,
                      hintText: AppLocalizations.of(context)!.cNICNumber,
                   prefixIcon: Icon(Icons.label_important_outline),
                      suffixIcon: cnicNoController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () =>
                                  cnicNoController.clear(),
                            ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontSize: 15),
                      labelStyle: const TextStyle(
                          color: Colors.black, fontSize: 15),
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
                    controller: passwordTextEditingController,
                    keyboardType: TextInputType.text,
                    obscureText: isPasswordVisible,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText:AppLocalizations.of(context)!.password,
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
                          }),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontSize: 15),
                      labelStyle: const TextStyle(
                          color: Colors.black, fontSize: 15),
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
                   const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(
                          text: selectedDate != null
                              ? "${selectedDate!.toLocal()}"
                                  .split(' ')[0]
                              : "",
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.dateOfBirth,
                          hintText:  AppLocalizations.of(context)!.dateOfBirth,
                        ),
                        validator: (value) {
                          if (selectedDate == null) {
                            return AppLocalizations.of(context)!.selectDateofBirth;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField(
                    value: selectedGender,
                    items: genderOptions
                        .map((gender) => DropdownMenuItem(
                              child: Text(gender),
                              value: gender,
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value as String?;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.gender,
                      hintText: AppLocalizations.of(context)!.gender,
                    ),
                    validator: (value) {
                      if (value == null) {
                        return AppLocalizations.of(context)!.selectGender;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          saveUserInfo();
                        }
                        var response = http.post(
                            Uri.parse(
                                "http://192.168.1.2:3000/Chauff/AjoutChauf"),
                            body: {
                              "Nom": nameTextEditingController.value.toString(),
                              "Prenom":
                                  passwordTextEditingController.value.toString(),
                              "phone":
                                  phoneTextEditingController.value.toString(),
                              "email":
                                  emailTextEditingController.value.toString(),
                              "DateNaissance":
                                  dateNaissanceController.value.toString(),
                              "gender": selectedGender!,
                              "Cstatus": cStatus.toString(),
                              "address": addressController.value.toString(),
                              "postalCode":
                                  postalCodeController.value.toString(),
                              "licence": licenceController.value.toString(),
                              "cnicNo": cnicNoController.value.toString(),
                            });
                        print(response.toString());
                      },
                      child:  Text(
                        AppLocalizations.of(context)!.next,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )),

                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login_screen');
                      },
                      child:  Text(
                        AppLocalizations.of(context)!.alreadyhaveanaccountLoginNow,
                        style: TextStyle(color: Colors.black),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
