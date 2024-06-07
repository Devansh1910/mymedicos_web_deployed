import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mymedicosweb/Usersdetails.dart';
// Import UserDetailsFetcher class

class AppBarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: UserDetailsFetcher().fetchUserDetails(), // Call UserDetailsFetcher to fetch user details
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          final userName = snapshot.data!['userName'];
          final userProfileImageUrl = snapshot.data!['userProfileImageUrl'];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: userProfileImageUrl != null
                        ? NetworkImage(
                      userProfileImageUrl,
                      scale: 2.0, // Adjust the scale if needed
                    )
                        : AssetImage('assets/image/default_profile.png'), // Placeholder image
                    radius: 20.0, // Adjust the size of the CircleAvatar
                    child: userProfileImageUrl == null ? Icon(Icons.person) : null,
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
          return Text("No user data found.");
        }
      },
    );
  }
}
