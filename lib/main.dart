import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:users_app/InfoHandler/app_info.dart';
import 'package:users_app/provider/internet_provider.dart';
import 'package:users_app/provider/sign_in_provider.dart';

import 'assistants/Geofire_assistant.dart';
import 'authentication/login_screen.dart';
import 'authentication/phone_signin.dart';
import 'authentication/register_google_sign_in.dart';
import 'authentication/register_screen.dart';
import 'mainScreens/main_screen.dart';
import 'mainScreens/rate_driver_screen.dart';
import 'mainScreens/search_places_screen.dart';
import 'mainScreens/select_active_driver_screen.dart';
import 'splashScreen/splash_screen.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

Completer<AndroidMapRenderer?>? _initializedRendererCompleter;
Future<AndroidMapRenderer?> initializeMapRenderer() async {
  if (_initializedRendererCompleter != null) {
    return _initializedRendererCompleter!.future;
  }

  final Completer<AndroidMapRenderer?> completer =
      Completer<AndroidMapRenderer?>();
  _initializedRendererCompleter = completer;

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    unawaited(mapsImplementation
        .initializeWithRenderer(AndroidMapRenderer.latest)
        .then((AndroidMapRenderer initializedRenderer) =>
            completer.complete(initializedRenderer)));
  } else {
    completer.complete(null);
  }

  return completer.future;
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
if (Platform.isAndroid) {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
      initializeMapRenderer();
    }
}

  await Firebase.initializeApp();

  runApp(await initializeApp());
}

Future<Widget> initializeApp() async {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => SignInProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => InternetProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => AppInfo(),
      ),
      ChangeNotifierProvider(
        create: (context) => GeoFireAssistant(),
      ),
    ],
    child: MyApp(),
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
    setState(() {// For T
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Accessing SignInProvider
    SignInProvider signInProvider = Provider.of<SignInProvider>(context);

    // Accessing InternetProvider
    InternetProvider internetProvider = Provider.of<InternetProvider>(context);

    return GetMaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => MySplashScreen(),
        '/main_screen': (context) => MainScreen(),
        '/phone_signin': (context) => Phonesignin(),
        '/login_screen': (context) => Login(),
        '/register_screen': (context) => Register(),
        '/register_googlesignin_screen': (context) => Registersignin(),
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
