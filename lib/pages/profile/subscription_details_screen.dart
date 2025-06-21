import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import 'package:o_b_d2_scanner_frontend/backend/services/subscription_service.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  const SubscriptionDetailsScreen({super.key});

  @override
  State<SubscriptionDetailsScreen> createState() => _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Subscription Details',
          style: FlutterFlowTheme.of(context).titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<SubscriptionService>(
        builder: (context, subscriptionService, child) {
          final isPro = subscriptionService.isPro;
          final isTrial = subscriptionService.isTrialActive;
          final remainingTrialDays = subscriptionService.remainingTrialDays;
          final remainingSubscriptionDays = subscriptionService.remainingSubscriptionDays;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubscriptionStatusCard(isPro, isTrial, remainingTrialDays, remainingSubscriptionDays),
                const SizedBox(height: 24),
                _buildCurrentPlanCard(subscriptionService),
                const SizedBox(height: 24),
                _buildBillingHistoryCard(),
                const SizedBox(height: 24),
                _buildUsageStatsCard(),
                const SizedBox(height: 24),
                _buildActionsCard(isPro, isTrial),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionStatusCard(bool isPro, bool isTrial, int remainingTrialDays, int remainingSubscriptionDays) {
    String statusText = 'Free Plan';
    String subtitleText = 'Upgrade to unlock premium features';
    IconData statusIcon = Icons.person_outline;

    if (isPro) {
      statusText = 'Pro Plan Active';
      subtitleText = 'You have access to all premium features';
      statusIcon = FontAwesomeIcons.crown;
    } else if (isTrial) {
      statusText = 'Pro Trial Active';
      subtitleText = '$remainingTrialDays days remaining in trial';
      statusIcon = FontAwesomeIcons.crown;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPro || isTrial
              ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
              : [FlutterFlowTheme.of(context).primary, FlutterFlowTheme.of(context).secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isPro || isTrial ? const Color(0xFFFFD700) : FlutterFlowTheme.of(context).primary).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: FlutterFlowTheme.of(context).titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitleText,
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isPro || isTrial) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFeatureChip('Unlimited Scans', Icons.all_inclusive),
                const SizedBox(width: 8),
                _buildFeatureChip('Advanced Analytics', Icons.analytics),
                const SizedBox(width: 8),
                _buildFeatureChip('Priority Support', Icons.support_agent),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(SubscriptionService subscriptionService) {
    return _buildSectionCard(
      'Current Plan',
      Icons.card_membership_outlined,
      [
        _buildPlanInfoRow('Plan Name', subscriptionService.currentPlan?.name ?? 'Free Plan'),
        _buildPlanInfoRow('Billing Cycle', subscriptionService.currentPlan?.billingPeriod ?? 'N/A'),
        _buildPlanInfoRow('Price', subscriptionService.currentPlan != null 
            ? '\$${subscriptionService.currentPlan!.price.toStringAsFixed(2)}/${subscriptionService.currentPlan!.billingPeriod}'
            : 'Free'),
        _buildPlanInfoRow('Next Billing', subscriptionService.nextBillingDate ?? 'N/A'),
        _buildPlanInfoRow('Auto-Renewal', subscriptionService.autoRenewal ? 'Enabled' : 'Disabled'),
      ],
    );
  }

  Widget _buildBillingHistoryCard() {
    return _buildSectionCard(
      'Billing History',
      Icons.receipt_outlined,
      [
        _buildBillingHistoryItem('March 2024', '\$9.99', 'Paid', true),
        _buildBillingHistoryItem('February 2024', '\$9.99', 'Paid', true),
        _buildBillingHistoryItem('January 2024', '\$9.99', 'Paid', true),
        _buildBillingHistoryItem('December 2023', 'Free Trial', 'Completed', false),
      ],
    );
  }

  Widget _buildUsageStatsCard() {
    return _buildSectionCard(
      'Usage Statistics',
      Icons.analytics_outlined,
      [
        _buildUsageStatRow('Scans This Month', '47', 'Unlimited'),
        _buildUsageStatRow('Reports Generated', '12', 'Unlimited'),
        _buildUsageStatRow('Storage Used', '2.3 GB', '10 GB'),
        _buildUsageStatRow('Support Tickets', '1', 'Priority'),
      ],
    );
  }

  Widget _buildActionsCard(bool isPro, bool isTrial) {
    return _buildSectionCard(
      'Actions',
      Icons.settings_outlined,
      [
        if (isPro) ...[
          _buildActionItem(
            'Manage Subscription',
            'Update billing info, change plan',
            Icons.edit_outlined,
            () => _showManageSubscription(),
          ),
          _buildActionItem(
            'Cancel Subscription',
            'Cancel your pro subscription',
            Icons.cancel_outlined,
            () => _showCancelSubscriptionDialog(),
            isDestructive: true,
          ),
        ] else if (isTrial) ...[
          _buildActionItem(
            'Continue Pro',
            'Keep your premium features',
            Icons.upgrade_outlined,
            () => _showUpgradeDialog(),
          ),
        ] else ...[
          _buildActionItem(
            'Upgrade to Pro',
            'Unlock premium features',
            Icons.upgrade_outlined,
            () => _showUpgradeDialog(),
          ),
        ],
        _buildActionItem(
          'Download Invoice',
          'Get your latest invoice',
          Icons.download_outlined,
          () => _downloadInvoice(),
        ),
        _buildActionItem(
          'Contact Support',
          'Get help with billing',
          Icons.support_agent_outlined,
          () => _contactSupport(),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPlanInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          Text(
            value,
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingHistoryItem(String period, String amount, String status, bool isPaid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period,
                  style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                Text(
                  amount,
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPaid 
                  ? FlutterFlowTheme.of(context).success.withValues(alpha: 0.1)
                  : FlutterFlowTheme.of(context).warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: isPaid 
                    ? FlutterFlowTheme.of(context).success
                    : FlutterFlowTheme.of(context).warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStatRow(String label, String current, String limit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          Row(
            children: [
              Text(
                current,
                style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              Text(
                ' / $limit',
                style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
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

  // Action methods
  void _showManageSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manage subscription coming soon!')),
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelSubscription();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upgrade dialog coming soon!')),
    );
  }

  void _downloadInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice download coming soon!')),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact support coming soon!')),
    );
  }

  void _cancelSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subscription cancelled successfully. You will lose access at the end of your billing period.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
} 