import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mymedicosweb/homescreen2/home_screen_2.dart';

class QuizResultScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final List<int?> selectedAnswers;
  final int remainingTime;
  final String quizTitle;
  final String quizId;
  final String dueDate;


  QuizResultScreen({
    required this.questions,
    required this.selectedAnswers,
    required this.remainingTime,
    required this.quizTitle,
    required this.quizId,
    required this.dueDate,

  });

  @override
  _QuizResultScreenState createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  int currentQuestionIndex = 0;

  int correctAnswers = 0;
  int incorrectAnswers = 0;
  int skippedQuestions = 0;
  int totalMarks = 0;

  @override
  void initState() {
    super.initState();
    _calculateResults();
  }

  void goToNextQuestion() {
    setState(() {
      currentQuestionIndex =
          (currentQuestionIndex + 1) % widget.questions.length;
    });
  }

  void _calculateResults() {
    for (int i = 0; i < widget.questions.length; i++) {
      String correctAnswer = widget.questions[i]['Correct'];
      int? selectedAnswer = widget.selectedAnswers[i];
      String? selectedAnswerText;
      if (selectedAnswer != null) {
        selectedAnswerText = selectedAnswer == 0
            ? widget.questions[i]['A']
            : selectedAnswer == 1
            ? widget.questions[i]['B']
            : selectedAnswer == 2
            ? widget.questions[i]['C']
            : widget.questions[i]['D'];
      }

      if (selectedAnswerText == correctAnswer) {
        correctAnswers++;
      } else if (selectedAnswerText == null) {
        skippedQuestions++;
      } else {
        incorrectAnswers++;
      }
    }
    totalMarks =
        correctAnswers * 4; // Assuming each correct answer gives 4 marks
  }

  void goToPreviousQuestion() {
    setState(() {
      currentQuestionIndex =
          (currentQuestionIndex - 1) % widget.questions.length;
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

  void _navigateTohome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen2(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int hours = widget.remainingTime ~/ 3600;
    int minutes = (widget.remainingTime % 3600) ~/ 60;
    int seconds = widget.remainingTime % 60;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    bool isMobile = screenWidth < 600;

    String selectedAnswerText = widget.selectedAnswers[currentQuestionIndex] !=
        null
        ? (widget.selectedAnswers[currentQuestionIndex] == 0
        ? widget.questions[currentQuestionIndex]['A']
        : widget.selectedAnswers[currentQuestionIndex] == 1
        ? widget.questions[currentQuestionIndex]['B']
        : widget.selectedAnswers[currentQuestionIndex] == 2
        ? widget.questions[currentQuestionIndex]['C']
        : widget.questions[currentQuestionIndex]['D'])
        : 'Not Answered';
    String correctAnswerText = widget
        .questions[currentQuestionIndex]['Correct'];
    bool isCorrect = selectedAnswerText == correctAnswerText;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 1),
        // Adjust the height as needed
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black,
                  width: 1.0), // Border styling for the bottom side
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.quizTitle), // Grandtest heading
                Text(
                  widget.dueDate, // Replace with actual due date
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(
                      8), // Adjust the border radius as needed
                ),
                child: ElevatedButton(
                  onPressed: _navigateTohome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    // Make the button transparent to show the container's background color
                    elevation: 0,
                    // Remove elevation
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8), // Adjust the border radius to match the container
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    // Adjust padding as needed
                    child: Text(
                      'Go Home',
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: isMobile
          ? Drawer(
        child: Column(
          children: [
            InstructionPanel(
              notVisited: widget.selectedAnswers
                  .where((a) => a == null)
                  .length,
              notAnswered: widget.selectedAnswers
                  .where((a) => a == null)
                  .length,
              answered: widget.selectedAnswers
                  .where((a) => a != null)
                  .length,
              markedForReview: 0, // Since this is the result screen, we don't track reviews
              // Same as above
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.0),
                  // Border styling
                  borderRadius: BorderRadius.circular(
                      8.0), // Optional: rounded corners
                ),
                child: QuestionNavigationPanel(
                  questionCount: widget.questions.length,
                  currentQuestionIndex: currentQuestionIndex,
                  questionsMarkedForReview: List<bool>.filled(
                      widget.questions.length, false),
                  selectedAnswers: widget.selectedAnswers,
                  onSelectQuestion: selectQuestion,
                ),
              ),
            ),
          ],
        ),
      )
          : null,
      body: Container(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    HeaderSection(
                      remainingTime: widget.remainingTime,
                      correctAnswers: correctAnswers,
                      incorrectAnswers: incorrectAnswers,
                      skippedQuestions: skippedQuestions,
                      totalMarks: totalMarks,
                    ),
                    SizedBox(height: 50,),
                    Container(
                      color: Colors.white,
                      // Set the background color of the question section to white
                      child: QuestionSection(
                        question: widget
                            .questions[currentQuestionIndex]['Question'],
                        options: [
                          widget.questions[currentQuestionIndex]['A'],
                          widget.questions[currentQuestionIndex]['B'],
                          widget.questions[currentQuestionIndex]['C'],
                          widget.questions[currentQuestionIndex]['D'],
                        ],
                        selectedAnswer: widget
                            .selectedAnswers[currentQuestionIndex],
                      ),
                    ),
                    NavigationButtons(
                      onNextPressed: goToNextQuestion,
                      onPreviousPressed: goToPreviousQuestion,
                    ),
                    DescriptionSection(description: widget
                        .questions[currentQuestionIndex]['Description']),
                  ],
                ),
              ),
            ),
            if (!isMobile)
              Container(
                width: 400,
                // Adjust the width as needed
                color: Colors.white,
                // Background color for the side panel
                child: Column(
                  children: [
                    InstructionPanel(
                      notVisited: widget.selectedAnswers
                          .where((a) => a == null)
                          .length,
                      notAnswered: widget.selectedAnswers
                          .where((a) => a == null)
                          .length,
                      answered: widget.selectedAnswers
                          .where((a) => a != null)
                          .length,
                      markedForReview: 0, // Since this is the result screen, we don't track reviews
                      // Same as above
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.0),
                          // Border styling
                          borderRadius: BorderRadius.circular(
                              0.0), // Optional: rounded corners
                        ),
                        child: QuestionNavigationPanel(
                          questionCount: widget.questions.length,
                          currentQuestionIndex: currentQuestionIndex,
                          questionsMarkedForReview: List<bool>.filled(widget
                              .questions.length, false),
                          selectedAnswers: widget.selectedAnswers,
                          onSelectQuestion: selectQuestion,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DescriptionSection extends StatelessWidget {
  final String description;

  DescriptionSection({required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Html(
            data: description,
            style: {
              'p': Style(fontSize: FontSize(16.0)), // Example style for paragraph tags
              // Add more styles as needed for different HTML tags
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}


class HeaderSection extends StatelessWidget {
  final int remainingTime;
  final int correctAnswers;
  final int incorrectAnswers;
  final int skippedQuestions;
  final int totalMarks;

  HeaderSection({
    required this.remainingTime,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.skippedQuestions,
    required this.totalMarks,
  });

  @override
  Widget build(BuildContext context) {
    int hours = remainingTime ~/ 3600;
    int minutes = (remainingTime % 3600) ~/ 60;
    int seconds = remainingTime % 60;

  return Container(
    height:250,
      padding: EdgeInsets.symmetric(vertical: 16.0 ,horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start, // Added crossAxisAlignment
        children: [
          Expanded(
            flex: 1, // Give the first column some flexibility
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remaining Time: $hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 16,fontFamily: 'Inter'),
                ),
                SizedBox(height: 10),
                Text('Correct Answers: $correctAnswers', style: TextStyle(fontSize: 16,fontFamily: 'Inter')),
                SizedBox(height: 5),
                Text('Incorrect Answers: $incorrectAnswers', style: TextStyle(fontSize: 16,fontFamily: 'Inter')),
                SizedBox(height: 5),
                Text('Skipped Questions: $skippedQuestions', style: TextStyle(fontSize: 16,fontFamily: 'Inter')),
                SizedBox(height: 5),
                Text('Total Marks: $totalMarks', style: TextStyle(fontSize: 16,fontFamily: 'Inter')),
              ],
            ),
          ),
          SizedBox(width: 20), // Add some space between the columns
          Expanded(
            flex: 1, // Give the second column some flexibility
            child: SizedBox(
              height: 200, // Set a fixed height for the PieChart
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: correctAnswers.toDouble(),
                      title: 'Correct',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: incorrectAnswers.toDouble(),
                      title: 'Incorrect',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.grey,
                      value: skippedQuestions.toDouble(),
                      title: 'Skipped',
                      radius: 50,
                    ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
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
          Text('Question:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,fontFamily: 'Inter')),
          SizedBox(height: 10),
          Text(question, style: TextStyle(fontSize: 16,fontFamily: 'Inter')),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return isMobile
            ? Column(
          children: [

            SizedBox(height: 16), // Adjust spacing between the two rows of buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _customButton(
                    onPressed: onPreviousPressed,
                    label: 'Previous',
                  ),
                ),
                Expanded(
                  child: _customButton(
                    onPressed: onNextPressed,
                    label: 'Next',
                  ),
                ),
              ],
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [




            SizedBox(width: 200), // Adjust spacing between the two sets of buttons

            _customButton(
              onPressed: onPreviousPressed,
              label: 'Previous',
            ),


            _customButton(
              onPressed: onNextPressed,
              label: 'Next',


            ),
            SizedBox(width: 10),
          ],
        );
      },
    );
  }

  Widget _customButton({VoidCallback? onPressed, required String label}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
class InstructionPanel extends StatelessWidget {
  final int notVisited;
  final int notAnswered;
  final int answered;
  final int markedForReview;

  InstructionPanel({
    required this.notVisited,
    required this.notAnswered,
    required this.answered,
    required this.markedForReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8.0), // Add left padding
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
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
        ],
      ),
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
              decoration: BoxDecoration(
                color: Colors.white, // Inside color
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(10), // Slightly rounded corners
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color, // Text color same as border color
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color, // Label color same as border color
              ),
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
      padding: const EdgeInsets.all(4.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // Disable internal scrolling
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: questionCount,
              itemBuilder: (context, index) {
                bool markedForReview = questionsMarkedForReview[index];
                bool hasSelectedAnswer = selectedAnswers[index] != null;

                Color borderColor = Colors.grey; // Default color
                if (markedForReview) {
                  borderColor = Colors.purple;
                } else if (hasSelectedAnswer) {
                  borderColor = Colors.green;
                } else if (currentQuestionIndex == index) {
                  borderColor = Colors.blue;
                }

                return GestureDetector(
                  onTap: () => onSelectQuestion(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Inside color
                      border: Border.all(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(10), // Slightly rounded corners
                    ),
                    child: Center(
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: borderColor, // Text color same as border color
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
