import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:go_router/go_router.dart';

class AuthWelcomeScreenWidget extends StatefulWidget {
  const AuthWelcomeScreenWidget({super.key});

  @override
  State<AuthWelcomeScreenWidget> createState() => _AuthWelcomeScreenWidgetState();
}

class _AuthWelcomeScreenWidgetState extends State<AuthWelcomeScreenWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingStep> _steps = [
    _OnboardingStep(
      icon: Icons.directions_car,
      title: 'Welcome to Auto Fix',
      subtitle: 'Your intelligent OBD2 diagnostic companion',
      description: 'Get real-time insights into your vehicle\'s health with advanced diagnostics and AI-powered analysis.',
    ),
    _OnboardingStep(
      icon: Icons.bluetooth,
      title: 'Connect Your OBD2',
      subtitle: 'Easy Bluetooth pairing',
      description: 'Pair your OBD2 device for seamless and fast vehicle scans.',
    ),
    _OnboardingStep(
      icon: Icons.analytics,
      title: 'Advanced Diagnostics',
      subtitle: 'Understand your car',
      description: 'Get detailed reports and explanations for trouble codes and vehicle health.',
    ),
    _OnboardingStep(
      icon: Icons.chat_bubble_outline,
      title: 'AI Chat Assistant',
      subtitle: 'Ask anything automotive',
      description: 'Let our AI help you with car questions, maintenance, and troubleshooting.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      // Skip complex terms modal, go directly to login where terms acceptance is handled
      GoRouter.of(context).go('/authLogin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: FlutterFlowTheme.of(context).secondary,
                        child: Icon(step.icon, size: 56, color: FlutterFlowTheme.of(context).primary),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        step.title,
                        style: FlutterFlowTheme.of(context).headlineMedium.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        step.subtitle,
                        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(color: FlutterFlowTheme.of(context).primary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          step.description,
                          style: FlutterFlowTheme.of(context).bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Spacer(flex: 3),
                    ],
                  );
                },
              ),
            ),
            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  width: isActive ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? FlutterFlowTheme.of(context).primary : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            // Next button
            Padding(
              padding: const EdgeInsets.only(bottom: 32, right: 24, left: 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  child: Text(_currentPage == _steps.length - 1 ? 'Get Started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}