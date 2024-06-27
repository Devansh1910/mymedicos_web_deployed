import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mymedicosweb/Home/home.dart';

import 'package:universal_html/html.dart' as html;

class FmgeQuizResultScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final List<int?> selectedAnswers;
  final int remainingTime;
  final String quizTitle;
  final String quizId;
  final String dueDate;


  FmgeQuizResultScreen({
    required this.questions,
    required this.selectedAnswers,
    required this.remainingTime,
    required this.quizTitle,
    required this.quizId,
    required this.dueDate,

  });

  @override
  _FmgeQuizResultScreenState createState() => _FmgeQuizResultScreenState();
}

class _FmgeQuizResultScreenState extends State<FmgeQuizResultScreen> {
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
    context.go('/homescreen');
  }

  @override
  Widget build(BuildContext context) {
    // if (MediaQuery.of(context).viewInsets.bottom == 0.0) {
    //   setState(() {
    //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    //     html.document.exitFullscreen();
    //   });
    //   // Exit full-screen mode
    //
    //   // Optionally clear any other full-screen related cache/settings if needed
    // }


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
    return WillPopScope(
      onWillPop: () async => false,
      child:Scaffold(
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
              automaticallyImplyLeading: !kIsWeb,
              backgroundColor: Colors.white,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.quizTitle,style: TextStyle(fontFamily: 'Inter',fontSize: 24,fontWeight: FontWeight.bold),), // Grandtest heading
                  Text(
                    DateFormat('dd MMMM yyyy').format(DateTime.parse(widget.dueDate)),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              leading: !isMobile ? null : IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Open the drawer when the menu icon is pressed
                },
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
        drawer: Drawer(
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
                    border: Border.all(color: Colors.black, width: 2.0),
                    // Border styling
                    borderRadius: BorderRadius.circular(
                        0.0), // Optional: rounded corners
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
        ),
        body: Container(
          color: Colors.white,
          child: Row(
            children: [
              Expanded(

                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      isMobile ? MobileHeaderSection(
                        timeTaken: widget.remainingTime, // Example values, replace with actual data
                        totalQuestions: 200,
                        correctAnswers: correctAnswers,
                        incorrectAnswers: incorrectAnswers,
                        skippedQuestions: skippedQuestions,
                        totalMarks:totalMarks,
                      ):
                      HeaderSection(
                        timeTaken: widget.remainingTime, // Assuming remainingTime represents time taken in seconds
                        totalQuestions: 200, // Assuming totalQuestions is the total number of questions
                        correctAnswers: correctAnswers,
                        incorrectAnswers: incorrectAnswers,
                        skippedQuestions: skippedQuestions,
                        totalMarks: totalMarks,
                      ),

                      SizedBox(height: 50,),
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        // Set the background color of the question section to white
                        child: QuestionSection(
                          currentquestionindex1:currentQuestionIndex,
                          question: widget
                              .questions[currentQuestionIndex]['Question'],
                          image: widget.questions[currentQuestionIndex]['Image'],
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
                  width: 480,
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
                            border: Border.all(color: Colors.black, width: 2.0),
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
      ),
    );
  }
}


class ImageDisplayWidget extends StatefulWidget {
  final String image;

  const ImageDisplayWidget({Key? key, required this.image}) : super(key: key);

  @override
  _ImageDisplayWidgetState createState() => _ImageDisplayWidgetState();
}

class _ImageDisplayWidgetState extends State<ImageDisplayWidget> {
  void _openFullScreenImage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImage(image: widget.image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openFullScreenImage,
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: CachedNetworkImage(
          imageUrl: widget.image,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String image;

  const FullScreenImage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],  // Changed to grey
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Center(
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 3.0,
            child: CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.contain,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expanantions :',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,fontFamily: 'Inter'),
          ),
          SizedBox(height: 10),
          Html(
            data: description,
            style: {
              'p': Style(fontSize: FontSize(16.0),fontFamily: 'Inter'), // Example style for paragraph tags
              // Add more styles as needed for different HTML tags
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
class MobileHeaderSection extends StatelessWidget {
  final int timeTaken; // Time taken in seconds
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int skippedQuestions;
  final int totalMarks;

  MobileHeaderSection({
    required this.timeTaken,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.skippedQuestions,
    required this.totalMarks,
  });

  @override
  Widget build(BuildContext context) {
    int hours = timeTaken ~/ 3600;
    int minutes = (timeTaken % 3600) ~/ 60;
    int seconds = timeTaken % 60;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Text(
              'NEET PG/Quiz Result:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Summary:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter'
                  ),
                ),
                SizedBox(height: 10),
                _buildInfoBox(
                  icon: Icons.access_time,
                  title: 'Time Taken',
                  subtitle: '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                ),
                SizedBox(width: 10),
                _buildInfoBox(
                  icon: Icons.check_circle,
                  title: 'Correct Answers',
                  subtitle: '$correctAnswers / $totalQuestions',
                ),
                SizedBox(height: 5),
                _buildInfoBox(
                  icon: Icons.cancel,
                  title: 'Incorrect Answers',
                  subtitle: '$incorrectAnswers / $totalQuestions',
                ),
                SizedBox(width: 10),
                _buildInfoBox(
                  icon: Icons.not_interested,
                  title: 'Skipped Questions',
                  subtitle: '$skippedQuestions / $totalQuestions',
                ),
                SizedBox(height: 5),
                _buildInfoBox(
                  icon: Icons.star,
                  title: 'Total Marks',
                  subtitle: '$totalMarks',
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Analytics:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: 250,
                  height: 250,
                  child: AspectRatio(
                    aspectRatio: 1,
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
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPercentageText('Correct:', correctAnswers, totalQuestions),
                    _buildPercentageText('Incorrect:', incorrectAnswers, totalQuestions),
                    _buildPercentageText('Skipped:', skippedQuestions, totalQuestions),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageText(String title, int count, int totalQuestions) {
    double percentage = (count / totalQuestions) * 100;
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(2)}%', // Show percentage with two decimal places
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Opacity(
                  opacity: 0.5, // Adjust opacity as needed
                  child: Icon(
                    icon,
                    size: 40,
                    color: Colors.grey, // Set the color to grey
                  ),
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}



class HeaderSection extends StatelessWidget {
  final int timeTaken; // Time taken in seconds
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int skippedQuestions;
  final int totalMarks;

  HeaderSection({
    required this.timeTaken,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.skippedQuestions,
    required this.totalMarks,
  });

  @override
  Widget build(BuildContext context) {
    int hours = timeTaken ~/ 3600;
    int minutes = (timeTaken % 3600) ~/ 60;
    int seconds = timeTaken % 60;

    return Container(
      height: 500, // Adjusted height to accommodate the heading
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: EdgeInsets.only(left: 20.0), // Add padding to the left
            child: Text(
              'NEET PG/Quiz Result:', // The heading
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),

          SizedBox(height: 20), // Space between the heading and the content
          Row(
            children: [
              SizedBox(width: 50),
              Container(
                width: 500,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Summary:',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter'
                      ),
                    ),
                    SizedBox(height: 10),


                    _buildInfoBox(
                      icon: Icons.access_time,
                      title: 'Time Taken',
                      subtitle: '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    ),
                    SizedBox(width: 10), // Adjusted width between columns
                    _buildInfoBox(
                      icon: Icons.check_circle,
                      title: 'Correct Answers',
                      subtitle: '$correctAnswers / $totalQuestions',
                    ),


                    SizedBox(height: 5),

                    _buildInfoBox(
                      icon: Icons.cancel,
                      title: 'Incorrect Answers',
                      subtitle: '$incorrectAnswers / $totalQuestions',
                    ),
                    SizedBox(width: 10), // Adjusted width between columns
                    _buildInfoBox(
                      icon: Icons.not_interested,
                      title: 'Skipped Questions',
                      subtitle: '$skippedQuestions / $totalQuestions',
                    ),

                    SizedBox(height: 5),
                    _buildInfoBox(
                      icon: Icons.star,
                      title: 'Total Marks',
                      subtitle: '$totalMarks',
                    ),
                  ],
                ),
              ),
              SizedBox(width: 30,),

              Container(
                width: 500,
                height: 400,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 250,
                      height: 250,
                      child: AspectRatio(
                        aspectRatio: 1,
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
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPercentageText('Correct:', correctAnswers, totalQuestions),
                        _buildPercentageText('Incorrect:', incorrectAnswers, totalQuestions),
                        _buildPercentageText('Skipped:', skippedQuestions, totalQuestions),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageText(String title, int count, int totalQuestions) {
    double percentage = (count / totalQuestions) * 100;
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(2)}%', // Show percentage with two decimal places
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Opacity(
                  opacity: 0.5, // Adjust opacity as needed
                  child: Icon(
                    icon,
                    size: 40,
                    color: Colors.grey, // Set the color to grey
                  ),
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
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
  final String image;
  final int currentquestionindex1;

  QuestionSection({
    required this.question,
    required this.options,
    required this.image,
    required this.selectedAnswer,
    required this.currentquestionindex1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question:'+(currentquestionindex1+1).toString(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              question,
              style: TextStyle(fontSize: 16, fontFamily: 'Inter'),
            ),
          ),
          SizedBox(height: 10),
          if (image.isNotEmpty && image != "noimage")
            ImageDisplayWidget(image: image),
          SizedBox(height: 20),
          ...options.asMap().entries.map((entry) {
            int idx = entry.key;
            String option = entry.value;
            String letter = String.fromCharCode(65 + idx); // Convert index to letter (A, B, C, ...)
            return InkWell(

              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: selectedAnswer == idx ?Color(0xFF5BFC8B): Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24, // Adjust the width as needed
                      height: 24, // Adjust the height as needed
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF5BFC8B),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        letter,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Inter'
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: selectedAnswer == idx ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: _customButton(
                    onPressed: onPreviousPressed,
                    label: 'Previous',
                  ),
                ),
                SizedBox(width: 20),
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [




            // Adjust spacing between the two sets of buttons

            _customButton(
              onPressed: onPreviousPressed,
              label: 'Previous',
            ),
            SizedBox(width: 20),


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
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0.0),
        border: Border.symmetric(
          vertical: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 0),
            // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instruction Summary',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter'
            ),
          ),
          SizedBox(height: 8),
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
        margin: EdgeInsets.symmetric(vertical: 8.0,horizontal: 10),
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
    String heading="Navigate and Review :";
    return  SingleChildScrollView(
      child:Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column( // Wrap the GridView.builder inside a Column
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                heading, // Display the heading
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter'
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                " Assure yourself navigate from anywhere", // Display the heading
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Inter'
                ),
              ),
            ),

            Column(
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

          ],
        ),
      ),
    );
  }
}