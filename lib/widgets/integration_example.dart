import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../backend/providers/app_state_provider.dart';
import 'enhanced_loading_widget.dart';
import 'enhanced_error_handler.dart';
import 'accessibility_widgets.dart';
import '../backend/services/smart_cache_service.dart';
import 'diagnostic_report_templates.dart';
import 'onboarding_tutorial_system.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntegrationExample extends StatefulWidget {
  const IntegrationExample({super.key});

  @override
  State<IntegrationExample> createState() => _IntegrationExampleState();
}

class _IntegrationExampleState extends State<IntegrationExample> {
  bool _isLoading = false;
  final SmartCacheService _cacheService = SmartCacheService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() => _isLoading = true);
    
    try {
      await _cacheService.initialize();
      EnhancedErrorHandler.showToast(
        context,
        'Services initialized successfully!',
        type: ToastType.success,
      );
    } catch (e) {
      EnhancedErrorHandler.showToast(
        context,
        'Failed to initialize services',
        type: ToastType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Features Demo'),
        actions: [
          // Accessibility settings button
          IconButton(
            onPressed: () => _showAccessibilitySettings(context),
            icon: const Icon(Icons.accessibility),
          ),
          // Help button
          ContextualHelpWidget(
            helpText: 'This screen demonstrates all the enhanced features including loading states, error handling, accessibility, caching, and more.',
            title: 'Enhanced Features Demo',
          ),
        ],
      ),
      body: _isLoading
          ? const EnhancedLoadingWidget(
              message: 'Initializing enhanced features...',
              type: LoadingType.spinner,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Connection status
                  _buildConnectionStatus(),
                  const SizedBox(height: 20),
                  
                  // Loading states demo
                  _buildLoadingStatesDemo(),
                  const SizedBox(height: 20),
                  
                  // Error handling demo
                  _buildErrorHandlingDemo(),
                  const SizedBox(height: 20),
                  
                  // Accessibility demo
                  _buildAccessibilityDemo(),
                  const SizedBox(height: 20),
                  
                  // Cache management demo
                  _buildCacheManagementDemo(),
                  const SizedBox(height: 20),
                  
                  // Report generation demo
                  _buildReportGenerationDemo(),
                  const SizedBox(height: 20),
                  
                  // Tutorial system demo
                  _buildTutorialSystemDemo(),
                ],
              ),
            ),
    );
  }

  Widget _buildConnectionStatus() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection Status',
                  style: FlutterFlowTheme.of(context).titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusIndicator('OBD2', appState.canPerformScans),
                    const SizedBox(width: 16),
                    _buildStatusIndicator('Internet', appState.canFetchVehicleData),
                    const SizedBox(width: 16),
                    _buildStatusIndicator('AI', appState.canUseAI),
                  ],
                ),
                const SizedBox(height: 8),
                OfflineIndicator(
                  isOnline: appState.isConnectedToInternet,
                  onRetry: () => _retryConnection(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(String label, bool isConnected) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildLoadingStatesDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loading States Demo',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () => _showLoadingDemo(LoadingType.spinner),
                  child: const Text('Spinner'),
                ),
                ElevatedButton(
                  onPressed: () => _showLoadingDemo(LoadingType.progress),
                  child: const Text('Progress'),
                ),
                ElevatedButton(
                  onPressed: () => _showLoadingDemo(LoadingType.skeleton),
                  child: const Text('Skeleton'),
                ),
                ElevatedButton(
                  onPressed: () => _showLoadingDemo(LoadingType.shimmer),
                  child: const Text('Shimmer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorHandlingDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error Handling Demo',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () => _showErrorDemo(ToastType.error),
                  child: const Text('Error Toast'),
                ),
                ElevatedButton(
                  onPressed: () => _showErrorDemo(ToastType.warning),
                  child: const Text('Warning Toast'),
                ),
                ElevatedButton(
                  onPressed: () => _showErrorDemo(ToastType.success),
                  child: const Text('Success Toast'),
                ),
                ElevatedButton(
                  onPressed: () => _showErrorDialog(),
                  child: const Text('Error Dialog'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibilityDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accessibility Demo',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 16),
            AccessibilityAwareWidget(
              child: ScalableText(
                'This text scales with system settings',
                style: FlutterFlowTheme.of(context).bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
            KeyboardNavigableWidget(
              onEnter: () => _showSnackBar('Enter pressed'),
              onSpace: () => _showSnackBar('Space pressed'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Press Enter or Space (when focused)'),
              ),
            ),
            const SizedBox(height: 16),
            VoiceNavigationWidget(
              voiceLabel: 'Accessibility test button',
              voiceHint: 'Double tap to activate',
              onVoiceActivate: () => _showSnackBar('Voice activated'),
              child: ElevatedButton(
                onPressed: () => _showSnackBar('Button pressed'),
                child: const Text('Voice Navigation Test'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheManagementDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cache Management Demo',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: _showCacheStats,
                  child: const Text('Show Stats'),
                ),
                ElevatedButton(
                  onPressed: _addMockData,
                  child: const Text('Add Mock Data'),
                ),
                ElevatedButton(
                  onPressed: _syncData,
                  child: const Text('Sync Data'),
                ),
                ElevatedButton(
                  onPressed: _exportData,
                  child: const Text('Export Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportGenerationDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Generation Demo',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () => _generateReport('Standard Report'),
                  child: const Text('Standard Report'),
                ),
                ElevatedButton(
                  onPressed: () => _generateReport('Detailed Report'),
                  child: const Text('Detailed Report'),
                ),
                ElevatedButton(
                  onPressed: () => _generateReport('Summary Report'),
                  child: const Text('Summary Report'),
                ),
                ElevatedButton(
                  onPressed: _showCustomReportDialog,
                  child: const Text('Custom Report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialSystemDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tutorial System Demo',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: _showOnboarding,
                  child: const Text('Show Onboarding'),
                ),
                ElevatedButton(
                  onPressed: _showFAQ,
                  child: const Text('Show FAQ'),
                ),
                ElevatedButton(
                  onPressed: _showVideoGuide,
                  child: const Text('Show Video Guide'),
                ),
                ElevatedButton(
                  onPressed: _resetTutorials,
                  child: const Text('Reset Tutorials'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Demo methods
  void _showLoadingDemo(LoadingType type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Loading Demo'),
        content: SizedBox(
          height: 200,
          child: EnhancedLoadingWidget(
            message: 'Loading demo content...',
            type: type,
            progress: type == LoadingType.progress ? 0.7 : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDemo(ToastType type) {
    EnhancedErrorHandler.showToast(
      context,
      'This is a ${type.name} message',
      type: type,
    );
  }

  void _showErrorDialog() {
    EnhancedErrorHandler.showUserFriendlyError(
      context,
      'This is a sample error message that demonstrates the enhanced error handling system.',
      title: 'Sample Error',
      onRetry: () => _showSnackBar('Retry action performed'),
      onDismiss: () => _showSnackBar('Error dismissed'),
    );
  }

  void _showAccessibilitySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accessibility Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('High Contrast'),
              value: AccessibilitySettings.isHighContrastEnabled,
              onChanged: (value) {
                AccessibilitySettings.updateSettings(highContrast: value);
                Navigator.of(context).pop();
              },
            ),
            SwitchListTile(
              title: const Text('Reduced Motion'),
              value: AccessibilitySettings.isReducedMotionEnabled,
              onChanged: (value) {
                AccessibilitySettings.updateSettings(reducedMotion: value);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCacheStats() async {
    try {
      final stats = await _cacheService.getCacheStats();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cache Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Items: ${stats.totalItems}'),
              Text('Pending Sync: ${stats.pendingSync}'),
              Text('Cache Size: ${stats.formattedCacheSize}'),
              Text('Last Cleanup: ${stats.lastCleanup.toString()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      EnhancedErrorHandler.showToast(
        context,
        'Failed to get cache stats',
        type: ToastType.error,
      );
    }
  }

  Future<void> _addMockData() async {
    try {
      await _cacheService.cacheVehicleData('demo_user', {
        'vin': 'DEMO123456789',
        'make': 'Demo',
        'model': 'Vehicle',
        'year': '2023',
      });
      
      await _cacheService.addToSyncQueue('create_vehicle', {
        'vin': 'DEMO123456789',
        'make': 'Demo',
        'model': 'Vehicle',
      });
      
      EnhancedErrorHandler.showToast(
        context,
        'Mock data added successfully',
        type: ToastType.success,
      );
    } catch (e) {
      EnhancedErrorHandler.showToast(
        context,
        'Failed to add mock data',
        type: ToastType.error,
      );
    }
  }

  Future<void> _syncData() async {
    setState(() => _isLoading = true);
    try {
      await _cacheService.syncWhenOnline();
      EnhancedErrorHandler.showToast(
        context,
        'Data synced successfully',
        type: ToastType.success,
      );
    } catch (e) {
      EnhancedErrorHandler.showToast(
        context,
        'Failed to sync data',
        type: ToastType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportData() async {
    try {
      final exportData = await _cacheService.exportData('demo_user');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Data'),
          content: SingleChildScrollView(
            child: Text(exportData),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      EnhancedErrorHandler.showToast(
        context,
        'Failed to export data',
        type: ToastType.error,
      );
    }
  }

  Future<void> _generateReport(String templateName) async {
    setState(() => _isLoading = true);
    try {
      // Create a mock diagnostic report
      final mockReport = _createMockDiagnosticReport();
      
      final filePath = await DiagnosticReportTemplates.generatePDFReport(
        mockReport,
        templateName,
      );
      
      EnhancedErrorHandler.showToast(
        context,
        'Report generated: $filePath',
        type: ToastType.success,
      );
    } catch (e) {
      EnhancedErrorHandler.showToast(
        context,
        'Failed to generate report',
        type: ToastType.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCustomReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Report Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Include Vehicle Info'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Include Trouble Codes'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Include Live Data'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Include Emissions'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Include Recommendations'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generateReport('Custom Report');
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showOnboarding() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  void _showFAQ() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FAQScreen()),
    );
  }

  void _showVideoGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Guide'),
        content: const VideoGuideWidget(
          title: 'How to Use Auto Fix',
          description: 'Learn the basics of using Auto Fix for vehicle diagnostics.',
          videoUrl: 'https://example.com/video',
          thumbnailUrl: 'https://example.com/thumbnail',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    EnhancedErrorHandler.showToast(
      context,
      'Tutorials reset successfully',
      type: ToastType.success,
    );
  }

  void _retryConnection() {
    EnhancedErrorHandler.showToast(
      context,
      'Retrying connection...',
      type: ToastType.info,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Helper method to create mock diagnostic report
  dynamic _createMockDiagnosticReport() {
    // This would normally come from your diagnostic models
    return {
      'id': 'demo_report_${DateTime.now().millisecondsSinceEpoch}',
      'vehicleVin': 'DEMO123456789',
      'scanDate': DateTime.now(),
      'troubleCodes': [],
      'liveData': [],
      'emissionsStatus': [],
      'recommendations': ['Vehicle appears to be in good condition'],
    };
  }
} 