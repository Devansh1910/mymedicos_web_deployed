import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
class TopImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
     
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      width: double.infinity,
      child:SvgPicture.asset(
        'assets/image/Frame 160.png',
        fit:BoxFit.cover,

      ),
      // Image.asset(
      //   'assets/image/Frame 160.png',
      //   fit: BoxFit.cover,
      // ),
    );
  }
}
