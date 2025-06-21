import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';

class UpgradeProScreen extends StatefulWidget {
  const UpgradeProScreen({super.key});

  @override
  State<UpgradeProScreen> createState() => _UpgradeProScreenState();
}

class _UpgradeProScreenState extends State<UpgradeProScreen> {
  String _selectedPlan = 'monthly';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Unlimited Scans',
      'description': 'No daily limits on diagnostic scans',
      'icon': Icons.all_inclusive,
      'free': false,
      'pro': true,
    },
    {
      'title': 'Advanced Analytics',
      'description': 'Detailed reports and trend analysis',
      'icon': Icons.analytics,
      'free': false,
      'pro': true,
    },
    {
      'title': 'Export Reports',
      'description': 'Export data in multiple formats',
      'icon': Icons.download,
      'free': false,
      'pro': true,
    },
    {
      'title': 'Priority Support',
      'description': '24/7 customer support',
      'icon': Icons.support_agent,
      'free': false,
      'pro': true,
    },
    {
      'title': 'Cloud Backup',
      'description': 'Automatic data backup',
      'icon': Icons.cloud_upload,
      'free': false,
      'pro': true,
    },
    {
      'title': 'Multiple Vehicles',
      'description': 'Manage unlimited vehicles',
      'icon': Icons.directions_car,
      'free': true,
      'pro': true,
    },
    {
      'title': 'Basic Scans',
      'description': '5 scans per day',
      'icon': Icons.speed,
      'free': true,
      'pro': true,
    },
    {
      'title': 'Email Support',
      'description': 'Basic email support',
      'icon': Icons.email,
      'free': true,
      'pro': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        elevation: 0,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30,
          borderWidth: 1,
          buttonSize: 60,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 30,
          ),
          onPressed: () async {
            context.go('/profile-settings');
          },
        ),
        title: Text(
          'Upgrade to Pro',
          style: FlutterFlowTheme.of(context).titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPricingSection(),
            const SizedBox(height: 24),
            _buildFeatureComparison(),
            const SizedBox(height: 24),
            _buildTestimonialSection(),
            const SizedBox(height: 24),
            _buildUpgradeButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700),
            const Color(0xFFFFA500),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const FaIcon(
              FontAwesomeIcons.crown,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Unlock Premium Features',
            style: FlutterFlowTheme.of(context).titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Get unlimited scans, advanced analytics, and priority support',
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Plan',
            style: FlutterFlowTheme.of(context).titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPlanCard(
                  'Monthly',
                  '\$9.99',
                  '/month',
                  _selectedPlan == 'monthly',
                  () => setState(() => _selectedPlan = 'monthly'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlanCard(
                  'Yearly',
                  '\$99.99',
                  '/year',
                  _selectedPlan == 'yearly',
                  () => setState(() => _selectedPlan = 'yearly'),
                  isPopular: true,
                ),
              ),
            ],
          ),
          if (_selectedPlan == 'yearly') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Save 17% with yearly plan',
                    style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanCard(String title, String price, String period, bool isSelected, VoidCallback onTap, {bool isPopular = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1)
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isPopular) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'POPULAR',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              title,
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: FlutterFlowTheme.of(context).titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                Text(
                  period,
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feature Comparison',
            style: FlutterFlowTheme.of(context).titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Feature',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Free',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Pro',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD700),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._features.map((feature) => _buildFeatureRow(feature)),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(Map<String, dynamic> feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  feature['icon'],
                  size: 16,
                  color: FlutterFlowTheme.of(context).primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'],
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        feature['description'],
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Icon(
              feature['free'] ? Icons.check : Icons.close,
              color: feature['free'] ? Colors.green : Colors.grey,
              size: 16,
            ),
          ),
          Expanded(
            child: Icon(
              feature['pro'] ? Icons.check : Icons.close,
              color: feature['pro'] ? const Color(0xFFFFD700) : Colors.grey,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
            FlutterFlowTheme.of(context).secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'What Our Users Say',
                style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTestimonial(
            'John D.',
            'Professional Mechanic',
            'The Pro features have saved me hours of diagnostic work. The unlimited scans and detailed reports are invaluable.',
            Icons.person,
          ),
          const SizedBox(height: 12),
          _buildTestimonial(
            'Sarah M.',
            'Car Enthusiast',
            'Upgrading to Pro was the best decision. The advanced analytics help me understand my vehicle better.',
            Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonial(String name, String role, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: FlutterFlowTheme.of(context).primary),
              const SizedBox(width: 8),
              Text(
                name,
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• $role',
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _upgradeToPro(),
          icon: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const FaIcon(FontAwesomeIcons.crown),
          label: Text(_isLoading ? 'Processing...' : 'Upgrade to Pro'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Start with a 7-day free trial. Cancel anytime.',
          style: FlutterFlowTheme.of(context).bodySmall.copyWith(
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.security, size: 16, color: FlutterFlowTheme.of(context).secondaryText),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Secure payment powered by Stripe',
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _upgradeToPro() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate upgrade process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const FaIcon(FontAwesomeIcons.crown, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            const Text('Welcome to Pro!'),
          ],
        ),
        content: const Text(
          'Your Pro subscription has been activated! You now have access to all premium features including unlimited scans, advanced analytics, and priority support.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/profile-settings');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.white,
            ),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }
} 