import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailsFetcher {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedPhoneNumber = prefs.getString('phoneNumber');

    if (savedPhoneNumber != null) {
      try {
        final QuerySnapshot querySnapshot = await _firestore.collection("users").get();
        final List<DocumentSnapshot> documents = querySnapshot.docs;

        for (var document in documents) {
          final dataMap = document.data() as Map<String, dynamic>;
          final field1 = dataMap["Phone Number"];

          if (field1 != null && savedPhoneNumber != null) {
            final int comparisonResult = field1.compareTo(savedPhoneNumber);
            if (comparisonResult == 0) {
              final String userName = dataMap["Name"];
              final String userEmail = dataMap["Email ID"];
              final String userLocation = dataMap["Location"];
              final String userInterest = dataMap["Interest"];
              final String userPrefix = dataMap["Prefix"];
              final bool? mcnVerified = dataMap["MCN verified"];
              final String? phone=dataMap["Phone Number"];

              final String? userProfileImageUrl = await fetchUserProfileImageUrl(savedPhoneNumber);

              return {
                "userName": userName,
                "userEmail": userEmail,
                "userLocation": userLocation,
                "userInterest": userInterest,
                "userPrefix": userPrefix,
                "mcnVerified": mcnVerified,
                "userProfileImageUrl": userProfileImageUrl,
                "Phone Number":phone
              };
            }
          } else {
            print("Field1 or savedPhoneNumber is null");
          }
        }
      } catch (error) {
        print("Error fetching user details: $error");
        throw error; // Throw an exception to indicate error
      }
    } else {
      print("Phone number not found in local storage");
      throw Exception("Phone number not found in local storage"); // Throw an exception to indicate error
    }

    // If method execution reaches here without returning any value, throw an exception
    throw Exception("User details not found");
  }

  Future<String?> fetchUserProfileImageUrl(String phoneNumber) async {
    try {
      final ref = FirebaseStorage.instance.ref().child("users").child(phoneNumber).child("profile_image.jpg");
      final url = await ref.getDownloadURL();
      print("image url "+"$url");
      return url;
    } catch (error) {
      print("Error fetching profile image URL: $error");
      return null;
    }
  }
}
