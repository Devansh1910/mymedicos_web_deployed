import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mymedicosweb/footer2.dart';
import 'package:mymedicosweb/login/login_check.dart';
import 'package:mymedicosweb/pg_neet/app_bar_content.dart';
import 'package:mymedicosweb/pg_neet/app_drawer.dart';
import 'package:mymedicosweb/pg_neet/proven_effective_content.dart';
import 'package:mymedicosweb/pg_neet/sideDrawer.dart';
import 'package:flutter_svg/svg.dart';
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() async {
    UserNotifier userNotifier = UserNotifier();
    await userNotifier.isInitialized;
    setState(() {
      _isLoggedIn = userNotifier.isLoggedIn;
      _isInitialized = true;
    });
    // If the user is not logged in, navigate to the login screen
    if (!_isLoggedIn) {
      // You can replace '/login' with the route name of your login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 600;
    UserNotifier userNotifier = UserNotifier();
    bool isLoggedIn = userNotifier.isLoggedIn;



    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If the user is not logged in, return an empty container
    if (!_isLoggedIn) {
      return Container();
    }

    return Scaffold(
      appBar:AppBar(
        automaticallyImplyLeading: false, // Set to true to show the back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (MediaQuery.of(context).size.width <= 600) {
                      Scaffold.of(context).openDrawer();
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage('url_to_user_profile_image'),
                  ),
                ),
                SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning!', // Replace with the actual title
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.0, // Adjust the font size as needed
                        fontWeight: FontWeight.bold, // Adjust the font weight as needed
                      ),
                    ),
                    Text(
                      'UserName', // Replace with the actual subtitle
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.0, // Adjust the font size as needed
                        color: Colors.grey, // Adjust the color as needed
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
        ),
      ),
      drawer: MediaQuery.of(context).size.width <= 600 ? AppDrawer() : null,
      body: Column(
        children: [
          OrangeStrip(
            text: 'Give your learning an extra edge with our premium content, curated exclusively for you!',
          ),
          Expanded(
            child: Row(
              children: [
                if (isLargeScreen) sideDrawer(initialIndex: 3,),
                Expanded(
                  child: SingleChildScrollView(
                    child: MainContent(
                      isLargeScreen: isLargeScreen,




                    ),
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


class MainContent extends StatelessWidget {
  final bool isLargeScreen;

  MainContent({required this.isLargeScreen});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenSize = MediaQuery
        .of(context)
        .size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 16),
          Text('Details', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
          SizedBox(height: 10),
          Text('Go through the details.', style: TextStyle(
              fontSize: 20, color: Colors.grey, fontFamily: 'Inter')),
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150'), // Replace with the actual image URL
                ),
                SizedBox(height: 10),
                Text('Your profile is up to date',
                    style: TextStyle(color: Colors.blue)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Name"),
              _buildStyledTextField('Name','Name'),
              Text("Email ID"),
              _buildStyledTextField('Email ID','Name'),
              Text("Contact Number"),
              _buildStyledTextField('Contact Number','Name'),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Interest"),
                          _buildStyledTextField('Name', 'Speciality'),
                        ],
                      ),
                    ),
                     // Add some space between the columns
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Interes2"),
                          _buildStyledTextField('Email ID', 'SPeciality'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),




              Text("Location"),
              _buildStyledTextField('Location','Name'),
            ],
          ),

          SizedBox(height: 30),
          Text('Med Wallet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
              'Get the coins in your wallet to explore all features of our application with ease.'),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
              border: Border.all(color: Colors.black, width: 1),

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Get Credits', style: TextStyle(fontSize: 16)),
                    Text('5634', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Text(
                    'MedCoin – These Credits could be used for purchasing Premium Exam Sets, Test Cases and Preparation Sets.'),
                SizedBox(height: 20),
                AdWatchButton(coinValue: 10),
                AdWatchButton(coinValue: 20),
              ],
            ),
          ),
          ProvenEffectiveContent(screenWidth: screenWidth),
          Footer2(),

        ],
      ),
    );
  }

  Widget _buildStyledTextField(String labelText, String valueText) {
    return Container(
      width: 600,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          valueText,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }




}
class AdWatchButton extends StatelessWidget {
  final int coinValue;

  AdWatchButton({required this.coinValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
      child: Container(
        height: 70,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1), // Border color and width
          borderRadius: BorderRadius.circular(9.0), // Border radius
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF9F1E7), // Background color
            padding: EdgeInsets.all(15),
            textStyle: TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9.0), // Button radius
            ),
            elevation: 0
          ),
          onPressed: () {
            // Add your ad watching logic here
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Get $coinValue Coins in your MedWallet',style: TextStyle(color:Colors.grey,fontSize:17,fontFamily: 'Inter'),),
                  SizedBox(height: 4),
                  Text(
                    'Watch an Ad and get $coinValue coins instantly in your account.',
                    style: TextStyle(fontSize: 17, color: Colors.grey,fontFamily: 'Inter'),
                  ),
                ],
              ),
              Text('Watch',style: TextStyle(fontFamily: 'Inter'),),
            ],
          ),
        ),
      ),
    );
  }
}

//
// @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: !kIsWeb,
//         title: AppBarContent(),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Center(
//           child: Column(
//             children: [
//               OrangeStrip(
//                 text: 'Give your learning an extra edge with our premium content, curated exclusively for you!',
//               ),
//               SizedBox(height: 32),
//
//               // Profile Picture Section
//               ProfilePictureSection(),
//               SizedBox(height: 32),
//
//
//               // Details Section
//               Container(
//                 width: screenSize.width * 0.7,
//                 child: Card(
//                   elevation: 5,
//                   child: Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Details',
//                           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 8),
//                         Text('Go through the details.'),
//                         SizedBox(height: 16),
//                         TextField(
//                           decoration: InputDecoration(labelText: 'Name'),
//                         ),
//                         TextField(
//                           decoration: InputDecoration(labelText: 'Email ID'),
//                         ),
//                         TextField(
//                           decoration: InputDecoration(labelText: 'Contact Number'),
//                         ),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 decoration: InputDecoration(labelText: 'Interest'),
//                               ),
//                             ),
//                             SizedBox(width: 16),
//                             Expanded(
//                               child: TextField(
//                                 decoration: InputDecoration(labelText: 'Interest'),
//                               ),
//                             ),
//                           ],
//                         ),
//                         TextField(
//                           decoration: InputDecoration(labelText: 'Location'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 32),
//
//               // Med Wallet Section
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }


class ProfilePictureSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with actual image URL
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  // Handle profile image update
                },
                child: Icon(Icons.camera_alt),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Your profile is up-to-date',
          style: TextStyle(color: Colors.blue),
        ),
      ],
    );
  }
}


class CreditCard extends StatelessWidget {
  final String title;
  final String subtitle;

  CreditCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Watch'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrangeStrip extends StatelessWidget {
  final String text;

  const OrangeStrip({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFFF6E5),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter'
                ),
                children: [
                  TextSpan(
                    text: text,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}