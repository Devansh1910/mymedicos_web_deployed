import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymedicosweb/login/login_check.dart';
import 'package:mymedicosweb/login/sign_up.dart';
import 'package:provider/provider.dart';
// import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
// import 'package:carousel_slider/carousel_controller.dart' as carousel_slider_controller;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLargeScreen = screenSize.width > 800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            SvgPicture.asset('assets/image/logo.svg', height: 40),
            const SizedBox(width: 10),
            Text(
              'mymedicos',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: Colors.grey,
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
              constraints: BoxConstraints(maxWidth: isLargeScreen ? 1200 : screenSize.width * 0.95),
              child: isLargeScreen
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Expanded(
                  //   flex: 1,
                  //   // child: CarouselWithCustomText(),
                  // ),
                  const SizedBox(width: 200),
                  Expanded(
                    flex: 1,
                    child: LoginForm(screenSize: screenSize, isLargeScreen: isLargeScreen),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // CarouselWithCustomText(),
                  const SizedBox(height: 20),
                  LoginForm(screenSize: screenSize, isLargeScreen: isLargeScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final Size screenSize;
  final bool isLargeScreen;

  LoginForm({
    Key? key,
    required this.screenSize,
    required this.isLargeScreen,
  }) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool isOtpSent = false;
  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';
  UserNotifier userNotifier = UserNotifier();

  Future<bool> checkIfUserRegistered(String phoneNumber) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('Phone Number', isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking user registration: $e');
      return false;
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void sendOtp() async {
    String phoneNumber = "+91" + phoneController.text;

    bool isUserRegistered = await checkIfUserRegistered(phoneNumber);
    if (!isUserRegistered) {
      Navigator.pushNamed(context, '/register');
      return;
    }

    if (isUserRegistered) {
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            print('Failed to verify phone number: ${e.message}');
            print('Error code: ${e.code}');
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
            });
          },
          codeAutoRetrievalTimeout: (String verId) {
            setState(() {
              verificationId = verId;
            });
          },
        );

        setState(() {
          isOtpSent = true;
        });
      } catch (e) {
        print('Error during phone number verification: $e');
        if (e is PlatformException) {
          print('PlatformException details: ${e.details}');
        } else if (e is FirebaseAuthException) {
          print('FirebaseAuthException message: ${e.message}');
        } else {
          print('Unexpected error type: ${e.runtimeType}');
        }
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignUpScreen()),
      );
    }
  }

  void registered() async {
    String phoneNumber = "+91" + phoneController.text;

    bool isUserRegistered = await checkIfUserRegistered(phoneNumber);
    if (!isUserRegistered) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignUpScreen()),
      );
      return;
    } else {
      sendOtp();
    }
  }

  void verifyOtp() async {
    String otp = otpControllers.map((controller) => controller.text).join();
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    try {
      await _auth.signInWithCredential(credential);
      String phoneNumber = "+91" + phoneController.text;
      Provider.of<UserNotifier>(context, listen: false).logIn(phoneNumber);

      Navigator.pushNamed(context, '/homescreen');
      print('Phone number verified successfully!');
    } catch (e) {
      print('Failed to verify OTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(widget.isLargeScreen ? 20 : 10),
      padding: EdgeInsets.symmetric(vertical: widget.isLargeScreen ? 45 : 10, horizontal: widget.isLargeScreen ? 20 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Let\'s get started',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (!isOtpSent) ...[
            const Text(
              'Enter your mobile number to Sign up/Sign in to your account',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CountryCodeDropdown(),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Phone Number',
                    ),
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
                    controller: otpControllers[index],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: isOtpSent ? verifyOtp : registered,
              child: Text(
                isOtpSent ? 'Verify' : 'Continue',
                style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: widget.screenSize.width > 800 ? 80 : 50,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
           Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  "Don't have an account? Register",
                  style: TextStyle(
                    color: Colors.blue,
                    fontFamily: 'Inter',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),
          const Text(
            'By signing up, you agree to Terms & Conditions and Privacy Policy',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

//
// class CarouselWithCustomText extends StatefulWidget {
//   @override
//   _CarouselWithCustomTextState createState() => _CarouselWithCustomTextState();
// }
//
// class _CarouselWithCustomTextState extends State<CarouselWithCustomText> {
//   int _current = 0;
//   final carousel_slider_controller.CarouselController _controller = carousel_slider_controller.CarouselController();
//
//   final List<String> captions = [
//     'Embarking on the PG NEET Journey',
//     'Strategies, Tools, and Insights for Success with mymedicos',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         carousel_slider.CarouselSlider(
//           items: captions.map((caption) {
//             return Center(
//               child: Text(
//                 caption,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'Inter'),
//               ),
//             );
//           }).toList(),
//           carouselController: _controller,
//           options: carousel_slider.CarouselOptions(
//             autoPlay: true,
//             aspectRatio: 16 / 9,
//             enlargeCenterPage: true,
//             height: 200,
//             onPageChanged: (index, reason) {
//               setState(() {
//                 _current = index;
//               });
//             },
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: captions.asMap().entries.map((entry) {
//             return GestureDetector(
//               onTap: () => _controller.animateToPage(entry.key),
//               child: Container(
//                 width: 12.0,
//                 height: 12.0,
//                 margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _current == entry.key
//                       ? Color.fromRGBO(0, 0, 0, 0.9)
//                       : Color.fromRGBO(0, 0, 0, 0.4),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }

class CountryCodeDropdown extends StatefulWidget {
  @override
  _CountryCodeDropdownState createState() => _CountryCodeDropdownState();
}

class _CountryCodeDropdownState extends State<CountryCodeDropdown> {
  String currentCode = '+91';
  final List<CountryCode> codes = [
    CountryCode(code: '+1', flagUri: 'assets/image/flag1.svg'),
    CountryCode(code: '+91', flagUri: 'assets/image/flag2.svg'),
    CountryCode(code: '+44', flagUri: 'assets/image/flag3.svg'),
    CountryCode(code: '+81', flagUri: 'assets/image/flag4.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: currentCode,
      icon: const Icon(Icons.arrow_drop_down),
      underline: Container(
        height: 1,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          currentCode = newValue!;
        });
      },
      items: codes.map<DropdownMenuItem<String>>((CountryCode code) {
        return DropdownMenuItem<String>(
          value: code.code,
          child: Row(
            children: [
              code.flagUri.endsWith('.svg')
                  ? SvgPicture.asset(code.flagUri, width: 20, height: 12)
                  : Image.asset(code.flagUri, width: 20, height: 12),
              const SizedBox(width: 8),
              Text(code.code),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class CountryCode {
  final String code;
  final String flagUri;

  CountryCode({required this.code, required this.flagUri});
}
