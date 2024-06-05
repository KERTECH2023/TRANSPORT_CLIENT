import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:users_app/mainScreens/main_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _thirdController = TextEditingController();
  final TextEditingController _fourthController = TextEditingController();
  final TextEditingController _fifthController = TextEditingController();
  final TextEditingController _sixthController = TextEditingController();
  String? otpCode;
  final String verificationId = Get.arguments[0];
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    _thirdController.dispose();
    _fourthController.dispose();
    _fifthController.dispose();
    _sixthController.dispose();
    super.dispose();
  }

  // verify otp
  void verifyOtp(
      String verificationId,
      String userOtp,
      ) async {
    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);
      User? user = (await auth.signInWithCredential(creds)).user;
      if (user != null) {
        Get.to(MainScreen());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        e.message.toString(),
        AppLocalizations.of(context)!.eerror,
        colorText: Colors.white,
      );
    }
  }


  void _login() {
    if (otpCode != null) {
      verifyOtp(verificationId, otpCode!);
    } else {
      Get.snackbar(
        AppLocalizations.of(context)!.otp,
        AppLocalizations.of(context)!.error,
        colorText: Colors.white,
      );
    }
  }

  // _buildSocialLogo(file) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: <Widget>[
  //       Image.asset(
  //         file,
  //         height: 38.5,
  //       ),
  //     ],
  //   );
  // }

  final ButtonStyle style = ElevatedButton.styleFrom(
      minimumSize: const Size(188, 48),
      backgroundColor: const Color(0xFFFD7877),
      elevation: 6,
      textStyle: const TextStyle(fontSize: 16),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          )));

  Widget buildText(String text) => Center(
    child: Text(
      text,
      style: const TextStyle(fontSize: 24, color: Colors.white),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F2B2F),
      // backgroundColor: Color(0xff215D5F),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 200),
              buildText(AppLocalizations.of(context)!.otp),
              buildText(AppLocalizations.of(context)!.number),
              const SizedBox(height: 50),
              Pinput(
                length: 6,
                showCursor: true,
                defaultPinTheme: PinTheme(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: const Color(0xff2C474A),
                    ),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey),
                ),
                onCompleted: (value) {
                  setState(() {
                    otpCode = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                  style: style,
                  onPressed: _login,
                  child: Text(
                    AppLocalizations.of(context)!.loginas,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  )),
              const SizedBox(height: 80),
               Text(
                AppLocalizations.of(context)!.errorcode,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),
               Text(
                AppLocalizations.of(context)!.resendCode,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
