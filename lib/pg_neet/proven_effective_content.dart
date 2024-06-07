import 'package:flutter/material.dart';

class ProvenEffectiveContent extends StatelessWidget {
  final double screenWidth;

  ProvenEffectiveContent({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth,
      decoration: const BoxDecoration(
        color: Color(0xFFEAFBF9),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proven Effective Content',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          const Text(
            'Concise, high yield, highly effective content that yields results. The strike rate proves it.',
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: const [
                    FeatureCard(
                      imagePath: 'assets/top_quality_content.png',
                      title: 'Top Quality Content',
                      description: 'Enrich your knowledge with highly informative, engaging content crafted by the Dream Team.',
                    ),
                    FeatureCard(
                      imagePath: 'assets/learn_anytime_anywhere.png',
                      title: 'Learn Anytime, Anywhere',
                      description: 'Access the best quality content and turn any place into a classroom whenever you want.',
                    ),
                    FeatureCard(
                      imagePath: 'assets/in_depth_analytics.png',
                      title: 'In-Depth Analytics',
                      description: 'Evaluate your strengths and shortcomings with the help of performance graphs.',
                    ),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: const [
                      FeatureCard(
                        imagePath: 'assets/top_quality_content.png',
                        title: 'Top Quality Content',
                        description: 'Enrich your knowledge with highly informative, engaging content crafted by the Dream Team.',
                      ),
                      FeatureCard(
                        imagePath: 'assets/learn_anytime_anywhere.png',
                        title: 'Learn Anytime, Anywhere',
                        description: 'Access the best quality content and turn any place into a classroom whenever you want.',
                      ),
                      FeatureCard(
                        imagePath: 'assets/in_depth_analytics.png',
                        title: 'In-Depth Analytics',
                        description: 'Evaluate your strengths and shortcomings with the help of performance graphs.',
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
class FeatureCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const FeatureCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final double cardWidth = isMobile ? screenWidth * 0.9 : screenWidth / 3 - 24;

    return Container(
      width: cardWidth,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: isMobile ? 0 : 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9, // Adjust the aspect ratio as needed
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FeatureCardList extends StatelessWidget {
  final List<FeatureCard> cards;

  const FeatureCardList({
    Key? key,
    required this.cards,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 30, vertical: 20),
      child: isMobile
          ? Column(
        children: cards,
      )
          : Wrap(
        spacing: 12,
        runSpacing: 12,
        children: cards,
      ),
    );
  }
}