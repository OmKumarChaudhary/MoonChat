import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_contents.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _controller;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < contents.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_controller.hasClients) {
        _controller.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  AnimatedContainer _buildDots({
    int? index,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(50),
        ),
        color: _currentPage == index 
            ? const Color(0xFF4A1CFA) // Active dot color (Purple)
            : const Color(0xFF383838), // Inactive dot color (Dark Grey)
      ),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      curve: Curves.easeIn,
      width: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF151522), // Dark background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Listener(
                // Pause/Restart timer on touch using Listener to not block PageView gestures
                onPointerDown: (_) => _timer?.cancel(),
                onPointerUp: (_) => _startAutoPlay(),
                onPointerCancel: (_) => _startAutoPlay(),
                child: PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  controller: _controller,
                  onPageChanged: (value) => setState(() => _currentPage = value),
                  itemCount: contents.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           // Image Section
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Image.asset(
                                contents[i].image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          
                          // Text Section
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                Text(
                                  contents[i].title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Mulish",
                                    fontWeight: FontWeight.w700,
                                    fontSize: (width <= 550) ? 28 : 32,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  contents[i].desc,
                                  style: TextStyle(
                                    color: Colors.white70, // Slightly dimmer text
                                    fontFamily: "Mulish",
                                    fontWeight: FontWeight.w300,
                                    fontSize: (width <= 550) ? 16 : 18,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Dots Section (Fixed Position)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  contents.length,
                  (int index) => _buildDots(
                    index: index,
                  ),
                ),
              ),
            ),
            
            // Buttons Section
            Expanded(
              flex: 1,
              child: Padding(
                // Reduced vertical padding to prevent overflow
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to Signup
                          Navigator.pushNamed(context, '/signup');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A1CFA), // Primary color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16), // Rounded corners
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: "Mulish",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                           // Navigate to Login
                           Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF222232), // Dark button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide.none, 
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "I already have an account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: "Mulish",
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
