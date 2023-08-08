

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:users_app/assistants/assistant_methods.dart';

import '../global/global.dart';
import '../widgets/progress_dialog.dart';

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
        return ProgressDialog(message: "Logging in");
      },
    );

    final User? firebaseUser = (await firebaseAuth
            .signInWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim(),
            )
            .catchError((message) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error" + message);
        }))
        .user;

    if (firebaseUser != null) {
      DatabaseReference reference =
          FirebaseDatabase.instance.ref().child("Users");
      reference.child(firebaseUser.uid).once().then((userKey) {
        final snapshot = userKey.snapshot;
        if (snapshot.exists) {
          currentFirebaseUser = firebaseUser;
          Fluttertoast.showToast(msg: "Login Successful");
          Navigator.pushNamed(context, '/');
        } else {
          Fluttertoast.showToast(
              msg: "No User record exists with these credentials");
          firebaseAuth.signOut();
          Navigator.pushNamed(context, '/');
        }
      });
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Wrong Credentials! Try Again");
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
    // Implement the Phone Number Login logic here
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
                  const Text(
                    "Login as a User",
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
                      labelText: "Email",
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email),
                      suffixIcon: emailTextEditingController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  emailTextEditingController.clear(),
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
                        return "The field is empty";
                      } else if (!value.contains('@')) {
                        return "Invalid Email Address";
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
                      labelText: "Password",
                      hintText: "Password",
                      prefixIcon: Icon(Icons.password),
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
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      labelStyle: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "The field is empty";
                      } else
                        return null;
                    },
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
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                    const SizedBox(height: 10), // Adding some space between "Login" button and "Or" text
                  const Text(
                    "Or",
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
                        style: customButtonStyle(), // Custom style for Google Sign-In button
                        child: Image.asset(
                          "images/google.png",
                          width: 50,
                          height: 50,
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: handleFacebookLogin,
                        style: customButtonStyle(), // Custom style for Facebook Login button
                        child: Image.asset(
                          "images/facebook.png",
                          width: 50,
                          height: 50,
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: handlePhoneNumberLogin,
                        style: customButtonStyle(), // Custom style for Phone Number Login button
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
                    child: const Text(
                      "Don't have an account? Register Now",
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
