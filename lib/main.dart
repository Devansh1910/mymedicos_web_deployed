import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mymedicosweb/login/components/login_check.dart';
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
import 'pg_neet/ExamPaymentScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCE7_gYf1UZ-KgfRS45xPKYkAy0S5GxYbk",
      authDomain: "mymedicosupdated.firebaseapp.com",
      databaseURL: "https://mymedicosupdated-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "mymedicosupdated",
      storageBucket: "mymedicosupdated.appspot.com",
      messagingSenderId: "968103235749",
      appId: "1:968103235749:web:403b7c7a79c3846fedbd4c",
      measurementId: "G-B66D4LFS4J",
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


  Future<DocumentSnapshot> fetchQuizDetails(String examId) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final CollectionReference quizzCollection = db.collection('PGupload').doc('Weekley').collection('Quiz');

    QuerySnapshot querySnapshot = await quizzCollection.where('qid', isEqualTo: examId).get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    } else {
      throw Exception('Quiz not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeNotifier, LocaleNotifier, UserNotifier>(
      builder: (context, themeNotifier, localeNotifier, userNotifier, child) {
        if (!userNotifier.isInitialized) {
          return LoadingScreen(); // Show loading screen while initializing
        }

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
            '/homescreen': (context) => HomeScreen2(),
            '/pgneet': (context) => PgNeet(),
            '/profile': (context) => const ProfileScreen(),

          },
            onGenerateRoute: (settings) {
              final Uri uri = Uri.parse(settings.name!);
              if (uri.path == '/examdetails' && uri.queryParameters.containsKey('examId')) {
                final String examId = uri.queryParameters['examId']!;
                final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>? ?? {};
                String title = args['title'] ?? 'null';
                String dueDate = args['dueDate'] ?? '2024-06-21 00:00:00.000';

                print("duedatemain: $dueDate");
                print("titlemain: $title");

                if (title.compareTo('null')==0) {
                  return MaterialPageRoute(
                    builder: (context) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: fetchQuizDetails(examId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              height: 200,
                              width: 200,
                              child: CircularProgressIndicator(),
                            ) ;
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            // return ErrorPage(); // Handle error appropriately
                          }

                          final DocumentSnapshot document = snapshot.data!;
                          title = document.get('title');
                          Timestamp toTimestamp = document.get('to');
                          DateTime to = toTimestamp.toDate();
                          dueDate = to.toString();

                          print("duedatemain: $dueDate");
                          print("titlemain: $title");

                          return PgNeetPayment(
                            quizId: examId,
                            title: title,
                            dueDate: dueDate,
                          );
                        },
                      );
                    },
                  );
                }

                return MaterialPageRoute(
                  builder: (context) {
                    return PgNeetPayment(
                      quizId: examId,
                      title: title,
                      dueDate: dueDate,
                    );
                  },
                );
              }
              return null; // Return null for unknown routes, can also return a 404 page here
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
