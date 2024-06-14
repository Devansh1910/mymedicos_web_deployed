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
  Future<void> deductCoinsAndNavigate(String phoneNumber) async {
    setState(() {
      _isLoading = true;
    });
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    DataSnapshot snapshot =
    await databaseReference.child('profiles').child(phoneNumber).child('coins').get();
    int currentCoins = snapshot.value as int;

    if (currentCoins >= 50) {
      currentCoins -= 50;
      await databaseReference.child('profiles').child(phoneNumber).child('coins').set(currentCoins);
      if (widget.quizId != null) {

        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation'),
              content: const Text('50 med coins will be deducted. Do you want to proceed?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPage(
                          quizId: widget.quizId,
                          title: widget.title,
                          duedate: widget.dueDate,
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
                      onTakeTest: (String phoneNumber) => deductCoinsAndNavigate(phoneNumber),
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
  final Future<void> Function(String) onTakeTest;

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
    double screenWidth = MediaQuery.of(context).size.width; // Ensure screenWidth is available

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isLargeScreen ? 32 : 16,vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,

        children: <Widget>[

      Row(
        mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures the Row items are spaced apart
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the start (left)
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                 Text(
                   "Due Date:"+formatDate(widget.dueDate),
                    style: const TextStyle(fontFamily: 'Inter',fontSize: 18,color: Colors.grey),
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



        const SizedBox(height: 30),
          InstructionContainer(),
          // const SizedBox(height: 16),
          // CreditStrip(),
          const SizedBox(height: 30),
          const Text(
            'Format of the Question Paper:',
            style: TextStyle(fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
          const Text(
            'Go through the under given instructions for better understanding of the examination.',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          const SizedBox(height: 20),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row

          Row(
            children: [
      if (MediaQuery.of(context).size.width > 600) ...[

                const SizedBox(width: 16),
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
                      child: Icon(Icons.timer), // Add icon related to time/duration
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '200 mins',
                          style: TextStyle(fontFamily: 'Inter'),
                        ),
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
              // Add SizedBox and other sections similar to the first one with different icons

              // Second column
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
                      child: Icon(Icons.assignment), // Add icon related to score/details
                    ),
                    const SizedBox(width: 8),
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

              // Third column
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
                      child: Icon(Icons.language), // Add icon related to language
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'English',
                          style: TextStyle(fontFamily: 'Inter'),
                        ),
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

          // Below the condition for small screen (width <= 600)
          if (MediaQuery.of(context).size.width <= 600) ...[
            SizedBox(height: 20),
            Row(
              children: [
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
                    child: Icon(Icons.timer), // Add icon related to time/duration
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '200 mins',
                        style: TextStyle(fontFamily: 'Inter'),
                      ),
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
            ],
    ),
            SizedBox(height: 20),
            // Additional rows for small screens
            Row(
              children: [
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
                        child: Icon(Icons.assignment), // Add icon related to score/details
                      ),
                      const SizedBox(width: 8),
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
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
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
                        child: Icon(Icons.language), // Add icon related to language
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'English',
                            style: TextStyle(fontFamily: 'Inter'),
                          ),
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
            ),
          ],
    ],
    ),
          SizedBox(height: 30,),
          Row(
            children: [
              Checkbox(
                value: widget.hasReadInstructions,
                onChanged: widget.onCheckboxChanged,
                activeColor: Colors.black,
              ),
              const Text(
                'I have read all the instructions',
                style: TextStyle(fontFamily: 'Inter'),
              ),
            ],
          ),
          SizedBox(height: 20,),
          Center(
            child: Container(
              color: const Color(0xFFFFFFFF),
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
                    onPressed:
                      widget.hasReadInstructions
                          ? () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String? phoneNumber = prefs.getString('phoneNumber');
                        if (phoneNumber != null) {
                          await  widget.onTakeTest(phoneNumber);

                        } else {
                          Fluttertoast.showToast(
                            msg: "Phone number not found. Please login again.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      }


                        : () {
                          Fluttertoast.showToast(
                          msg: "Please click on the checkbox to proceed",
                           toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0,
                          );
                      },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'START EXAMINATION',
                        style: TextStyle(fontFamily: 'Inter', color: Colors.black),
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



    // Update phone number


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

