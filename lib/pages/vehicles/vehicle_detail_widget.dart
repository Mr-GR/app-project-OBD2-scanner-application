import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../chat/chat_screen_widget.dart';

class VehicleDetailWidget extends StatefulWidget {
  final VehicleRecord vehicle;
  
  const VehicleDetailWidget({
    Key? key,
    required this.vehicle,
  }) : super(key: key);

  @override
  State<VehicleDetailWidget> createState() => _VehicleDetailWidgetState();
}

class _VehicleDetailWidgetState extends State<VehicleDetailWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: true,
        title: Text(
          widget.vehicle.nickname ?? '${widget.vehicle.year} ${widget.vehicle.make}',
          style: FlutterFlowTheme.of(context).headlineMedium.copyWith(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 20,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () {
              _startNewChat();
            },
          ),
        ],
        centerTitle: false,
        elevation: 2,
      ),
      body: Column(
        children: [
          _buildVehicleInfoCard(),
          _buildTabBar(),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.car,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vehicle.nickname ?? '${widget.vehicle.year} ${widget.vehicle.make} ${widget.vehicle.model}',
                        style: FlutterFlowTheme.of(context).titleMedium,
                      ),
                      Text(
                        'VIN: ${widget.vehicle.vin}',
                        style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Make', widget.vehicle.make),
                ),
                Expanded(
                  child: _buildInfoItem('Model', widget.vehicle.model),
                ),
                Expanded(
                  child: _buildInfoItem('Year', widget.vehicle.year),
                ),
              ],
            ),
            if (widget.vehicle.color != null || widget.vehicle.licensePlate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (widget.vehicle.color != null) ...[
                    Expanded(
                      child: _buildInfoItem('Color', widget.vehicle.color!),
                    ),
                  ],
                  if (widget.vehicle.licensePlate != null) ...[
                    Expanded(
                      child: _buildInfoItem('Plate', widget.vehicle.licensePlate!),
                    ),
                  ],
                ],
              ),
            ],
            if (widget.vehicle.mileage != null) ...[
              const SizedBox(height: 12),
              _buildInfoItem('Mileage', '${widget.vehicle.mileage} miles'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.copyWith(
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
        Text(
          value,
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: FlutterFlowTheme.of(context).secondaryBackground,
      child: TabBar(
        controller: _tabController,
        labelColor: FlutterFlowTheme.of(context).primary,
        unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
        indicatorColor: FlutterFlowTheme.of(context).primary,
        tabs: const [
          Tab(
            icon: Icon(Icons.info_outline),
            text: 'Overview',
          ),
          Tab(
            icon: Icon(Icons.analytics),
            text: 'Scans',
          ),
          Tab(
            icon: Icon(Icons.chat),
            text: 'Chats',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildScansTab(),
        _buildChatsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        final scanResults = vehicleProvider.scanResults;
        final chatSessions = vehicleProvider.chatSessions;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCard(
                'Scan History',
                scanResults.length.toString(),
                'Total scans performed',
                Icons.analytics,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildOverviewCard(
                'Chat Sessions',
                chatSessions.length.toString(),
                'Total chat sessions',
                Icons.chat,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildOverviewCard(
                'Last Activity',
                widget.vehicle.lastScanDate != null 
                    ? _formatDate(widget.vehicle.lastScanDate!)
                    : 'Never',
                'Last scan performed',
                Icons.schedule,
                Colors.orange,
              ),
              const SizedBox(height: 24),
              
              if (scanResults.isNotEmpty) ...[
                Text(
                  'Recent Scans',
                  style: FlutterFlowTheme.of(context).titleMedium,
                ),
                const SizedBox(height: 12),
                ...scanResults.take(3).map((scan) => _buildRecentScanItem(scan)),
              ],
              
              const SizedBox(height: 24),
              
              if (chatSessions.isNotEmpty) ...[
                Text(
                  'Recent Chats',
                  style: FlutterFlowTheme.of(context).titleMedium,
                ),
                const SizedBox(height: 12),
                ...chatSessions.take(3).map((session) => _buildRecentChatItem(session)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                  Text(
                    value,
                    style: FlutterFlowTheme.of(context).titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScanItem(ScanResult scan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          scan.scanType == 'bluetooth' ? Icons.bluetooth : Icons.build,
          color: FlutterFlowTheme.of(context).primary,
        ),
        title: Text('${scan.scanType.toUpperCase()} Scan'),
        subtitle: Text(_formatDate(scan.scanDate)),
        trailing: scan.errorCodes.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${scan.errorCodes.length} errors',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'No errors',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRecentChatItem(ChatSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.chat,
          color: FlutterFlowTheme.of(context).primary,
        ),
        title: Text(session.title),
        subtitle: Text(_formatDate(session.sessionDate)),
        trailing: Text(
          '${session.messages.length} messages',
          style: FlutterFlowTheme.of(context).bodySmall.copyWith(
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
        onTap: () {
          // Navigate to chat session
          _openChatSession(session);
        },
      ),
    );
  }

  Widget _buildScansTab() {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        final scanResults = vehicleProvider.scanResults;
        
        if (scanResults.isEmpty) {
          return _buildEmptyState(
            'No Scans Yet',
            'Perform your first scan to see results here.',
            Icons.analytics,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scanResults.length,
          itemBuilder: (context, index) {
            final scan = scanResults[index];
            return _buildScanResultCard(scan);
          },
        );
      },
    );
  }

  Widget _buildScanResultCard(ScanResult scan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(
          scan.scanType == 'bluetooth' ? Icons.bluetooth : Icons.build,
          color: FlutterFlowTheme.of(context).primary,
        ),
        title: Text('${scan.scanType.toUpperCase()} Scan'),
        subtitle: Text(_formatDate(scan.scanDate)),
        trailing: scan.errorCodes.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${scan.errorCodes.length} errors',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'No errors',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (scan.errorCodes.isNotEmpty) ...[
                  Text(
                    'Error Codes:',
                    style: FlutterFlowTheme.of(context).titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...scan.errorCodes.map((code) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $code',
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),
                ],
                if (scan.notes != null) ...[
                  Text(
                    'Notes:',
                    style: FlutterFlowTheme.of(context).titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(scan.notes!),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Share scan results
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlutterFlowTheme.of(context).primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Start chat about this scan
                          _startChatAboutScan(scan);
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsTab() {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        final chatSessions = vehicleProvider.chatSessions;
        
        if (chatSessions.isEmpty) {
          return _buildEmptyState(
            'No Chat Sessions',
            'Start a chat to discuss your vehicle diagnostics.',
            Icons.chat,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chatSessions.length,
          itemBuilder: (context, index) {
            final session = chatSessions[index];
            return _buildChatSessionCard(session);
          },
        );
      },
    );
  }

  Widget _buildChatSessionCard(ChatSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          child: Icon(
            Icons.chat,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(session.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(session.sessionDate)),
            if (session.summary != null) ...[
              const SizedBox(height: 4),
              Text(
                session.summary!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${session.messages.length}',
              style: FlutterFlowTheme.of(context).titleSmall,
            ),
            Text(
              'messages',
              style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
        onTap: () {
          _openChatSession(session);
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: FlutterFlowTheme.of(context).headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: FlutterFlowTheme.of(context).bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 1: // Scans tab
        return FloatingActionButton(
          onPressed: () {
            // Start new scan
            _startNewScan();
          },
          backgroundColor: FlutterFlowTheme.of(context).primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 2: // Chats tab
        return FloatingActionButton(
          onPressed: () {
            // Start new chat
            _startNewChat();
          },
          backgroundColor: FlutterFlowTheme.of(context).primary,
          child: const Icon(Icons.chat, color: Colors.white),
        );
      default:
        return null;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _startNewScan() {
    // Navigate to scan screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to scan screen')),
    );
  }

  void _startNewChat() {
    // Navigate to chat screen with vehicle context
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreenWidget(
          vehicleVin: widget.vehicle.vin,
          initialTitle: 'Chat about ${widget.vehicle.nickname ?? '${widget.vehicle.year} ${widget.vehicle.make}'}',
        ),
      ),
    );
  }

  void _startChatAboutScan(ScanResult scan) {
    // Start chat with scan context
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreenWidget(
          vehicleVin: widget.vehicle.vin,
          initialTitle: 'Chat about ${scan.scanType.toUpperCase()} scan',
        ),
      ),
    );
  }

  void _openChatSession(ChatSession session) {
    // Open existing chat session
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreenWidget(
          vehicleVin: session.vehicleVin,
          chatSessionId: session.id,
          initialTitle: session.title,
        ),
      ),
    );
  }
} 