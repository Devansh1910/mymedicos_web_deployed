  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mymedicosweb/Profile/profile.dart';
import 'package:mymedicosweb/components/Appbar.dart';
import 'package:mymedicosweb/components/Credit.dart';
  import 'package:mymedicosweb/components/Footer.dart';



  import 'package:mymedicosweb/Landing/components/HeroImage.dart';
import 'package:mymedicosweb/components/drawer/app_drawer.dart';
import 'package:mymedicosweb/components/drawer/sideDrawer.dart';
import 'package:mymedicosweb/login/components/login_check.dart';
import 'package:mymedicosweb/pg_neet/ExamPaymentScreen.dart';
import 'package:url_launcher/url_launcher.dart';



  class PgNeet extends StatefulWidget {
    @override
    _PgNeetState createState() => _PgNeetState();
  }

  class _PgNeetState extends State<PgNeet> {
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
      if (!_isInitialized) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(appBar: AppBar(
            automaticallyImplyLeading: !kIsWeb,
            title: AppBarContent(),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: isLargeScreen ? null : IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer when the menu icon is pressed
              },
            ),
          ),
          drawer: isLargeScreen ? null : AppDrawer(initialIndex: 1),


            body: MainContent(isLargeScreen: isLargeScreen),
          );
        },
      );
    }
  }
  class MainContent extends StatelessWidget {
    final bool isLargeScreen;

    MainContent({required this.isLargeScreen});

    @override
    Widget build(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;

      return Column(
        children: [
          const OrangeStrip(
            text: 'Give your learning an extra edge with our premium content, curated exclusively for you!',
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                if (isLargeScreen) sideDrawer(initialIndex: 1),
                Expanded(
                  child: SingleChildScrollView(
                    child: FutureBuilder<Map<String, List<QuizPG>>>(
                      future: fetchAndCategorizeQuizzes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No quizzes available.'));
                        }

                        Map<String, List<QuizPG>> categorizedQuizzes = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const TopImage(),
                            QuizSection(
                              title: 'OnGoing Grand Test',
                              description: 'Go through these examinations for better preparation & get ready for the final buzz!',
                              quizzes: categorizedQuizzes['Ongoing']!,
                              screenWidth: screenWidth,
                            ),
                            QuizSection1(
                              title: 'Upcoming Grand Test',
                              description: 'Go through these examinations for better preparation & get ready for the final buzz!',
                              quizzes: categorizedQuizzes['Upcoming']!,
                              screenWidth: screenWidth,
                            ),
                            QuizSection2(
                              title: 'Terminated Grand Test',
                              description: 'Go through these examinations for better preparation & get ready for the final buzz!',
                              quizzes: categorizedQuizzes['Terminated']!,
                              screenWidth: screenWidth,
                            ),
                            ProvenEffectiveContent(screenWidth: screenWidth),
                            CreditStrip(),
                            const Footer(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }


    Future<Map<String, List<QuizPG>>> fetchAndCategorizeQuizzes() async {
      QuizService quizService = QuizService();
      List<String> excludeIds = await quizService.fetchQuizResults();
      List<QuizPG> quizzes = await quizService.fetchQuizzes(excludeIds);

      return QuizCategorizer.categorizeQuizzes(quizzes);
    }
  }


  class QuizCategorizer {
    static Map<String, List<QuizPG>> categorizeQuizzes(List<QuizPG> quizzes) {
      List<QuizPG> ongoingQuizzes = [];
      List<QuizPG> upcomingQuizzes = [];
      List<QuizPG> terminatedQuizzes = [];

      DateTime now = DateTime.now();

      for (QuizPG quiz in quizzes) {
        if ((quiz.to.isAfter(now))&&(quiz.from.isBefore(now))) {
          ongoingQuizzes.add(quiz);
        } else if (quiz.to.isBefore(now)) {
          terminatedQuizzes.add(quiz);
        } else {
          upcomingQuizzes.add(quiz);
        }
      }

      return {
        'Ongoing': ongoingQuizzes,
        'Upcoming': upcomingQuizzes,
        'Terminated': terminatedQuizzes,
      };
    }
  }

  class QuizSection2 extends StatefulWidget {
    final String title;
    final String description;
    final List<QuizPG> quizzes;
    final double screenWidth;

    QuizSection2({
      required this.title,
      required this.description,
      required this.quizzes,
      required this.screenWidth,
    });

    @override
    _QuizSection2State createState() => _QuizSection2State();
  }

  class _QuizSection2State extends State<QuizSection2> {
    late ScrollController _scrollController;

    @override
    void initState() {
      super.initState();
      _scrollController = ScrollController();
    }

    @override
    void dispose() {
      _scrollController.dispose();
      super.dispose();
    }

    void scrollRight() {
      _scrollController.animateTo(
        _scrollController.offset + widget.screenWidth,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }

    void scrollLeft() {
      _scrollController.animateTo(
        _scrollController.offset - widget.screenWidth,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }

    @override
    Widget build(BuildContext context) {
      bool isMobile = widget.screenWidth < 600;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: isMobile ? widget.screenWidth * 0.05 : widget.screenWidth * 0.015,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              widget.description,
              style: TextStyle(
                fontSize: isMobile ? widget.screenWidth * 0.04 : widget.screenWidth * 0.012,
                color: Colors.grey,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: widget.quizzes.isEmpty
                  ? Center(
                child: Text(
                  'No content available',
                  style: TextStyle(
                    fontSize: isMobile ? widget.screenWidth * 0.04 : widget.screenWidth * 0.012,
                    color: Colors.grey,
                    fontFamily: 'Inter',
                  ),
                ),
              )
                  : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          scrollLeft();
                        },
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          child: Row(
                            children: [
                              const SizedBox(width: 16), // Add initial padding
                              ...widget.quizzes.map((quiz) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: QuizCard(
                                    quiz: quiz,
                                    screenWidth: widget.screenWidth,
                                    path: "assets/image/past.png",
                                    onTap: (questionId) {
                                      Fluttertoast.showToast(
                                        msg: "These tests are terminated",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                      print('Tapped on question with ID: $questionId');
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          scrollRight();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  class QuizSection1 extends StatefulWidget {
    final String title;
    final String description;
    final List<QuizPG> quizzes;
    final double screenWidth;

    QuizSection1({
      required this.title,
      required this.description,
      required this.quizzes,
      required this.screenWidth,
    });

    @override
    _QuizSection1State createState() => _QuizSection1State();
  }

  class _QuizSection1State extends State<QuizSection1> {
    late ScrollController _scrollController;

    @override
    void initState() {
      super.initState();
      _scrollController = ScrollController();
    }

    @override
    void dispose() {
      _scrollController.dispose();
      super.dispose();
    }

    void scrollRight() {
      _scrollController.animateTo(
        _scrollController.offset + widget.screenWidth,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }

    void scrollLeft() {
      _scrollController.animateTo(
        _scrollController.offset - widget.screenWidth,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }

    void scheduleEventInCalendar(DateTime startTime) async {
      // Format the data you want to pass to the calendar event
      String title = 'Schedule your quiz';
      String description = 'This is a scheduled quiz event';
      String location = 'Online'; // Example location
      DateTime endTime = startTime.add(Duration(hours: 1)); // Example: ends 1 hour after start

      String startDate = '${startTime.year}${startTime.month.toString().padLeft(2, '0')}${startTime.day.toString().padLeft(2, '0')}T${startTime.hour.toString().padLeft(2, '0')}${startTime.minute.toString().padLeft(2, '0')}00';
      String endDate = '${endTime.year}${endTime.month.toString().padLeft(2, '0')}${endTime.day.toString().padLeft(2, '0')}T${endTime.hour.toString().padLeft(2, '0')}${endTime.minute.toString().padLeft(2, '0')}00';

      String url = 'https://calendar.google.com/calendar/render?action=TEMPLATE&text=$title&dates=$startDate/$endDate&details=$description&location=$location';

      // Launch the URL in a browser or the default calendar app
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    @override
    Widget build(BuildContext context) {
      bool isMobile = widget.screenWidth < 600;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: isMobile ? widget.screenWidth * 0.05 : widget.screenWidth * 0.015,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              widget.description,
              style: TextStyle(
                fontSize: isMobile ? widget.screenWidth * 0.04 : widget.screenWidth * 0.012,
                color: Colors.grey,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: widget.quizzes.isEmpty
                  ? Center(
                child: Text(
                  'No content available',
                  style: TextStyle(
                    fontSize: isMobile ? widget.screenWidth * 0.04 : widget.screenWidth * 0.012,
                    color: Colors.grey,
                    fontFamily: 'Inter',
                  ),
                ),
              )
                  : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          scrollLeft();
                        },
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          child: Row(
                            children: [
                              const SizedBox(width: 16), // Add initial padding
                              ...widget.quizzes.map((quiz) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: QuizCard(
                                    quiz: quiz,
                                    screenWidth: widget.screenWidth,
                                    path: "assets/image/liveadapter.png",
                                    onTap: (questionId) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PgNeetPayment(
                                            title: quiz.title,
                                            quizId: questionId,
                                            dueDate: quiz.to.toString(),
                                          ),
                                        ),
                                      );
                                      print('Tapped on question with ID: $questionId');
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          scrollRight();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () {
                          if (widget.quizzes.isNotEmpty) {
                            scheduleEventInCalendar(widget.quizzes.first.from);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }


  class QuizSection extends StatefulWidget {
    final String title;
    final String description;
    final List<QuizPG> quizzes;
    final double screenWidth;

    QuizSection({
      required this.title,
      required this.description,
      required this.quizzes,
      required this.screenWidth,
    });

    @override
    _QuizSectionState createState() => _QuizSectionState();
  }

  class _QuizSectionState extends State<QuizSection> {
    late ScrollController _scrollController;

    @override
    void initState() {
      super.initState();
      _scrollController = ScrollController();
    }

    @override
    void dispose() {
      _scrollController.dispose();
      super.dispose();
    }

    void scrollRight() {
      _scrollController.animateTo(
        _scrollController.offset + widget.screenWidth,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }

    void scrollLeft() {
      _scrollController.animateTo(
        _scrollController.offset - widget.screenWidth,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }

    @override
    Widget build(BuildContext context) {
      bool isMobile = widget.screenWidth < 600;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: isMobile ? widget.screenWidth * 0.05 : widget.screenWidth * 0.015,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              widget.description,
              style: TextStyle(
                fontSize: isMobile ? widget.screenWidth * 0.04 : widget.screenWidth * 0.012,
                color: Colors.grey,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: widget.quizzes.isEmpty
                  ? Center(
                child: Text(
                  'No content available',
                  style: TextStyle(
                    fontSize: isMobile ? widget.screenWidth * 0.04 : widget.screenWidth * 0.012,
                    color: Colors.grey,
                    fontFamily: 'Inter',
                  ),
                ),
              )
                  : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          scrollLeft();
                        },
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          child: Row(
                            children: [
                              const SizedBox(width: 16), // Add initial padding
                              ...widget.quizzes.map((quiz) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: QuizCard(
                                    quiz: quiz,
                                    screenWidth: widget.screenWidth,
                                    path: "assets/image/liveadapter.png",
                                    onTap: (questionId) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PgNeetPayment(
                                            title: quiz.title,
                                            quizId: questionId,
                                            dueDate: quiz.to.toString(),
                                          ),
                                        ),
                                      );
                                      print('Tapped on question with ID: $questionId');
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          scrollRight();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
  class QuizPG {
    final String title;
    final String speciality;
    final DateTime to;
    final DateTime from;
    final String qid;

    QuizPG({required this.title, required this.speciality, required this.to,required this.from,required this.qid});

    factory QuizPG.fromMap(Map<String, dynamic> data) {
      return QuizPG(
        title: data['title'] ?? '',
        speciality: data['speciality'] ?? '',
        to: (data['to'] as Timestamp).toDate(),
        qid:data['qid'] ?? ' ',
        from:(data['from'] as Timestamp).toDate()
      );
    }
  }

  class QuizService {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    Future<List<String>> fetchQuizResults() async {
      List<String> subcollectionIds = [];

      User? user = auth.currentUser;
      if (user != null) {
        String userId = user.phoneNumber ?? '';
        CollectionReference quizResultsCollection = db.collection('QuizResults').doc(userId).collection('Exam');
        QuerySnapshot subcollectionSnapshot = await quizResultsCollection.get();
        for (var subdocument in subcollectionSnapshot.docs) {
          subcollectionIds.add(subdocument.id);
        }
      }

      return subcollectionIds;
    }

    Future<List<QuizPG>> fetchQuizzes(List<String> excludeIds) async {
      List<QuizPG> quizzes = [];
      CollectionReference quizzCollection = db.collection('PGupload').doc('Weekley').collection('Quiz');
      Query query = quizzCollection;

      QuerySnapshot querySnapshot = await query.get();
      for (var document in querySnapshot.docs) {
        if (!excludeIds.contains(document.id)) {
          String title = document.get('title');
          String speciality = document.get('speciality');
          Timestamp toTimestamp = document.get('to');
          DateTime to = toTimestamp.toDate();
          Timestamp fromTimestamp = document.get('from');
          String qid=document.get('qid');
          DateTime from = fromTimestamp.toDate();
          if (speciality.compareTo("Exam")==0)
          quizzes.add(QuizPG(title: title, speciality: speciality, to: to,from:from,qid:qid));
        }
      }

      return quizzes;
    }
  }

  class QuizCard extends StatelessWidget {
    final QuizPG quiz;
    final double screenWidth;
    final Function(String) onTap;
    final String path;

    QuizCard({required this.quiz, required this.screenWidth, required this.onTap, required this.path});

    @override
    Widget build(BuildContext context) {
      bool isMobile = screenWidth < 600;

      return GestureDetector(
        onTap: () => onTap(quiz.qid), // Pass the ID of the question when tapped
        child: Container(
          height: isMobile ? 250 : 300,
          width: isMobile ? screenWidth - 32 : 500, // Adjust the width as needed
          margin: const EdgeInsets.only(right: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15.0), // Adjust the padding as needed
                  child: Image.asset(
                    path, // Replace with actual image path
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: isMobile ? 120 : double.infinity, // Adjust the height for mobile
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: TextStyle(
                          fontSize: isMobile ? screenWidth * 0.04 : screenWidth * 0.012,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        'Due Date: ${quiz.to}',
                        style: TextStyle(
                          fontSize: isMobile ? screenWidth * 0.04 : screenWidth * 0.012,
                          color: Colors.grey,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

