import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:users_app/InfoHandler/app_info.dart';
import 'package:users_app/authentication/phone_signin.dart';
import 'package:users_app/mainScreens/rate_driver_screen.dart';
import 'package:users_app/mainScreens/search_places_screen.dart';
import 'package:users_app/mainScreens/select_active_driver_screen.dart';
import 'package:users_app/splashScreen/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'authentication/login_screen.dart';
import 'authentication/register_screen.dart';
import 'mainScreens/main_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
   static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  
}

class _MyAppState extends State<MyApp> {
    Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => MySplashScreen(),
        '/main_screen': (context) => MainScreen(),
        '/phone_signin': (context) => Phonesignin(),
        '/login_screen': (context) => Login(),
        '/register_screen': (context) => Register(),
        '/search_places_screen': (context) => SearchPlaces(),
        '/select_active_driver_screen': (context) => SelectActiveDriverScreen(),
        '/rate_driver_screen': (context) => RateDriverScreen(),
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      debugShowCheckedModeBanner: false,
      
    );
  }
}
