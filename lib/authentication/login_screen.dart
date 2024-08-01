import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:get/get.dart';
import 'package:users_app/authentication/otp_page.dart';
import 'package:users_app/authentication/phoneauth_screen.dart';
import 'package:users_app/classesLanguage/language.dart';
import 'package:users_app/classesLanguage/language_constants.dart';
import 'package:users_app/main.dart';
import 'package:users_app/utils/next_screen.dart';
import 'package:users_app/utils/snack_bar.dart';
import '../global/global.dart';
import '../mainScreens/main_screen.dart';
import '../provider/internet_provider.dart';
import '../provider/sign_in_provider.dart';
import '../widgets/progress_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();

}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
       final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController twitterController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController phoneController =
      RoundedLoadingButtonController();

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  bool isPasswordVisible = true;

  @override
  void initState() {
    super.initState();

    emailTextEditingController.addListener(() => setState(() {}));
    passwordTextEditingController.addListener(() => setState(() {}));
    
  }
Future<void> loginUser() async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ProgressDialog(message: AppLocalizations.of(context)!.loggingin);
    },
  );

  try {
    final User? firebaseUser = (await firebaseAuth
            .signInWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim(),
            ))
        .user;

    if (firebaseUser != null) {
      DatabaseReference reference =
          FirebaseDatabase.instance.ref().child("Users");
      reference.child(firebaseUser.uid).once().then((userKey) {
        final snapshot = userKey.snapshot;
        if (snapshot.exists) {
          currentFirebaseUser = firebaseUser;
          Fluttertoast.showToast(msg: AppLocalizations.of(context)!.loginSuccessful);
          Navigator.pushNamed(context, '/');
        } else {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.noUserRecordExists);
          firebaseAuth.signOut();
          Navigator.pushNamed(context, '/');
        }
      });
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: AppLocalizations.of(context)!.wrongCredentials);
    }
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context);
    if (e.code == 'wrong-password') {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: AppLocalizations.of(context)!.eerror,
        desc: AppLocalizations.of(context)!.wrongCredentials,
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: AppLocalizations.of(context)!.eerror,
        desc: e.message ?? 'An unknown error occurred',
      ).show();
    }
  } catch (e) {
    Navigator.pop(context);
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: AppLocalizations.of(context)!.eerror,
      desc: e.toString(),
    ).show();
  }
}

 // Future<void> _signInWithGoogle() async {
//   try {
    
//     final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
//     if (googleSignInAccount != null) {
//       final GoogleSignInAuthentication googleSignInAuthentication =
//           await googleSignInAccount.authentication;

//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleSignInAuthentication.accessToken,
//         idToken: googleSignInAuthentication.idToken,
//       );

//       final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
//       final User? user = authResult.user;

//       // Perform additional actions if needed (e.g., navigate to another screen)
//       // For example:
//       if (user != null) {
//         // Navigate to home screen or do something else
//         print('User signed in: ${user.displayName}');
//       }
//     } else {
//       // User canceled Google Sign-In
//       print('User canceled Google Sign-In');
//     }
//   } catch (error) {
//     print('Google Sign-In Error: $error');
//     // Handle Google Sign-In error
//   }
// }
    // Function for Google Sign-In
   Future<UserCredential> signInWithGoogle() async {
//   // Step 1: Initiate Google Sign-In
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

//   // Step 2: Obtain Google Sign-In Authentication
   final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

//   // Step 3: Create Firebase credentials
  final OAuthCredential credential = GoogleAuthProvider.credential(
     accessToken: googleAuth.accessToken,     idToken: googleAuth.idToken,
  );

//   // Step 4: Sign in with Firebase using the obtained credentials
   return await FirebaseAuth.instance.signInWithCredential(credential);
  
 }

 Future<void> handleGoogleSignIn() async {
   try {
   UserCredential userCredential = await signInWithGoogle();
    User? user = userCredential.user;

    if (user != null) {
//       // Check if the user already exists in your database
      bool isUserExists = await checkIfUserExists(user.email!);

       if (isUserExists) {
//         // User already exists, redirect to their account
         Navigator.pushNamed(context, '/main_screen');
      } else {
        // User doesn't exist, redirect to the registration screen.
        Navigator.pushNamed(context, '/register_googlesignin_screen', arguments: {'email': user.email});
      }
    } else {
      // Handle sign-in failure here, if needed.
      Fluttertoast.showToast(msg: "Google Sign-In Failed. Please try again.");
    }
  } catch (e) {
    // Handle sign-in failure and errors here, if needed.
   print("Google Sign-In Error: $e");
    Fluttertoast.showToast(msg: "Google Sign-In Error: $e");
  }
 }
 Future<bool> checkIfUserExists(String email) async {
  try {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('Users');
    var snapshot = await databaseReference.orderByChild('email').equalTo(email).get();
    
    // For newer versions of Firebase (version 9 or later)
    // Use snapshot.exists() instead of snapshot.value != null
    return snapshot.exists;
  } catch (e) {
    print("Error checking if user exists: $e");
    return false;
  }
}
// Future handleGoogleSignIn() async {
//     final sp = context.read<SignInProvider>();
//     final ip = context.read<InternetProvider>();
//     await ip.checkInternetConnection();

