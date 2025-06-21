import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../flutter_flow/flutter_flow_theme.dart';

class AccessibilityWidgets {
  static Widget withSemantics({
    required Widget child,
    String? label,
    String? hint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  static Widget withLiveRegion({
    required Widget child,
    String? announcement,
    bool isLiveRegion = true,
  }) {
    return Semantics(
      liveRegion: isLiveRegion,
      child: child,
    );
  }

  static void announceForAccessibility(BuildContext context, String message) {
    // Use SemanticsService.announce if available, otherwise use a fallback
    try {
      // This is a fallback implementation since SemanticsService might not be available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Silent fallback
    }
  }
}

class HighContrastWidget extends StatelessWidget {
  final Widget child;
  final bool enableHighContrast;

  const HighContrastWidget({
    super.key,
    required this.child,
    this.enableHighContrast = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableHighContrast) return child;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.white,
          onSecondary: Colors.black,
          surface: Colors.black,
          onSurface: Colors.white,
          background: Colors.black,
          onBackground: Colors.white,
        ),
      ),
      child: child,
    );
  }
}

class ScalableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? minScale;
  final double? maxScale;

  const ScalableText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.minScale = 0.8,
    this.maxScale = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaler.scale(1.0).clamp(
            minScale ?? 0.8,
            maxScale ?? 2.0,
          ),
        ),
      ),
    );
  }
}

class KeyboardNavigableWidget extends StatefulWidget {
  final Widget child;
  final FocusNode? focusNode;
  final VoidCallback? onEnter;
  final VoidCallback? onSpace;
  final bool autofocus;

  const KeyboardNavigableWidget({
    super.key,
    required this.child,
    this.focusNode,
    this.onEnter,
    this.onSpace,
    this.autofocus = false,
  });

  @override
  State<KeyboardNavigableWidget> createState() => _KeyboardNavigableWidgetState();
}

class _KeyboardNavigableWidgetState extends State<KeyboardNavigableWidget> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onEnter?.call();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.space) {
            widget.onSpace?.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        button: true,
        child: widget.child,
      ),
    );
  }
}

class VoiceNavigationWidget extends StatelessWidget {
  final Widget child;
  final String? voiceLabel;
  final String? voiceHint;
  final VoidCallback? onVoiceActivate;

  const VoiceNavigationWidget({
    super.key,
    required this.child,
    this.voiceLabel,
    this.voiceHint,
    this.onVoiceActivate,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: voiceLabel,
      hint: voiceHint,
      onTap: onVoiceActivate,
      child: child,
    );
  }
}

class AccessibilitySettings {
  static bool isHighContrastEnabled = false;
  static bool isScreenReaderEnabled = false;
  static double textScaleFactor = 1.0;
  static bool isReducedMotionEnabled = false;
  static bool isBoldTextEnabled = false;

  static void updateSettings({
    bool? highContrast,
    bool? screenReader,
    double? textScale,
    bool? reducedMotion,
    bool? boldText,
  }) {
    if (highContrast != null) isHighContrastEnabled = highContrast;
    if (screenReader != null) isScreenReaderEnabled = screenReader;
    if (textScale != null) textScaleFactor = textScale;
    if (reducedMotion != null) isReducedMotionEnabled = reducedMotion;
    if (boldText != null) isBoldTextEnabled = boldText;
  }
}

class AccessibilityAwareWidget extends StatelessWidget {
  final Widget child;
  final bool respectReducedMotion;
  final bool respectHighContrast;
  final bool respectTextScaling;

  const AccessibilityAwareWidget({
    super.key,
    required this.child,
    this.respectReducedMotion = true,
    this.respectHighContrast = true,
    this.respectTextScaling = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    if (respectReducedMotion && AccessibilitySettings.isReducedMotionEnabled) {
      result = _applyReducedMotion(result);
    }

    if (respectHighContrast && AccessibilitySettings.isHighContrastEnabled) {
      result = HighContrastWidget(
        enableHighContrast: true,
        child: result,
      );
    }

    if (respectTextScaling) {
      result = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(AccessibilitySettings.textScaleFactor),
        ),
        child: result,
      );
    }

    return result;
  }

  Widget _applyReducedMotion(Widget child) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: child,
    );
  }
}

class AccessibilityTestWidget extends StatelessWidget {
  const AccessibilityTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccessibilityAwareWidget(
              child: ScalableText(
                'This text scales with system settings',
                style: FlutterFlowTheme.of(context).titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            KeyboardNavigableWidget(
              onEnter: () => _showSnackBar(context, 'Enter pressed'),
              onSpace: () => _showSnackBar(context, 'Space pressed'),
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
              voiceLabel: 'Test button for voice navigation',
              voiceHint: 'Double tap to activate',
              onVoiceActivate: () => _showSnackBar(context, 'Voice activated'),
              child: ElevatedButton(
                onPressed: () => _showSnackBar(context, 'Button pressed'),
                child: const Text('Voice Navigation Test'),
              ),
            ),
            const SizedBox(height: 16),
            AccessibilityWidgets.withSemantics(
              label: 'Important information',
              hint: 'This is a test of screen reader support',
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[100],
                child: const Text('This should be announced by screen readers'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
} 