import 'dart:math';
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
import 'package:intl_phone_field/intl_phone_field.dart';
import 'verify_email_screen.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

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
  String? completePhoneNumber;
  bool isPasswordVisible = true;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    nameTextEditingController.addListener(() => setState(() {}));
    emailTextEditingController.addListener(() => setState(() {}));
    phoneTextEditingController.addListener(() => setState(() {}));
  }

  String generateVerificationCode() {
    const length = 5;
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    ));
  }

  Future<void> sendVerificationEmail(String email, String code) async {
    final smtpServer = gmail("mahdikaroui383@gmail.com", "doyr zflv xvcu rumh");
    final message = Message()
      ..from = Address("mahdikaroui383@gmail.com", "TunisieUber")
      ..recipients.add(email)
      ..subject = "Code de vérification"
      ..text = "Votre code de vérification est : $code";

    try {
      final sendReport = await send(message, smtpServer);
      print("Message envoyé : ${sendReport.toString()}");
    } catch (e) {
      print("Erreur lors de l'envoi de l'email : $e");
    }
  }

  Future<void> sendVerificationCode(String email) async {
    // Vérifier si l'email existe déjà
    List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    if (signInMethods.isNotEmpty) {
      Fluttertoast.showToast(msg: "Cet email est déjà utilisé.");
      return;
    }

    String code = generateVerificationCode();
    await sendVerificationEmail(email, code);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyCodeScreen(
          email: email,
          code: code,
          name: nameTextEditingController.text.trim(),
          phone: completePhoneNumber!,
          healthStatus: SelectHealthStatus,
          imageFile: _imageFile,
        ),
      ),
    );
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
                    style: const TextStyle(color: Colors.black),
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
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black),
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
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  IntlPhoneField(
                    controller: phoneTextEditingController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.phoneNumber,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    initialCountryCode: 'MA',
                    onChanged: (phone) {
                      completePhoneNumber = phone.completeNumber;
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return AppLocalizations.of(context)!.fieldIsEmpty;
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordTextEditingController,
                    keyboardType: TextInputType.text,
                    obscureText: isPasswordVisible,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      hintText: AppLocalizations.of(context)!.password,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: isPasswordVisible
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
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
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    hint: Text("healthStatus"),
                    value: SelectHealthStatus,
                    items: HealthStatus.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        SelectHealthStatus = newValue;
                      });
                    },
                    decoration: InputDecoration(
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
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.fieldIsEmpty;
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        sendVerificationCode(emailTextEditingController.text.trim());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text("Register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