//     if (ip.hasInternet == false) {
//       openSnackbar(context, "Check your Internet connection", Colors.red);
//       googleController.reset();
//     } else {
//       await sp.signInWithGoogle().then((value) {
//         if (sp.hasError == true) {
//           openSnackbar(context, sp.errorCode.toString(), Colors.red);
//           googleController.reset();
//         } else {
//           // checking whether user exists or not
//           sp.checkUserExists().then((value) async {
//             if (value == true) {
//               // user exists
//               await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
//                   .saveDataToSharedPreferences()
//                   .then((value) => sp.setSignIn().then((value) {
//                         googleController.success();
//                         handleAfterSignIn();
//                       })));
//             } else {
//               // user does not exist
//               sp.saveDataToFirestore().then((value) => sp
//                   .saveDataToSharedPreferences()
//                   .then((value) => sp.setSignIn().then((value) {
//                         googleController.success();
//                         handleAfterSignIn();
//                       })));
//             }
//           });
//         }
//       });
//     }
//   }


// Function to save user data to Firebase Realtime Database
// void saveUserDataToDatabase(String email, String? photoUrl) {
//   DatabaseReference reference = FirebaseDatabase.instance.ref().child("Users");
  
//   // Create a map of user data to be saved
//   Map<String, dynamic> userData = {
//     "email": email,
//     "photoUrl": photoUrl ?? "", // Use empty string if photoUrl is null
//     // Add other user data fields if needed
//   };

