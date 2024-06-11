import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TopImage extends StatelessWidget {
  const TopImage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the width of the screen
    double screenWidth = MediaQuery.of(context).size.width;

    String imagePath = 'assets/landing/bkhero.png'; // Default for mobile
    double containerHeight = 300; // Default height for mobile

    // Adjust image path and size for tablet
    if (screenWidth > 600 && screenWidth < 1200) {
      imagePath = 'assets/landing/CRACK.png';
      containerHeight = 250;
    }
    // Adjust image path and size for desktop
    else if (screenWidth >= 1200) {
      imagePath = 'assets/landing/CrackBack.png';
      containerHeight = 400;
    }

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
      ),
      width: double.infinity,
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
      ),
    );
  }
}
