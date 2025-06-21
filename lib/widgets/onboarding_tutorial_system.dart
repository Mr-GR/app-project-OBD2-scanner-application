import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

class OnboardingTutorialSystem {
  static const String _onboardingCompleteKey = 'onboarding_complete';

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  static Future<bool> hasSeenTutorial(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorial_$tutorialId') ?? false;
  }

  static Future<void> markTutorialSeen(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_$tutorialId', true);
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Auto Fix',
      subtitle: 'Your intelligent OBD2 diagnostic companion',
      description: 'Get real-time insights into your vehicle\'s health with advanced diagnostics and AI-powered analysis.',
      icon: Icons.car_repair,
      color: Colors.blue,
    ),
    OnboardingPage(
      title: 'Smart Diagnostics',
      subtitle: 'Advanced OBD2 scanning',
      description: 'Connect to your vehicle and get detailed diagnostic reports with trouble codes, live data, and emissions status.',
      icon: Icons.analytics,
      color: Colors.green,
    ),
    OnboardingPage(
      title: 'AI-Powered Analysis',
      subtitle: 'Intelligent recommendations',
      description: 'Get personalized recommendations and explanations for diagnostic issues using advanced AI technology.',
      icon: Icons.psychology,
      color: Colors.purple,
    ),
    OnboardingPage(
      title: 'Vehicle Management',
      subtitle: 'Keep track of your fleet',
      description: 'Manage multiple vehicles, track maintenance history, and monitor performance over time.',
      icon: Icons.directions_car,
      color: Colors.orange,
    ),
    OnboardingPage(
      title: 'Ready to Start',
      subtitle: 'Let\'s get your vehicle checked',
      description: 'Connect your OBD2 device and start monitoring your vehicle\'s health today.',
      icon: Icons.check_circle,
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: FlutterFlowTheme.of(context).headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: FlutterFlowTheme.of(context).titleMedium.copyWith(
              color: page.color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            page.description,
            style: FlutterFlowTheme.of(context).bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page indicators
          Row(
            children: List.generate(_pages.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? FlutterFlowTheme.of(context).primary
                      : Colors.grey[300],
                ),
              );
            }),
          ),
          
          // Next/Get Started button
          ElevatedButton(
            onPressed: () {
              if (_currentPage < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                _completeOnboarding();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _completeOnboarding() async {
    await OnboardingTutorialSystem.markOnboardingComplete();
    if (mounted) {
      GoRouter.of(context).go('/home');
    }
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final List<TutorialStep> steps;
  final String tutorialId;
  final VoidCallback? onComplete;

  const TutorialOverlay({
    super.key,
    required this.child,
    required this.steps,
    required this.tutorialId,
    this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    final hasSeen = await OnboardingTutorialSystem.hasSeenTutorial(widget.tutorialId);
    if (!hasSeen) {
      setState(() {
        _showTutorial = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showTutorial && _currentStep < widget.steps.length)
          _buildTutorialOverlay(),
      ],
    );
  }

  Widget _buildTutorialOverlay() {
    final step = widget.steps[_currentStep];
    
    return Container(
      color: Colors.black54,
      child: Stack(
        children: [
          // Highlighted area
          Positioned(
            left: step.targetRect.left,
            top: step.targetRect.top,
            child: Container(
              width: step.targetRect.width,
              height: step.targetRect.height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          
          // Tooltip
          Positioned(
            left: step.tooltipPosition.dx,
            top: step.tooltipPosition.dy,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 250),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    step.title,
                    style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.description,
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_currentStep + 1} of ${widget.steps.length}',
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          if (_currentStep > 0)
                            TextButton(
                              onPressed: _previousStep,
                              child: const Text('Previous'),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _nextStep,
                            child: Text(
                              _currentStep < widget.steps.length - 1 ? 'Next' : 'Finish',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _completeTutorial() async {
    await OnboardingTutorialSystem.markTutorialSeen(widget.tutorialId);
    setState(() {
      _showTutorial = false;
    });
    widget.onComplete?.call();
  }
}

class TutorialStep {
  final String title;
  final String description;
  final Rect targetRect;
  final Offset tooltipPosition;

  TutorialStep({
    required this.title,
    required this.description,
    required this.targetRect,
    required this.tooltipPosition,
  });
}

class ContextualHelpWidget extends StatelessWidget {
  final String helpText;
  final String? title;
  final IconData? icon;

  const ContextualHelpWidget({
    super.key,
    required this.helpText,
    this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showHelpDialog(context),
      icon: Icon(
        icon ?? Icons.help_outline,
        size: 20,
        color: FlutterFlowTheme.of(context).secondaryText,
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: FlutterFlowTheme.of(context).primary,
            ),
            const SizedBox(width: 8),
            Text(title ?? 'Help'),
          ],
        ),
        content: Text(helpText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'How do I connect my OBD2 device?',
      answer: 'To connect your OBD2 device, go to Settings > Connection Settings and follow the pairing instructions. Make sure your device is compatible with ELM327 protocol.',
    ),
    FAQItem(
      question: 'What does the check engine light mean?',
      answer: 'The check engine light indicates that your vehicle\'s onboard diagnostic system has detected a problem. Use our app to scan for trouble codes and get detailed information.',
    ),
    FAQItem(
      question: 'How accurate are the diagnostic reports?',
      answer: 'Our diagnostic reports are based on industry-standard OBD2 protocols and provide accurate information about your vehicle\'s condition. However, always consult a professional mechanic for serious issues.',
    ),
    FAQItem(
      question: 'Can I use this app with any vehicle?',
      answer: 'This app works with most vehicles manufactured after 1996 that support OBD2 protocol. Some older or specialized vehicles may not be compatible.',
    ),
    FAQItem(
      question: 'How do I export my diagnostic reports?',
      answer: 'You can export diagnostic reports as PDF files. Go to the report details and tap the share button to export or share the report.',
    ),
    FAQItem(
      question: 'What is the difference between pending and confirmed trouble codes?',
      answer: 'Pending codes are detected but not yet confirmed by the vehicle\'s computer. Confirmed codes have been verified and are more likely to cause the check engine light to illuminate.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          return _buildFAQItem(_faqs[index]);
        },
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: FlutterFlowTheme.of(context).titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq.answer,
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}

class VideoGuideWidget extends StatelessWidget {
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;

  const VideoGuideWidget({
    super.key,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 60,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '5:30',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _playVideo(context),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Watch Video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _playVideo(BuildContext context) {
    // Implementation for video playback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playing video: $title')),
    );
  }
} 