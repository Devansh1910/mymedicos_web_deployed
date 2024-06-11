import 'package:flutter/material.dart';

class AlternatingImageTextList extends StatelessWidget {
  final List<String> imagePaths;
  final List<String> titles;
  final List<String> descriptions;

  const AlternatingImageTextList({
    super.key,
    required this.imagePaths,
    required this.titles,
    required this.descriptions,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // Define mobile threshold

    return SizedBox(
      width: isMobile
          ? screenWidth
          : screenWidth * 0.6, // Adjust width based on screen size
      child: ListView.builder(
        itemCount: titles.length,
        itemBuilder: (context, index) {
          final isEvenIndex = index.isEven;

          if (isMobile) {
            // Mobile layout: stack image and text vertically
            return Container(
              margin: const EdgeInsets.symmetric(
                  vertical: 20), // Add margin for spacing
              padding:
                  const EdgeInsets.all(16), // Adjust padding for card height
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      imagePaths[index],
                      fit: BoxFit.fitHeight,
                      height: 200, // Fixed height for image
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    titles[index],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20, // Title font size
                        fontFamily: String.fromEnvironment('Inter-SemiBold')),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    descriptions[index],
                    style: const TextStyle(
                        fontSize: 16,
                        fontFamily: String.fromEnvironment('Inter-Regular')),
                  ),
                ],
              ),
            );
          } else {
            // Desktop/tablet layout: alternate image and text horizontally
            return Container(
              margin: const EdgeInsets.symmetric(
                  vertical: 20), // Add margin for spacing
              padding:
                  const EdgeInsets.all(16), // Adjust padding for card height
              height: 300, // Adjust height of the container
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEvenIndex)
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imagePaths[index],
                          fit: BoxFit.contain,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  if (isEvenIndex) const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titles[index],
                          style: TextStyle(
                            fontWeight: isEvenIndex
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 24, // Title font size
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          descriptions[index],
                          style: TextStyle(
                            fontWeight: isEvenIndex
                                ? FontWeight.normal
                                : FontWeight.bold,
                            fontSize: 16, // Description font size
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isEvenIndex) const SizedBox(width: 16),
                  if (!isEvenIndex)
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imagePaths[index],
                          fit: BoxFit.cover,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
