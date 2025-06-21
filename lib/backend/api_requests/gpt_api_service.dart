import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/diagnostic_models.dart';

class GPTApiService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  final String _apiKey;
  
  GPTApiService(this._apiKey);

  // Generate diagnostic analysis using GPT
  Future<Map<String, dynamic>> generateDiagnosticAnalysis({
    required DiagnosticReport report,
    required NHTSAVehicleData? vehicleData,
  }) async {
    try {
      final prompt = _buildDiagnosticPrompt(report, vehicleData);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(),
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'max_tokens': 2000,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        return _parseGPTResponse(content);
      } else {
        print('GPT API error: ${response.statusCode} - ${response.body}');
        return _getDefaultAnalysis();
      }
    } catch (e) {
      print('Error generating diagnostic analysis: $e');
      return _getDefaultAnalysis();
    }
  }

  // Build comprehensive diagnostic prompt
  String _buildDiagnosticPrompt(DiagnosticReport report, NHTSAVehicleData? vehicleData) {
    final buffer = StringBuffer();
    
    // Vehicle information
    buffer.writeln('VEHICLE INFORMATION:');
    if (vehicleData != null) {
      buffer.writeln('Make: ${vehicleData.make}');
      buffer.writeln('Model: ${vehicleData.model}');
      buffer.writeln('Year: ${vehicleData.year}');
      buffer.writeln('Engine: ${vehicleData.engineCylinders} cylinders, ${vehicleData.engineConfiguration}');
      buffer.writeln('Fuel Type: ${vehicleData.fuelType}');
      buffer.writeln('Transmission: ${vehicleData.transmissionStyle}');
      buffer.writeln('Drive Type: ${vehicleData.driveType}');
    } else {
      buffer.writeln('VIN: ${report.vehicleVin}');
    }
    buffer.writeln('Scan Date: ${report.scanDate}');
    buffer.writeln();

    // Diagnostic Trouble Codes
    buffer.writeln('DIAGNOSTIC TROUBLE CODES:');
    if (report.troubleCodes.isEmpty) {
      buffer.writeln('No trouble codes found - vehicle appears to be operating normally.');
    } else {
      for (final code in report.troubleCodes) {
        buffer.writeln('${code.code} (${code.severity}): ${code.description}');
        buffer.writeln('  Category: ${code.category}');
        buffer.writeln('  Status: ${code.isPending ? "Pending" : "Confirmed"}');
        buffer.writeln();
      }
    }

    // Live Data
    buffer.writeln('LIVE DATA:');
    for (final data in report.liveData) {
      buffer.writeln('${data.name}: ${data.value} ${data.unit}');
    }
    buffer.writeln();

    // Emissions Status
    buffer.writeln('EMISSIONS MONITOR STATUS:');
    for (final monitor in report.emissionsStatus) {
      buffer.writeln('${monitor.monitor}: ${monitor.status}');
    }
    buffer.writeln();

    // Analysis request
    buffer.writeln('Please provide:');
    buffer.writeln('1. Overall vehicle health assessment with a numerical health score (0-100)');
    buffer.writeln('2. Detailed analysis of each trouble code');
    buffer.writeln('3. Analysis of live data values');
    buffer.writeln('4. Emissions compliance status');
    buffer.writeln('5. Specific repair recommendations');
    buffer.writeln('6. Priority level for each issue');
    buffer.writeln('7. Estimated repair costs (if possible)');
    buffer.writeln('8. Safety implications');
    buffer.writeln('9. Preventive maintenance suggestions');
    buffer.writeln();
    buffer.writeln('IMPORTANT: Include a health score in your response using this format: "Health Score: XX" where XX is a number from 0-100.');

    return buffer.toString();
  }

  // System prompt for GPT
  String _getSystemPrompt() {
    return '''
You are an expert automotive diagnostic technician with 20+ years of experience. You specialize in OBD2 diagnostics, engine management systems, and vehicle repair.

Your role is to analyze diagnostic scan results and provide:
1. Clear, professional diagnostic analysis
2. Accurate trouble code interpretations
3. Practical repair recommendations
4. Safety assessments
5. Cost estimates when possible
6. Preventive maintenance advice

Always consider:
- Vehicle make, model, and year specifics
- Common failure patterns for the vehicle
- Safety implications of each issue
- Cost-effective repair strategies
- Environmental impact of repairs

Provide responses in a structured, easy-to-understand format suitable for both technicians and vehicle owners.
''';
  }

  // Parse GPT response into structured format
  Map<String, dynamic> _parseGPTResponse(String content) {
    try {
      // Try to extract structured sections
      final sections = <String, String>{};
      final lines = content.split('\n');
      
      String currentSection = '';
      String currentContent = '';
      
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        
        // Check for section headers
        if (line.trim().endsWith(':') && line.length < 50) {
          if (currentSection.isNotEmpty) {
            sections[currentSection] = currentContent.trim();
          }
          currentSection = line.trim().replaceAll(':', '');
          currentContent = '';
        } else {
          currentContent += line + '\n';
        }
      }
      
      // Add last section
      if (currentSection.isNotEmpty) {
        sections[currentSection] = currentContent.trim();
      }

      // Extract key information
      final analysis = sections['Overall Assessment'] ?? sections['Vehicle Health Assessment'] ?? '';
      final recommendations = sections['Recommendations'] ?? sections['Repair Recommendations'] ?? '';
      final severity = _extractSeverity(content);
      final priorityIssues = _extractPriorityIssues(content);
      final safetyIssues = _extractSafetyIssues(content);
      final costEstimate = _extractCostEstimate(content);
      final healthScore = _extractHealthScore(content);

      return {
        'analysis': analysis,
        'recommendations': recommendations,
        'severity': severity,
        'priorityIssues': priorityIssues,
        'safetyIssues': safetyIssues,
        'costEstimate': costEstimate,
        'healthScore': healthScore,
        'fullResponse': content,
        'sections': sections,
      };
    } catch (e) {
      print('Error parsing GPT response: $e');
      return {
        'analysis': content,
        'recommendations': '',
        'severity': 'Info',
        'priorityIssues': [],
        'safetyIssues': [],
        'costEstimate': '',
        'healthScore': '',
        'fullResponse': content,
        'sections': {},
      };
    }
  }

  // Extract severity from response
  String _extractSeverity(String content) {
    final lowerContent = content.toLowerCase();
    
    if (lowerContent.contains('critical') || lowerContent.contains('severe') || 
        lowerContent.contains('dangerous') || lowerContent.contains('immediate')) {
      return 'Critical';
    } else if (lowerContent.contains('warning') || lowerContent.contains('moderate') ||
               lowerContent.contains('attention')) {
      return 'Warning';
    } else if (lowerContent.contains('good') || lowerContent.contains('normal') ||
               lowerContent.contains('healthy')) {
      return 'Good';
    } else {
      return 'Info';
    }
  }

  // Extract priority issues
  List<String> _extractPriorityIssues(String content) {
    final issues = <String>[];
    final lines = content.split('\n');
    
    for (final line in lines) {
      if (line.toLowerCase().contains('priority') || 
          line.toLowerCase().contains('urgent') ||
          line.toLowerCase().contains('immediate')) {
        issues.add(line.trim());
      }
    }
    
    return issues;
  }

  // Extract safety issues
  List<String> _extractSafetyIssues(String content) {
    final issues = <String>[];
    final lines = content.split('\n');
    
    for (final line in lines) {
      if (line.toLowerCase().contains('safety') || 
          line.toLowerCase().contains('dangerous') ||
          line.toLowerCase().contains('hazard')) {
        issues.add(line.trim());
      }
    }
    
    return issues;
  }

  // Extract cost estimate
  String _extractCostEstimate(String content) {
    final costPattern = RegExp(r'\$[\d,]+(?:-\$[\d,]+)?');
    final match = costPattern.firstMatch(content);
    return match?.group(0) ?? '';
  }

  // Extract health score
  String _extractHealthScore(String content) {
    final healthPattern = RegExp(r'Health Score: (\d+)');
    final match = healthPattern.firstMatch(content);
    return match?.group(1) ?? '';
  }

  // Get default analysis when GPT fails
  Map<String, dynamic> _getDefaultAnalysis() {
    return {
      'analysis': 'Unable to generate AI analysis at this time. Please review the diagnostic data manually.',
      'recommendations': 'Consult with a qualified automotive technician for proper diagnosis and repair.',
      'severity': 'Info',
      'priorityIssues': [],
      'safetyIssues': [],
      'costEstimate': '',
      'healthScore': '',
      'fullResponse': 'Analysis unavailable',
      'sections': {},
    };
  }

  // Generate simplified analysis for quick overview
  Future<String> generateQuickAnalysis(DiagnosticReport report) async {
    try {
      final prompt = '''
Analyze this diagnostic scan in 2-3 sentences:

Trouble Codes: ${report.troubleCodes.map((c) => c.code).join(', ')}
Live Data Points: ${report.liveData.length}
Emissions Status: ${report.emissionsStatus.where((e) => e.status == 'Not Ready').length} not ready

Provide a brief, clear assessment of vehicle health and any immediate concerns.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'max_tokens': 150,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Vehicle diagnostic scan completed. Review results for any issues.';
      }
    } catch (e) {
      return 'Vehicle diagnostic scan completed. Review results for any issues.';
    }
  }

  // Generate maintenance recommendations
  Future<List<String>> generateMaintenanceRecommendations({
    required NHTSAVehicleData vehicleData,
    required List<LiveDataPoint> liveData,
  }) async {
    try {
      final prompt = '''
Based on this vehicle information and live data, provide 5-7 specific maintenance recommendations:

Vehicle: ${vehicleData.year} ${vehicleData.make} ${vehicleData.model}
Engine: ${vehicleData.engineCylinders} cylinders, ${vehicleData.engineConfiguration}
Fuel Type: ${vehicleData.fuelType}

Live Data:
${liveData.map((d) => '${d.name}: ${d.value} ${d.unit}').join('\n')}

Provide practical, specific maintenance recommendations that would benefit this vehicle.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'max_tokens': 500,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Parse recommendations into list
        final recommendations = <String>[];
        final lines = content.split('\n');
        
        for (final line in lines) {
          if (line.trim().isNotEmpty && 
              (line.trim().startsWith('-') || 
               line.trim().startsWith('•') || 
               line.trim().startsWith('1.') ||
               line.trim().startsWith('2.') ||
               line.trim().startsWith('3.') ||
               line.trim().startsWith('4.') ||
               line.trim().startsWith('5.'))) {
            recommendations.add(line.trim().replaceAll(RegExp(r'^[-•\d\.\s]+'), ''));
          }
        }
        
        return recommendations;
      } else {
        return _getDefaultMaintenanceRecommendations();
      }
    } catch (e) {
      return _getDefaultMaintenanceRecommendations();
    }
  }

  // Default maintenance recommendations
  List<String> _getDefaultMaintenanceRecommendations() {
    return [
      'Check engine oil level and condition',
      'Inspect air filter and replace if dirty',
      'Check tire pressure and condition',
      'Inspect brake system components',
      'Check coolant level and condition',
      'Inspect battery terminals and connections',
      'Review vehicle maintenance schedule',
    ];
  }

  // Generate diagnostic response for AI chat
  Future<String> generateDiagnosticResponse(Map<String, dynamic> context) async {
    try {
      final question = context['question'] as String;
      final vehicleData = context['vehicleData'] as Map<String, dynamic>?;
      final lastReport = context['lastReport'] as Map<String, dynamic>?;

      final prompt = _buildChatPrompt(question, vehicleData, lastReport);

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': _getChatSystemPrompt(),
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return _getDefaultChatResponse(question);
      }
    } catch (e) {
      print('Error generating diagnostic response: $e');
      return _getDefaultChatResponse(context['question'] as String);
    }
  }

  // Build chat prompt
  String _buildChatPrompt(String question, Map<String, dynamic>? vehicleData, Map<String, dynamic>? lastReport) {
    final buffer = StringBuffer();
    
    buffer.writeln('Question: $question');
    buffer.writeln();

    if (vehicleData != null) {
      buffer.writeln('Vehicle Information:');
      buffer.writeln('Make: ${vehicleData['make'] ?? 'Unknown'}');
      buffer.writeln('Model: ${vehicleData['model'] ?? 'Unknown'}');
      buffer.writeln('Year: ${vehicleData['year'] ?? 'Unknown'}');
      buffer.writeln('Engine: ${vehicleData['engineCylinders'] ?? 'Unknown'} cylinders');
      buffer.writeln('Fuel Type: ${vehicleData['fuelType'] ?? 'Unknown'}');
      buffer.writeln();
    }

    if (lastReport != null) {
      buffer.writeln('Recent Diagnostic Information:');
      final troubleCodes = lastReport['troubleCodes'] as List<dynamic>? ?? [];
      if (troubleCodes.isNotEmpty) {
        buffer.writeln('Trouble Codes:');
        for (final code in troubleCodes) {
          buffer.writeln('- ${code['code']}: ${code['description']}');
        }
        buffer.writeln();
      }
      
      final healthScore = lastReport['healthScore'];
      if (healthScore != null) {
        buffer.writeln('Last Health Score: $healthScore');
        buffer.writeln();
      }
    }

    buffer.writeln('Please provide a helpful, informative response to the user\'s question about their vehicle.');

    return buffer.toString();
  }

  // System prompt for chat
  String _getChatSystemPrompt() {
    return '''
You are an expert automotive diagnostic assistant with extensive knowledge of vehicle systems, maintenance, and troubleshooting.

Your role is to:
1. Answer questions about vehicle diagnostics, maintenance, and repair
2. Provide helpful, accurate information about automotive systems
3. Suggest appropriate actions based on the user's situation
4. Explain technical concepts in simple terms
5. Recommend when professional help is needed

Always consider:
- The specific vehicle information provided
- Safety implications of any advice
- Cost-effective solutions
- When to recommend professional service

Keep responses conversational, helpful, and informative. If you don't have enough information to provide a complete answer, ask for more details or recommend consulting a professional.
''';
  }

  // Default chat response
  String _getDefaultChatResponse(String question) {
    final lowerQuestion = question.toLowerCase();
    
    if (lowerQuestion.contains('check engine') || lowerQuestion.contains('cel')) {
      return 'A check engine light indicates that your vehicle\'s onboard diagnostic system has detected an issue. The most common causes include loose gas cap, oxygen sensor problems, catalytic converter issues, or spark plug/ignition coil problems. I recommend having the trouble codes read to identify the specific issue.';
    } else if (lowerQuestion.contains('oil') || lowerQuestion.contains('maintenance')) {
      return 'Regular oil changes are crucial for engine health. Most vehicles need oil changes every 5,000-7,500 miles or 6-12 months. Check your owner\'s manual for specific recommendations for your vehicle.';
    } else if (lowerQuestion.contains('brake') || lowerQuestion.contains('stopping')) {
      return 'Brake issues can be safety-critical. If you\'re experiencing brake problems like squeaking, grinding, or reduced stopping power, I strongly recommend having your brakes inspected by a professional immediately.';
    } else {
      return 'I\'d be happy to help with your vehicle question. Could you provide more specific details about your vehicle and the issue you\'re experiencing? This will help me give you more accurate advice.';
    }
  }
} 