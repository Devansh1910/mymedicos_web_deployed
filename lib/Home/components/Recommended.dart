import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mymedicosweb/pg_neet/ExamPaymentScreen.dart';

class RecommendedGrandTest extends StatelessWidget {
  final double screenWidth;
  final QuizService quizService = QuizService(); // Instantiate the QuizService

  RecommendedGrandTest({
    super.key,
    required this.screenWidth,
  });

  void navigateToPgNeetPayment(BuildContext context, String title, String quizId, DateTime dueDate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PgNeetPayment(
          title: title,
          quizId: quizId,
          dueDate: dueDate.toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = screenWidth < 600;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Recommended Grand Test',
            style: TextStyle(
              fontSize: isMobile ? screenWidth * 0.05 : screenWidth * 0.015, // Adjusted font size for mobile
              fontFamily: 'Inter',
            ),
          ),
          Text(
            'Go through these examinations for better preparation & get ready for the final buzz!',
            style: TextStyle(
              fontSize: isMobile ? screenWidth * 0.045 : screenWidth * 0.012, // Adjusted font size for mobile
              color: Colors.grey,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder(
            future: quizService.fetchQuizzes(2), // Fetch only 2 quizzes
            builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Show loading indicator while fetching data
              }
              if (snapshot.hasError) {
                return const Text('Error fetching quizzes');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'No content available',
                      style: TextStyle(
                        fontSize: isMobile ? screenWidth * 0.04 : screenWidth * 0.012,
                        color: Colors.grey,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                );
              }
              List<Map<String, dynamic>> quizzes = snapshot.data!;
              return SingleChildScrollView( // Wrap with SingleChildScrollView
                scrollDirection: Axis.horizontal, // Set scroll direction to horizontal
                child: Row(
                  children: quizzes.map((quizData) {
                    var quiz = QuizPG(
                      qid: quizData['qid'],
                      title: quizData['title'],
                      to: (quizData['to'] as Timestamp).toDate(),
                    );
                    return Padding(
                      padding: const EdgeInsets.all(8.0), // Adjust the padding value as needed
                      child: QuizCard(
                        quiz: quiz,
                        screenWidth: screenWidth,
                        onTap: (quizId) {
                          navigateToPgNeetPayment(context, quiz.title, quizId, quiz.to);
                        },
                        path: 'assets/image/liveadapter.png',
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class QuizCard extends StatelessWidget {
  final QuizPG quiz;
  final double screenWidth;
  final Function(String) onTap;
  final String mobileImagePath = 'assets/image/mobile_image.png';
  final String path;

  QuizCard({required this.quiz, required this.screenWidth, required this.onTap, required this.path});

  @override
  Widget build(BuildContext context) {
    bool isMobile = screenWidth < 600;

    return GestureDetector(
      onTap: () => onTap(quiz.qid), // Pass the ID of the question when tapped
      child: Container(
        height: isMobile ? 200 : 250,
        width: isMobile ? screenWidth - 160 : 500, // Adjust the width as needed
        margin: const EdgeInsets.only(bottom: 0.0), // Adjust the margin as needed
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8.0), // Add border radius for rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0.0), // Adjust the padding as needed
                child: Image.asset(
                  path, // Replace with actual image path
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: isMobile ? 120 : double.maxFinite, // Adjust the height for mobile
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ), // Match border radius for rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: TextStyle(
                            fontSize: isMobile ? screenWidth * 0.03 : screenWidth * 0.013,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Text(
                          'Due Date: ${DateFormat('d MMM yy').format(quiz.to)}',
                          style: TextStyle(
                            fontSize: isMobile ? screenWidth * 0.03 : screenWidth * 0.013,
                            color: Colors.grey,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "Attempt Now",
                          style: TextStyle(
                            fontSize: isMobile ? screenWidth * 0.03 : screenWidth * 0.013,
                            color: Colors.red,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

class QuizService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference quizCollection;

  QuizService()
      : quizCollection = FirebaseFirestore.instance
      .collection('PGupload')
      .doc('Weekley')
      .collection('Quiz');

  Future<List<String>> fetchQuizResults() async {
    List<String> subcollectionIds = [];

    User? user = auth.currentUser;
    if (user != null) {
      String userId = user.phoneNumber ?? '';
      CollectionReference quizResultsCollection =
      db.collection('QuizResults').doc(userId).collection('Exam');
      QuerySnapshot subcollectionSnapshot = await quizResultsCollection.get();
      for (var subdocument in subcollectionSnapshot.docs) {
        subcollectionIds.add(subdocument.id);
      }
    }

    return subcollectionIds;
  }

  Future<List<Map<String, dynamic>>> fetchQuizzes(int limit) async {
    try {
      List<String> quizResultsIds = await fetchQuizResults();

      QuerySnapshot querySnapshot = await quizCollection
          .where('speciality', isEqualTo: 'home')
          .limit(limit)
          .get();

      List<Map<String, dynamic>> quizzes = querySnapshot.docs
          .where((doc) => !quizResultsIds.contains(doc.id))
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return quizzes;
    } catch (e, stackTrace) {
      print('Error fetching quizzes: $e\n$stackTrace');
      return [];
    }
  }
}

class QuizPG {
  final String qid;
  final String title;
  final DateTime to;

  QuizPG({required this.qid, required this.title, required this.to});
}
