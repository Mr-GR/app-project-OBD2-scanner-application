import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  
  // Mock payment methods data
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': '1',
      'type': 'visa',
      'last4': '4242',
      'expiry': '12/25',
      'name': 'John Doe',
      'isDefault': true,
    },
    {
      'id': '2',
      'type': 'mastercard',
      'last4': '5555',
      'expiry': '08/26',
      'name': 'John Doe',
      'isDefault': false,
    },
  ];

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
          'Payment Methods',
          style: FlutterFlowTheme.of(context).titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAddPaymentMethod(),
            icon: Icon(
              Icons.add,
              color: FlutterFlowTheme.of(context).primary,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBillingAddressCard(),
            const SizedBox(height: 24),
            _buildPaymentMethodsCard(),
            const SizedBox(height: 24),
            _buildBillingHistoryCard(),
            const SizedBox(height: 24),
            _buildSecurityCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingAddressCard() {
    return _buildSectionCard(
      'Billing Address',
      Icons.location_on_outlined,
      [
        _buildAddressInfo(),
        const SizedBox(height: 16),
        _buildActionButton(
          'Edit Billing Address',
          Icons.edit_outlined,
          () => _editBillingAddress(),
        ),
      ],
    );
  }

  Widget _buildAddressInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'John Doe',
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '123 Main Street',
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          Text(
            'Apt 4B',
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          Text(
            'New York, NY 10001',
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          Text(
            'United States',
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsCard() {
    return _buildSectionCard(
      'Payment Methods',
      Icons.credit_card_outlined,
      [
        ..._paymentMethods.map((method) => _buildPaymentMethodItem(method)),
        const SizedBox(height: 16),
        _buildActionButton(
          'Add Payment Method',
          Icons.add,
          () => _showAddPaymentMethod(),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodItem(Map<String, dynamic> method) {
    final isDefault = method['isDefault'] as bool;
    final type = method['type'] as String;
    final last4 = method['last4'] as String;
    final expiry = method['expiry'] as String;
    final name = method['name'] as String;

    IconData cardIcon;
    Color cardColor;
    
    switch (type) {
      case 'visa':
        cardIcon = FontAwesomeIcons.ccVisa;
        cardColor = const Color(0xFF1A1F71);
        break;
      case 'mastercard':
        cardIcon = FontAwesomeIcons.ccMastercard;
        cardColor = const Color(0xFFEB001B);
        break;
      default:
        cardIcon = Icons.credit_card;
        cardColor = FlutterFlowTheme.of(context).primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault 
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).alternate,
          width: isDefault ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(
              cardIcon,
              color: cardColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '•••• •••• •••• $last4',
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                            color: FlutterFlowTheme.of(context).primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$name • Expires $expiry',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            onSelected: (value) => _handlePaymentMethodAction(value, method),
            itemBuilder: (context) => [
              if (!isDefault) ...[
                const PopupMenuItem(
                  value: 'set_default',
                  child: Row(
                    children: [
                      Icon(Icons.star_outline, size: 16),
                      SizedBox(width: 8),
                      Text('Set as Default'),
                    ],
                  ),
                ),
              ],
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remove', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingHistoryCard() {
    return _buildSectionCard(
      'Billing History',
      Icons.receipt_outlined,
      [
        _buildBillingHistoryItem('March 2024', '\$9.99', 'Paid', 'Visa •••• 4242'),
        _buildBillingHistoryItem('February 2024', '\$9.99', 'Paid', 'Visa •••• 4242'),
        _buildBillingHistoryItem('January 2024', '\$9.99', 'Paid', 'Visa •••• 4242'),
        _buildBillingHistoryItem('December 2023', 'Free Trial', 'Completed', 'N/A'),
        const SizedBox(height: 16),
        _buildActionButton(
          'Download All Invoices',
          Icons.download_outlined,
          () => _downloadAllInvoices(),
        ),
      ],
    );
  }

  Widget _buildSecurityCard() {
    return _buildSectionCard(
      'Security',
      Icons.security_outlined,
      [
        _buildSecurityItem(
          'Two-Factor Authentication',
          'Add an extra layer of security',
          Icons.verified_user_outlined,
          true,
          () => _toggleTwoFactor(),
        ),
        _buildSecurityItem(
          'Login Notifications',
          'Get notified of new logins',
          Icons.notifications_outlined,
          true,
          () => _toggleLoginNotifications(),
        ),
        _buildSecurityItem(
          'Payment Alerts',
          'Get notified of all payments',
          Icons.payment_outlined,
          false,
          () => _togglePaymentAlerts(),
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

  Widget _buildActionButton(String text, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildBillingHistoryItem(String period, String amount, String status, String method) {
    final isPaid = status == 'Paid';
    
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
                  method,
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPaid 
                      ? FlutterFlowTheme.of(context).success.withValues(alpha: 0.1)
                      : FlutterFlowTheme.of(context).warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
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
        ],
      ),
    );
  }

  Widget _buildSecurityItem(String title, String subtitle, IconData icon, bool isEnabled, VoidCallback onTap) {
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
                  color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: FlutterFlowTheme.of(context).primary,
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
                        color: FlutterFlowTheme.of(context).primaryText,
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
              Switch(
                value: isEnabled,
                onChanged: (value) => onTap(),
                activeColor: FlutterFlowTheme.of(context).primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action methods
  void _showAddPaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddPaymentMethodSheet(),
    );
  }

  Widget _buildAddPaymentMethodSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Payment Method',
                  style: FlutterFlowTheme.of(context).titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCardNumberField(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildExpiryField()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildCvvField()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildNameField(),
                      const SizedBox(height: 16),
                      _buildBillingAddressField(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _savePaymentMethod(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FlutterFlowTheme.of(context).primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Add Payment Method'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Card Number',
        hintText: '1234 5678 9012 3456',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.credit_card),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter card number';
        }
        return null;
      },
    );
  }

  Widget _buildExpiryField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Expiry Date',
        hintText: 'MM/YY',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter expiry date';
        }
        return null;
      },
    );
  }

  Widget _buildCvvField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'CVV',
        hintText: '123',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter CVV';
        }
        return null;
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Cardholder Name',
        hintText: 'John Doe',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter cardholder name';
        }
        return null;
      },
    );
  }

  Widget _buildBillingAddressField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Billing Address',
        hintText: 'Same as account address',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.location_on),
      ),
    );
  }

  void _savePaymentMethod() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment method added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handlePaymentMethodAction(String action, Map<String, dynamic> method) {
    switch (action) {
      case 'set_default':
        _setDefaultPaymentMethod(method);
        break;
      case 'edit':
        _editPaymentMethod(method);
        break;
      case 'remove':
        _removePaymentMethod(method);
        break;
    }
  }

  void _setDefaultPaymentMethod(Map<String, dynamic> method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${method['type'].toString().toUpperCase()} •••• ${method['last4']} set as default'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editPaymentMethod(Map<String, dynamic> method) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit payment method coming soon!')),
    );
  }

  void _removePaymentMethod(Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Payment Method'),
        content: Text(
          'Are you sure you want to remove ${method['type'].toString().toUpperCase()} •••• ${method['last4']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment method removed successfully!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _editBillingAddress() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit billing address coming soon!')),
    );
  }

  void _downloadAllInvoices() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading all invoices...')),
    );
  }

  void _toggleTwoFactor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Two-factor authentication toggled!')),
    );
  }

  void _toggleLoginNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login notifications toggled!')),
    );
  }

  void _togglePaymentAlerts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment alerts toggled!')),
    );
  }
} 