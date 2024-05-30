import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLargeScreen = screenSize.width > 800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            SvgPicture.asset('assets/image/logo.svg', height: 40),
            const SizedBox(width: 10),
            Text(
              'mymedicos',
              style: TextStyle(fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/image/background.svg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isLargeScreen ? 1200 : screenSize.width * 0.95),
              child: isLargeScreen
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: CarouselWithCustomText(),
                  ),
                  const SizedBox(width: 200),
                  Expanded(
                    flex: 1,
                    child: LoginForm(screenSize: screenSize, isLargeScreen: isLargeScreen),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CarouselWithCustomText(),
                  const SizedBox(height: 20),
                  LoginForm(screenSize: screenSize, isLargeScreen: isLargeScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({
    Key? key,
    required this.screenSize,
    required this.isLargeScreen,
  }) : super(key: key);

  final Size screenSize;
  final bool isLargeScreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(isLargeScreen ? 20 : 10),
      padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 45 : 10, horizontal: isLargeScreen ? 20 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Let\'s get started',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Enter your mobile number to Sign up/Sign in to your account',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CountryCodeDropdown(),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Phone Number',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text(
                'Continue',
                style: TextStyle(color: Colors.black, fontFamily: 'Inter'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: screenSize.width > 800 ? 80 : 50,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'By signing up, you agree to Terms & Conditions and Privacy Policy',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CarouselWithCustomText extends StatefulWidget {
  @override
  _CarouselWithCustomTextState createState() => _CarouselWithCustomTextState();
}

class _CarouselWithCustomTextState extends State<CarouselWithCustomText> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  final List<String> captions = [
    'Embarking on the PG NEET Journey',
    'Strategies, Tools, and Insights for Success with mymedicos',
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, -20),
            child: CarouselSlider(
              items: captions.map((caption) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Embarking on the ',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'Inter'),
                            ),
                            TextSpan(
                              text: 'PG NEET Journey',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'Inter'),
                            ),
                            TextSpan(
                              text: ' ',
                              style: TextStyle(fontSize: 24, fontFamily: 'Inter'),
                            ),
                            TextSpan(
                              text: 'Strategies, Tools, and Insights ',
                              style: TextStyle(fontSize: 24, fontFamily: 'Inter'),
                            ),
                            TextSpan(
                              text: 'for Success with mymedicos',
                              style: TextStyle(fontSize: 24, fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              carouselController: _controller,
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 16 / 9,
                enlargeCenterPage: true,
                height: 200,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: captions.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == entry.key
                        ? Color.fromRGBO(0, 0, 0, 0.9)
                        : Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
class CountryCodeDropdown extends StatefulWidget {
  @override
  _CountryCodeDropdownState createState() => _CountryCodeDropdownState();
}

class _CountryCodeDropdownState extends State<CountryCodeDropdown> {
  String currentCode = '+91';
  final List<CountryCode> codes = [
    CountryCode(code: '+1', flagUri: 'assets/image/flag1.svg'),
    CountryCode(code: '+91', flagUri: 'assets/image/flag2.svg'),
    CountryCode(code: '+44', flagUri: 'assets/image/flag3.svg'),
    CountryCode(code: '+81', flagUri: 'assets/image/flag4.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
        value: currentCode,
        icon: const Icon(Icons.arrow_drop_down),
        underline: Container(
          height: 1,
          color: Colors.deepPurpleAccent,
        ),
        onChanged: (String? newValue) {
          setState(() {
            currentCode = newValue!;
          });
        },
        items: codes.map<DropdownMenuItem<String>>((CountryCode code) {
      return DropdownMenuItem<String>(
          value: code.code,
          child: Row(
          children: [
          code.flagUri.endsWith('.svg')
          ? SvgPicture.asset(code.flagUri, width: 20, height: 12)
          : Image.asset(code.flagUri, width: 20, height: 12),
    const SizedBox(width: 8),
            Text(code.code),
          ],
          ),
      );
        }).toList(),
    );
  }
}

class CountryCode {
  final String code;
  final String flagUri;

  CountryCode({required this.code, required this.flagUri});
}

