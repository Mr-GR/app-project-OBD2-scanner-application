import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../flutter_flow/flutter_flow_theme.dart';
import '../backend/models/diagnostic_models.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DiagnosticReportTemplates {
  static const List<String> availableTemplates = [
    'Standard Report',
    'Detailed Report',
    'Summary Report',
    'Custom Report',
  ];

  static Future<String> generatePDFReport(
    DiagnosticReport report,
    String templateName, {
    Map<String, dynamic>? customOptions,
  }) async {
    final pdf = pw.Document();
    
    switch (templateName) {
      case 'Standard Report':
        pdf.addPage(_generateStandardReport(report));
        break;
      case 'Detailed Report':
        pdf.addPage(_generateDetailedReport(report));
        break;
      case 'Summary Report':
        pdf.addPage(_generateSummaryReport(report));
        break;
      case 'Custom Report':
        pdf.addPage(_generateCustomReport(report, customOptions ?? {}));
        break;
      default:
        pdf.addPage(_generateStandardReport(report));
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/diagnostic_report_${report.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }

  static pw.Page _generateStandardReport(DiagnosticReport report) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(report),
            pw.SizedBox(height: 20),
            _buildVehicleInfo(report),
            pw.SizedBox(height: 20),
            _buildTroubleCodes(report),
            pw.SizedBox(height: 20),
            _buildLiveData(report),
            pw.SizedBox(height: 20),
            _buildEmissionsStatus(report),
            pw.SizedBox(height: 20),
            _buildRecommendations(report),
          ],
        );
      },
    );
  }

  static pw.Page _generateDetailedReport(DiagnosticReport report) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(report),
            pw.SizedBox(height: 20),
            _buildVehicleInfo(report),
            pw.SizedBox(height: 20),
            _buildDetailedTroubleCodes(report),
            pw.SizedBox(height: 20),
            _buildDetailedLiveData(report),
            pw.SizedBox(height: 20),
            _buildDetailedEmissionsStatus(report),
            pw.SizedBox(height: 20),
            _buildDetailedRecommendations(report),
            pw.SizedBox(height: 20),
            _buildTechnicalDetails(report),
          ],
        );
      },
    );
  }

  static pw.Page _generateSummaryReport(DiagnosticReport report) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(report),
            pw.SizedBox(height: 20),
            _buildVehicleInfo(report),
            pw.SizedBox(height: 20),
            _buildSummaryTroubleCodes(report),
            pw.SizedBox(height: 20),
            _buildSummaryRecommendations(report),
          ],
        );
      },
    );
  }

  static pw.Page _generateCustomReport(
    DiagnosticReport report,
    Map<String, dynamic> options,
  ) {
    final sections = <pw.Widget>[];
    
    sections.add(_buildHeader(report));
    sections.add(pw.SizedBox(height: 20));

    if (options['includeVehicleInfo'] ?? true) {
      sections.add(_buildVehicleInfo(report));
      sections.add(pw.SizedBox(height: 20));
    }

    if (options['includeTroubleCodes'] ?? true) {
      sections.add(_buildTroubleCodes(report));
      sections.add(pw.SizedBox(height: 20));
    }

    if (options['includeLiveData'] ?? false) {
      sections.add(_buildLiveData(report));
      sections.add(pw.SizedBox(height: 20));
    }

    if (options['includeEmissions'] ?? true) {
      sections.add(_buildEmissionsStatus(report));
      sections.add(pw.SizedBox(height: 20));
    }

    if (options['includeRecommendations'] ?? true) {
      sections.add(_buildRecommendations(report));
      sections.add(pw.SizedBox(height: 20));
    }

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: sections,
        );
      },
    );
  }

  // Header section
  static pw.Widget _buildHeader(DiagnosticReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Diagnostic Report',
            style: pw.TextStyle(
              fontSize: 24,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on: ${report.scanDate.toLocal()}',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
          pw.Text(
            'Report ID: ${report.id}',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Vehicle information section
  static pw.Widget _buildVehicleInfo(DiagnosticReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Vehicle Information',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('VIN: ${report.vehicleVin}'),
                    pw.Text('Make: ${report.vehicleData?.make ?? 'N/A'}'),
                    pw.Text('Model: ${report.vehicleData?.model ?? 'N/A'}'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Year: ${report.vehicleData?.year ?? 'N/A'}'),
                    pw.Text('Engine: ${report.vehicleData?.engineConfiguration ?? 'N/A'}'),
                    pw.Text('Fuel Type: ${report.vehicleData?.fuelType ?? 'N/A'}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Trouble codes section
  static pw.Widget _buildTroubleCodes(DiagnosticReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Diagnostic Trouble Codes',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          if (report.troubleCodes.isEmpty)
            pw.Text('No trouble codes found')
          else
            ...report.troubleCodes.map((code) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: _getSeverityColor(code.severity),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${code.code} - ${code.description}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    'Category: ${code.category} | Status: ${code.isConfirmed ? 'Confirmed' : 'Pending'}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  // Live data section
  static pw.Widget _buildLiveData(DiagnosticReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Live Data',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          if (report.liveData.isEmpty)
            pw.Text('No live data available')
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Parameter', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Unit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...report.liveData.map((data) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(data.name),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(data.value.toString()),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(data.unit),
                    ),
                  ],
                )),
              ],
            ),
        ],
      ),
    );
  }

  // Emissions status section
  static pw.Widget _buildEmissionsStatus(DiagnosticReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Emissions Monitor Status',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          if (report.emissionsStatus.isEmpty)
            pw.Text('No emissions data available')
          else
            ...report.emissionsStatus.map((status) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: status.status == 'Ready' ? PdfColors.green : PdfColors.orange,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${status.monitor} - ${status.status}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    status.description,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  // Recommendations section
  static pw.Widget _buildRecommendations(DiagnosticReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Recommendations',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          if (report.recommendations.isEmpty)
            pw.Text('No specific recommendations at this time')
          else
            ...report.recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value;
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 20,
                      height: 20,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blue,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          '${index + 1}',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Text(recommendation),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // Helper methods for detailed sections
  static pw.Widget _buildDetailedTroubleCodes(DiagnosticReport report) {
    // Enhanced trouble codes with more details
    return _buildTroubleCodes(report);
  }

  static pw.Widget _buildDetailedLiveData(DiagnosticReport report) {
    // Enhanced live data with graphs/charts
    return _buildLiveData(report);
  }

  static pw.Widget _buildDetailedEmissionsStatus(DiagnosticReport report) {
    // Enhanced emissions with detailed status
    return _buildEmissionsStatus(report);
  }

  static pw.Widget _buildDetailedRecommendations(DiagnosticReport report) {
    // Enhanced recommendations with priority levels
    return _buildRecommendations(report);
  }

  static pw.Widget _buildTechnicalDetails(DiagnosticReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Technical Details',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Scan Date: ${report.scanDate.toLocal()}'),
          pw.Text('Health Score: ${report.healthScore ?? 'N/A'}'),
          pw.Text('Severity: ${report.severity}'),
          pw.Text('Trouble Codes Found: ${report.troubleCodes.length}'),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryTroubleCodes(DiagnosticReport report) {
    final confirmedCodes = report.troubleCodes.where((code) => code.isConfirmed).length;
    final pendingCodes = report.troubleCodes.where((code) => !code.isConfirmed).length;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Trouble Codes Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Total Codes: ${report.troubleCodes.length}'),
          pw.Text('Confirmed Codes: $confirmedCodes'),
          pw.Text('Pending Codes: $pendingCodes'),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryRecommendations(DiagnosticReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          if (report.troubleCodes.isEmpty)
            pw.Text('Vehicle appears to be in good condition')
          else
            pw.Text('${report.troubleCodes.length} issue(s) detected - see detailed report'),
        ],
      ),
    );
  }

  static PdfColor _getSeverityColor(String severity) {
    switch (severity) {
      case 'P':
        return PdfColors.red;
      case 'C':
        return PdfColors.orange;
      case 'B':
        return PdfColors.yellow;
      case 'U':
        return PdfColors.blue;
      default:
        return PdfColors.grey;
    }
  }

  static Future<void> exportReport() async {
    if (kIsWeb) {
      // Use web download/export logic here
      // For example, use AnchorElement for download
      print('Exporting report on web: use web download logic');
      return;
    }
    final output = await getTemporaryDirectory();
    // ... rest of export logic ...
  }
}

