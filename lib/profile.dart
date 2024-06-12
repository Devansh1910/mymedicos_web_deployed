import 'dart:io';
import 'dart:html' as html;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymedicosweb/Usersdetails.dart';
import 'package:mymedicosweb/components/Footer.dart';
import 'package:mymedicosweb/login/login_check.dart';
import 'package:mymedicosweb/pg_neet/app_bar_content.dart';
import 'package:mymedicosweb/pg_neet/app_drawer.dart';
import 'package:mymedicosweb/Landing/components/proven_effective_content.dart';
import 'package:mymedicosweb/pg_neet/sideDrawer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mymedicosweb/components/Footer.dart';
import 'package:mymedicosweb/login/login_check.dart';
import 'package:mymedicosweb/pg_neet/app_bar_content.dart';
import 'package:mymedicosweb/pg_neet/app_drawer.dart';
import 'package:mymedicosweb/Landing/components/proven_effective_content.dart';
import 'package:mymedicosweb/pg_neet/sideDrawer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mymedicosweb/components/Footer.dart';
import 'package:mymedicosweb/login/login_check.dart';
import 'package:mymedicosweb/pg_neet/app_bar_content.dart';
import 'package:mymedicosweb/pg_neet/app_drawer.dart';

import 'package:mymedicosweb/pg_neet/sideDrawer.dart';
import 'package:flutter_svg/svg.dart';
// Import your UserDetailsFetcher class

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mymedicosweb/components/Footer.dart';
import 'package:mymedicosweb/login/login_check.dart';
import 'package:mymedicosweb/pg_neet/app_bar_content.dart';
import 'package:mymedicosweb/pg_neet/app_drawer.dart';
import 'package:mymedicosweb/Landing/components/proven_effective_content.dart';
import 'package:mymedicosweb/pg_neet/sideDrawer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import your UserDetailsFetcher class

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  late Map<String, dynamic> _userDetails;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() async {
    UserDetailsFetcher userFetcher = UserDetailsFetcher();
    try {
      final userDetails = await userFetcher.fetchUserDetails();
      setState(() {
        _userDetails = userDetails;
        _isLoggedIn = true;
        _isInitialized = true;
      });
    } catch (error) {
      print("Error initializing user: $error");
      setState(() {
        _isLoggedIn = false;
        _isInitialized = true;
      });
      // Handle error or navigate to login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 600;

    if (!_isInitialized) {
      return const Scaffold(
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
      appBar: AppBar(
        automaticallyImplyLeading: !kIsWeb,
        title: AppBarContent(),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: isLargeScreen ? null : IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer(); // Open the drawer when the menu icon is pressed
          },
        ),
      ),
      drawer: MediaQuery.of(context).size.width <= 600 ?   AppDrawer(initialIndex: 0) : null,
      body: Column(
        children: [
          const OrangeStrip(
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
                      userDetails: _userDetails ?? {}, // Add a null check here
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


class MainContent extends StatefulWidget {
  final bool isLargeScreen;
  final Map<String, dynamic> userDetails;


  MainContent({required this.isLargeScreen, required this.userDetails});

  @override
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {

  late String userId;
  String? userProfileImageUrl;

  @override
  void initState() {
    super.initState();



      fetchUserProfileImageVerified();

  }

  Future<void> fetchUserProfileImageVerified( ) async {
    SharedPreferences prefs =  await SharedPreferences.getInstance();
   userId = prefs.getString('phoneNumber')!;
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageRef = storage.ref().child("users").child(userId).child("profile_image.jpg");
    try {
      String downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        userProfileImageUrl = downloadUrl;
      });
    } catch (exception) {
      print("Error fetching profile image: ${exception.toString()}");
    }
  }

  Future<void> uploadProfileImage(bool isLargeScreen) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('phoneNumber') ?? '';
    print("userid 0" + userId);

    try {
      File? pickedFile;

      if (isLargeScreen) {
        // Web specific code
        final input = html.FileUploadInputElement();
        input.accept = 'image/*';
        input.click();
        await input.onChange.first;
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          await reader.onLoad.first;
          final buffer = reader.result as Uint8List;
          final blob = html.Blob([buffer]);
          pickedFile = File(html.Url.createObjectUrlFromBlob(blob));
        }
      } else {
        // Mobile specific code
        final picker = ImagePicker();
        final xFile = await picker.pickImage(source: ImageSource.gallery);
        pickedFile = xFile != null ? File(xFile.path) : null;
      }

      if (pickedFile != null) {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference storageRef = storage.ref().child("users").child(userId).child("profile_image.jpg");
        await storageRef.putFile(pickedFile);
        await fetchUserProfileImageVerified();

        // Show a toast message for successful upload
        Fluttertoast.showToast(
          msg: "Profile image uploaded successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (error) {
      print("Error uploading profile image: $error");
      Fluttertoast.showToast(
        msg: "Error uploading profile image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }







  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileView = screenWidth < 600; // Example breakpoint for mobile view

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isLargeScreen ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 16),
          const Text('Details', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
          const SizedBox(height: 10),
          const Text('Go through the details.', style: TextStyle(
              fontSize: 20, color: Colors.grey, fontFamily: 'Inter')),
          const SizedBox(height: 20),
          isMobileView
              ? Column(
            children: [
              _buildProfileImage(),
              const SizedBox(height: 20),
              _buildStyledTextField('Name', widget.userDetails["userName"] ?? 'Default Name'),
              const SizedBox(height: 10),
              _buildStyledTextField('Email ID', widget.userDetails["userEmail"] ?? 'example@example.com'),
              const SizedBox(height: 10),
              _buildStyledTextField('Contact Number', widget.userDetails["Phone Number"] ?? '000-000-0000'),
              const SizedBox(height: 10),
            ],
          )
              : Row(
            children: [
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Name"),
                    const SizedBox(height: 10),
                    _buildStyledTextField('Name', widget.userDetails["userName"] ?? 'Default Name'),
                    const SizedBox(height: 10),
                    const Text("Email ID"),
                    const SizedBox(height: 10),
                    _buildStyledTextField('Email ID', widget.userDetails["userEmail"] ?? 'example@example.com'),
                    const SizedBox(height: 10),
                    const Text("Contact Number"),
                    const SizedBox(height: 10),
                    _buildStyledTextField('Contact Number', widget.userDetails["Phone Number"] ?? '000-000-0000'),
                  ],
                ),
              ),
              const SizedBox(width: 200),
              _buildProfileImage(),
              const SizedBox(width: 200),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Interest"),
                    _buildStyledTextField('Interest', widget.userDetails["userInterest"] ?? 'Default Interest'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Location"),
                    _buildStyledTextField('Location', widget.userDetails["userLocation"] ?? 'Default Location'),
                  ],
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            'Med Wallet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Get the coins in your wallet to explore all features of our application with ease.',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Get Credits', style: TextStyle(fontSize: 16)),
                    Text('5634', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const Text(
                    'MedCoin – These Credits could be used for purchasing Premium Exam Sets, Test Cases and Preparation Sets.'),
                const SizedBox(height: 20),
                AdWatchButton(coinValue: 10),
                AdWatchButton(coinValue: 20),
              ],
            ),
          ),
          ProvenEffectiveContent(screenWidth: screenWidth),
          const Footer(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Material(
              elevation: 4.0, // Adjust the elevation as needed
              shape: CircleBorder(),
              child: CircleAvatar(
                radius: 20.0, // Adjust the size of the CircleAvatar
                backgroundColor: Colors.transparent, // Make the CircleAvatar's background transparent
              ),
            ),
            CircleAvatar(
              radius: 80.0, // Adjust the size of the CircleAvatar
              backgroundColor: Colors.grey.shade200, // Placeholder background color
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: userProfileImageUrl ?? 'https://via.placeholder.com/150',
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/image/default_profile.png',
                    fit: BoxFit.cover,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async{
            print("upload image");
            await uploadProfileImage(isLargeScreen);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.camera_alt),
              SizedBox(width: 5),
              Text("Upload Avatar"),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildStyledTextField(String labelText, String? valueText) {
    return Container(
      width: double.infinity, // Make it full-width
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          valueText ?? 'No data available',
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}

class AdManager {
  static RewardedAd? _rewardedAd;

  static void loadAd() {
    RewardedAd.load(
      adUnitId: "ca-app-pub-1452770494559845/3094113721",
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          print('Ad failed to load: $error');
          // Handle ad loading failure
        },
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          print('Ad loaded successfully');
          // Handle ad loading success
        },
      ),
    );
  }

  static RewardedAd? get rewardedAd => _rewardedAd;
}

class AdWatchButton extends StatelessWidget {
  final int coinValue;

  AdWatchButton({required this.coinValue});

  void watchAd(BuildContext context) {
    RewardedAd? ad = AdManager.rewardedAd;
    if (ad != null) {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) {
          print('Ad showed fullscreen content');
          // Ad showed fullscreen content.
        },
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          print('Ad dismissed fullscreen content');
          // Ad dismissed fullscreen content.
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          print('Failed to show fullscreen ad: $error');
          // Ad failed to show fullscreen content.
        },
      );

      ad.show(
        onUserEarnedReward: (Ad ad, RewardItem reward) {
          print('User earned reward: ${reward.amount}');
          // User earned reward, update coins accordingly
          updateCoinsAndDatabase(reward.amount);
        },
      );
    } else {
      print('Rewarded ad is null');
      // Ad not loaded, handle accordingly
    }
  }

  void updateCoinsAndDatabase(num rewardAmount) {
    // Update coins in your database and do any other necessary operations
    num totalCoins = coinValue + rewardAmount;
    print("Total coins after watching ad: $totalCoins");
    // Update database here
  }

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
              backgroundColor: const Color(0xFFF9F1E7), // Background color
              padding: const EdgeInsets.all(15),
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.0), // Button radius
              ),
              elevation: 0
          ),
          onPressed: () {
            print("button preseed");
            // Call the watchAd function when the button is pressed
            watchAd(context);

          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Get $coinValue Coins in your MedWallet',style: const TextStyle(color:Colors.grey,fontSize:17,fontFamily: 'Inter'),),
                  const SizedBox(height: 4),
                  Text(
                    'Watch an Ad and get $coinValue coins instantly in your account.',
                    style: const TextStyle(fontSize: 17, color: Colors.grey,fontFamily: 'Inter'),
                  ),
                ],
              ),
              const Text('Watch',style: TextStyle(fontFamily: 'Inter'),),
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


