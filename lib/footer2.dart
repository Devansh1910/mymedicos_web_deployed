import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
class Footer2 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 800;

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