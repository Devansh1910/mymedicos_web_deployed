import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg
import 'package:mymedicosweb/Landing/components/GridImagenText.dart';
import 'package:mymedicosweb/components/Newsletter.dart';
import 'package:mymedicosweb/components/Footer.dart';
import 'package:mymedicosweb/Landing/components/proven_effective_content.dart';
import 'package:mymedicosweb/Landing/components/HeroImage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../settings_screen.dart';
import '../../login/sign_up.dart';

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
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/landing/logoperfect.svg',
                  height: 40,
                  placeholderBuilder: (BuildContext context) => Container(
                    padding: const EdgeInsets.all(30.0),
                    child: const CircularProgressIndicator(),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'mymedicos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF85E8D1),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white, // text color
                    side: const BorderSide(
                        color: Color.fromARGB(255, 36, 36, 36),
                        width: 1), // border color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    // Add margin to the right
                  ),
                  child:  Center(
                    child: GestureDetector(
                      onTap: () {
                        _launchURL("https://mymedicos.in/contactus/"); // Function to launch URL
                      },
                      child: Text(
                        'Contact us',
                        style: TextStyle(
                          fontFamily: 'Inter', // text style
                          fontSize: 18,
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Space between buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
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
            const OrangeStrip(
              imagePath: 'assets/landing/playstore1.png',
              text: 'Download mymedicos *Application* available on PlayStore.',
            ),
            const TopImage(),
            const SizedBox(
              height: 1100,
              child: AlternatingImageTextList(
                imagePaths: [
                  'assets/landing/top.png',
                  'assets/landing/mid.png',
                  'assets/landing/mid2.png',
                  // Add more image paths as needed
                ],
                titles: [
                  'Prepare for success​',
                  'Master Every Topic, One Chapter at a Time',
                  'Each day, challenge yourself',
                  // Add more titles as needed
                ],
                descriptions: [
                  'Welcome to a community that understands your journey and is dedicated to helping you thrive in the world of medical postgraduate education!',
                  'With focused and structured content, you can navigate through your studies efficiently and effectively, building a strong foundation of knowledge step by step.',
                  'Whether youre preparing for an exam or just looking to test your knowledge, our daily quizzes provide a consistent and effective method to track your progress and keep learning exciting.',
                  // Add more descriptions as needed
                ],
              ),
            ),
            ProvenEffectiveContent(screenWidth: screenWidth),
            const Newsletter(),
            const Footer(),
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
    super.key,
    required this.imagePath,
    required this.text,

  });
  Future<void> _launchURL() async {
    final Uri uri = Uri.parse("https://play.google.com/store/search?q=mymedicos&c=apps&hl=en");
    if (!await launchUrl(uri)) {
      throw 'Could not launch ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> parts = text.split('*');

    return GestureDetector(
      onTap: _launchURL,
      child: Container(
        color: const Color(0xFFFFF6E5),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                  children: [
                    TextSpan(
                      text: parts[0],
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: parts[1],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: parts[2],
                      style: const TextStyle(
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
      ),
    );
  }
}
