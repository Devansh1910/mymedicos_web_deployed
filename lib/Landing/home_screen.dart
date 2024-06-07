import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  // Import flutter_svg
import 'package:mymedicosweb/Landing/Alternate_image_text.dart';
import 'package:mymedicosweb/Landing/Footer.dart';
import 'package:mymedicosweb/Landing/home_screen.dart';
import 'package:mymedicosweb/footer2.dart';

import 'package:mymedicosweb/pg_neet/proven_effective_content.dart';
import 'package:mymedicosweb/pg_neet/top_image.dart';
import '../settings_screen.dart';
import '../login/login_screen.dart';
import '../sign_up.dart';  // Import SignUpScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(  // Use SvgPicture.asset to load SVG
                  'assets/image/logo.svg',
                  height: 40,
                  placeholderBuilder: (BuildContext context) => Container(
                    padding: const EdgeInsets.all(30.0),
                    child: const CircularProgressIndicator(),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Mymedicos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF85E8D1), // Custom color
                  ),
                ),
              ],
            ),

              Row(
                children: [
                  ElevatedButton(
                  onPressed: () {
                             Navigator.pushNamed(context, '/login');
                               },
                                 style: ElevatedButton.styleFrom(
                                 backgroundColor: Colors.grey, // background color
                                   shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(8.0), // rounded corners
                               ),

                                                  ),
                                   child: const Text(
                                              'Signup/Login',
                                  style: TextStyle(color: Colors.white,fontFamily: 'Inter'), // text color
                              ),
                                ),
                ],
              ),

          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(

          children: <Widget>[

            OrangeStrip(
              imagePath: 'assets/image/image1.png',
              text: 'Download my medicos *Application* available on PlayStore.',
            ),

           TopImage(),
            Container(
              height:1100, // Set a specific height for the container
              child: AlternatingImageTextList(
                imagePaths: [
                  'assets/image/image1.png',
                  'assets/image/image1.png',
                  'assets/image/image1.png',
                  // Add more image paths as needed
                ],
                titles: [
                  'Title 1',
                  'Title 2',
                  'Title 3',
                  // Add more titles as needed
                ],
                descriptions: [
                  'Description 1',
                  'Description 2',
                  'Description 3',
                  // Add more descriptions as needed
                ],
              ),
            ),


            ProvenEffectiveContent(screenWidth: screenWidth),
            Footer(),
            Footer2(),

              ],
            ),
           ),

    );
  }
}


class OrangeStrip extends StatelessWidget {
  final String imagePath;
  final String text;

  const OrangeStrip({
    required this.imagePath,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> parts = text.split('*');

    return Container(
      color: Color(0xFFFFF6E5),
      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),

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
                    text: parts[0],
                    style: TextStyle(

                      color: Colors.black,
                    ),
                  ),

                  TextSpan(
                    text: parts[1],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: parts[2],
                    style: TextStyle(

                      color: Colors.black,
                    ),
                  ),
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Image.asset(
                        imagePath,
                        height: 20,
                        width: 20,
                      ),
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




