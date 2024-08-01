import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/global.dart';
import '../widgets/progress_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class reclamation extends StatefulWidget {
  const reclamation({Key? key}) : super(key: key);

  @override
  State<reclamation> createState() => _reclamationState();
}

class _reclamationState extends State<reclamation> {
 TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController reclamationTextEditingController = TextEditingController();


 

   saveCarInfo()
  {
    Map driverCarInfoMap =
    {
      "Full Name": nameTextEditingController.text.trim(),
      "Email": emailTextEditingController.text.trim(),
      "Phone": phoneTextEditingController.text.trim(),
      "Reclamation": reclamationTextEditingController.text.trim(),
    };

    DatabaseReference ReclamationRef = FirebaseDatabase.instance.ref().child("Reclamation");
   ReclamationRef.child(currentFirebaseUser!.uid).set(driverCarInfoMap);

    Fluttertoast.showToast(msg: AppLocalizations.of(context)!.reclamatioHasbeenAddedSuccessfully);
    Navigator.pushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [

              const SizedBox(height: 24,),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/logofi.png"),
              ),

              const SizedBox(height: 10,),

               Text(
                AppLocalizations.of(context)!.addyourComplaint,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
                  TextFormField(
                    controller: nameTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Colors.black,
                    ),

                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.name,
                      hintText: AppLocalizations.of(context)!.nameHint,

                      prefixIcon: Icon(Icons.person_2),
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

                      hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10
                      ),

                      labelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 15
                      ),

                    ),

                    validator: (value){
                      if(value!.isEmpty){
                        return AppLocalizations.of(context)!.fieldIsEmpty;
                      }

                      else {
                        return null;
                      }
                    },

                  ),

              const SizedBox(height: 20,),

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

                      hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10
                      ),

                      labelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 15
                      ),

                    ),

                    validator: (value){
                      if(value!.isEmpty){
                        return AppLocalizations.of(context)!.fieldIsEmpty;
                      }

                      else if (!value.contains('@')) {
                        return AppLocalizations.of(context)!.invalidEmailAddress;
                      }

                      else {
                        return null;
                      }
                    },

                  ),

              const SizedBox(height: 20,),

              TextFormField(
                    controller: phoneTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Colors.black,
                    ),

                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.phoneNumber,
                      hintText: AppLocalizations.of(context)!.phoneNumber,

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

                      hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10
                      ),

                      labelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 15
                      ),

                    ),

                    validator: (value){
                      if(value!.isEmpty){
                        return AppLocalizations.of(context)!.fieldIsEmpty;
                      }

                      else if (value.length != 11) {
                        return AppLocalizations.of(context)!.correctnum;
                      }

                      else {
                        return null;
                      }
                    },

                  ),

                   TextFormField(
                    controller: reclamationTextEditingController,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      color: Colors.black,
                    ),

                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.reclamation,
                      hintText: AppLocalizations.of(context)!.reclamation,

                      prefixIcon: Icon(Icons.report),
                      suffixIcon: reclamationTextEditingController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => reclamationTextEditingController.clear(),
                      ),

                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),

                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),

                      hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10
                      ),

                      labelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 15
                      ),

                    ),

                    validator: (value){
                      if(value!.isEmpty){
                        return AppLocalizations.of(context)!.fieldIsEmpty;
                      }


                      else {
                        return null;
                      }
                    },

                  ),


              const SizedBox(height: 20,),

              ElevatedButton(
                onPressed: ()
                {
                  if(nameTextEditingController.text.isNotEmpty
                      && emailTextEditingController.text.isNotEmpty
                      && phoneTextEditingController.text.isNotEmpty && reclamationTextEditingController.text.isNotEmpty)
                  {
                    saveCarInfo();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child:  Text(
                  AppLocalizations.of(context)!.submit,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}