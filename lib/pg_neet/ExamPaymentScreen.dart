import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mymedicosweb/login/components/login_check.dart';
import 'package:mymedicosweb/login/login_screen.dart';
import 'package:mymedicosweb/pg_neet/QuizScreen.dart';
import 'package:mymedicosweb/components/drawer/sideDrawer.dart';
import 'package:mymedicosweb/components/Appbar.dart';
import 'package:mymedicosweb/components/drawer/app_drawer.dart';
import 'package:mymedicosweb/pg_neet/NeetScree.dart';
import 'package:mymedicosweb/components/Credit.dart';
import 'package:mymedicosweb/profile/profile.dart';
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
        children: [
          const OrangeStrip(
            text: 'Give your learning an extra edge with our premium content, curated exclusively for you!',
          ),
          Expanded(
            child: Row(
              children: [
                if (isLargeScreen) sideDrawer(initialIndex: 1,),
                Expanded(
                  child: SingleChildScrollView(
                    child: MainContent(
                      isLargeScreen: isLargeScreen,
                      hasReadInstructions: hasReadInstructions,
                      onCheckboxChanged: (bool? value) {
                        setState(() {
                          hasReadInstructions = value ?? false;
                        });
                      },
                      title: widget.title,
                      qid:widget.quizId,
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


class MainContent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    late DatabaseReference databaseReference;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            dueDate,
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          const SizedBox(height: 16),
          InstructionContainer(),
          const SizedBox(height: 16),
          CreditStrip(),
          const SizedBox(height: 16),
          const Text(
            'Format of the Question Paper:',
            style: TextStyle(fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
          const Text(
            'Go through the under given instructions for better understanding of the examination.',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // First column
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
                    ),
                    const SizedBox(width: 8),
                    const Column(
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
              if (MediaQuery.of(context).size.width > 600) const SizedBox(width: 16),
              if (MediaQuery.of(context).size.width > 600)
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
                      ),
                      const SizedBox(width: 8),
                      const Column(
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
              if (MediaQuery.of(context).size.width > 600) const SizedBox(width: 16),
              if (MediaQuery.of(context).size.width > 600)
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
                      ),
                      const SizedBox(width: 8),
                      const Column(
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
          if (MediaQuery.of(context).size.width <= 600) ...[
            const SizedBox(height: 16),
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
                      ),
                      const SizedBox(width: 8),
                      const Column(
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
            const SizedBox(height: 16),
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
                      ),
                      const SizedBox(width: 8),
                      const Column(
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

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: isLargeScreen ? 2 : 3,
                child: const TextField(
                  decoration: InputDecoration(
                    labelText: 'Apply Coupon',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size.fromHeight(55),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontFamily: 'Inter', color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: hasReadInstructions,
                onChanged: onCheckboxChanged,
                activeColor: Colors.black,
              ),
              const Text(
                'I have read all the instructions',
                style: TextStyle(fontFamily: 'Inter'),
              ),
            ],
          ),
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
                      hasReadInstructions
                          ? () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String? phoneNumber = prefs.getString('phoneNumber');
                        if (phoneNumber != null) {
                          await onTakeTest(phoneNumber);

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
      padding: const EdgeInsets.all(16),
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
          SizedBox(height: 16),
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

