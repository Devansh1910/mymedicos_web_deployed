import 'dart:async';
import 'dart:io';
import 'dart:html' as html;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymedicosweb/Profile/Usersdetails.dart';
import 'package:mymedicosweb/components/Appbar.dart';
import 'package:mymedicosweb/components/Footer.dart';
import 'package:mymedicosweb/components/drawer/app_drawer.dart';
import 'package:mymedicosweb/components/drawer/sideDrawer.dart';
// ignore: unused_import
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Import your UserDetailsFetcher class

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// Import your UserDetailsFetcher class

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
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

      ),

      body: Column(
        children: [
          const OrangeStrip(
            text: 'Supercharge Your NEET PG Prep with Exclusive, Curated Content',
          ),
          Expanded(
            child: Row(
              children: [
                if (isLargeScreen) SideDrawer(initialIndex: 3,),
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


  const MainContent({super.key, required this.isLargeScreen, required this.userDetails});

  @override
  // ignore: library_private_types_in_public_api
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {

  late String userId;
  String? userProfileImageUrl;
  int currentCoins = 0;
  late DatabaseReference databaseReference;
  bool _isLoading = true;
  User? currentUser;



  @override
  void initState() {
    super.initState();



    fetchUserProfileImageVerified();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchCurrentUserCoins();
      } else {
        fetchPhoneNumberFromLocalStorage();
      }
    });

  }


  Future<void> fetchPhoneNumberFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneNumber = prefs.getString('phoneNumber');
    if (phoneNumber != null) {
      fetchCoinsFromDatabase(phoneNumber);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void fetchCurrentUserCoins() {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String? phoneNumber = currentUser!.phoneNumber;
      if (phoneNumber != null) {

        fetchCoinsFromDatabase(phoneNumber);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print("Current user is null");
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<String?> fetchUserProfileImageVerified() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userProfileImageUrl = prefs.getString('userProfileImageUrl');

      if (userProfileImageUrl == null) {
        // Create a completer to manage the future
        final Completer<String?> completer = Completer<String?>();

        // Check if the value is set periodically
        final int checkIntervalMilliseconds = 100;
        Timer? timer;

        // Define a function to check if the value is set
        void checkIfValueSet() {
          final String? updatedUrl = prefs.getString('userProfileImageUrl');
          if (updatedUrl != null) {
            completer.complete(updatedUrl);
            timer?.cancel(); // Cancel the timer once the value is set
          }
        }

        // Start checking periodically
        timer = Timer.periodic(Duration(milliseconds: checkIntervalMilliseconds), (_) {
          checkIfValueSet();
        });

        // Return the future
        return completer.future;
      } else {
        return userProfileImageUrl;
      }
    } catch (error) {
      print("Error fetching profile image URL from SharedPreferences: $error");
      return null;
    }
  }




  // Future<void> fetchUserProfileImageVerified( ) async {
  //   SharedPreferences prefs =  await SharedPreferences.getInstance();
  //  userId = prefs.getString('phoneNumber')!;
  //   FirebaseStorage storage = FirebaseStorage.instance;
  //   Reference storageRef = storage.ref().child("users").child(userId).child("profile_image.jpg");
  //   try {
  //     String downloadUrl = await storageRef.getDownloadURL();
  //     setState(() {
  //       userProfileImageUrl = downloadUrl;
  //     });
  //   } catch (exception) {
  //     print("Error fetching profile image: ${exception.toString()}");
  //   }
  // }
  Future<Uint8List> _loadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }


  Future<void> uploadProfileImage(BuildContext context, bool isLargeScreen) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('phoneNumber') ?? '';
    print("UserID: $userId");

    try {
      Uint8List? pickedFileBytes;
      File? pickedFile;

      if (isLargeScreen) {
        // Web specific code
        print("Running on large screen");
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
          pickedFileBytes = reader.result as Uint8List;
          print("File selected on web: ${file.name}");
        }
      } else {
        // Mobile specific code
        print("Running on mobile");
        final picker = ImagePicker();
        final xFile = await picker.pickImage(source: ImageSource.gallery);
        if (xFile != null) {
          pickedFile = File(xFile.path);
          print("File selected on mobile: ${xFile.name}");
        }
      }

      if (pickedFile != null || pickedFileBytes != null) {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference storageRef = storage.ref().child("users").child(userId).child("profile_image.jpg");

        UploadTask uploadTask;
        if (pickedFile != null) {
          // For mobile
          uploadTask = storageRef.putFile(
            pickedFile,
            SettableMetadata(contentType: 'image/jpeg'), // Set content type to image/jpeg
          );
        } else {
          // For web
          uploadTask = storageRef.putData(
            pickedFileBytes!,
            SettableMetadata(contentType: 'image/jpeg'), // Set content type to image/jpeg
          );
        }

        // Show a progress dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Uploading..."),
                ],
              ),
            );
          },
        );

        uploadTask.whenComplete(() async {
          Navigator.pop(context); // Close the progress dialog
          String imageUrl = await storageRef.getDownloadURL();
          // Save the image URL to the user's profile
          // Assuming you have a user reference (e.g., FirebaseDatabase reference)
          // userRef.child("profileImage").setValue(imageUrl);
          await fetchUserProfileImageVerified();

          // Show a toast message for successful upload
          Fluttertoast.showToast(
            msg: "Profile image uploaded successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          // Update the avatar image view (assuming you have a stateful widget to handle this)
          // final bitmap = await _loadImage(imageUrl);
          // setState(() {
          //   avatarImageView = Image.memory(bitmap);
          // });
        }).catchError((error) {
          Navigator.pop(context); // Close the progress dialog
          print("Error uploading profile image: $error");
          Fluttertoast.showToast(
            msg: "Error uploading profile image: $error",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        });
      } else {
        throw Exception("No file selected");
      }
    } catch (error) {
      print("Error uploading profile image: $error");
      Fluttertoast.showToast(
        msg: "Error uploading profile image: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  void fetchCoinsFromDatabase(String phoneNumber) {
    databaseReference = FirebaseDatabase.instance.reference();

    // Retrieve coins
    databaseReference.child('profiles').child(phoneNumber).child('coins').onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      int? coinsValue = snapshot.value as int?;
      setState(() {
        currentCoins = coinsValue ?? 0;
        _isLoading = false;
      });
    });

    // Update phone number
    databaseReference.child('profiles').child(phoneNumber).child('phoneNumber').set(phoneNumber).then((_) {
      print('Phone number updated successfully');
    }).catchError((error) {
      print('Error updating phone number: $error');
    });
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left) of the column
            children: [
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.only(left: 16), // Add left padding
                child: Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              SizedBox(height: 2),
              Padding(
                padding: EdgeInsets.only(left: 16), // Add left padding
                child: Text(
                  'Go through the details.',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),

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
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[


                    Text('Get Credits', style: TextStyle(fontSize: 16)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/profile'); // Navigate to the profile page
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: screenWidth < 600 ? 5 : 10,
                            horizontal: screenWidth < 600 ? 20 : 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Text(
                          '$currentCoins',
                          style: TextStyle(
                            fontSize: screenWidth < 600 ? 12 : 18,
                            color: Colors.grey,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),

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
            const Material(
              elevation: 4.0, // Adjust the elevation as needed
              shape: CircleBorder(),
              child: CircleAvatar(
                radius: 20.0, // Adjust the size of the CircleAvatar
                backgroundColor: Colors.transparent, // Make the CircleAvatar's background transparent
              ),
            ),
            FutureBuilder<String?>(
              future: fetchUserProfileImageVerified(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  print("image url 2:"+snapshot.data!);
                  final imageUrl = snapshot.data!;
                  return _buildCircleAvatar(
                    imageUrl: imageUrl,
                    radius: 80.0,
                    onTap: () async {
                      print("upload image");
                      await uploadProfileImage(context, isLargeScreen);
                    },
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCircleAvatar({required String imageUrl, required double radius, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade200,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(
                  Icons.person, // Use the error icon
                  color: Colors.grey,
                  size: 80,// Customize the color if needed
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                Icons.upload_outlined,
                color: Colors.blue,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }



  // Widget _buildCircleAvatar({required String imageUrl, required double radius, required Function() onTap}) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Stack(
  //       children: [
  //         CircleAvatar(
  //           radius: radius,
  //           backgroundColor: Colors.grey.shade200,
  //           child: ClipOval(
  //             child: CachedNetworkImage(
  //               imageUrl: imageUrl,
  //               placeholder: (context, url) => CircularProgressIndicator(),
  //               errorWidget: (context, url, error) => Icon(
  //                 Icons.error, // Use the error icon
  //                 color: Colors.red, // Customize the color if needed
  //               ),
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //         ),
  //         Align(
  //           alignment: Alignment.bottomRight,
  //           child: Container(
  //             margin: EdgeInsets.all(4),
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               color: Colors.white,
  //             ),
  //             child: Icon(
  //               Icons.upload_outlined,
  //               color: Colors.blue,
  //               size: 24,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }






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
      adUnitId: "ca-app-pub-1452770494559845/5321727710",
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

  const AdWatchButton({super.key, required this.coinValue});

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

  const ProvenEffectiveContent({super.key, required this.screenWidth});



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

        print("Status Code: ${response.statusCode}");
        print("Headers: ${response.headers}");
        print("API Response: ${response.body}");

        if (response.statusCode == 200) {
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
              SnackBar(content: Text("Failed order: ${requestBody["message"]}")),
            );
          }
        } else {
          // Handle non-200 response codes
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response.statusCode} ${response.reasonPhrase}")),
          );
        }
      } catch (e) {
        // Dismiss the loading indicator
        Navigator.of(context, rootNavigator: true).pop();
        print("Error making HTTP request: $e");
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

  const PaymentPublicationActivity({required this.orderCode});

  @override
  Widget build(BuildContext context) {
    Uri apiUrl = Uri.parse(
        "https://admin.mymedicos.in/api/ecom/medcoins/checkout/$orderCode");

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Publication Activity'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showPaymentDialog(context, apiUrl),
          child: Text('Open Payment Page'),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, Uri url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pay Now'),
          content: Text('Your order ID is $orderCode'),
          actions: <Widget>[
            TextButton(
              child: Text('Return to Profile'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ElevatedButton(
              child: Text('Pay'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _processPayment(url, context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _processPayment(Uri url, BuildContext context) async {
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Handle successful response
        final responseData = json.decode(response.body);
        // Process the response data as needed
        // Example: Navigate to a success page
        Navigator.pushNamed(context, '/payment-success');
      } else {
        // Handle error response
        _showErrorDialog(context, 'Payment failed. Please try again.');
      }
    } catch (e) {
      _showErrorDialog(context, 'An error occurred. Please try again.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
  const ProfilePictureSection({super.key});

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

  const CreditCard({super.key, required this.title, required this.subtitle});

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

  const OrangeStrip({super.key,
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