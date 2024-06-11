import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymedicosweb/pg_neet/pg_neet_payment.dart';

class RecommendedGrandTest extends StatelessWidget {
  final double screenWidth;
  final QuizService quizService = QuizService(); // Instantiate the QuizService

  RecommendedGrandTest({
    super.key,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Recommended Grand Test',
            style: TextStyle(
              fontSize: screenWidth * 0.015,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            'Go through these examinations for better preparation & get ready for the final buzz!',
            style: TextStyle(
              fontSize: screenWidth * 0.012,
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
              if (snapshot.hasError || !snapshot.hasData) {
                return const Text('Error fetching quizzes');
              }
              List<Map<String, dynamic>> quizzes = snapshot.data!;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth < 600 ? 1 : 2,
                  crossAxisSpacing: 32.0,
                  mainAxisSpacing: 32.0,
                  childAspectRatio: 2, // Adjusts the height of the cards
                ),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  var quiz = quizzes[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the next screen and pass arguments
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PgNeetPayment(
                            title: quiz['title'],
                            quizId: quiz['qid'],
                            dueDate:((quiz['to']as Timestamp).toDate()).toString(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Image.asset(
                              'assets/image/Frame 168.png',
                              fit: BoxFit.cover,
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
                                children: <Widget>[
                                  Text(
                                    quiz['title'],
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.012,
                                      fontFamily: 'Inter',
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                  Text(
                                    'Due Date: ${(quiz['to']as Timestamp).toDate()}',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.012,
                                      color: Colors.grey,
                                      fontFamily: 'Inter',
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class QuizService {
  final CollectionReference quizCollection;

  QuizService()
      : quizCollection = FirebaseFirestore.instance
      .collection('PGupload')
      .doc('Weekley')
      .collection('Quiz');

  Future<List<Map<String, dynamic>>> fetchQuizzes(int limit) async {
    try {
      QuerySnapshot querySnapshot = await quizCollection
          .where('speciality', isEqualTo: 'home')
          .limit(limit)
          .get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e, stackTrace) {
      print('Error fetching quizzes: $e\n$stackTrace');
      return [];
    }
  }
}


class QuizDetailScreen extends StatelessWidget {
  final String title;
  final String quizId;
  final String dueDate;

  QuizDetailScreen({
    super.key,
    required this.title,
    required this.quizId,
    required Timestamp dueDate,
  }) : dueDate = dueDate.toDate().toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Title: $title'),
            Text('Quiz ID: $quizId'),
            Text('Due Date: $dueDate'),
          ],
        ),
      ),
    );
  }
}
