import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mymedicosweb/login/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String name = '';
  String phoneNumber = '';
  String location = '';
  String? interest;
  String? interest2;
  String? prefix; // Allow prefix to be null initially
  String fcmToken = '';
  bool isMCNVerified = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final List<String> welcomeMessages = [
    "Welcome! Ready to join us?",
    "Hello! Let's get you started.",
    "Hi there! Sign up to get the best experience.",
    "Greetings! Fill in your details to continue.",
    "Welcome aboard! Let's make your journey awesome.",
  ];
  final List<String> specialities = [
    "Select Speciality",
    "Internal Medicine",
    "Pediatrics",
    "Surgery",
    "Obstetrics and Gynecology",
    "Anesthesiology",
    "Psychiatry",
    "Radiology",
    "Emergency Medicine",
    "Dermatology",
    "Family Medicine",
    "Ophthalmology",
    "Pathology",
    "Physical Medicine and Rehabilitation",
    "Infectious Disease",
    "Allergy and Immunology",
    "Pulmonology",
    "Nuclear Medicine",
    "Otolaryngology (ENT)",
    "Preventive Medicine",
    "Microbiology",
    "Pharmacology",
    "Forensic Medicine",
    "Physiology",
    "Anatomy",
    "Biochemistry",
    "Duty Doctor",
  ];

  final List<String> subspecialities = [
    "Speciality2",
    "Cardiology",
    "Gastroenterology (M)",
    "Nephrology",
    "Pulmonology",
    "Rheumatology",
    "Endocrinology",
    "Hematology",
    "Sleep Medicine",
    "Neurology",
    "Hepatology",
    "Neonatology",
    "Pediatric Cardiology",
    "Pediatric Gastroenterology",
    "Pediatric Nephrology",
    "Pediatric Pulmonology",
    "Pediatric Rheumatology",
    "Pediatric Endocrinology",
    "Pediatric Hemato-Oncology",
    "Cardiothoracic Surgery",
    "Neurosurgery",
    "Transplant Surgery",
    "Pediatric Surgery",
    "Plastic Surgery",
    "Urology",
    "Vascular Surgery",
    "Gastroenterology (S)",
    "Oncosurgery",
    "Maternal-Fetal Medicine",
    "Gynecologic Oncology",
    "Reproductive Endocrinology and Infertility",
    "Pain Medicine",
    "Critical Care Medicine",
    "Child and Adolescent Psychiatry",
    "Geriatric Psychiatry",
    "Neuro Radiology",
    "Interventional Radiology",
    "Sports Medicine",
    "Hand Surgery",
    "Clinical Hematology",
    "Histopathology",
    "Forensic Pathology",
    "Transfusion Medicine",
    "Clinical Pharmacology",
    // Add other subspecialities here
  ];


  int _currentMessageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startWelcomeMessageRotation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startWelcomeMessageRotation() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _currentMessageIndex =
            (_currentMessageIndex + 1) % welcomeMessages.length;
      });
    });
  }
  bool isValidEmail(String email) {
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  bool isValidPhoneNumber(String phoneNumber) {
    String pattern = r'^[0-9]{10}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(phoneNumber);
  }


  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (!isValidEmail(email)) {
        _showToast('Please enter a valid email address.');
        return;
      }
      if (!isValidPhoneNumber(phoneNumber)) {
        _showToast('Please enter a valid phone number.');
        return;
      }
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: "user_password", // You should get this from a TextFormField
        );

        User? user = userCredential.user;
        if (user != null) {
          user.sendEmailVerification();

          await _firestore.collection('users').add({
            'Email ID': email,
            'Name': name,
            'Phone Number': phoneNumber,
            'Location': location,
            'Interest': interest,
            'Interest2': interest2,
            'Prefix': prefix,
            'MCN verified': false,
            'FCM Token': fcmToken,
            'QuizToday': "",
            'MedCoins': 0,
            'Streak': 0,
          }).then((docRef) async {
            await _firestore.collection('users').doc(docRef.id).update({'DocID': docRef.id});
          });

          Fluttertoast.showToast(msg: "Registration successful! Please verify your email.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

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
            const Text(
              'Mymedicos',
              style: TextStyle(
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
              constraints: BoxConstraints(
                maxWidth: isLargeScreen ? 1200 : screenSize.width * 0.95,
              ),
              child: isLargeScreen
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 200),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: _buildSignUpForm(screenSize, isLargeScreen),
                    ),
                  ),
                ],
              )
                  : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    _buildSignUpForm(screenSize, isLargeScreen),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(Size screenSize, bool isLargeScreen) {
    return Container(
      margin: EdgeInsets.all(isLargeScreen ? 20 : 10),
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 20 : 10,
        horizontal: isLargeScreen ? 20 : 10,
      ),
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Account',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Please fill the following details!',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Prefix',
              value: prefix,
              items: ['Hr.', 'Nr.', 'Dr.'],
              onChanged: (newValue) {
                setState(() {
                  prefix = newValue;
                });
              },
            ),
            _buildTextField(
              label: 'Name',
              icon: Icons.person,
              validator: (value) =>
              value!.isEmpty ? 'Please enter your name' : null,
              onSaved: (value) => name = value!,
            ),
            _buildTextField(
              label: 'Email ID',
              icon: Icons.email,
              validator: (value) =>
              value!.isEmpty ? 'Please enter an email address' : null,
              onSaved: (value) => email = value!,
            ),

            _buildPhoneNumberField(
              label: 'Phone Number',
              icon: Icons.phone,
              validator: (value) =>
              value!.isEmpty ? 'Please enter your phone number' : null,
              onSaved: (value) => phoneNumber = value!,
            ),

            _buildDropdownField(
              label: 'Speciality',
              value: interest,
              items: specialities,
              onChanged: (value) {
                setState(() {
                  interest = value;
                });
              },
            ),
            _buildDropdownField(
              label: 'Speciality2',
              value: interest2,
              items: subspecialities,
              onChanged: (value) {
                setState(() {
                  interest2 = value;
                });
              },
            ),
            _buildTextField(
              label: 'Location',
              icon: Icons.location_on,
              onSaved: (value) => location = value!,
              validator: (value) => null,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _register();

                  // Process data or navigate to another screen
                } else {
                  _showToast('Please fill in all required fields.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF68B1D0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FormFieldValidator<String> validator,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildPhoneNumberField({
    required String label,
    required IconData icon,
    required FormFieldValidator<String> validator,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.list),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) =>
        value == null ? 'Please select an option' : null,
        onSaved: (value) {
          if (label == 'Speciality') {
            interest = value;
          } else if (label == 'Speciality2') {
            interest2 = value;
          } else if (label == 'Prefix') {
            prefix = value;
          }
        },
      ),
    );
  }
}
