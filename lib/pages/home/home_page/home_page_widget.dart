import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:o_b_d2_scanner_frontend/config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/vehicle_service.dart';
import '/auth/auth_util.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  List<VehicleResponse> _vehicles = [];
  bool _vehiclesLoading = true;
  final PageController _pageController = PageController(viewportFraction: 0.8);

  // Quick Chat state
  final TextEditingController _quickChatController = TextEditingController();
  String? _quickChatResponse;
  String? _quickChatError;
  bool _quickChatLoading = false;
  int _chatExchangeCount = 0;
  
  // User state
  String? _userName;
  bool _userLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _loadUserData();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _vehiclesLoading = true;
    });

    try {
      final vehicles = await VehicleService.getVehicles();
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _vehiclesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _vehiclesLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading vehicles: $e',
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _userLoading = true;
    });

    try {
      // First try to get the name from name entry onboarding
      final prefs = await SharedPreferences.getInstance();
      final displayName = prefs.getString('user_display_name');
      
      if (displayName != null && displayName.isNotEmpty) {
        setState(() {
          _userName = displayName;
          _userLoading = false;
        });
      } else {
        // Fallback to user data if no display name is set
        final userData = await AuthUtil.getCurrentUser();
        if (mounted && userData != null) {
          setState(() {
            _userName = userData['name'] ?? userData['email']?.split('@')[0];
            _userLoading = false;
          });
        } else {
          setState(() {
            _userName = null;
            _userLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = null;
          _userLoading = false;
        });
      }
    }
  }

  void _navigateToAddCar() async {
    final result = await GoRouter.of(context).push('/add-vehicle');
    if (result == true) {
      // Refresh vehicles list
      _loadVehicles();
    }
  }

  Future<void> _deleteVehicle(VehicleResponse vehicle) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete ${vehicle.make} ${vehicle.model}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await VehicleService.deleteVehicle(vehicle.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Vehicle deleted successfully',
                style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          _loadVehicles(); // Refresh list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error deleting vehicle: $e',
                style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  Future<void> _setPrimaryVehicle(VehicleResponse vehicle) async {
    try {
      await VehicleService.setPrimaryVehicle(vehicle.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${vehicle.make} ${vehicle.model} set as primary vehicle',
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        _loadVehicles(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error setting primary vehicle: $e',
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _sendQuickChat() async {
    final message = _quickChatController.text.trim();
    if (message.isEmpty) return;

    // Check if we've had 2+ exchanges, redirect to full chat
    if (_chatExchangeCount >= 2) {
      GoRouter.of(context).push('/chat');
      return;
    }

    setState(() {
      _quickChatLoading = true;
      _quickChatResponse = null;
      _quickChatError = null;
    });

    try {
      // Get primary vehicle for context
      final primaryVehicle = _vehicles.isNotEmpty 
          ? _vehicles.firstWhere((v) => v.isPrimary, orElse: () => _vehicles.first)
          : null;

      // Build request body with vehicle context
      final requestBody = {
        'message': message,
        if (primaryVehicle != null) 'context': {
          'vin': primaryVehicle.vin,
          'vehicle_info': {
            'make': primaryVehicle.make,
            'model': primaryVehicle.model,
            'year': primaryVehicle.year.toString(),
            if (primaryVehicle.vehicleType?.isNotEmpty == true)
              'type': primaryVehicle.vehicleType,
          }
        }
      };

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/chat/quick'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Debug: Print the response to see the actual structure
        print('Quick Chat API Response: $data');
        
        // Extract response text from nested structure
        String? responseText;
        
        // Handle nested message structure: {message: {content: "..."}}
        if (data['message'] != null && data['message'] is Map) {
          final messageData = data['message'] as Map<String, dynamic>;
          if (messageData['content'] != null) {
            responseText = messageData['content'].toString();
          }
        } 
        // Fallback to direct field access
        else if (data['response'] != null) {
          responseText = data['response'].toString();
        } else if (data['message'] != null) {
          responseText = data['message'].toString();
        } else if (data['reply'] != null) {
          responseText = data['reply'].toString();
        } else if (data['answer'] != null) {
          responseText = data['answer'].toString();
        } else if (data['text'] != null) {
          responseText = data['text'].toString();
        } else if (data['content'] != null) {
          responseText = data['content'].toString();
        }
        
        // Clean up the response text - remove JSON wrapper patterns
        if (responseText != null) {
          responseText = _cleanResponseText(responseText);
        }
        
        setState(() {
          _quickChatResponse = responseText ?? 'No response received. Raw: ${data.toString()}';
          _quickChatError = null;
          _chatExchangeCount++;
        });
        _quickChatController.clear();
        
        // If this was the second exchange, show hint about full chat
        if (_chatExchangeCount >= 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'For longer conversations, tap "AI Chat" to continue',
                style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: FlutterFlowTheme.of(context).primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              action: SnackBarAction(
                label: 'Open Chat',
                textColor: Colors.white,
                onPressed: () => GoRouter.of(context).push('/chat'),
              ),
            ),
          );
        }
      } else {
        print('Quick Chat API Error - Status: ${response.statusCode}, Body: ${response.body}');
        setState(() {
          _quickChatResponse = null;
          _quickChatError = 'API Error ${response.statusCode}: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _quickChatResponse = null;
        _quickChatError = 'Error: $e';
      });
    } finally {
      setState(() {
        _quickChatLoading = false;
      });
    }
  }

  void _resetQuickChat() {
    setState(() {
      _quickChatController.clear();
      _quickChatResponse = null;
      _quickChatError = null;
      _chatExchangeCount = 0;
    });
  }

  String _cleanResponseText(String text) {
    String cleaned = text.trim();
    
    // Remove metadata patterns like "*Not automotive: llm_classification (746.85ms)*"
    cleaned = cleaned.replaceAll(RegExp(r'\*[^*]*:\s*[^*()]*\([^)]*\)\*'), '');
    
    // Remove common JSON wrapper patterns
    if (cleaned.startsWith('{content:') || cleaned.startsWith('{"content":')) {
      final contentMatch = RegExp(r'\{["\s]*content["\s]*:\s*["\s]*(.+?)["\s]*\}').firstMatch(cleaned);
      if (contentMatch != null) {
        cleaned = contentMatch.group(1) ?? cleaned;
      }
    }
    
    if (cleaned.startsWith('{message:') || cleaned.startsWith('{"message":')) {
      final messageMatch = RegExp(r'\{["\s]*message["\s]*:\s*["\s]*(.+?)["\s]*\}').firstMatch(cleaned);
      if (messageMatch != null) {
        cleaned = messageMatch.group(1) ?? cleaned;
      }
    }
    
    // Remove surrounding quotes
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    
    // Remove escape characters
    cleaned = cleaned.replaceAll('\\"', '"');
    cleaned = cleaned.replaceAll('\\n', '\n');
    cleaned = cleaned.replaceAll('\\t', '\t');
    
    // Remove all emojis and special characters
    cleaned = _removeEmojis(cleaned);
    
    // Clean up extra whitespace and line breaks
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n'); // Remove triple+ line breaks
    cleaned = cleaned.replaceAll(RegExp(r'^\s+', multiLine: true), ''); // Remove leading whitespace
    
    return cleaned.trim();
  }
  
  String _removeEmojis(String text) {
    // Remove various emoji ranges and special characters
    return text
        .replaceAll(RegExp(r'[â¢•·◦▪▫‣⁃]'), '-') // Replace bullet point emojis with dashes
        .replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true), '') // Emoticons
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F5FF}]', unicode: true), '') // Misc symbols
        .replaceAll(RegExp(r'[\u{1F680}-\u{1F6FF}]', unicode: true), '') // Transport
        .replaceAll(RegExp(r'[\u{1F1E0}-\u{1F1FF}]', unicode: true), '') // Flags
        .replaceAll(RegExp(r'[\u{2600}-\u{26FF}]', unicode: true), '') // Misc symbols
        .replaceAll(RegExp(r'[\u{2700}-\u{27BF}]', unicode: true), '') // Dingbats
        .replaceAll(RegExp(r'[\u{E000}-\u{F8FF}]', unicode: true), '') // Private use
        .replaceAll(RegExp(r'[\u{1F900}-\u{1F9FF}]', unicode: true), '') // Supplemental symbols
        .replaceAll(RegExp(r'[\u{1FA00}-\u{1FA6F}]', unicode: true), '') // Chess symbols
        .replaceAll(RegExp(r'[\u{1FA70}-\u{1FAFF}]', unicode: true), '') // Symbols and pictographs extended-A
        .replaceAll(RegExp(r'[^\x00-\x7F]+'), '') // Remove all non-ASCII characters
        .trim();
  }

  Widget _buildFormattedResponse(String response) {
    // Split response into paragraphs and format
    final paragraphs = response.split('\n\n');
    List<Widget> formattedWidgets = [];

    for (int i = 0; i < paragraphs.length; i++) {
      final paragraph = paragraphs[i].trim();
      if (paragraph.isEmpty) continue;

      // Check for different formatting patterns
      if (paragraph.startsWith('**') && paragraph.endsWith('**')) {
        // Bold headers
        formattedWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              paragraph.replaceAll('**', ''),
              style: FlutterFlowTheme.of(context).titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        );
      } else if (paragraph.startsWith('•') || paragraph.startsWith('-')) {
        // Bullet points
        formattedWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    paragraph.replaceFirst(RegExp(r'^[•-]\s*'), ''),
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (paragraph.contains(':') && paragraph.split(':')[0].length < 30) {
        // Key-value pairs (like "Code: P0420")
        final parts = paragraph.split(':');
        if (parts.length == 2) {
          formattedWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RichText(
                text: TextSpan(
                  style: FlutterFlowTheme.of(context).bodyMedium,
                  children: [
                    TextSpan(
                      text: '${parts[0].trim()}: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    TextSpan(
                      text: parts[1].trim(),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // Regular paragraph
          formattedWidgets.add(_buildRegularParagraph(paragraph));
        }
      } else {
        // Regular paragraph
        formattedWidgets.add(_buildRegularParagraph(paragraph));
      }

      // Add spacing between paragraphs (except last one)
      if (i < paragraphs.length - 1) {
        formattedWidgets.add(const SizedBox(height: 8));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: formattedWidgets,
    );
  }

  Widget _buildRegularParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
          height: 1.4, // Better line spacing
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        elevation: 0,
        title: _userLoading 
          ? Text(
              'Home', 
              style: FlutterFlowTheme.of(context).titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _userName != null ? 'Welcome, $_userName!' : 'Welcome!',
                  style: FlutterFlowTheme.of(context).titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Home',
                  style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => GoRouter.of(context).push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadVehicles,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Carousel
                SizedBox(
                  height: 160,
                  child: PageView(
                    controller: _pageController,
                    children: [
                      _QuickActionCard(
                        icon: Icons.chat_bubble_outline,
                        color: Colors.blue,
                        title: 'AI Chat',
                        subtitle: 'Ask the AI assistant',
                        onTap: () {
                          GoRouter.of(context).push('/chat');
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.add_card,
                        color: Colors.green,
                        title: 'Add Car',
                        subtitle: 'Add a new vehicle',
                        onTap: _navigateToAddCar,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Chat Section
                Card(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flash_on, color: Colors.orange, size: 24),
                            const SizedBox(width: 8),
                            Text('Quick Chat', style: FlutterFlowTheme.of(context).titleMedium),
                            const Spacer(),
                            if (_quickChatResponse != null || _quickChatError != null)
                              TextButton.icon(
                                onPressed: _resetQuickChat,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Reset'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _chatExchangeCount >= 2 
                              ? 'Tap "AI Chat" above for longer conversations'
                              : 'Ask me anything about your car or OBD2 diagnostics',
                          style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                            color: _chatExchangeCount >= 2 ? Colors.orange : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _quickChatController,
                                enabled: _chatExchangeCount < 2,
                                decoration: InputDecoration(
                                  hintText: _chatExchangeCount >= 2 
                                      ? 'Use full AI Chat for more questions'
                                      : 'What would you like to know?',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: _quickChatLoading
                                      ? const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        )
                                      : null,
                                ),
                                onSubmitted: (_) => _chatExchangeCount < 2 ? _sendQuickChat() : null,
                                maxLines: 2,
                                minLines: 1,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _chatExchangeCount >= 2 
                                  ? () => GoRouter.of(context).push('/chat')
                                  : (_quickChatLoading ? null : _sendQuickChat),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _chatExchangeCount >= 2 
                                    ? Colors.blue 
                                    : FlutterFlowTheme.of(context).primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(_chatExchangeCount >= 2 ? 'Full Chat' : 'Ask'),
                            ),
                          ],
                        ),
                        if (_quickChatResponse != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primaryBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.smart_toy, color: Colors.blue, size: 18),
                                    const SizedBox(width: 8),
                                    Text('AI Response', style: FlutterFlowTheme.of(context).titleSmall),
                                    const Spacer(),
                                    Icon(Icons.auto_awesome, color: Colors.blue.withOpacity(0.6), size: 16),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildFormattedResponse(_quickChatResponse!),
                              ],
                            ),
                          ),
                        ],
                        if (_quickChatError != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Text(_quickChatError!, style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // My Vehicles Section
                Card(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('My Vehicles', style: FlutterFlowTheme.of(context).titleMedium),
                            TextButton.icon(
                              onPressed: _navigateToAddCar,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Vehicle'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_vehiclesLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else if (_vehicles.isEmpty)
                          Column(
                            children: [
                              Icon(
                                Icons.directions_car_outlined,
                                size: 48,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No vehicles added yet',
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap "Add Vehicle" to get started',
                                style: FlutterFlowTheme.of(context).bodySmall,
                              ),
                            ],
                          )
                        else
                          Column(
                            children: _vehicles.map((vehicle) => _buildVehicleCard(vehicle)).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(VehicleResponse vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: vehicle.isPrimary
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).primary.withOpacity(0.2),
          width: vehicle.isPrimary ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car,
                color: FlutterFlowTheme.of(context).primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                  style: FlutterFlowTheme.of(context).titleSmall,
                ),
              ),
              if (vehicle.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PRIMARY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'primary':
                      _setPrimaryVehicle(vehicle);
                      break;
                    case 'delete':
                      _deleteVehicle(vehicle);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (!vehicle.isPrimary)
                    PopupMenuItem(
                      value: 'primary',
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 18),
                          const SizedBox(width: 8),
                          const Text('Set as Primary'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'VIN: ${vehicle.vin}',
            style: FlutterFlowTheme.of(context).bodySmall.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          if (vehicle.vehicleType?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              'Type: ${vehicle.vehicleType}',
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 12),
                Text(title, style: FlutterFlowTheme.of(context).titleSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: FlutterFlowTheme.of(context).bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
