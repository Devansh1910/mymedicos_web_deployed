import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mymedicosweb/Home/components/Recommended.dart';
import 'package:mymedicosweb/Landing/components/HeroImage.dart';
import 'package:mymedicosweb/Profile/Usersdetails.dart';

import 'package:mymedicosweb/components/Appbar.dart';
import 'package:mymedicosweb/components/Credit.dart';
import 'package:mymedicosweb/components/Footer.dart';
import 'package:mymedicosweb/components/Sponsor.dart';
import 'package:mymedicosweb/components/drawer/app_drawer.dart';
import 'package:mymedicosweb/components/drawer/sideDrawer.dart';

import 'package:mymedicosweb/login/components/login_check.dart';
import 'package:shared_preferences/shared_preferences.dart';



class HomeScreen2 extends StatefulWidget {
  @override
  _HomeScreen2State createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }
  void logOut() async {
    _isLoggedIn = false;
    _phoneNumber = null;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('phoneNumber');
    } catch (e) {
      // Handle any errors that occur while clearing login status
      print('Failed to clear login status: $e');
    }
  // Notify listeners after logging out
  }


  void _initializeUser() async {
    try {
      UserNotifier userNotifier = UserNotifier();
      await userNotifier.isInitialized;

      setState(() {
        _isLoggedIn = userNotifier.isLoggedIn;
        _isInitialized = true;
      });

      if (_isLoggedIn) {
        // Fetch user details including profile image URL
        UserDetailsFetcher userDetailsFetcher = UserDetailsFetcher();
        Map<String, dynamic> userDetails = await userDetailsFetcher.fetchUserDetails();

        // Extract user details
        String userName = userDetails['userName'];
        String userProfileImageUrl = userDetails['userProfileImageUrl'];

        // Store the user information in local storage using SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userName', userName);
        prefs.setString('userProfileImageUrl', userProfileImageUrl);
      } else {
        // If the user is not logged in, navigate to the login screen
        // Replace '/login' with your actual login screen route name
        context.go('/login');
      }
    } catch (error) {
      print("Error initializing user: $error");
      // Handle error here (e.g., show error message, navigate to an error screen)
      // Example:
      // Navigator.of(context).pushReplacementNamed('/error');
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

    return WillPopScope(
      onWillPop: () async {
        // Show alert dialog when user tries to leave the page
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Are you sure?"),
              content: Text("Do you want to leave the site?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    logOut();
                    // Navigate to the home screen when user confirms
                    context.go('/');
                  },
                  child: Text("Logout"),
                ),
                TextButton(
                  onPressed: () {
                    // Dismiss the dialog when user cancels
                    Navigator.of(context).pop(false);
                  },
                  child: Text("Cancel"),
                ),
              ],
            );
          },
        );
        // Return false to prevent the default back navigation behavior
        return false;
      },
    child:
      LayoutBuilder(
      builder: (context, constraints) {
        final bool isLargeScreen = constraints.maxWidth > 600;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: !isLargeScreen,
            title: AppBarContent(),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          drawer: isLargeScreen?null: AppDrawer(initialIndex: 0,),

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
      ),
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