class ProvenEffectiveContent extends StatelessWidget {
  final double screenWidth;

  ProvenEffectiveContent({required this.screenWidth});



  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth,
      decoration: const BoxDecoration(
        color: Color(0xFFEAFBF9),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proven Effective Content',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          const Text(
            'Concise, high yield, highly effective content that yields results. The strike rate proves it.',
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children:  [
                    FeatureCard(
                      imagePath: 'assets/top_quality_content.png',
                      title: 'Top Quality Content',
                      description: 'Enrich your knowledge with highly informative, engaging content crafted by the Dream Team.',
                      onTap: () =>  processCreditsOrderPackage1(context),
                    ),
                    FeatureCard(
                      imagePath: 'assets/learn_anytime_anywhere.png',
                      title: 'Learn Anytime, Anywhere',
                      description: 'Access the best quality content and turn any place into a classroom whenever you want.',
                      onTap: () => processCreditsOrderPackage2(context),
                    ),
                    FeatureCard(
                      imagePath: 'assets/in_depth_analytics.png',
                      title: 'In-Depth Analytics',
                      description: 'Evaluate your strengths and shortcomings with the help of performance graphs.',
                      onTap: () =>  processCreditsOrderPackage3(context),
                    ),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children:  [
                      FeatureCard(
                        imagePath: 'assets/top_quality_content.png',
                        title: 'Top Quality Content',
                        description: 'Enrich your knowledge with highly informative, engaging content crafted by the Dream Team.',
                        onTap: () => processCreditsOrderPackage1(context),
                      ),
                      FeatureCard(
                        imagePath: 'assets/learn_anytime_anywhere.png',
                        title: 'Learn Anytime, Anywhere',
                        description: 'Access the best quality content and turn any place into a classroom whenever you want.',
                        onTap: () =>  processCreditsOrderPackage2(context),
                      ),
                      FeatureCard(
                        imagePath: 'assets/in_depth_analytics.png',
                        title: 'In-Depth Analytics',
                        description: 'Evaluate your strengths and shortcomings with the help of performance graphs.',
                        onTap: () =>  processCreditsOrderPackage3(context),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }


}

Future<void> processCreditsOrderPackage1(BuildContext context) async {
  // Show a loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing order..."),
            ],
          ),
        ),
      );
    },
  );

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    String userId = currentUser.phoneNumber ?? "";

    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference usersRef = db.collection("users");

    QuerySnapshot querySnapshot = await usersRef.where("Phone Number", isEqualTo: userId).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot document = querySnapshot.docs.first;

      String url = "https://admin.mymedicos.in/api/ecom/medcoins/generateOrder/$userId/package1";
      print("API Request URL: $url");

      try {
        http.Response response = await http.get(Uri.parse(url));
        print("API Response: ${response.body}");

        var requestBody = json.decode(response.body);
        if (requestBody["status"] == "success") {
          String orderNumber = requestBody["order_id"];
          print("Order ID check: $orderNumber");

          // Dismiss the loading indicator
          Navigator.of(context, rootNavigator: true).pop();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Order Successful"),
                content: Text("Your order number is: $orderNumber"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Pay Now"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to the payment screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPublicationActivity(orderCode: orderNumber),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // Dismiss the loading indicator
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed order.")),
          );
        }
      } catch (e) {
        // Dismiss the loading indicator
        Navigator.of(context, rootNavigator: true).pop();
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } else {
      // Dismiss the loading indicator
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to retrieve user information")),
      );
    }
  } else {
    // Dismiss the loading indicator
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not authenticated")),
    );
  }
}

