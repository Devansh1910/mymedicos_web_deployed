import 'package:flutter/material.dart';
class AlternatingImageTextList extends StatelessWidget {
  final List<String> imagePaths;
  final List<String> titles;
  final List<String> descriptions;

  const AlternatingImageTextList({
    Key? key,
    required this.imagePaths,
    required this.titles,
    required this.descriptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // Define mobile threshold

    return Container(
      width: isMobile ? screenWidth : screenWidth * 0.6, // Adjust width based on screen size
      child: ListView.builder(
        itemCount: titles.length,
        itemBuilder: (context, index) {
          final isEvenIndex = index.isEven;

          if (isMobile) {
            // Mobile layout: stack image and text vertically
            return Container(
              margin: EdgeInsets.symmetric(vertical: 20), // Add margin for spacing
              padding: EdgeInsets.all(16), // Adjust padding for card height
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
                      fit: BoxFit.cover,
                      height: 200, // Fixed height for image
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    titles[index],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(descriptions[index]),
                ],
              ),
            );
          } else {
            // Desktop/tablet layout: alternate image and text horizontally
            return Container(
              margin: EdgeInsets.symmetric(vertical: 20), // Add margin for spacing
              padding: EdgeInsets.all(16), // Adjust padding for card height
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
                          fit: BoxFit.cover,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                        ),
                      ),
                    ),
                  if (isEvenIndex) SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titles[index],
                          style: TextStyle(fontWeight: isEvenIndex ? FontWeight.bold : FontWeight.normal),
                        ),
                        SizedBox(height: 16),
                        Text(
                          descriptions[index],
                          style: TextStyle(fontWeight: isEvenIndex ? FontWeight.normal : FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (!isEvenIndex) SizedBox(width: 16),
                  if (!isEvenIndex)
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imagePaths[index],
                          fit: BoxFit.cover,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
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