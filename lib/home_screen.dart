import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  // Import flutter_svg
import 'settings_screen.dart';
import 'login_screen.dart';
import 'sign_up.dart';  // Import SignUpScreen

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
        backgroundColor: Colors.grey[400],
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
            if (!isMobile)
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      print("Navigate to FMGE details or functionalities");
                    },
                    child: Text('FMGE', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      print("Navigate to NEET PG details or functionalities");
                    },
                    child: Text('NEET PG', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: _navigateToSignUp,
                    child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Login', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: _navigateToSettings,
            ),
          ],
        ),
      ),
      drawer: isMobile
          ? Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('FMGE'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('NEETPG'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Sign Up'),
              onTap: _navigateToSignUp,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      )
          : null,
      body: SingleChildScrollView(
        child: Column(

          children: <Widget>[

            OrangeStrip(
              imagePath: 'assets/image/image1.png',
              text: 'Download my medicos *Application* available on PlayStore.',
            ),

            CarouselSlider(
              options: CarouselOptions(
                height:450.0,
                autoPlay: true,

              ),
              items: [1, 2, 3, 4, 5].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,

                      decoration: BoxDecoration(
                        color: Colors.amber,
                      ),
                      child: Center(
                        child: Text(
                          'Image $i',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
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


            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEAFBF9), // Set the background color to green
              ),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    'Proven Effective Content',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Concise, high yield, highly effective content that yields results. The strike rate proves it.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        // Mobile layout
                        return Column(
                          children: const [
                            FeatureCard(
                              imagePath: 'assets/top_quality_content.png',
                              title: 'Top Quality Content',
                              description: 'Enrich your knowledge with highly informative, engaging content crafted by the Dream Team.',
                            ),
                            FeatureCard(
                              imagePath: 'assets/learn_anytime_anywhere.png',
                              title: 'Learn Anytime, Anywhere',
                              description: 'Access the best quality content and turn any place into a classroom whenever you want.',
                            ),
                            FeatureCard(
                              imagePath: 'assets/in_depth_analytics.png',
                              title: 'In-Depth Analytics',
                              description: 'Evaluate your strengths and shortcomings with the help of performance graphs.',
                            ),
                          ],
                        );
                      } else {
                        // Web layout
                        return Wrap(

                          spacing: 16.0,
                          runSpacing: 16.0,
                          children: const [
                            FeatureCard(
                              imagePath: 'assets/top_quality_content.png',
                              title: 'Top Quality Content',
                              description: 'Enrich your knowledge with highly informative, engaging content crafted by the Dream Team.',
                            ),
                            FeatureCard(
                              imagePath: 'assets/learn_anytime_anywhere.png',
                              title: 'Learn Anytime, Anywhere',
                              description: 'Access the best quality content and turn any place into a classroom whenever you want.',
                            ),
                            FeatureCard(
                              imagePath: 'assets/in_depth_analytics.png',
                              title: 'In-Depth Analytics',
                              description: 'Evaluate your strengths and shortcomings with the help of performance graphs.',
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Footer(),
            Footer2(),

              ],
            ),
           ),

    );
  }
}

class FeatureCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const FeatureCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
  }) : super(key: key);

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
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
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
    Key? key,
    required this.cards,
  }) : super(key: key);

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



class AlternatingImageTextList extends StatelessWidget {
  final List<String> imagePaths;
  final List<String> titles;
  final List<String> descriptions;

