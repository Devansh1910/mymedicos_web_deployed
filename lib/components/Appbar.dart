import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarContent extends StatelessWidget {
  Future<Map<String, dynamic>> _getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName') ?? 'Default User';
    final userProfileImageUrl = prefs.getString('userProfileImageUrl') ?? '';
    return {'userName': userName, 'userProfileImageUrl': userProfileImageUrl};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final userName = snapshot.data!['userName'];
          final userProfileImageUrl = snapshot.data!['userProfileImageUrl'];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector( // Add GestureDetector to make the image clickable
                onTap: () {
                  Scaffold.of(context).openDrawer(); // Open the drawer when image is tapped
                },
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Material(
                          elevation: 4.0,
                          shape: CircleBorder(),
                          child: CircleAvatar(
                            radius: 20.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        CircleAvatar(
                          radius: 20.0,
                          backgroundColor: Colors.grey.shade200,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: userProfileImageUrl,
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/image/past.png',
                                fit: BoxFit.cover,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning!',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userName,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/image/logo.svg',
                height: 40,
                placeholderBuilder: (BuildContext context) => Container(
                  padding: const EdgeInsets.all(30.0),
                  child: const CircularProgressIndicator(),
                ),
              ),
            ],
          );

        } else {
          return Center(child: Text("No user data found."));
        }
      },
    );
  }
}
