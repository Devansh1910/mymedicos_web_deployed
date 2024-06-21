import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mymedicosweb/Profile/profile.dart';
import 'package:mymedicosweb/login/components/login_check.dart';
import 'package:mymedicosweb/login/login_screen.dart';
import 'package:mymedicosweb/pg_neet/QuizScreen.dart';
import 'package:mymedicosweb/components/drawer/sideDrawer.dart';
import 'package:mymedicosweb/components/Appbar.dart';
import 'package:mymedicosweb/components/drawer/app_drawer.dart';
import 'package:mymedicosweb/pg_neet/NeetScree.dart';
import 'package:mymedicosweb/components/Credit.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/svg.dart';
class PgNeetPayment extends StatefulWidget {
  final String title;
  final String quizId;
  final String dueDate;

  PgNeetPayment({
    Key? key,
    required this.title,
    required this.quizId,
    required this.dueDate,
  }) : super(key: key);

  @override
  _PgNeetPaymentState createState() => _PgNeetPaymentState();
}

class _PgNeetPaymentState extends State<PgNeetPayment> {
  bool hasReadInstructions = false;
  bool _isLoggedIn = false;
  bool _isLoading = false;
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


  Future<void> addCouponToUsedListAndStartTest(String phoneNumber, String couponCode) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentReference userCouponDoc = _firestore.collection("CouponUsed").doc(phoneNumber);

      // Check if the document exists
      var docSnapshot = await userCouponDoc.get();
      if (docSnapshot.exists) {
        // Document exists, update it
        await updateCouponUsedList(userCouponDoc, couponCode);
      } else {
        // Document does not exist, create it first
        await createCouponUsedList(userCouponDoc, couponCode);
      }