class ReportSharingService {
  static Future<void> shareViaEmail(String filePath, String recipient) async {
    final uri = Uri.parse('mailto:$recipient?subject=Diagnostic Report&body=Please find the diagnostic report attached.');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<void> shareViaWhatsApp(String filePath, String phoneNumber) async {
    final uri = Uri.parse('whatsapp://send?phone=$phoneNumber&text=Diagnostic Report');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<void> printReport(String filePath) async {
    // Implementation for printing would depend on platform
    print('Printing report: $filePath');
  }
}

class TrendAnalysisWidget extends StatelessWidget {
  final List<DiagnosticReport> reports;

  const TrendAnalysisWidget({
    super.key,
    required this.reports,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend Analysis',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 16),
            _buildTrendChart(),
            const SizedBox(height: 16),
            _buildTrendSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    // Placeholder for chart widget
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('Chart will be implemented here'),
      ),
    );
  }

  Widget _buildTrendSummary() {
    if (reports.isEmpty) {
      return const Text('No historical data available');
    }

    final recentReports = reports.take(5).toList();
    final totalCodes = recentReports.fold<int>(0, (sum, report) => sum + report.troubleCodes.length);
    final avgCodes = totalCodes / recentReports.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Average trouble codes per scan: ${avgCodes.toStringAsFixed(1)}'),
        Text('Total scans analyzed: ${reports.length}'),
        Text('Date range: ${reports.last.scanDate.toLocal()} - ${reports.first.scanDate.toLocal()}'),
      ],
    );
  }
} 