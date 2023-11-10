import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:get/get.dart';
import 'package:users_app/authentication/otp_page.dart';
import 'package:users_app/classesLanguage/language.dart';
import 'package:users_app/classesLanguage/language_constants.dart';
import 'package:users_app/main.dart';
import '../global/global.dart';
import '../widgets/progress_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();

}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
      

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  bool isPasswordVisible = true;

  @override
  void initState() {
    super.initState();

    emailTextEditingController.addListener(() => setState(() {}));
    passwordTextEditingController.addListener(() => setState(() {}));
  }

  loginUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(message: AppLocalizations.of(context)!.loggingin);
      },
    );

    final User? firebaseUser = (await firebaseAuth
            .signInWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim(),
            )
            .catchError((message) {
          Navigator.pop(context);
           AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: AppLocalizations.of(context)!.eerror,
      desc: "${AppLocalizations.of(context)!.wrongCredentials}"
    ).show();
          
        }))
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
  }

    // Function for Google Sign-In
  Future<UserCredential> signInWithGoogle() async {
  // Step 1: Initiate Google Sign-In
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Step 2: Obtain Google Sign-In Authentication
  final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

  // Step 3: Create Firebase credentials
  final OAuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Step 4: Sign in with Firebase using the obtained credentials
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

 Future<void> handleGoogleSignIn() async {
    try {
      UserCredential userCredential = await signInWithGoogle();
      User? user = userCredential.user;
      if (user != null) {
        // Successfully signed in with Google.
        // You can store the user information or perform any other actions here.
        Navigator.pushNamed(context, '/main_screen'); // Replace '/next_interface' with the route of your next interface.
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

  // Function for Facebook Login
  void handleFacebookLogin() {
    // Implement the Facebook Login logic here
  }

  // Function for Phone Number Login
  void handlePhoneNumberLogin() {
    Navigator.pushNamed(context, '/phone_signin');
  }

  ButtonStyle customButtonStyle() {
    return ElevatedButton.styleFrom(
      primary: Colors.transparent,
      onPrimary: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                      // ...
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
                      primary: Colors.black,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: handleGoogleSignIn,
                        style: customButtonStyle(),
                        child: Image.asset(
                          "images/google.png",
                          width: 50,
                          height: 50,
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: handleFacebookLogin,
                        style: customButtonStyle(),
                        child: Image.asset(
                          "images/facebook.png",
                          width: 50,
                          height: 50,
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: handlePhoneNumberLogin,
                        style: customButtonStyle(),
                        child: Image.asset(
                          "images/phone.png",
                          width: 50,
                          height: 50,
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
 
  
}
