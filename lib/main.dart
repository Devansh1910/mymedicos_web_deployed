import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mymedicosweb/FMGE/FmgeResultScreen.dart';
import 'package:mymedicosweb/FMGE/Fmgepaymentscreen.dart';
import 'package:mymedicosweb/FMGE/Fmgequizscreen.dart';
import 'package:mymedicosweb/FMGE/fmge.dart';
import 'package:mymedicosweb/login/components/login_check.dart';
import 'package:mymedicosweb/pg_neet/QuizScreen.dart';
import 'package:mymedicosweb/pg_neet/ResultScreen.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';

import 'models/theme_notifier.dart';
import 'models/locale_notifier.dart';
 // Assuming you have a UserNotifier model
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
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    // Optionally report errors to a monitoring service
  };

  setPathUrlStrategy();
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

  @override
  Widget build(BuildContext context) {
    final UserNotifier userNotifier = Provider.of<UserNotifier>(context, listen: false);
    final bool loggedIn = userNotifier.isLoggedIn;
    final GoRouter router = GoRouter(
      initialLocation: !loggedIn?'/':'/homescreen',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(title: 'Mymedicos'),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/homescreen',
          builder: (context, state) => HomeScreen2(),
        ),
        GoRoute(
          path: '/fmge',
          builder: (context, state) => Fmge(),
        ),
        GoRoute(
          path: '/pgneet',
          builder: (context, state) => PgNeet(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/fmge/examdetails',
          builder: (context, state) {
            final examId = state.uri.queryParameters['examId']!;
            final extra = state.extra as Map<String, dynamic>?;
            final title = extra?['title'] ?? 'null';
            final dueDate = extra?['dueDate'] ?? '2024-06-21 00:00:00.000';

            if (title == 'null') {
              return FutureBuilder<DocumentSnapshot>(
                future: fetchQuizDetails(examId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Scaffold(
                      body: Center(
                        child: Text('Error loading quiz details'),
                      ),
                    );
                  }

                  final document = snapshot.data!;
                  final quizTitle = document.get('title');
                  final Timestamp toTimestamp = document.get('to');
                  final dueDate = toTimestamp.toDate().toString();

                  return Fmgepaymentscreen(
                    quizId: examId,
                    title: quizTitle,
                    dueDate: dueDate,
                  );
                },
              );
            }

            return Fmgepaymentscreen(
              quizId: examId,
              title: title,
              dueDate: dueDate,
            );
          },
        ),
        GoRoute(
          path: '/examdetails',
          builder: (context, state) {
            final examId = state.uri.queryParameters['examId']!;
            final extra = state.extra as Map<String, dynamic>?;
            final title = extra?['title'] ?? 'null';
            final dueDate = extra?['dueDate'] ?? '2024-06-21 00:00:00.000';

            if (title == 'null') {
              return FutureBuilder<DocumentSnapshot>(
                future: fetchQuizDetails(examId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Scaffold(
                      body: Center(
                        child: Text('Error loading quiz details'),
                      ),
                    );
                  }

                  final document = snapshot.data!;
                  final quizTitle = document.get('title');
                  final Timestamp toTimestamp = document.get('to');
                  final dueDate = toTimestamp.toDate().toString();

                  return PgNeetPayment(
                    quizId: examId,
                    title: quizTitle,
                    dueDate: dueDate,
                  );
                },
              );
            }

            return PgNeetPayment(
              quizId: examId,
              title: title,
              dueDate: dueDate,
            );
          },
        ),
              GoRoute(
            path: '/examdetails/examscreen',
           builder: (context, state) {

           final extra = state.extra as Map<String, dynamic>?;
           final examId = extra?['quizId']!;
           final title = extra?['title'];
           final dueDate = extra?['dueDate'];
            final discount = extra?['discount'];

            return QuizPage(
             quizId: examId,
            title: title,
           duedate: dueDate,
             discount: discount,
            );
              },
           ),
        GoRoute(
          path: '/fmge/examdetails/examscreen',
          builder: (context, state) {

            final extra = state.extra as Map<String, dynamic>?;
            final examId = extra?['quizId']!;
            final title = extra?['title'];
            final dueDate = extra?['dueDate'];
            final discount = extra?['discount'];

            return FmgeQuizPage(
              quizId: examId,
              title: title,
              duedate: dueDate,
              discount: discount,
            );
          },
        ),
        GoRoute(
          path: '/fmge/examdetails/examscreen/resultscreen',
          builder: (context, state) {

            final extra = state.extra as Map<String, dynamic>?;
            final examId = extra?['quizId']!;
            final title = extra?['quizTitle'];
            final dueDate = extra?['dueDate'];
            final remainingTime = extra?['remainingTime'];
            final selectedAnswers = extra?['selectedAnswers'];
            final questions = extra?['questions'];

            return FmgeQuizResultScreen(
              quizId: examId,
              quizTitle: title,
              dueDate: dueDate,
              remainingTime: remainingTime,
              selectedAnswers:selectedAnswers,
              questions:questions,
            );
          },
        ),
        GoRoute(
          path: '/examdetails/examscreen/resultscreen',
          builder: (context, state) {

            final extra = state.extra as Map<String, dynamic>?;
            final examId = extra?['quizId']!;
            final title = extra?['quizTitle'];
            final dueDate = extra?['dueDate'];
            final remainingTime = extra?['remainingTime'];
            final selectedAnswers = extra?['selectedAnswers'];
            final questions = extra?['questions'];

            return QuizResultScreen(
              quizId: examId,
              quizTitle: title,
              dueDate: dueDate,
              remainingTime: remainingTime,
                selectedAnswers:selectedAnswers,
                questions:questions,
            );
          },
        ),

      ],
      redirect: (context, state) {
        final UserNotifier userNotifier = Provider.of<UserNotifier>(context, listen: false);
        final bool loggedIn = userNotifier.isLoggedIn;
        final bool loggingIn = state.uri.toString() == '/login';

        // If the user is not logged in and tries to access a protected route, redirect to login
        if (!loggedIn && !loggingIn) return '/login';

        // If the user is logged in and tries to access the login or register page, redirect to home
        if (loggedIn && (state.uri.toString() == '/login' || state.uri.toString() == '/register')) return '/';

        return null;
      },
      errorBuilder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Page not found'),
        ),
      ),
    );

    return Consumer3<ThemeNotifier, LocaleNotifier, UserNotifier>(
      builder: (context, themeNotifier, localeNotifier, userNotifier, child) {
        if (!userNotifier.isInitialized) {
          return const LoadingScreen(); // Show loading screen while initializing
        }

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: themeNotifier.currentTheme,
          locale: localeNotifier.currentLocale,
          routerConfig: router,
        );
      },
    );
  }

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
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