  const AlternatingImageTextList({
    Key? key,
    required this.imagePaths,
    required this.titles,
    required this.descriptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // Define mobile threshold

    return Container(
      width: isMobile ? screenWidth : screenWidth * 0.6, // Adjust width based on screen size
      child: ListView.builder(
        itemCount: titles.length,
        itemBuilder: (context, index) {
          final isEvenIndex = index.isEven;

          if (isMobile) {
            // Mobile layout: stack image and text vertically
            return Container(
              margin: EdgeInsets.symmetric(vertical: 20), // Add margin for spacing
              padding: EdgeInsets.all(16), // Adjust padding for card height
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),

              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      imagePaths[index],
                      fit: BoxFit.cover,
                      height: 200, // Fixed height for image
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    titles[index],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(descriptions[index]),
                ],
              ),
            );
          } else {
            // Desktop/tablet layout: alternate image and text horizontally
            return Container(
              margin: EdgeInsets.symmetric(vertical: 20), // Add margin for spacing
              padding: EdgeInsets.all(16), // Adjust padding for card height
              height: 300, // Adjust height of the container
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),

              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEvenIndex)
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imagePaths[index],
                          fit: BoxFit.cover,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                        ),
                      ),
                    ),
                  if (isEvenIndex) SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titles[index],
                          style: TextStyle(fontWeight: isEvenIndex ? FontWeight.bold : FontWeight.normal),
                        ),
                        SizedBox(height: 16),
                        Text(
                          descriptions[index],
                          style: TextStyle(fontWeight: isEvenIndex ? FontWeight.normal : FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (!isEvenIndex) SizedBox(width: 16),
                  if (!isEvenIndex)
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imagePaths[index],
                          fit: BoxFit.cover,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine if the device is a mobile (considering less than 600 as mobile)
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      color: Color(0xFFFFF6E5),
      child: isMobile
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscribe for Regular Newsletter',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enter your email Id here for getting regular updates and features related to the application firstly.',
            style: TextStyle(fontSize: 16, fontFamily: 'Inter'),
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: 'Enter your email ID',
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
              labelStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'Inter',
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Handle submit button pressed
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              backgroundColor: Color(0xFF4F4F4F),
              textStyle: TextStyle(
                fontFamily: 'Inter',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Slightly rounded edges with a radius of 8
              ),
            ),
            child: Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscribe for Regular Newsletter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Enter your email Id here for getting regular updates and features related to the application firstly.',
                  style: TextStyle(fontSize: 16, fontFamily: 'Inter'),
                ),
              ],
            ),
          ),
          SizedBox(width: 80),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 700, // Adjust width as needed
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Enter your email ID',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Handle submit button pressed
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    backgroundColor: Color(0xFF4F4F4F),
                    textStyle: TextStyle(
                      fontFamily: 'Inter',
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Slightly rounded edges with a radius of 8
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Footer2 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Container(
      padding: isMobile ? EdgeInsets.all(16.0) : EdgeInsets.symmetric(vertical: 16.0, horizontal: 50),
      color: Color(0xFFF6EAD6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isMobile ? _buildMobileContent(context) : _buildWebContent(context),
          SizedBox(height: 16),
          Divider(color: Colors.grey),
          SizedBox(height: 16),
          Text('@2024 Broverg Corporation Pvt. Ltd.'),
        ],
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset('assets/image/logo.svg', height: 50),
            SizedBox(width: 8),
            Text(
              'mymedicos',
              style: TextStyle(
                fontSize: 24,
                color: Color(0XFF6A6A6A),
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text('About us', style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
        SizedBox(height: 10),
        Text('Contact Us', style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
        SizedBox(height: 30),
        Text('Privacy Policy', style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
        SizedBox(height: 5),
        Text('Terms & Conditions', style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
        SizedBox(height: 5),
        Text('FAQ\'s', style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
        SizedBox(height: 30),
        Text(
          'Download Application',
          style: TextStyle(fontFamily: 'Inter', color: Color(0XFF6A6A6A), fontSize: 24),
        ),
        SizedBox(height: 8),
        Text(
          'Enter your phone number to get the download link of our mobile app.',
          style: TextStyle(fontFamily: 'Inter', color: Color(0XFF6A6A6A)),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(),
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[200],
                    child: Image.asset('assets/indian_flag_icon.png'),
                  ),
                  Text('+91', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Container(
                    width: 150,
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter the Phone number',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Send link',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebContent(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/image/logo.svg', height: 50),
                SizedBox(width: 8),
                Text(
                  'mymedicos',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0XFF6A6A6A),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('About us', style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
            SizedBox(height: 10),
            Text('Contact Us', style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
            SizedBox(height: 30),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60),
            Text('Privacy Policy', style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
            SizedBox(height: 5),
            Text('Terms & Conditions', style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
            SizedBox(height: 5),
            Text('FAQ\'s', style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
            SizedBox(height: 30),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(0),
                      color: Colors.grey,
                      width: 1,
                      height: 150,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download Application',
                        style: TextStyle(fontFamily: 'Inter', color: Color(0XFF6A6A6A), fontSize: 24),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: screenWidth * 0.4, // Adjust the width as needed
                        child: Text(
                          'Enter your phone number to get the download link of our mobile app.',
                          style: TextStyle(fontFamily: 'Inter', color: Color(0XFF6A6A6A), fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.005),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[200],
                                  child: Image.asset('assets/indian_flag_icon.png'),
                                ),
                                Text('+91', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 8),
                                Container(
                                  width: screenWidth * 0.3, // Adjust the width as needed
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter the Phone number',
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Send link',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


              ],
            ),
          ],
        ),
      ],
    );
  }
}
