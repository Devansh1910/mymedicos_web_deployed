import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String name = '';
  String phoneNumber = '';
  String location = '';
  String interest = '';
  String interest2 = '';
  String? prefix; // Allow prefix to be null initially
  String fcmToken = '';
  bool isMCNVerified = false;

  final List<String> welcomeMessages = [
    "Welcome! Ready to join us?",
    "Hello! Let's get you started.",
    "Hi there! Sign up to get the best experience.",
    "Greetings! Fill in your details to continue.",
    "Welcome aboard! Let's make your journey awesome.",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/image/logo.svg',
              height: 40,
              placeholderBuilder: (BuildContext context) => Container(
                padding: const EdgeInsets.all(30.0),
                child: const CircularProgressIndicator(),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Mymedicos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF85E8D1),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[200],
      ),
      body: Container(
        color: Colors.grey[400],
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: double.infinity,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          aspectRatio: 1.0,
                          autoPlayInterval: const Duration(seconds: 3),
                        ),
                        items: [
                          'assets/image1.jpg',
                          'assets/image2.jpg',
                          'assets/image3.jpg'
                        ].map((item) => Container(
                          child: Center(
                            child: Image.asset(item, fit: BoxFit.cover, width: 1000),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey[400], // Right-side specific background
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[

                                Card(
                                  elevation: 4.0,
                                  margin: const EdgeInsets.only(right: 16.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(

                                      children: [
                                        Center(
                                          child: Text(
                                            welcomeMessages[_currentMessageIndex],
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color:Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        _buildTextField(
                                          label: 'Email ID',
                                          icon: Icons.email,
                                          validator: (value) => value!.isEmpty ? 'Please enter an email address' : null,
                                          onSaved: (value) => email = value!,
                                        ),
                                        _buildTextField(
                                          label: 'Name',
                                          icon: Icons.person,
                                          validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                                          onSaved: (value) => name = value!,
                                        ),
                                        _buildTextField(
                                          label: 'Phone Number',
                                          icon: Icons.phone,
                                          validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                                          onSaved: (value) => phoneNumber = value!,
                                        ),
                                        _buildTextField(
                                          label: 'Location',
                                          icon: Icons.location_on,
                                          onSaved: (value) => location = value!,
                                          validator: (value) => null,
                                        ),
                                        _buildTextField(
                                          label: 'Interest',
                                          icon: Icons.star,
                                          onSaved: (value) => interest = value!,
                                          validator: (value) => null,
                                        ),
                                        _buildTextField(
                                          label: "Interest2",
                                          icon: Icons.star_border,
                                          onSaved: (value) => interest2 = value!,
                                          validator: (value) => null,
                                        ),
                                        DropdownButtonFormField<String>(
                                          value: prefix,
                                          onChanged: (newValue) {
                                            setState(() {
                                              prefix = newValue!;
                                            });
                                          },
                                          items: <String>['Mr.', 'Ms.', 'Dr.']
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          decoration: InputDecoration(
                                            labelText: 'Prefix',
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          validator: (value) => value == null ? 'Please select a prefix' : null,
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: _submitForm,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16,horizontal:300),
                                            textStyle: const TextStyle(fontSize: 18),
                                            backgroundColor: Colors.grey[800],
                                          ),
                                          child: const Text(
                                            'Sign Up',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Handle the form submission logic here, e.g., send data to an API or a server
      print('Form submitted with following details:');
      print('Email: $email');
      print('Name: $name');
      print('Phone Number: $phoneNumber');
      print('Location: $location');
      print('Interest: $interest');
      print('Interest2: $interest2');
      print('Prefix: $prefix');
      print('MCN Verified: $isMCNVerified');
      print('FCM Token: $fcmToken');
    }
  }
}
