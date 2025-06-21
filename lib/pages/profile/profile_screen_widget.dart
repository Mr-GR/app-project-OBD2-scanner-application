import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import 'package:o_b_d2_scanner_frontend/backend/services/subscription_service.dart';

class ProfileScreenWidget extends StatefulWidget {
  const ProfileScreenWidget({super.key});

  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late SubscriptionService _subscriptionService;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _subscriptionService = SubscriptionService();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _subscriptionService,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
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
              context.pop();
            },
          ),
          title: Text(
            'Profile',
            style: FlutterFlowTheme.of(context).titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 16),
                _buildTabBar(),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            _buildProUpgradeCard(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPersonalTab(),
                  _buildSettingsTab(),
                  _buildSupportTab(),
                  _buildAccountTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        final isPro = subscriptionService.isPro;
        final isTrial = subscriptionService.isTrialActive;
        final remainingTrialDays = subscriptionService.remainingTrialDays;
        
        String planText = 'Free Plan';
        Color planColor = Colors.white.withValues(alpha: 0.2);
        
        if (isPro) {
          planText = 'Pro Plan';
          planColor = const Color(0xFFFFD700).withValues(alpha: 0.2);
        } else if (isTrial) {
          planText = 'Pro Trial (${remainingTrialDays}d left)';
          planColor = const Color(0xFFFFD700).withValues(alpha: 0.2);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FlutterFlowTheme.of(context).primary,
                FlutterFlowTheme.of(context).secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'john.doe@example.com',
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: planColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPro || isTrial) ...[
                            const FaIcon(
                              FontAwesomeIcons.crown,
                              color: Color(0xFFFFD700),
                              size: 10,
                            ),
                            const SizedBox(width: 3),
                          ],
                          Text(
                            planText,
                            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit profile coming soon!')),
                  );
                },
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
        labelStyle: FlutterFlowTheme.of(context).bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: FlutterFlowTheme.of(context).bodySmall,
        tabs: const [
          Tab(
            icon: Icon(Icons.person_outline, size: 20),
            text: 'Personal',
          ),
          Tab(
            icon: Icon(Icons.settings_outlined, size: 20),
            text: 'Settings',
          ),
          Tab(
            icon: Icon(Icons.help_outline, size: 20),
            text: 'Support',
          ),
          Tab(
            icon: Icon(Icons.account_circle_outlined, size: 20),
            text: 'Account',
          ),
        ],
      ),
    );
  }

  Widget _buildProUpgradeCard() {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        final isPro = subscriptionService.isPro;
        final isTrial = subscriptionService.isTrialActive;
        
        // Don't show upgrade card if user is already pro
        if (isPro) {
          return Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700),
                  const Color(0xFFFFA500),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.crown,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pro Active',
                        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'You have access to all premium features',
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Show upgrade card for free users or trial users
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFD700),
                const Color(0xFFFFA500),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.crown,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTrial ? 'Continue Pro' : 'Upgrade to Pro',
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isTrial ? 'Keep your premium features' : 'Unlock premium features',
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: subscriptionService.isLoading ? null : () {
                  _showProUpgradeDialog();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFFA500),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  subscriptionService.isLoading 
                      ? 'Loading...' 
                      : (isTrial ? 'Continue' : 'Upgrade'),
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSection(
            'Personal Information',
            [
              _buildProfileItem(
                icon: Icons.person_outline,
                title: 'Personal Information',
                subtitle: 'Name, email, phone number',
                onTap: () => _showEditProfileDialog(),
              ),
              _buildProfileItem(
                icon: Icons.location_on_outlined,
                title: 'Location',
                subtitle: 'Manage location settings',
                onTap: () => _showLocationSettings(),
              ),
              _buildProfileItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Push notifications, email alerts',
                onTap: () => _showNotificationSettings(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSection(
            'App Settings',
            [
              _buildProfileItem(
                icon: Icons.bluetooth_outlined,
                title: 'OBD2 Connection',
                subtitle: 'Bluetooth settings, device management',
                onTap: () => context.push('/connection-settings'),
              ),
              _buildProfileItem(
                icon: Icons.data_usage_outlined,
                title: 'Data & Storage',
                subtitle: 'Cache management, data usage',
                onTap: () => _showDataSettings(),
              ),
              _buildProfileItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy & Security',
                subtitle: 'Data privacy, security settings',
                onTap: () => _showPrivacySettings(),
              ),
              _buildProfileItem(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Theme, language, display settings',
                onTap: () => _showAppearanceSettings(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSection(
            'Help & Support',
            [
              _buildProfileItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                onTap: () => context.go('/support'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        final isPro = subscriptionService.isPro;
        final isTrial = subscriptionService.isTrialActive;
        final remainingTrialDays = subscriptionService.remainingTrialDays;
        final remainingSubscriptionDays = subscriptionService.remainingSubscriptionDays;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildSection(
                'Account Management',
                [
                  if (isPro || isTrial) ...[
                    _buildProfileItem(
                      icon: Icons.card_membership_outlined,
                      title: 'Subscription',
                      subtitle: isTrial 
                          ? 'Pro Trial - ${remainingTrialDays} days remaining'
                          : 'Pro Plan - ${remainingSubscriptionDays} days remaining',
                      onTap: () => _showSubscriptionDetails(),
                    ),
                    _buildProfileItem(
                      icon: Icons.payment_outlined,
                      title: 'Payment Methods',
                      subtitle: 'Credit cards, billing info',
                      onTap: () => _showPaymentMethods(),
                    ),
                    if (isPro) ...[
                      _buildProfileItem(
                        icon: Icons.cancel_outlined,
                        title: 'Cancel Subscription',
                        subtitle: 'Cancel your pro subscription',
                        onTap: () => _showCancelSubscriptionDialog(),
                        isDestructive: true,
                      ),
                    ],
                  ] else ...[
                    _buildProfileItem(
                      icon: Icons.card_membership_outlined,
                      title: 'Subscription',
                      subtitle: 'Free plan - upgrade to pro',
                      onTap: () => _showProUpgradeDialog(),
                    ),
                  ],
                  _buildProfileItem(
                    icon: Icons.history_outlined,
                    title: 'Account History',
                    subtitle: 'Login history, activity log',
                    onTap: () => _showAccountHistory(),
                  ),
                  _buildProfileItem(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    subtitle: 'Sign out of your account',
                    onTap: () => _showSignOutDialog(),
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: FlutterFlowTheme.of(context).titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate,
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive 
                      ? FlutterFlowTheme.of(context).error.withValues(alpha: 0.1)
                      : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isDestructive 
                      ? FlutterFlowTheme.of(context).error
                      : FlutterFlowTheme.of(context).primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDestructive 
                            ? FlutterFlowTheme.of(context).error
                            : FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const FaIcon(FontAwesomeIcons.crown, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            const Text('Upgrade to Pro'),
          ],
        ),
        content: Consumer<SubscriptionService>(
          builder: (context, subscriptionService, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose your plan:'),
                const SizedBox(height: 16),
                Consumer<SubscriptionService>(
                  builder: (context, subscriptionService, child) {
                    return Column(
                      children: subscriptionService.availablePlans.map((plan) => _buildPlanOption(plan)).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFD700)),
                      const SizedBox(width: 8),
                      Text(
                        'Special Offer: 30-day free trial',
                        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<SubscriptionService>(
            builder: (context, subscriptionService, child) {
              return ElevatedButton(
                onPressed: subscriptionService.isLoading ? null : () {
                  Navigator.pop(context);
                  _processProUpgrade();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.white,
                ),
                child: subscriptionService.isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Start Free Trial'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption(SubscriptionPlan plan) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        final isSelected = plan.isPopular;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFFFFD700).withValues(alpha: 0.1)
                : FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xFFFFD700)
                  : FlutterFlowTheme.of(context).alternate,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                // TODO: Select plan
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                plan.name,
                                style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected 
                                      ? const Color(0xFFFFD700)
                                      : FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                              if (plan.isPopular) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'POPULAR',
                                    style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.description,
                            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${plan.price.toStringAsFixed(2)}/${plan.billingPeriod}',
                            style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected 
                                  ? const Color(0xFFFFD700)
                                  : FlutterFlowTheme.of(context).primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFFFFD700),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _processProUpgrade() async {
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
    
    try {
      // Start with free trial
      final success = await subscriptionService.startFreeTrial();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Free trial started successfully!'),
            backgroundColor: Color(0xFFFFD700),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start free trial. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Placeholder methods for profile actions
  void _showEditProfileDialog() {
    context.push('/personal-information');
  }

  void _showLocationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: FlutterFlowTheme.of(context).primary),
            const SizedBox(width: 8),
            Text(
              'Location Settings',
              style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TODO: Implement Location Settings Screen',
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This feature will allow you to:\n'
              '• Manage location permissions\n'
              '• Set location preferences\n'
              '• Configure location-based features\n'
              '• Control location data sharing',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    context.push('/notification-settings');
  }

  void _showDataSettings() {
    context.push('/data-storage-settings');
  }

  void _showPrivacySettings() {
    context.push('/security-settings');
  }

  void _showAppearanceSettings() {
    context.push('/appearance-settings');
  }

  void _showSubscriptionDetails() {
    context.push('/subscription-details');
  }

  void _showPaymentMethods() {
    context.push('/payment-methods');
  }

  void _showAccountHistory() {
    context.push('/account-history');
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement sign out logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sign out functionality coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showCancelSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your Pro subscription? '
          'You will lose access to premium features at the end of your current billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          Consumer<SubscriptionService>(
            builder: (context, subscriptionService, child) {
              return ElevatedButton(
                onPressed: subscriptionService.isLoading ? null : () async {
                  Navigator.pop(context);
                  await _cancelSubscription();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).error,
                  foregroundColor: Colors.white,
                ),
                child: subscriptionService.isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Cancel Subscription'),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _cancelSubscription() async {
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
    
    try {
      final success = await subscriptionService.cancelSubscription();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription cancelled successfully. You will lose access at the end of your billing period.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel subscription. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 