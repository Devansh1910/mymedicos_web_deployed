import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _phoneNumber;
  bool _isInitialized = false; // Add _isInitialized flag

  bool get isLoggedIn => _isLoggedIn;
  String? get phoneNumber => _phoneNumber;
  bool get isInitialized => _isInitialized; // Getter for isInitialized flag

  UserNotifier() {
    _initialize(); // Initialize the UserNotifier
  }

  // Initialize the UserNotifier by loading login status and phone number from shared preferences
  void _initialize() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _phoneNumber = prefs.getString('phoneNumber');
      _isInitialized = true; // Set _isInitialized to true after loading data
    } catch (e) {
      // Handle any errors that occur during initialization
      print('Failed to initialize UserNotifier: $e');
      _isInitialized = false; // Set _isInitialized to false if initialization fails
    }
    notifyListeners(); // Notify listeners after initialization
  }

  // Log in the user and save status and phone number in shared preferences
  void logIn(String phoneNumber) async {
    _isLoggedIn = true;
    _phoneNumber = phoneNumber;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('phoneNumber', phoneNumber);
    } catch (e) {
      // Handle any errors that occur while saving login status
      print('Failed to save login status: $e');
    }
    notifyListeners(); // Notify listeners after logging in
  }

  // Log out the user and clear status and phone number in shared preferences
  void logOut() async {
    _isLoggedIn = false;
    _phoneNumber = null;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('phoneNumber');
    } catch (e) {
      // Handle any errors that occur while clearing login status
      print('Failed to clear login status: $e');
    }
    notifyListeners(); // Notify listeners after logging out
  }
}