      // After updating or creating the coupon list, start the test or perform any other action
     // Replace with your actual test initiation logic
    } catch (e) {
      print('Error adding coupon and starting test: $e');
      // Handle error as per your application's requirement
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> updateCouponUsedList(DocumentReference userCouponDoc, String couponCode) async {
    // Update existing document with new coupon code
    try {
      await userCouponDoc.update({
        "coupon_used": FieldValue.arrayUnion([couponCode]),
      });
      print('Coupon code added to user\'s used list');
    } catch (e) {
      print('Error adding coupon code to used list: $e');
      throw e; // Rethrow the exception to handle it in UI if needed
    }
  }

  Future<void> createCouponUsedList(DocumentReference userCouponDoc, String couponCode) async {
    // Create new document with initial coupon data
    try {
      await userCouponDoc.set({
        "coupon_used": [couponCode],
      });
      print('New coupon list created for user');
    } catch (e) {
      print('Failed to create new coupon list for user: $e');
      throw e; // Rethrow the exception to handle it in UI if needed
    }
  }
  Future<void> deductCoinsAndNavigate(String phoneNumber,int discount,String code) async {
    setState(() {
      _isLoading = true;
    });
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    DataSnapshot snapshot =
    await databaseReference.child('profiles').child(phoneNumber).child('coins').get();
    int currentCoins = snapshot.value as int;
    print("discount 20"+discount.toString());

    if (currentCoins >= 50-discount) {

      int coins=50-discount;

      await databaseReference.child('profiles').child(phoneNumber).child('coins').set(currentCoins);
      if (widget.quizId != null) {

        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation'),
              content:  Text('$coins med coins will be deducted. Do you want to proceed?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    addCouponToUsedListAndStartTest(phoneNumber,code);
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPage(
                          quizId: widget.quizId,
                          title: widget.title,
                          duedate: widget.dueDate,
                          discount:discount,
                        ),
                      ),
                    );
                  },
                  child: const Text('Proceed'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle the case where 'qid' is null
        print('Error: quizId is null');
      }

    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Not enough coins'),
            content: const Text('You do not have enough coins to proceed.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
                child: const Text('Credit'),
              ),
            ],
          );
        },
      );
    }
    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 600;
    UserNotifier userNotifier = UserNotifier();
    bool isLoggedIn = userNotifier.isLoggedIn;
    // String title1 = ''; // Initialize with default value
    // DateTime? dueDate1;
    // String quizId ='';
    // final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // if (args != null) {
    //   title1 = args['title'] ?? 'Loading'; // Update with the value from args
    //   quizId = args['quizId']  ?? ' sfc';
    //   dueDate1 = args['dueDate'] as DateTime? ?? null; // Update with the value from args
    //   print('Tapped on question with ID: $quizId');
    //   // Use the retrieved arguments here
    // }
    print('Tapped on question with ID: $widget.quizId');

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: !kIsWeb,
        title: AppBarContent(),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: isLargeScreen ? null : IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer(); // Open the drawer when the menu icon is pressed
          },
        ),
      ),
      drawer: MediaQuery.of(context).size.width <= 600 ?   AppDrawer(initialIndex: 0) : null,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OrangeStrip(
            text: 'Give your learning an extra edge with our premium content, curated exclusively for you!',
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLargeScreen) SideDrawer(initialIndex: 1,),
                Expanded(
                  child: SingleChildScrollView(

                    padding: EdgeInsets.zero, // Ensure no extra padding in the scroll view
                    child: MainContent(
                      isLargeScreen: isLargeScreen,
                      hasReadInstructions: hasReadInstructions,
                      onCheckboxChanged: (bool? value) {
                        setState(() {
                          hasReadInstructions = value ?? false;
                        });
                      },
                      title: widget.title,
                      qid: widget.quizId,
                      dueDate: widget.dueDate,
                      onTakeTest: (String phoneNumber,int discount,String code) => deductCoinsAndNavigate(phoneNumber,discount,code),
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
  final bool hasReadInstructions;
  final ValueChanged<bool?> onCheckboxChanged;
  final String title;
  final String qid;
  final String dueDate;
  final Future<void> Function(String, int,String) onTakeTest;

  MainContent({
    required this.isLargeScreen,
    required this.hasReadInstructions,
    required this.onCheckboxChanged,
    required this.title,
    required this.qid,
    required this.dueDate,
    required this.onTakeTest,
  });

  @override
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  int currentCoins = 0;
  late DatabaseReference databaseReference;
  bool _isLoading = true;
  User? currentUser;
  late String code1;
  int discount = 0; // State variable for discount

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

  String formatDate(String dueDate) {
    // Assuming dueDate is in the format 'yyyy-MM-dd'
    DateTime parsedDate = DateTime.parse(dueDate);
    String formattedDate = DateFormat('d,MMMM yyyy').format(parsedDate);
    return formattedDate;
  }

  Future<void> savePhoneNumberToLocalStorage(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber);
  }

  void fetchCoinsFromDatabase(String phoneNumber) {
    databaseReference = FirebaseDatabase.instance.reference();

    // Retrieve coins
    databaseReference
        .child('profiles')
        .child(phoneNumber)
        .child('coins')
        .onValue
        .listen((event) {
      DataSnapshot snapshot = event.snapshot;
      int? coinsValue = snapshot.value as int?;
      setState(() {
        currentCoins = coinsValue ?? 0;
        _isLoading = false;
      });
    });

    // Update phone number
    databaseReference
        .child('profiles')
        .child(phoneNumber)
        .child('phoneNumber')
        .set(phoneNumber)
        .then((_) {
      print('Phone number updated successfully');
    }).catchError((error) {
      print('Error updating phone number: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isLargeScreen ? 32 : 16,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Due Date: ${formatDate(widget.dueDate)}",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: screenWidth < 600 ? 5 : 10,
                    horizontal: screenWidth < 600 ? 20 : 40,
                  ),
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
          SizedBox(height: 30),
          InstructionContainer(),
          SizedBox(height: 30),
          Text(
            'Format of the Question Paper:',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Go through the under given instructions for better understanding of the examination.',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              if (MediaQuery.of(context).size.width > 600) ...[
                SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(Icons.timer),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('200 mins', style: TextStyle(fontFamily: 'Inter')),
                          Text(
                            'Duration',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(Icons.assignment),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '200 Questions - 800 Marks',
                            style: TextStyle(fontFamily: 'Inter'),
                          ),
                          Text(
                            'Score details',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(Icons.language),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('English', style: TextStyle(fontFamily: 'Inter')),
                          Text(
                            'Language',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (MediaQuery.of(context).size.width <= 600) ...[
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(Icons.timer),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('200 mins', style: TextStyle(fontFamily: 'Inter')),
                          Text(
                            'Duration',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(Icons.assignment),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '200 Questions - 800 Marks',
                            style: TextStyle(fontFamily: 'Inter'),
                          ),
                          Text(
                            'Score details',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(Icons.language),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('English', style: TextStyle(fontFamily: 'Inter')),
                          Text(
                            'Language',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 16),
          CouponScreen(
            isLargeScreen: widget.isLargeScreen,
            onDiscountChanged: (value) {
              setState(() {

                discount = value;
                print("Discount updated: $discount");
              });
            },
            oncodechanged:(value){
              setState(() {
                code1=value;
              });
            }
          ),
          SizedBox(height: 30),
          Row(
            children: [
              Checkbox(
                value: widget.hasReadInstructions,
                onChanged: widget.onCheckboxChanged,
                activeColor: Colors.black,
              ),
              Text(
                'I have read all the instructions',
                style: TextStyle(fontFamily: 'Inter'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: Container(
              color: Colors.white,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ElevatedButton(
                    onPressed: widget.hasReadInstructions
                        ? () async {
                      SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                      String? phoneNumber =
                      prefs.getString('phoneNumber');
                      if (phoneNumber != null) {
                        print("Discount when taking test: $discount");
                        await widget.onTakeTest(phoneNumber, discount,code1);
                      } else {
                        Fluttertoast.showToast(
                          msg:
                          "Phone number not found. Please login again.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    }
                        : () {
                      Fluttertoast.showToast(
                        msg:
                        "Please click on the checkbox to proceed",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'START EXAMINATION',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CouponScreen extends StatefulWidget {
  final bool isLargeScreen;
  final Function(int) onDiscountChanged;
  final Function (String) oncodechanged;

  CouponScreen({required this.isLargeScreen, required this.onDiscountChanged,required this.oncodechanged});

  @override
  _CouponScreenState createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {

  String? selectedCoupon;
  List<String> coupons = [];
  int discount = 0;
  String? phoneNumber;

  Future<List<String>> fetchCoupons() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Coupons').get();
    return querySnapshot.docs.map((doc) => doc['code'] as String).toList();
  }
  Future<void> fetchPhoneNumber() async {
    String? number = await fetchPhoneNumberFromLocalStorage();
    setState(() {
      phoneNumber = number;
    });
  }
  Future<String?> fetchPhoneNumberFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phoneNumber = prefs.getString('phoneNumber');
    return phoneNumber;
  }

  @override
  void initState() {
    super.initState();
    fetchPhoneNumber();
    fetchCoupons().then((fetchedCoupons) {
      setState(() {
        coupons = fetchedCoupons;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: widget.isLargeScreen ? 2 : 3,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Coupon',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedCoupon,
                  items: coupons.map((coupon) {
                    return DropdownMenuItem<String>(
                      value: coupon,
                      child: Text(coupon),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCoupon = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    applyCoupon(selectedCoupon);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size.fromHeight(55),
                  ),
                  child: Text(
                    'Apply',
                    style: TextStyle(fontFamily: 'Inter', color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  void applyCoupon(String? couponCode) {
    if (couponCode != null) {
      FirebaseFirestore.instance.collection('Coupons').where('code', isEqualTo: couponCode).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var couponDoc = querySnapshot.docs.first;

          // Extract fields from the document
          int discount = couponDoc['discount'];
          String aboutMessage = couponDoc['about'];

          // Check if the coupon code is already used by the user
          FirebaseFirestore.instance.collection('CouponUsed').doc(phoneNumber).get().then((couponUsedDoc) {
            if (couponUsedDoc.exists) {
              List<dynamic> couponUsedList = couponUsedDoc.data()?['coupon_used'];
              if (couponUsedList.contains(couponCode)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Coupon with code $couponCode is already used!')),
                );
              } else {
                // Update UI state with the selected coupon
                setState(() {
                  this.discount = discount; // Update discount in state
                  this.selectedCoupon = couponCode; // Update selectedCoupon in state
                });

                // Notify parent widget about the discount change
                widget.onDiscountChanged(discount);
                widget.oncodechanged(selectedCoupon!);

                // Show SnackBar with about message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(aboutMessage)),
                );
              }
            } else {
              // If the document doesn't exist, proceed with applying the coupon
              // Update UI state with the selected coupon
              setState(() {
                this.discount = discount; // Update discount in state
                this.selectedCoupon = couponCode; // Update selectedCoupon in state
              });

              // Notify parent widget about the discount change
              widget.onDiscountChanged(discount);
              widget.oncodechanged(selectedCoupon!);

              // Show SnackBar with about message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(aboutMessage)),
              );
            }
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to check coupon usage: $error')),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Coupon with code $couponCode not found!')),
          );
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch coupon: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a coupon!')),
      );
    }
  }

}

class InstructionContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This is the examination based quiz on the NEET 2023 pattern with more predictable questions.',
            style: TextStyle(fontSize: 16, fontFamily: 'Inter'),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.circle, color: Colors.green, size: 12),
              SizedBox(width: 8),
              Text('+4 for correct', style: TextStyle(fontFamily: 'Inter')),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.circle, color: Colors.red, size: 12),
              SizedBox(width: 8),
              Text('-1 for wrong', style: TextStyle(fontFamily: 'Inter')),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.circle, color: Colors.grey, size: 12),
              SizedBox(width: 8),
              Text('0 for skipped', style: TextStyle(fontFamily: 'Inter')),
            ],
          ),
        ],
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

