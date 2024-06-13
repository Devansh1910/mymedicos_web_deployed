import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditStrip extends StatefulWidget {
  @override
  _CreditStripState createState() => _CreditStripState();
}

class _CreditStripState extends State<CreditStrip> {
  int _coins = 0;
  bool _isLoading = true;
  User? currentUser;
  int currentCoins = 0;
  late DatabaseReference databaseReference;

  @override
  void initState() {
    super.initState();
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
        savePhoneNumberToLocalStorage(phoneNumber);
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

  Future<void> savePhoneNumberToLocalStorage(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber);
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

    return Container(
      color: Color(0xFFF9F1E7),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get Credits',
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? 14 : 20,
                        color: Colors.grey,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'MedCoin - These Credits could be used for purchasing Premium\nExam Sets, Test Cases and Preparation Sets',
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? 12 : 16,
                        color: Colors.grey,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
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
        ],
      ),
    );
  }
}
