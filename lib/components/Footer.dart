import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

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
        const SizedBox(height: 16),
        const Text('About us',
            style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
        const SizedBox(height: 10),
        const Text('Contact Us',
            style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
        const SizedBox(height: 30),
        const Text('Privacy Policy',
            style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
        const SizedBox(height: 5),
        const Text('Terms & Conditions',
            style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
        const SizedBox(height: 5),
        const Text('FAQ\'s',
            style: TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
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
                const SizedBox(width: 8),
                const Text(
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
            const SizedBox(height: 16),
            const Text('About us',
                style:
                    TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
            const SizedBox(height: 10),
            const Text('Contact Us',
                style:
                    TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
            const SizedBox(height: 30),
          ],
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60),
            Text('Privacy Policy',
                style:
                    TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
            SizedBox(height: 5),
            Text('Terms & Conditions',
                style:
                    TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
            SizedBox(height: 5),
            Text('FAQ\'s',
                style:
                    TextStyle(color: Color(0XFF6A6A6A), fontFamily: 'Inter')),
            SizedBox(height: 30),
          ],
        ),
      ],
    );
  }
}
