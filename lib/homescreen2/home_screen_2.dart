import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mymedicosweb/components/Footer.dart';
import 'package:mymedicosweb/homescreen2/Recommended.dart';
import 'package:mymedicosweb/login/login_check.dart';
import 'package:mymedicosweb/pg_neet/app_bar_content.dart';

import 'package:mymedicosweb/pg_neet/app_drawer.dart';
import 'package:mymedicosweb/Landing/components/proven_effective_content.dart';
import 'package:mymedicosweb/pg_neet/sideDrawer.dart';
import 'package:mymedicosweb/pg_neet/credit.dart';


class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreen2State createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() async {
    UserNotifier userNotifier = UserNotifier();
    // ignore: await_only_futures
    await userNotifier.isInitialized;
    setState(() {
      _isLoggedIn = userNotifier.isLoggedIn;
      _isInitialized = true;
    });
    // If the user is not logged in, navigate to the login screen
    if (!_isLoggedIn) {
      // You can replace '/login' with the route name of your login screen
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 600;

    // If the initialization is not completed yet, show a loading indicator
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If the user is not logged in, return an empty container
    if (!_isLoggedIn) {
      return Container();
    }
    // UserNotifier userNotifier=UserNotifier();
    // bool isLoggedIn = userNotifier.isLoggedIn;
    //
    // // If the user is not logged in, navigate to the login screen
    // if (!isLoggedIn) {
    //   // You can replace '/login' with the route name of your login screen
    //   Navigator.of(context).pushReplacementNamed('/login');
    //   return Container(); // Return an empty container while navigating
    // }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !kIsWeb,
        title: AppBarContent(),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      drawer: isLargeScreen ? null : AppDrawer(),
      body: Column(
        children: [
          const OrangeStrip(
            text: 'Give your learning an extra edge with our premium content, curated exclusively for you!',
          ),
          Expanded(
            child:Row(
            children: <Widget>[
              if (isLargeScreen) sideDrawer(initialIndex: 0),
              Expanded(
                child: SingleChildScrollView(

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      // Big image at the top
                      Container(

                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        width: double.infinity,
                        child: Image.asset(
                          'assets/image/Frame 160.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      RecommendedGrandTest(screenWidth: screenWidth),
                      ProvenEffectiveContent(screenWidth: screenWidth),
                      CreditStrip(),

                        const Footer(),

                    ],
                  ),
                ),
              ),
            ],
          ), ),

        ],
      ),
    );
  }
}

class OrangeStrip extends StatelessWidget {
  final String text;

  const OrangeStrip({super.key, 
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF6E5),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter'
                ),
                children: [
                  TextSpan(
                    text: text,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final double cardWidth = isMobile ? screenWidth * 0.9 : screenWidth / 3 - 24;

    return Container(
      width: cardWidth,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: isMobile ? 0 : 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9, // Adjust the aspect ratio as needed
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FeatureCardList extends StatelessWidget {
  final List<FeatureCard> cards;

  const FeatureCardList({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 30, vertical: 20),
      child: isMobile
          ? Column(
        children: cards,
      )
          : Wrap(
        spacing: 12,
        runSpacing: 12,
        children: cards,
      ),
    );
  }
}