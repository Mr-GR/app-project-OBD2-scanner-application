import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';

class TermsModalWidget extends StatefulWidget {
  const TermsModalWidget({
    Key? key,
    this.onAccept,
    this.onDecline,
  }) : super(key: key);

  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  @override
  State<TermsModalWidget> createState() => _TermsModalWidgetState();
}

class _TermsModalWidgetState extends State<TermsModalWidget> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _loadingTimer;
  
  // Document viewing and acceptance state
  bool _isViewingTerms = true;
  bool _hasViewedTerms = false;
  bool _hasViewedPrivacy = false;
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  
  // Track errors per document
  bool _hasTermsError = false;
  bool _hasPrivacyError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100 && _isLoading) {
              setState(() {
                _isLoading = false;
                _hasError = false;
                // Mark current document as viewed and clear its error
                if (_isViewingTerms) {
                  _hasViewedTerms = true;
                  _hasTermsError = false;
                } else {
                  _hasViewedPrivacy = true;
                  _hasPrivacyError = false;
                }
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
            // Set timeout for loading
            _loadingTimer?.cancel();
            _loadingTimer = Timer(Duration(seconds: 10), () {
              if (_isLoading) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                  // Track which document has error and clear its acceptance
                  if (_isViewingTerms) {
                    _hasTermsError = true;
                    _acceptedTerms = false;
                    _hasViewedTerms = false;
                  } else {
                    _hasPrivacyError = true;
                    _acceptedPrivacy = false;
                    _hasViewedPrivacy = false;
                  }
                });
              }
            });
          },
          onPageFinished: (String url) {
            _loadingTimer?.cancel();
            // Check if the loaded page is an error page
            _checkForErrorPage();
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation requests
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            _loadingTimer?.cancel();
            setState(() {
              _isLoading = false;
              _hasError = true;
              // Track which document has error and clear its acceptance
              if (_isViewingTerms) {
                _hasTermsError = true;
                _acceptedTerms = false;
                _hasViewedTerms = false;
              } else {
                _hasPrivacyError = true;
                _acceptedPrivacy = false;
                _hasViewedPrivacy = false;
              }
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_isViewingTerms ? Config.termsUrl : Config.privacyUrl));
  }

  void _switchDocument(bool viewTerms) {
    setState(() {
      _isViewingTerms = viewTerms;
      _isLoading = true;
      // Set global error state based on current document's error state
      _hasError = _isViewingTerms ? _hasTermsError : _hasPrivacyError;
    });
    _controller.loadRequest(Uri.parse(_isViewingTerms ? Config.termsUrl : Config.privacyUrl));
  }

  void _checkForErrorPage() async {
    try {
      // Check if the page contains error indicators
      final title = await _controller.getTitle();
      final url = await _controller.currentUrl();
      
      // Check for common error page indicators
      if (title != null && 
          (title.toLowerCase().contains('not available') || 
           title.toLowerCase().contains('not found') ||
           title.toLowerCase().contains('error') ||
           url == null ||
           url.startsWith('chrome-error://'))) {
        
        setState(() {
          _isLoading = false;
          _hasError = true;
          // Track which document has error and clear its acceptance
          if (_isViewingTerms) {
            _hasTermsError = true;
            _acceptedTerms = false;
            _hasViewedTerms = false;
          } else {
            _hasPrivacyError = true;
            _acceptedPrivacy = false;
            _hasViewedPrivacy = false;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = false;
          // Mark current document as viewed and clear its error
          if (_isViewingTerms) {
            _hasViewedTerms = true;
            _hasTermsError = false;
          } else {
            _hasViewedPrivacy = true;
            _hasPrivacyError = false;
          }
        });
      }
    } catch (e) {
      // If we can't check the page, assume error
      setState(() {
        _isLoading = false;
        _hasError = true;
        if (_isViewingTerms) {
          _hasTermsError = true;
          _acceptedTerms = false;
          _hasViewedTerms = false;
        } else {
          _hasPrivacyError = true;
          _acceptedPrivacy = false;
          _hasViewedPrivacy = false;
        }
      });
    }
  }

  bool get _canAccept => _acceptedTerms && _acceptedPrivacy && !_hasTermsError && !_hasPrivacyError;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Title and close button
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Legal Documents',
                          style: FlutterFlowTheme.of(context).headlineSmall.copyWith(
                            fontFamily: 'Inter Tight',
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 20,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Document tabs
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _switchDocument(true),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _isViewingTerms 
                                        ? FlutterFlowTheme.of(context).primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Terms & Conditions',
                                    style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                      color: _isViewingTerms
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(context).secondaryText,
                                      fontWeight: _isViewingTerms ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  if (_hasViewedTerms && !_hasTermsError) ...[
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: FlutterFlowTheme.of(context).success,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _switchDocument(false),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: !_isViewingTerms 
                                        ? FlutterFlowTheme.of(context).primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Privacy Policy',
                                    style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                      color: !_isViewingTerms
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(context).secondaryText,
                                      fontWeight: !_isViewingTerms ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  if (_hasViewedPrivacy && !_hasPrivacyError) ...[
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: FlutterFlowTheme.of(context).success,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // WebView Content
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _hasError
                    ? _buildErrorWidget()
                    : Stack(
                        children: [
                          WebViewWidget(controller: _controller),
                          if (_isLoading) _buildLoadingWidget(),
                        ],
                      ),
              ),
            ),
            // Acceptance checkboxes and buttons
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Checkboxes for acceptance
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (_hasViewedTerms && !_hasTermsError) ? (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        } : null,
                        activeColor: FlutterFlowTheme.of(context).primary,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: (_hasViewedTerms && !_hasTermsError) ? () {
                            setState(() {
                              _acceptedTerms = !_acceptedTerms;
                            });
                          } : null,
                          child: Text(
                            'I have read and agree to the Terms & Conditions',
                            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                              color: (_hasViewedTerms && !_hasTermsError)
                                  ? FlutterFlowTheme.of(context).primaryText
                                  : FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptedPrivacy,
                        onChanged: (_hasViewedPrivacy && !_hasPrivacyError) ? (value) {
                          setState(() {
                            _acceptedPrivacy = value ?? false;
                          });
                        } : null,
                        activeColor: FlutterFlowTheme.of(context).primary,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: (_hasViewedPrivacy && !_hasPrivacyError) ? () {
                            setState(() {
                              _acceptedPrivacy = !_acceptedPrivacy;
                            });
                          } : null,
                          child: Text(
                            'I have read and agree to the Privacy Policy',
                            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                              color: (_hasViewedPrivacy && !_hasPrivacyError)
                                  ? FlutterFlowTheme.of(context).primaryText
                                  : FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onDecline?.call();
                          },
                          text: 'Decline',
                          options: FFButtonOptions(
                            height: 50,
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.copyWith(
                              fontFamily: 'Inter Tight',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 16,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                            elevation: 0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: _canAccept ? () {
                            Navigator.of(context).pop();
                            widget.onAccept?.call();
                          } : null,
                          text: 'Accept & Continue',
                          options: FFButtonOptions(
                            height: 50,
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            color: _canAccept 
                                ? FlutterFlowTheme.of(context).primary
                                : FlutterFlowTheme.of(context).alternate,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.copyWith(
                              fontFamily: 'Inter Tight',
                              color: _canAccept 
                                  ? Colors.white
                                  : FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 16,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                            elevation: _canAccept ? 3 : 0,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(25),
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
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: FlutterFlowTheme.of(context).secondaryBackground.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: FlutterFlowTheme.of(context).primary,
            ),
            SizedBox(height: 16),
            Text(
              'Loading Terms & Conditions...',
              style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                fontFamily: 'Inter',
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: FlutterFlowTheme.of(context).error,
          ),
          SizedBox(height: 16),
          Text(
            'Unable to load Terms & Conditions',
            style: FlutterFlowTheme.of(context).headlineSmall.copyWith(
              fontFamily: 'Inter Tight',
              color: FlutterFlowTheme.of(context).primaryText,
              letterSpacing: 0.0,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
              fontFamily: 'Inter',
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
          ),
          SizedBox(height: 20),
          FFButtonWidget(
            onPressed: () {
              _initializeWebView();
            },
            text: 'Retry',
            options: FFButtonOptions(
              height: 40,
              padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.copyWith(
                fontFamily: 'Inter Tight',
                color: Colors.white,
                letterSpacing: 0.0,
              ),
              elevation: 3,
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}