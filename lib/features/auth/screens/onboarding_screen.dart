import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/themes/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data for the onboarding slides with a more "Pro" editorial feel
  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': StringConstants.onboarding1Title,
      'subtitle': StringConstants.onboarding1Subtitle,
      'icon': Icons.local_florist_outlined,
      'color': AppTheme.backgroundColor,
      'accent': AppTheme.primaryColor,
    },
    {
      'title': StringConstants.onboarding2Title,
      'subtitle': StringConstants.onboarding2Subtitle,
      'icon': Icons.auto_awesome_outlined,
      'color': const Color(0xFFF2F4F9), // Soft Blue-Grey
      'accent': AppTheme.secondaryColor,
    },
    {
      'title': StringConstants.onboarding3Title,
      'subtitle': StringConstants.onboarding3Subtitle,
      'icon': Icons.verified_outlined,
      'color': const Color(0xFFFDF2F2), // Blush Pink
      'accent': const Color(0xFF8E6E6E), // Muted Rose
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = _onboardingData[_currentPage];

    return Scaffold(
      backgroundColor: currentTheme['color'],
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: currentTheme['color'],
        child: Stack(
          children: [
            // Background Decorative Element
            Positioned(
              top: -100,
              right: -50,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: (currentTheme['accent'] as Color).withValues(
                    alpha: 0.05,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) =>
                  OnboardingPage(data: _onboardingData[index]),
            ),

            // Top Navigation
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    StringConstants.appName.toUpperCase(),
                    style: const TextStyle(
                      letterSpacing: 4,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  if (_currentPage != _onboardingData.length - 1)
                    TextButton(
                      onPressed: () => _pageController.jumpToPage(
                        _onboardingData.length - 1,
                      ),
                      child: Text(
                        StringConstants.skip,
                        style: TextStyle(
                          letterSpacing: 1,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 60,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => buildDot(index, currentTheme['accent']),
                    ),
                  ),

                  // Circular Action Button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        context.go(AppRoutes.login);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 70,
                      width: _currentPage == _onboardingData.length - 1
                          ? 160
                          : 70,
                      decoration: BoxDecoration(
                        color: currentTheme['accent'],
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: (currentTheme['accent'] as Color).withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _currentPage == _onboardingData.length - 1
                            ? const Text(
                                StringConstants.getStarted,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 20,
                              ),
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

  Widget buildDot(int index, Color accentColor) {
    final bool isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 4,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected ? accentColor : accentColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({required this.data, super.key});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Visual Asset Area
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(data['icon'], size: 120, color: data['accent']),
          ),
        ),
        const SizedBox(height: 60),
        // Editorial Text Content
        Text(
          data['title'],
          style: const TextStyle(
            fontSize: 36,
            height: 1.1,
            fontWeight: FontWeight.w300,
            color: Color(0xFF1A1A1A),
            fontFamily: 'Serif',
          ),
        ),
        const SizedBox(height: 24),
        Text(
          data['subtitle'],
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black.withValues(alpha: 0.5),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 120), // Spacer for bottom UI
      ],
    ),
  );
}