Future<void> processCreditsOrderPackage2(BuildContext context) async {
  // Show a loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing order..."),
            ],
          ),
        ),
      );
    },
  );

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    String userId = currentUser.phoneNumber ?? "";

    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference usersRef = db.collection("users");

    QuerySnapshot querySnapshot = await usersRef.where("Phone Number", isEqualTo: userId).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot document = querySnapshot.docs.first;

      String url = "https://admin.mymedicos.in/api/ecom/medcoins/generateOrder/$userId/package2";
      print("API Request URL: $url");

      try {
        http.Response response = await http.get(Uri.parse(url));
        print("API Response: ${response.body}");

        var requestBody = json.decode(response.body);
        if (requestBody["status"] == "success") {
          String orderNumber = requestBody["order_id"];
          print("Order ID check: $orderNumber");

          // Dismiss the loading indicator
          Navigator.of(context, rootNavigator: true).pop();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Order Successful"),
                content: Text("Your order number is: $orderNumber"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Pay Now"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to the payment screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPublicationActivity(orderCode: orderNumber),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // Dismiss the loading indicator
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed order.")),
          );
        }
      } catch (e) {
        // Dismiss the loading indicator
        Navigator.of(context, rootNavigator: true).pop();
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } else {
      // Dismiss the loading indicator
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to retrieve user information")),
      );
    }
  } else {
    // Dismiss the loading indicator
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not authenticated")),
    );
  }
}

