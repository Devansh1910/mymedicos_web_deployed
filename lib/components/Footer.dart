import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
class Footer extends StatelessWidget {
  const Footer({super.key});
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;

    return Container(
      padding: isMobile
          ? const EdgeInsets.all(16.0)
          : const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50),
      color: const Color(0xFFFFF6E5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isMobile ? _buildMobileContent(context) : _buildWebContent(context),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          const SizedBox(height: 16),
          const Text('@2024 Broverg Corporation Pvt Ltd.'),
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
            SvgPicture.asset('assets/landing/logoperfect.svg', height: 50),
            const SizedBox(width: 8),
            const Text(
              'mymedicos',
              style: TextStyle(
                  fontSize: 24,
                  color: Color.fromARGB(255, 55, 55, 55),
                  fontFamily: 'Inter-SemiBold'),
            ),
          ],
        ),

              GestureDetector(
                onTap: () {
                  html.window.open('https://mymedicos.in/about-us/', '_blank');
                  _launchURL('https://mymedicos.in/about-us/'); // Replace with actual URL
                },
                child: const Text(
                  'About us',
                  style: TextStyle(
                    color: Color(0xFF6A6A6A),
                    fontFamily: 'Inter',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  html.window.open('https://mymedicos.in/contactus/', '_blank');
                  _launchURL('https://mymedicos.in/contactus/');  // Replace with actual URL
                },
                child: const Text(
                  'Contact Us',
                  style: TextStyle(
                    color: Color(0xFF6A6A6A),
                    fontFamily: 'Inter',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  html.window.open('https://mymedicos.in/privacy-policy/', '_blank');
                  _launchURL('https://mymedicos.in/privacy-policy/'); // Replace with actual URL
                },
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Color(0xFF6A6A6A),
                    fontFamily: 'Inter',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 5),


        const SizedBox(height: 5),

      ],
    );
  }

  Widget _buildWebContent(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/image/logo.svg', height: 50),
                const SizedBox(width: 8),
                const Text(
                  'mymedicos',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF6A6A6A),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                html.window.open('https://mymedicos.in/about-us/', '_blank');
                _launchURL('https://mymedicos.in/about-us/'); // Replace with actual URL
              },
              child: const Text(
                'About us',
                style: TextStyle(
                  color: Color(0xFF6A6A6A),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                html.window.open('https://mymedicos.in/contactus/', '_blank');
                _launchURL('https://mymedicos.in/contactus/'); // Replace with actual URL
              },
              child: const Text(
                'Contact Us',
                style: TextStyle(
                  color: Color(0xFF6A6A6A),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            GestureDetector(
              onTap: () {
                html.window.open('https://mymedicos.in/privacy-policy/', '_blank');
                _launchURL('https://mymedicos.in/privacy-policy/'); // Replace with actual URL
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Color(0xFF6A6A6A),
                  fontFamily: 'Inter',
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ],
    );
  }
}
