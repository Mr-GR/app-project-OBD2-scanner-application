import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class FlutterFlowTheme {
  static FlutterFlowTheme? _instance;
  static FlutterFlowTheme get instance => _instance ??= FlutterFlowTheme();
  
  static ThemeMode _themeMode = ThemeMode.system;
  static ThemeMode get themeMode => _themeMode;

  static FlutterFlowTheme of(BuildContext context) {
    return FlutterFlowTheme();
  }

  // Primary colors - Replicating from image
  Color get primary => const Color(0xFF3B82F6); // Bright blue for accents, buttons
  Color get primaryBackground => const Color(0xFF0F172A); // Very dark blue/slate background
  Color get secondaryBackground => const Color(0xFF1E293B); // Darker blue/slate for cards
  Color get tertiary => const Color(0xFF3B82F6); // Bright blue, same as primary
  Color get tertiaryBackground => const Color(0xFF334155); // A slightly lighter slate for contrast

  // Text colors
  Color get primaryText => const Color(0xFFF1F5F9); // Off-white
  Color get secondaryText => const Color(0xFF94A3B8); // Light gray slate
  Color get tertiaryText => const Color(0xFF64748B); // Medium gray slate

  // Other colors
  Color get alternate => const Color(0xFF334155); // Border color
  Color get overlay => const Color(0x8A000000); // Dark overlay with transparency
  Color get error => const Color(0xFFF87171); // A lighter red for dark theme
  Color get success => const Color(0xFF4ADE80); // A lighter green
  Color get warning => const Color(0xFFFBBF24); // Amber/yellow for warnings

  // Accent colors - Automotive themed
  Color get accent1 => const Color(0xFF3B82F6); // Primary blue
  Color get accent2 => const Color(0xFF1E293B); // Secondary background color
  Color get accent3 => const Color(0xFFFBBF24); // Amber/orange
  Color get accent4 => const Color(0xFF334155); // Tertiary background
  
  // Additional colors
  Color get secondary => const Color(0xFF1E293B); // same as secondaryBackground
  Color get info => const Color(0xFFF1F5F9); // same as primaryText
  Color get lineColor => const Color(0xFF334155); // same as alternate/border color

  // Text styles
  TextStyle get displayLarge => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primaryText,
  );

  TextStyle get displayMedium => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryText,
  );

  TextStyle get displaySmall => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryText,
  );

  TextStyle get headlineLarge => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: primaryText,
  );

  TextStyle get headlineMedium => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: primaryText,
  );

  TextStyle get headlineSmall => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryText,
  );

  TextStyle get titleLarge => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: primaryText,
  );

  TextStyle get titleMedium => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primaryText,
  );

  TextStyle get titleSmall => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: primaryText,
  );

  TextStyle get bodyLarge => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: primaryText,
  );

  TextStyle get bodyMedium => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: primaryText,
  );

  TextStyle get bodySmall => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: secondaryText,
  );

  TextStyle get labelLarge => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primaryText,
  );

  TextStyle get labelMedium => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: primaryText,
  );

  TextStyle get labelSmall => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: secondaryText,
  );

  // Initialize theme
  static Future<void> initialize() async {
    // final prefs = await SharedPreferences.getInstance();
    // final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    // _themeMode = ThemeMode.values[themeModeIndex];
  }

  // Save theme mode
  static Future<void> saveThemeMode(ThemeMode mode) async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setInt('theme_mode', mode.index);
    _themeMode = mode;
  }

  // Theme data
  ThemeData get theme => darkTheme; // Point light theme to dark theme

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    primaryColor: primary,
    scaffoldBackgroundColor: primaryBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryText),
      titleTextStyle: TextStyle(
        color: primaryText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: secondaryBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        )
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryBackground,
      hintStyle: TextStyle(color: secondaryText),
      labelStyle: TextStyle(color: secondaryText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lineColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lineColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primary),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    ),
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: secondaryBackground,
      background: primaryBackground,
      error: error,
      onPrimary: Colors.white,
      onSecondary: primaryText,
      onSurface: primaryText,
      onBackground: primaryText,
      onError: Colors.white,
      brightness: Brightness.dark,
    )
  );
} 