//   // Save data to the database using the user's UID as the key
//   reference.child(FirebaseAuth.instance.currentUser!.uid).set(userData);
// }

  // Function for Facebook Login
   Future handleFacebookAuth() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackbar(context, "Check your Internet connection", Colors.red);
      facebookController.reset();
    } else {
      await sp.signInWithFacebook().then((value) {
        if (sp.hasError == true) {
          openSnackbar(context, sp.errorCode.toString(), Colors.red);
          facebookController.reset();
        } else {
          // checking whether user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        facebookController.success();
                        handleAfterSignIn();
                      })));
            } else {
              // user does not exist
              sp.saveDataToFirestore().then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        facebookController.success();
                        handleAfterSignIn();
                      })));
            }
          });
        }
      });
    }
  }

  // Function for Phone Number Login
  void handlePhoneNumberLogin() {
    Navigator.pushNamed(context, '/phone_signin');
  }

  ButtonStyle customButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
    );
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
                  Image.asset("images/logofi.png"),
                   Text(
                    AppLocalizations.of(context)!.loginas,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
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
                      suffixIcon: emailTextEditingController.text.isEmpty ?
                          Container(width: 0) :
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => emailTextEditingController.clear(),
                          ),

                      // enabledBorder: const OutlineInputBorder(
                      //   borderSide: BorderSide(color: Colors.black),
                      // ),

                      // focusedBorder: const UnderlineInputBorder(
                      //   borderSide: BorderSide(color: Colors.black),
                      // ),

                      // hintStyle: const TextStyle(
                      //     color: Colors.grey,
                      //     fontSize: 10
                      // ),

                      // labelStyle: const TextStyle(
                      //     color: Colors.black,
                      //     fontSize: 15
                      // ),
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
                    controller: passwordTextEditingController,
                    keyboardType: TextInputType.text,
                    obscureText: isPasswordVisible,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      hintText: AppLocalizations.of(context)!.password,
                      prefixIcon: Icon(Icons.password),
                       suffixIcon: IconButton(
                          icon: isPasswordVisible ?
                          const Icon(Icons.visibility_off) :
                          const Icon(Icons.visibility),

                          onPressed: () {
                            if(isPasswordVisible == true){
                              setState(() {
                                isPasswordVisible = false;
                              });
                            }

                            else {
                              setState(() {
                                isPasswordVisible = true;
                              });
                            }

                          }

                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.fieldIsEmpty;
                      } else {
                        return null;
                      }
                    },
                  ),
                  InkWell(
                    onTap: () async {
                      if (emailTextEditingController.text == ""){
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: AppLocalizations.of(context)!.eerror,
                          desc: AppLocalizations.of(context)!.pleasefilloutyouremailthenlickForgetpass,
                          ).show();
                          return;
                          }
                          try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailTextEditingController.text);
                         AwesomeDialog(
                          context: context,
                          dialogType: DialogType.success,
                          animType: AnimType.rightSlide,
                          title: AppLocalizations.of(context)!.succes,
                          desc: AppLocalizations.of(context)!.mailhasbeensenttoouremail,
                          ).show();
                          } catch (e){
                             AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: AppLocalizations.of(context)!.eerror,
                          desc: AppLocalizations.of(context)!.pleaseverifytheemailthatyouhaveentered,
                          ).show();


                          }

                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom:  20),
                      alignment:Alignment.topRight,
                      child:  Text(
                        AppLocalizations.of(context)!.forgetpassword,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                  
                  
                  
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        loginUser();
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.loginas,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.or,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                   const SizedBox(
                  height: 10,
                ),
                 Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    RoundedLoadingButton(
      onPressed: () {
        handleGoogleSignIn();
      },
      controller: googleController,
      successColor: Colors.red,
      width: MediaQuery.of(context).size.width * 0.15,
      elevation: 0,
      borderRadius: 25,
      color: Colors.red,
      child: Align(
      child: Wrap(
        children: const [
          Icon(
            FontAwesomeIcons.google,
            size: 20,
            color: Colors.white,
          ),
          SizedBox(
            width: 15,
          ),
        ],
      ),
    ),
    ),
    SizedBox(width: 20), // Add space between buttons
    RoundedLoadingButton(
      onPressed: () {
        handleFacebookAuth();
      },
      controller: facebookController,
      successColor: Colors.blue,
      width: MediaQuery.of(context).size.width * 0.15,
      elevation: 0,
      borderRadius: 25,
      color: Colors.blue,
        child: Align(
      child: Wrap(
        children: const [
          Icon(
            FontAwesomeIcons.facebook,
            size: 20,
            color: Colors.white,
          ),
          SizedBox(
            width: 15,
          ),
        ],
      ),
    ),
    ),
    SizedBox(width: 20), // Add space between buttons
    RoundedLoadingButton(
      onPressed: () {
        handlePhoneNumberLogin();
      },
      controller: phoneController,
      successColor: Colors.black,
      width: MediaQuery.of(context).size.width * 0.15,
      elevation: 0,
      borderRadius: 25,
      color: Colors.black,
      
      child: Wrap(
        children: const [
          Icon(
            FontAwesomeIcons.phone,
            size: 20,
            color: Colors.white,
            

          ),
          SizedBox(
            width: 15,
          ),
        ],
      ),
    ),
  ],
),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register_screen');
                    },
                    child: Text(
                      AppLocalizations.of(context)!.noAccountRegister,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
 handleAfterSignIn() {
  Future.delayed(const Duration(milliseconds: 1000)).then((value) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  });
}
  
}
