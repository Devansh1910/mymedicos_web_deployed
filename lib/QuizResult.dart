import 'package:flutter/material.dart';

class QuizResultScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final List<int?> selectedAnswers;
  final int remainingTime;
  final String quizTitle;
  final String quizId;

  QuizResultScreen({
    required this.questions,
    required this.selectedAnswers,
    required this.remainingTime,
    required this.quizTitle,
    required this.quizId,
  });

  @override
  _QuizResultScreenState createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  int currentQuestionIndex = 0;

  void goToNextQuestion() {
    setState(() {
      currentQuestionIndex = (currentQuestionIndex + 1) % widget.questions.length;
    });
  }

  void goToPreviousQuestion() {
    setState(() {
      currentQuestionIndex = (currentQuestionIndex - 1) % widget.questions.length;
      if (currentQuestionIndex < 0) {
        currentQuestionIndex = widget.questions.length - 1;
      }
    });
  }

  void selectQuestion(int index) {
    setState(() {
      currentQuestionIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    int hours = widget.remainingTime ~/ 3600;
    int minutes = (widget.remainingTime % 3600) ~/ 60;
    int seconds = widget.remainingTime % 60;

    String selectedAnswerText = widget.selectedAnswers[currentQuestionIndex] != null
        ? (widget.selectedAnswers[currentQuestionIndex] == 0
        ? widget.questions[currentQuestionIndex]['A']
        : widget.selectedAnswers[currentQuestionIndex] == 1
        ? widget.questions[currentQuestionIndex]['B']
        : widget.selectedAnswers[currentQuestionIndex] == 2
        ? widget.questions[currentQuestionIndex]['C']
        : widget.questions[currentQuestionIndex]['D'])
        : 'Not Answered';
    String correctAnswerText = widget.questions[currentQuestionIndex]['Correct'];
    bool isCorrect = selectedAnswerText == correctAnswerText;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Result'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                HeaderSection(
                  remainingTime: widget.remainingTime,
                  quizTitle: widget.quizTitle,
                  quizId: widget.quizId,
                ),
                QuestionSection(
                  question: widget.questions[currentQuestionIndex]['Question'],
                  options: [
                    widget.questions[currentQuestionIndex]['A'],
                    widget.questions[currentQuestionIndex]['B'],
                    widget.questions[currentQuestionIndex]['C'],
                    widget.questions[currentQuestionIndex]['D'],
                  ],
                  selectedAnswer: widget.selectedAnswers[currentQuestionIndex],
                ),
                NavigationButtons(
                  onNextPressed: goToNextQuestion,
                  onPreviousPressed: goToPreviousQuestion,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                InstructionPanel(
                  notVisited: widget.selectedAnswers.where((a) => a == null).length,
                  notAnswered: widget.selectedAnswers.where((a) => a == null).length,
                  answered: widget.selectedAnswers.where((a) => a != null).length,
                  markedForReview: 0, // Since this is the result screen, we don't track reviews
                  answeredAndMarkedForReview: 0, // Same as above
                ),
                Expanded(
                  child: QuestionNavigationPanel(
                    questionCount: widget.questions.length,
                    currentQuestionIndex: currentQuestionIndex,
                    questionsMarkedForReview: List<bool>.filled(widget.questions.length, false),
                    selectedAnswers: widget.selectedAnswers,
                    onSelectQuestion: selectQuestion,
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

class HeaderSection extends StatelessWidget {
  final int remainingTime;
  final String quizTitle;
  final String quizId;

  HeaderSection({required this.remainingTime, required this.quizTitle, required this.quizId});

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
          Text('Quiz Title: $quizTitle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Quiz ID: $quizId', style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
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

  QuestionSection({
    required this.question,
    required this.options,
    required this.selectedAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                onChanged: null, // Disabled in result screen
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

  NavigationButtons({this.onNextPressed, this.onPreviousPressed});

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
          bool hasSelectedAnswer = selectedAnswers[index] != null;

          return GestureDetector(
            onTap: () => onSelectQuestion(index),
            child: Container(
              decoration: BoxDecoration(
                color: hasSelectedAnswer ? Colors.green : Colors.red,
                border: Border.all(
                  color: currentQuestionIndex == index ? Colors.blue : Colors.transparent,
                  width: 2.0,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
