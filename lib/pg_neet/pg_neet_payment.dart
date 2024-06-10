import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mymedicosweb/login/login_check.dart';
import 'package:mymedicosweb/login/login_screen.dart';
import 'package:mymedicosweb/pg_neet/QuizScreen.dart';
import 'package:mymedicosweb/pg_neet/sideDrawer.dart';
import 'package:mymedicosweb/pg_neet/app_bar_content.dart';
import 'package:mymedicosweb/pg_neet/app_drawer.dart';
import 'package:mymedicosweb/pg_neet/pg_neet.dart';
import 'package:mymedicosweb/pg_neet/credit.dart';
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
      return Scaffold(
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
      appBar:AppBar(
        automaticallyImplyLeading: false, // Set to true to show the back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (MediaQuery.of(context).size.width <= 600) {
                      Scaffold.of(context).openDrawer();
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage('url_to_user_profile_image'),
                  ),
                ),
                SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning!', // Replace with the actual title
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.0, // Adjust the font size as needed
                        fontWeight: FontWeight.bold, // Adjust the font weight as needed
                      ),
                    ),
                    Text(
                      'UserName', // Replace with the actual subtitle
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.0, // Adjust the font size as needed
                        color: Colors.grey, // Adjust the color as needed
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SvgPicture.asset(
              'assets/image/logo.svg',
              height: 40,
              placeholderBuilder: (BuildContext context) => Container(
                padding: const EdgeInsets.all(30.0),
                child: const CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
      drawer: MediaQuery.of(context).size.width <= 600 ? AppDrawer() : null,
      body: Column(
        children: [
          OrangeStrip(
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

  MainContent({
    required this.isLargeScreen,
    required this.hasReadInstructions,
    required this.onCheckboxChanged,
    required this.title,
    required this.qid,
    required this.dueDate,
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
            style: TextStyle(fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            dueDate,
            style: TextStyle(fontFamily: 'Inter'),
          ),
          SizedBox(height: 16),
          InstructionContainer(),
          SizedBox(height: 16),
          CreditStrip(),
          SizedBox(height: 16),
          Text(
            'Format of the Question Paper:',
            style: TextStyle(fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.bold),
          ),
          Text(
            'Go through the under given instructions for better understanding of the examination.',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          SizedBox(height: 8),
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
                    SizedBox(width: 8),
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
              if (MediaQuery.of(context).size.width > 600) SizedBox(width: 16),
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
              if (MediaQuery.of(context).size.width > 600) SizedBox(width: 16),
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
                      SizedBox(width: 8),
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
          if (MediaQuery.of(context).size.width <= 600) ...[
            SizedBox(height: 16),
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
              ],
            ),
            SizedBox(height: 16),
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
                      SizedBox(width: 8),
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

          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: isLargeScreen ? 2 : 3,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Apply Coupon',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {},
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
          Row(
            children: [
              Checkbox(
                value: hasReadInstructions,
                onChanged: onCheckboxChanged,
                activeColor: Colors.black,
              ),
              Text(
                'I have read all the instructions',
                style: TextStyle(fontFamily: 'Inter'),
              ),
            ],
          ),
          Center(
            child: Container(
              color: Color(0xFFFFFFFF),
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
                    onPressed: hasReadInstructions
                        ? () {
                      if (qid != null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirmation'),
                              content: Text('50 med coins will be deducted. Do you want to proceed?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QuizPage(quizId: qid, title: title,duedate:dueDate),
                                      ),
                                    );
                                  },
                                  child: Text('Proceed'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Handle the case where 'qid' is null
                        print('Error: quizId is null');
                      }
                    }
                        : null,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    child: Padding(
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
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

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Drawer Header',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('PG Neet'),
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('FMGE'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
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
      color: Color(0xFFFFF6E5),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter'
                ),
                children: [
                  TextSpan(
                    text: text,
                    style: TextStyle(
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

