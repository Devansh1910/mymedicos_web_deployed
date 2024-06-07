import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymedicosweb/QuizResult.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  final String title;

  QuizPage({Key? key, required this.quizId,required this.title}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  List<int?> selectedAnswers = [];
  List<bool> questionsMarkedForReview = [];
  late Timer _timer;
  int _remainingTime = 12600; // Time in seconds (210 minutes)
  bool _timeUp = false;

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timeUp = true;
          _timer.cancel();
        }
      });
    });
  }

  Future<void> _fetchQuizData() async {
    try {
      CollectionReference quizCollection = FirebaseFirestore.instance
          .collection("PGupload")
          .doc("Weekley")
          .collection("Quiz");

      QuerySnapshot querySnapshot = await quizCollection.get();
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        String? qid = document.get('qid'); // Fetch the quiz ID
        print("qid: $qid");

        // Check if qid is not null and matches the widget's quizId
        if (qid != null && qid == widget.quizId) {
          List<dynamic> dataList = data['Data'];
          for (var entry in dataList) {
            Neetpg question = Neetpg(
              question: entry['Question'] ?? '',
              optionA: entry['A'] ?? '',
              optionB: entry['B'] ?? '',
              optionC: entry['C'] ?? '',
              optionD: entry['D'] ?? '',
              correctAnswer: entry['Correct'] ?? '',
              imageUrl: entry['Image'] ?? '',
              description: entry['Description'] ?? '',
            );
            questions.add(question.toMap()); // Convert Neetpg object to a map
            selectedAnswers.add(null);
            questionsMarkedForReview.add(false);
          }

           // Assuming you want to stop after fetching one quiz
        }
      }

      setState(() {}); // Update the UI after fetching data
    } catch (e) {
      print("Error fetching quiz data: $e");
    }
  }

  void selectAnswer(int? answer) {
    setState(() {
      selectedAnswers[currentQuestionIndex] = answer;
    });
  }

  void toggleMarkForReview() {
    setState(() {
      questionsMarkedForReview[currentQuestionIndex] =
      !questionsMarkedForReview[currentQuestionIndex];
    });
  }

  void goToNextQuestion() {
    setState(() {
      currentQuestionIndex = (currentQuestionIndex + 1) % questions.length;
    });
  }

  void goToPreviousQuestion() {
    setState(() {
      currentQuestionIndex = (currentQuestionIndex - 1) % questions.length;
      if (currentQuestionIndex < 0) {
        currentQuestionIndex = questions.length - 1;
      }
    });
  }
  Future<void> _submitQuiz() async {
    int correctAnswers = 0;
    int skip = 0;

    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == null) {
        skip++;
      } else if (questions[i]['Correct'] == selectedAnswers[i].toString()) {
        correctAnswers++;
      }
    }

    int totalQuestions = questions.length;
    int score = (correctAnswers * 100) ~/ totalQuestions; // Example scoring formula

    // Upload the quiz result
    QuizResultUploader uploader = QuizResultUploader();
    await uploader.uploadQuizResult(
      id: widget.quizId,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      remainingTime: _remainingTime,
      score: score,
      skip: skip,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          quizId: widget.quizId,
          quizTitle: widget.title,
          questions: questions,
          selectedAnswers: selectedAnswers,
          remainingTime: _remainingTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                HeaderSection(remainingTime: _remainingTime),
                QuestionSection(
                  question: questions[currentQuestionIndex]['Question'],
                  options: [
                    questions[currentQuestionIndex]['A'],
                    questions[currentQuestionIndex]['B'],
                    questions[currentQuestionIndex]['C'],
                    questions[currentQuestionIndex]['D'],
                  ],
                  selectedAnswer: selectedAnswers[currentQuestionIndex],
                  onAnswerSelected: selectAnswer,
                ),
                NavigationButtons(
                  onNextPressed: goToNextQuestion,
                  onPreviousPressed: goToPreviousQuestion,
                  onMarkForReviewPressed: toggleMarkForReview,

                ),
                ElevatedButton(
                  onPressed: _submitQuiz,
                  child: Text('End Quiz'),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                InstructionPanel(
                  notVisited: selectedAnswers.where((a) => a == null).length,
                  notAnswered: selectedAnswers.where((a) => a == null).length,
                  answered: selectedAnswers.where((a) => a != null).length,
                  markedForReview:
                  questionsMarkedForReview.where((r) => r).length,
                  answeredAndMarkedForReview: selectedAnswers
                      .asMap()
                      .entries
                      .where((entry) =>
                  entry.value != null &&
                      questionsMarkedForReview[entry.key])
                      .length,
                ),
                Expanded(
                  child: QuestionNavigationPanel(
                    questionCount: questions.length,
                    currentQuestionIndex: currentQuestionIndex,
                    questionsMarkedForReview: questionsMarkedForReview,
                    selectedAnswers: selectedAnswers,
                    onSelectQuestion: (index) {
                      setState(() {
                        currentQuestionIndex = index;
                      });
                    },
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

class Neetpg {
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String imageUrl;
  final String description;

  Neetpg({
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.imageUrl,
    required this.description,
  });

  factory Neetpg.fromJson(Map<String, dynamic> json) {
    return Neetpg(
      question: json['Question'] ?? '',
      optionA: json['A'] ?? '',
      optionB: json['B'] ?? '',
      optionC: json['C'] ?? '',
      optionD: json['D'] ?? '',
      correctAnswer: json['Correct'] ?? '',
      imageUrl: json['Image'] ?? '',
      description: json['Description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Question': question,
      'A': optionA,
      'B': optionB,
      'C': optionC,
      'D': optionD,
      'Correct': correctAnswer,
      'Image': imageUrl,
      'Description': description,
    };
  }
}

class HeaderSection extends StatelessWidget {
  final int remainingTime;

  HeaderSection({required this.remainingTime});

  @override
  Widget build(BuildContext context) {
    int hours = remainingTime ~/ 3600;
    int minutes = (remainingTime % 3600) ~/ 60;
    int seconds = remainingTime % 60;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Candidate Name: [Your Name]',
              style: TextStyle(fontSize: 16, fontFamily: 'Inter')),
          Text('Exam Name: NEET PG',
              style: TextStyle(fontSize: 16, fontFamily: 'Inter')),
          Text('Subject Name: English-Paper 2-Dec-2019',
              style: TextStyle(fontSize: 16, fontFamily: 'Inter')),
          Text(
            'Remaining Time: $hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class QuestionSection extends StatelessWidget {
  final String question;
  final List<String> options;
  final int? selectedAnswer;
  final ValueChanged<int?> onAnswerSelected;

  QuestionSection({
    required this.question,
    required this.options,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(question, style: TextStyle(fontSize: 16)),
          SizedBox(height: 20),
          ...options.asMap().entries.map((entry) {
            int idx = entry.key;
            String option = entry.value;
            return ListTile(
              title: Text(option),
              leading: Radio<int?>(
                value: idx,
                groupValue: selectedAnswer,
                onChanged: onAnswerSelected,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class NavigationButtons extends StatelessWidget {
  final VoidCallback? onNextPressed;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onMarkForReviewPressed;

  NavigationButtons(
      {this.onNextPressed, this.onPreviousPressed, this.onMarkForReviewPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: onNextPressed,
          child: Text('Next'),
        ),
        ElevatedButton(
          onPressed: onPreviousPressed,
          child: Text('Previous'),
        ),
        ElevatedButton(
          onPressed: onMarkForReviewPressed,
          child: Text('Mark for Review'),
        ),
      ],
    );
  }
}

class InstructionPanel extends StatelessWidget {
  final int notVisited;
  final int notAnswered;
  final int answered;
  final int markedForReview;
  final int answeredAndMarkedForReview;

  InstructionPanel({
    required this.notVisited,
    required this.notAnswered,
    required this.answered,
    required this.markedForReview,
    required this.answeredAndMarkedForReview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InstructionTile(
          color: Colors.grey,
          label: 'Not Visited',
          count: notVisited,
        ),
        InstructionTile(
          color: Colors.red,
          label: 'Not Answered',
          count: notAnswered,
        ),
        InstructionTile(
          color: Colors.green,
          label: 'Answered',
          count: answered,
        ),
        InstructionTile(
          color: Colors.purple,
          label: 'Marked for Review',
          count: markedForReview,
        ),
        InstructionTile(
          color: Colors.blue,
          label:
          'Answered & Marked for Review (will be considered for evaluation)',
          count: answeredAndMarkedForReview,
        ),
      ],
    );
  }
}

class InstructionTile extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  InstructionTile({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Perform any action on tile tap
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              color: color,
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class QuestionNavigationPanel extends StatelessWidget {
  final int questionCount;
  final int currentQuestionIndex;
  final List<bool> questionsMarkedForReview;
  final List<int?> selectedAnswers;
  final ValueChanged<int> onSelectQuestion;

  QuestionNavigationPanel({
    required this.questionCount,
    required this.currentQuestionIndex,
    required this.questionsMarkedForReview,
    required this.selectedAnswers,
    required this.onSelectQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: questionCount,
        itemBuilder: (context, index) {
          bool markedForReview = questionsMarkedForReview[index];
          bool hasSelectedAnswer = selectedAnswers[index] != null;

          return GestureDetector(
            onTap: () => onSelectQuestion(index),
            child: Container(
              color: markedForReview
                  ? Colors.orange // Marked for review
                  : hasSelectedAnswer
                  ? Colors.green // Has selected answer
                  : currentQuestionIndex == index
                  ? Colors.blue // Current question
                  : Colors.grey, // Default color
              child: Center(child: Text((index + 1).toString())),
            ),
          );
        },
      ),
    );
  }
}

class QuizResultUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadQuizResult({
    required String id,
    required int correctAnswers,
    required int totalQuestions,
    required int remainingTime,
    required int score,
    required int skip,
  }) async {
    try {
      // Get the current user
      String? userId = FirebaseAuth.instance.currentUser?.phoneNumber;
      if (userId != null) {
        // Reference to the user's quiz results collection
        CollectionReference<Map<String, dynamic>> userResultsRef =
        _firestore.collection('QuizResults').doc(userId).collection('Exam');

        // Create a map with the quiz result data
        Map<String, dynamic> resultData = {
          'ID': id,
          'correctAnswers': correctAnswers,
          'totalQuestions': totalQuestions,
          'remainingTime': remainingTime,
          'Score': score,
          'skip': skip,
          'timestamp': Timestamp.now(),
        };

        // Upload the quiz result data to Firestore
        await userResultsRef.add(resultData);
        print('Quiz result uploaded successfully.');
      } else {
        print('User not logged in.');
      }
    } catch (error) {
      print('Error uploading quiz result: $error');
    }
  }
}