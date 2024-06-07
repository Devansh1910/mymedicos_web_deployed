import 'package:flutter/material.dart';

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
