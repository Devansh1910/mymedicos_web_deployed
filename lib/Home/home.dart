import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mymedicosweb/Home/components/Recommended.dart';
import 'package:mymedicosweb/Landing/components/HeroImage.dart';

import 'package:mymedicosweb/components/Appbar.dart';
import 'package:mymedicosweb/components/Credit.dart';
import 'package:mymedicosweb/components/Footer.dart';
import 'package:mymedicosweb/components/Sponsor.dart';
import 'package:mymedicosweb/components/drawer/app_drawer.dart';
import 'package:mymedicosweb/components/drawer/sideDrawer.dart';

import 'package:mymedicosweb/login/components/login_check.dart';



class HomeScreen2 extends StatefulWidget {
  @override
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
    await userNotifier.isInitialized;
    setState(() {
      _isLoggedIn = userNotifier.isLoggedIn;
      _isInitialized = true;
    });
    // If the user is not logged in, navigate to the login screen
    if (!_isLoggedIn) {
      // You can replace '/login' with the route name of your login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;


    // If the initialization is not completed yet, show a loading indicator
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If the user is not logged in, return an empty container
    if (!_isLoggedIn) {
      return Container();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLargeScreen = constraints.maxWidth > 600;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: !isLargeScreen,
            title: AppBarContent(),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          drawer: isLargeScreen ? null :  AppDrawer(initialIndex: 0),
          body: Column(
            children: [
              OrangeStrip(
                text: 'Enhance Your NEET PG Preparation with Our Exclusive Premium Content!',
              ),
              Expanded(

                child: Row(

                  children: <Widget>[
                    if (isLargeScreen) SideDrawer(initialIndex: 0),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Big image at the top
                            const TopImage(),
                            RecommendedGrandTest(screenWidth: screenWidth),
                            ProvenEffectiveContent(screenWidth: screenWidth),
                            CreditStrip(),
                            Footer(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OrangeStrip extends StatelessWidget {
  final String text;

  const OrangeStrip({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFFF6E5),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter'
                ),
                children: [
                  TextSpan(
                    text: text,
                    style: TextStyle(
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

