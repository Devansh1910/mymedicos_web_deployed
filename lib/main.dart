import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the generated file
import 'theme_notifier.dart';
import 'locale_notifier.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart'; // Ensure the correct path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyCE7_gYf1UZ-KgfRS45xPKYkAy0S5GxYbk",


        projectId: "mymedicosupdated",

        messagingSenderId: "968103235749",
        appId: "1:968103235749:web:403b7c7a79c3846fedbd4c",

        ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeNotifier, LocaleNotifier>(
      builder: (context, themeNotifier, localeNotifier, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: themeNotifier.currentTheme,
          locale: localeNotifier.currentLocale,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(title: 'Mymedicos'),
            '/settings': (context) => const SettingsScreen(),
            '/login': (context) => const LoginScreen(),
          },
        );
      },
    );
  }
}
