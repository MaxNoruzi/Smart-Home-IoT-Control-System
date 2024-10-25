import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iot_project/cubit/devices_screen_cubit.dart';
import 'package:iot_project/ui/screens/home_page_screen.dart';
import 'package:iot_project/ui/screens/login_screen.dart';
import 'package:iot_project/utils/appApi.dart';
import 'package:iot_project/utils/mqtt_client.dart';
import 'package:iot_project/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  var deviceData = <String, dynamic>{};
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    Utils.infoBox = await Hive.openBox('info');
    // checkDeviceInfo();
    /*
    document of Hive boxes and variables:
    info Box: key is "info" and there is three keys inside it
    1) "loggedIn" : it is a boolean that defines that user already logged in app or not , that means user have  a valid token
    2) "username" : a User information that contains thing like name and surname or ...
    3) "password" : auth information that includes accessToken and refreshToken  and expiresIn that shows expire time of accessToken
    4) "loggedOnce" : determine that user logged once in app but right now he may or may not be logged in
    */
    // Utils.isLoggedIn = Utils.infoBox.get("loggedIn") ?? false;
    if (Utils.infoBox.get("loggedIn") ?? false) {
      Utils.username = Utils.infoBox.get("username");
      Utils.password = Utils.infoBox.get("password");
      Utils.topic = "users/" + Utils.username;
      // Utils.lastLoginDate = DateTime.parse(Utils.infoBox.get("lastLoginDate"));
    }
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {};
    Utils.client = MqttService(
        broker: "212.23.201.244",
        clientId: "sadasdas",
        onConnected: () {},
        onDisconnected: () {});
    AppApi.instance.afterDioCreate();
    runApp(MyApp());
  }, (error, stackTrace) {
    print(error.toString() + stackTrace.toString() + deviceData.toString());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Solana',
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('en'),
      supportedLocales: const [
        Locale('en'), // English
        Locale('fa'), // Spanish
      ],
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.black, // Main primary color (black)
          onPrimary: Colors.white, // Text color on primary (white)
          secondary: Colors.red, // Accent color (red)
          onSecondary: Colors.white, // Text color on secondary (white)
          background: Colors.white, // Background color (white)
          onBackground: Colors.black, // Text color on background (black)
          surface:
              Colors.white, // Surface color for cards, dialogs, etc. (white)
          onSurface: Colors.black, // Text color on surface (black)
          error: Colors.redAccent, // Error color (red accent)
          onError: Colors.white, // Text color on error (white)
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // AppBar color (black)
          foregroundColor: Colors.white, // AppBar text and icon color (white)
          elevation: 4.0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black, // Main text color (black)
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black, // Secondary text color (black)
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            color: Colors.red, // Headline color (red accent)
            fontWeight: FontWeight.bold,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            color: Colors.white, // Button text color (white)
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Elevated button color (red)
            foregroundColor: Colors.white, // Elevated button text color (white)
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.red, // FAB color (red)
          foregroundColor: Colors.white, // FAB icon color (white)
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, // Icon color (black)
        ),
      ),
      routes: {
        '/home': (context) => BlocProvider(
              create: (context) => DevicesScreenCubit(),
              child: HomePageScreen(),
            ),
        '/login': (context) => LoginScreen(),
      },
      home: Utils.infoBox.get("loggedIn") ?? false
          ? BlocProvider(
              create: (context) => DevicesScreenCubit(),
              child: HomePageScreen(),
            )
          : LoginScreen(),
      // home: Scanner(),
    );
  }
}