Future<void> processCreditsOrderPackage3(BuildContext context) async {
  // Show a loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing order..."),
            ],
          ),
        ),
      );
    },
  );

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    String userId = currentUser.phoneNumber ?? "";

    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference usersRef = db.collection("users");

    QuerySnapshot querySnapshot = await usersRef.where("Phone Number", isEqualTo: userId).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot document = querySnapshot.docs.first;

      String url = "https://admin.mymedicos.in/api/ecom/medcoins/generateOrder/$userId/package3";
      print("API Request URL: $url");

      try {
        http.Response response = await http.get(Uri.parse(url));
        print("API Response: ${response.body}");

        var requestBody = json.decode(response.body);
        if (requestBody["status"] == "success") {
          String orderNumber = requestBody["order_id"];
          print("Order ID check: $orderNumber");

          // Dismiss the loading indicator
          Navigator.of(context, rootNavigator: true).pop();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Order Successful"),
                content: Text("Your order number is: $orderNumber"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Pay Now"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to the payment screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPublicationActivity(orderCode: orderNumber),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // Dismiss the loading indicator
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed order.")),
          );
        }
      } catch (e) {
        // Dismiss the loading indicator
        Navigator.of(context, rootNavigator: true).pop();
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } else {
      // Dismiss the loading indicator
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to retrieve user information")),
      );
    }
  } else {
    // Dismiss the loading indicator
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not authenticated")),
    );
  }
}
class PaymentPublicationActivity extends StatelessWidget {
  final String orderCode;

  const PaymentPublicationActivity({Key? key, required this.orderCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
      ),
      body: Center(
        child: Text("Order Code: $orderCode"),
      ),
    );
  }
}


class FeatureCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback onTap;

  const FeatureCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final double cardWidth = isMobile ? screenWidth * 0.9 : screenWidth / 3 - 24;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: isMobile ? 0 : 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9, // Adjust the aspect ratio as needed
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCardList extends StatelessWidget {
  final List<FeatureCard> cards;

  const FeatureCardList({
    Key? key,
    required this.cards,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 30, vertical: 20),
      child: isMobile
          ? Column(
        children: cards,
      )
          : Wrap(
        spacing: 12,
        runSpacing: 12,
        children: cards,
      ),
    );
  }
}
class ProfilePictureSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            const CircleAvatar(
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
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
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
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Watch'),
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
      color: const Color(0xFFFFF6E5),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter'
                ),
                children: [
                  TextSpan(
                    text: text,
                    style: const TextStyle(
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