import 'package:flutter/material.dart';

class Newsletter extends StatelessWidget {
  const Newsletter({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine if the device is a mobile (considering less than 600 as mobile)
    final isMobile = screenWidth < 600;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      color: const Color(0xFFFFF6E5),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscribe for Regular Newsletter',
                  style: TextStyle(
                    fontFamily: 'Inter-Semibold',
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your email Id here for getting regular updates and features related to the application firstly.',
                  style: TextStyle(fontSize: 14, fontFamily: 'Inter-Regular'),
                ),
                const SizedBox(height: 20),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter your email ID',
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Inter-Regular',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Handle submit button pressed
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    backgroundColor: const Color(0xFF4F4F4F),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8), // Slightly rounded edges with a radius of 8
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
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
                const SizedBox(width: 80),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
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
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Handle submit button pressed
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          backgroundColor: const Color(0xFF4F4F4F),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Slightly rounded edges with a radius of 8
                          ),
                        ),
                        child: const Text(
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
