import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mymedicosweb/Profile/Usersdetails.dart';
import 'package:mymedicosweb/login/components/login_check.dart';
import 'package:mymedicosweb/login/sign_up.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLargeScreen = screenSize.width > 800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 234, 251, 249),
        title: Row(
          children: [
            SvgPicture.asset('assets/landing/logoperfect.svg', height: 40),
            const SizedBox(width: 10),
            const Text(
              'mymedicos',
              style: TextStyle(
                fontFamily: 'Poppins-Semibold',
                color: Color.fromARGB(255, 45, 45, 45),
              ),
            ),
          ],
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/image/background.svg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: isLargeScreen ? 1200 : screenSize.width * 0.95),
              child: isLargeScreen
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // const Expanded(
                  //   flex: 1,
                  //   child: CarouselWithCustomText(),
                  // ),
                  const SizedBox(width: 200),
                  Expanded(
                    flex: 1,
                    child: LoginForm(
                        screenSize: screenSize,
                        isLargeScreen: isLargeScreen),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // const CarouselWithCustomText(),
                  const SizedBox(height: 20),
                  LoginForm(
                      screenSize: screenSize,
                      isLargeScreen: isLargeScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//
// class CarouselWithCustomText extends StatefulWidget {
//   const CarouselWithCustomText({super.key});
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _CarouselWithCustomTextState createState() => _CarouselWithCustomTextState();
// }
//
// class _CarouselWithCustomTextState extends State<CarouselWithCustomText> {
//   int _current = 0;
//   final CarouselController _controller = CarouselController();
//
//   final List<Map<String, String>> data = [
//     {
//       'image': 'assets/landing/Feature/1.png',
//       'title': 'Welcome to mymedicos',
//       'text':
//       'Embarking on the PG NEET Journey Strategies, Tools, and Insights for Success with mymedicos',
//     },
//     {
//       "image": "assets/landing/Feature/2.png",
//       "title": "QBank & Test Series",
//       "text": "Authentic pattern with rich explanations."
//     },
//     {
//       'image': 'assets/landing/Feature/3.png',
//       'title': 'Master Every Topic, One Chapter at a Time',
//       'text':
//       'With focused and structured content, you can navigate through your studies efficiently and effectively, building a strong foundation of knowledge step by step.',
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         CarouselSlider(
//           items: data.map((item) {
//             return Column(
//               children: [
//                 Expanded(
//                   child: Image.asset(item['image']!, fit: BoxFit.cover),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     item['title']!,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                         fontFamily: 'Poppins-Semibold',
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     item['text']!,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                         fontFamily: 'Poppins-Semibold',
//                         fontWeight: FontWeight.normal,
//                         fontSize: 16),
//                   ),
//                 ),
//               ],
//             );
//           }).toList(),
//           carouselController: _controller,
//           options: CarouselOptions(
//             autoPlay: true,
//             aspectRatio: 16 / 9,
//             enlargeCenterPage: true,
//             onPageChanged: (index, reason) {
//               setState(() {
//                 _current = index;
//               });
//             },
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: data.asMap().entries.map((entry) {
//             return GestureDetector(
//               onTap: () => _controller.animateToPage(entry.key),
//               child: Container(
//                 width: 20.0, // Increased width for a rectangle shape
//                 height: 12.0, // Keep height as is or adjust to your preference
//                 margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
//                 decoration: BoxDecoration(
//                     color: _current == entry.key
//                         ? const Color.fromARGB(255, 43, 208, 191) // Active color
//                         : Colors.grey, // Inactive color
//                     borderRadius: BorderRadius.circular(4.0) // Rounded edges
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }

class LoginForm extends StatefulWidget {
  final Size screenSize;
  final bool isLargeScreen;

  const LoginForm({
    super.key,
    required this.screenSize,
    required this.isLargeScreen,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool isOtpSent = false;
  bool isLoading = false;
  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < otpControllers.length; i++) {
      otpControllers[i].addListener(() {
        if (otpControllers[i].text.length == 1 && i < otpControllers.length - 1) {
          FocusScope.of(context).requestFocus(otpFocusNodes[i + 1]);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    phoneController.dispose();
    super.dispose();
  }

  void registered() async {
    setState(() {
      isLoading = true;
    });

    String phoneNumber = "+91${phoneController.text}";
    bool isUserRegistered = await checkIfUserRegistered(phoneNumber);
    if (!isUserRegistered) {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
      );
      return;
    } else {
      sendOtp();
    }
  }

  Future<bool> checkIfUserRegistered(String phoneNumber) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('Phone Number', isEqualTo: phoneNumber)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void sendOtp() async {
    String phoneNumber = phoneController.text;

    // Check if the phone number has exactly 10 digits
    if (phoneNumber.length != 10) {
      Fluttertoast.showToast(
        msg: 'The phone number must be exactly 10 digits!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Append country code
    phoneNumber = "+91$phoneNumber";

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        setState(() {
          isLoading = false;
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          isLoading = false;
        });
        if (e.code == 'invalid-phone-number') {
          showError('The phone number entered is invalid!');
        } else {
          showError('Failed to verify phone number. Please try again.');
        }
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          isOtpSent = true;
          isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        setState(() {
          verificationId = verId;
        });
      },
    );
  }

  void fetchUserDetailsAndNavigate(BuildContext context) async {
    final userDetailsFetcher = UserDetailsFetcher();
    try {
      final userDetails = await userDetailsFetcher.fetchUserDetails();

      // Navigate to home screen with user details

    } catch (error) {
      // Handle error
      print("Error fetching user details: $error");
      // Optionally, show a snackbar or dialog to inform the user about the error
    }
  }

  void verifyOtp() async {
    setState(() {
      isLoading = true;
    });

    String otp = otpControllers.map((controller) => controller.text).join();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    try {
      await _auth.signInWithCredential(credential);
      String phoneNumber = "+91${phoneController.text}";
      Provider.of<UserNotifier>(context, listen: false).logIn(phoneNumber);
      fetchUserDetailsAndNavigate(context);

      Navigator.pushNamed(context, '/homescreen');
      print('Phone number verified successfully!');
    } catch (e) {
      print('Failed to verify OTP: $e');
      showError('Failed to verify OTP. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget buildLoadingIndicator() {
    return Container(
      height: 300,
      width: double.infinity,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),

      onKey: (event) {
        if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          if (isOtpSent) {
            verifyOtp();
          } else {
            registered();
          }
        }
      },
      child: Container(
        margin: EdgeInsets.all(widget.isLargeScreen ? 20 : 10),
        padding: EdgeInsets.symmetric(
            vertical: widget.isLargeScreen ? 45 : 10,
            horizontal: widget.isLargeScreen ? 20 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isLoading
            ? buildLoadingIndicator()
            : Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Let\'s get started',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: String.fromEnvironment('Poppins-SemiBold'),
                  ),
                ),
                const SizedBox(height: 5),
                if (!isOtpSent) ...[
                  const Text(
                    'Enter your mobile number to Sign up/Sign in to your mymedicos account',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: String.fromEnvironment('Poppins-Regular'),
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        height: 40, // Adjust the height as needed
                        width: 40, // Adjust the width as needed
                        child: SvgPicture.asset(
                            'assets/login/indiaflag.svg'), // Update with the correct path to your image
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '+91', // Display the country code
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          key: Key('phoneTextField'),
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          // Set keyboard type to number
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, // Only allow digits
                            LengthLimitingTextInputFormatter(10),
                            // Limit to 10 digits
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                            hintText: 'Enter Phone Number',
                            counterText: '', // This hides the counter, which otherwise shows up due to maxLength
                          ),
                          autofocus: true, // Automatically focuses and opens keyboard when the screen loads
                        ),
                      ),

                    ],
                  ),
                ] else ...[
                  const Text(
                    'Enter the 6-digit OTP sent to your phone',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 40,
                        child: TextField(
                          focusNode: otpFocusNodes[index],
                          controller: otpControllers[index],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                        ),
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 20),
                Center(
                  child: OutlinedButton(
                    onPressed: isOtpSent ? verifyOtp : registered,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      minimumSize: const Size(double.infinity, 50), // Ensures the button takes the full width
                      padding: const EdgeInsets.symmetric(vertical: 8), // Sets the vertical padding
                    ),
                    child: Text(
                      isOtpSent ? 'Verify' : 'Continue',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontFamily: 'Inter-SemiBold',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
