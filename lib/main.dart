import 'package:flutter/material.dart';

import 'package:mymedicosweb/homescreen2/home_screen_2.dart';
import 'package:mymedicosweb/login/login_check.dart';

import 'package:mymedicosweb/pg_neet/QuizScreen.dart';

import 'package:mymedicosweb/pg_neet/pg_neet.dart';
import 'package:mymedicosweb/pg_neet/pg_neet_payment.dart';
import 'package:mymedicosweb/profile.dart';
import 'package:mymedicosweb/sign_up.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the generated file
import 'theme_notifier.dart';
import 'locale_notifier.dart';
import 'Landing/home_screen.dart';
import 'settings_screen.dart';
import 'login/login_screen.dart'; // Ensure the correct path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyCE7_gYf1UZ-KgfRS45xPKYkAy0S5GxYbk",
        authDomain: "mymedicosupdated.firebaseapp.com",
        databaseURL: "https://mymedicosupdated-default-rtdb.asia-southeast1.firebasedatabase.app",
        projectId: "mymedicosupdated",
        storageBucket: "mymedicosupdated.appspot.com",
        messagingSenderId: "968103235749",
        appId: "1:968103235749:web:403b7c7a79c3846fedbd4c",
        measurementId: "G-B66D4LFS4J"

        ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),
        ChangeNotifierProvider(create: (_) => UserNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeNotifier, LocaleNotifier, UserNotifier>(
      builder: (context, themeNotifier, localeNotifier, userNotifier, child) {
        if (!userNotifier.isInitialized) {
          return LoadingScreen(); // Show loading screen while initializing
        }
        // Once initialized, check login state and navigate accordingly
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeNotifier.currentTheme,
          locale: localeNotifier.currentLocale,
          initialRoute: userNotifier.isLoggedIn ? '/homescreen' : '/',
          routes: {
            '/': (context) => const HomeScreen(title: 'Mymedicos'),
            '/settings': (context) => const SettingsScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => SignUpScreen(),
            '/homescreen': (context) => HomeScreen2(),
            '/pgneet': (context) => PgNeet(),
            '/profile': (context) => ProfileScreen(),
            // '/quiz': (context) => QuizPage(),
          },
        );
      },
    );
  }
}
class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}