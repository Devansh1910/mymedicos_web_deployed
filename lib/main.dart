import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'models/theme_notifier.dart';
import 'models/locale_notifier.dart';
import 'login/login_screen.dart';
import 'login/sign_up.dart';
import 'Home/home.dart';
import 'extras/settings_screen.dart';
import 'Landing/screen/landing.dart';
import 'profile/profile.dart';
import 'pg_neet/NeetScree.dart';
import 'login/components/login_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
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
            '/register': (context) => const SignUpScreen(),
            '/homescreen': (context) =>  HomeScreen2(),
            '/pgneet': (context) =>  PgNeet(),
            '/profile': (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
