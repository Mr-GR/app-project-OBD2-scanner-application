import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';

class AccountHistoryScreen extends StatefulWidget {
  const AccountHistoryScreen({super.key});

  @override
  State<AccountHistoryScreen> createState() => _AccountHistoryScreenState();
}

class _AccountHistoryScreenState extends State<AccountHistoryScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Logins', 'Scans', 'Settings', 'Billing'];

  // Mock account history data
  final List<Map<String, dynamic>> _accountHistory = [
    {
      'id': '1',
      'type': 'login',
      'title': 'Successful Login',
      'description': 'Logged in from iPhone 14 Pro',
      'location': 'New York, NY, USA',
      'ip': '192.168.1.100',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'status': 'success',
    },
    {
      'id': '2',
      'type': 'scan',
      'title': 'Vehicle Scan Completed',
      'description': 'Scanned 2019 Toyota Camry',
      'location': 'New York, NY, USA',
      'ip': '192.168.1.100',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'success',
    },
    {
      'id': '3',
      'type': 'settings',
      'title': 'Profile Updated',
      'description': 'Changed email address',
      'location': 'New York, NY, USA',
      'ip': '192.168.1.100',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'success',
    },
    {
      'id': '4',
      'type': 'billing',
      'title': 'Payment Processed',
      'description': 'Pro subscription renewed',
      'location': 'New York, NY, USA',
      'ip': '192.168.1.100',
      'timestamp': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'success',
    },
    {
      'id': '5',
      'type': 'login',
      'title': 'Failed Login Attempt',
      'description': 'Incorrect password entered',
      'location': 'Unknown Location',
      'ip': '203.0.113.1',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'failed',
    },
    {
      'id': '6',
      'type': 'scan',
      'title': 'Vehicle Scan Started',
      'description': 'Started scan for 2020 Honda Civic',
      'location': 'New York, NY, USA',
      'ip': '192.168.1.100',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'success',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _getFilteredHistory();

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
          'Account History',
          style: FlutterFlowTheme.of(context).titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _exportHistory(),
            icon: Icon(
              Icons.download,
              color: FlutterFlowTheme.of(context).primary,
              size: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: filteredHistory.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(filteredHistory),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                selectedColor: FlutterFlowTheme.of(context).primary,
                labelStyle: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : FlutterFlowTheme.of(context).primaryText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected 
                      ? FlutterFlowTheme.of(context).primary
                      : FlutterFlowTheme.of(context).alternate,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No activity found',
            style: FlutterFlowTheme.of(context).titleMedium.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filter or check back later',
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> history) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final isLast = index == history.length - 1;
        
        return Column(
          children: [
            _buildHistoryItem(item),
            if (!isLast) const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final title = item['title'] as String;
    final description = item['description'] as String;
    final location = item['location'] as String;
    final ip = item['ip'] as String;
    final timestamp = item['timestamp'] as DateTime;
    final status = item['status'] as String;

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
          Row(
            children: [
              _buildActivityIcon(type, status),
              const SizedBox(width: 12),
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
                      description,
                      style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusIndicator(status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.computer_outlined,
                size: 14,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                ip,
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                size: 14,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                _formatTimestamp(timestamp),
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showActivityDetails(item),
                child: Text(
                  'Details',
                  style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                    color: FlutterFlowTheme.of(context).primary,
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

  Widget _buildActivityIcon(String type, String status) {
    IconData icon;
    Color color;

    switch (type) {
      case 'login':
        icon = Icons.login;
        break;
      case 'scan':
        icon = Icons.qr_code_scanner;
        break;
      case 'settings':
        icon = Icons.settings;
        break;
      case 'billing':
        icon = Icons.payment;
        break;
      default:
        icon = Icons.info;
    }

    switch (status) {
      case 'success':
        color = FlutterFlowTheme.of(context).success;
        break;
      case 'failed':
        color = FlutterFlowTheme.of(context).error;
        break;
      case 'warning':
        color = FlutterFlowTheme.of(context).warning;
        break;
      default:
        color = FlutterFlowTheme.of(context).primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    String text;

    switch (status) {
      case 'success':
        color = FlutterFlowTheme.of(context).success;
        text = 'Success';
        break;
      case 'failed':
        color = FlutterFlowTheme.of(context).error;
        text = 'Failed';
        break;
      case 'warning':
        color = FlutterFlowTheme.of(context).warning;
        text = 'Warning';
        break;
      default:
        color = FlutterFlowTheme.of(context).primary;
        text = 'Info';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  List<Map<String, dynamic>> _getFilteredHistory() {
    if (_selectedFilter == 'All') {
      return _accountHistory;
    }
    
    final filterType = _selectedFilter.toLowerCase().replaceAll('s', '');
    return _accountHistory.where((item) => item['type'] == filterType).toList();
  }

  void _showActivityDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildActivityDetailsSheet(item),
    );
  }

  Widget _buildActivityDetailsSheet(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activity Details',
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
            _buildDetailRow('Activity', item['title']),
            _buildDetailRow('Description', item['description']),
            _buildDetailRow('Location', item['location']),
            _buildDetailRow('IP Address', item['ip']),
            _buildDetailRow('Status', item['status'].toString().toUpperCase()),
            _buildDetailRow('Time', _formatTimestamp(item['timestamp'])),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _reportActivity(item);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Report Suspicious Activity'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export History'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportAsCSV();
            },
            child: const Text('CSV'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportAsPDF();
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  void _exportAsCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting as CSV...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportAsPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting as PDF...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _reportActivity(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Activity reported. Our security team will review it.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
} 