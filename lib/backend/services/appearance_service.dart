// TODO: FIREBASE INTEGRATION
// When ready to integrate Firebase, uncomment:
// import 'package:cloud_firestore/cloud_firestore.dart';

enum AppTheme {
  light,
  dark,
  system,
}

enum AppLanguage {
  english,
  spanish,
  french,
  german,
  chinese,
  japanese,
}

class AppearanceSettings {
  final String userId;
  final AppTheme theme;
  final AppLanguage language;
  final bool useSystemFont;
  final double fontSize;
  final bool reduceMotion;
  final bool highContrast;

  AppearanceSettings({
    required this.userId,
    this.theme = AppTheme.system,
    this.language = AppLanguage.english,
    this.useSystemFont = true,
    this.fontSize = 1.0,
    this.reduceMotion = false,
    this.highContrast = false,
  });

  factory AppearanceSettings.fromMap(String userId, Map<String, dynamic> data) {
    return AppearanceSettings(
      userId: userId,
      theme: AppTheme.values.firstWhere(
        (t) => t.toString() == 'AppTheme.${data['theme'] ?? 'system'}',
        orElse: () => AppTheme.system,
      ),
      language: AppLanguage.values.firstWhere(
        (l) => l.toString() == 'AppLanguage.${data['language'] ?? 'english'}',
        orElse: () => AppLanguage.english,
      ),
      useSystemFont: data['useSystemFont'] ?? true,
      fontSize: (data['fontSize'] ?? 1.0).toDouble(),
      reduceMotion: data['reduceMotion'] ?? false,
      highContrast: data['highContrast'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'theme': theme.toString().split('.').last,
    'language': language.toString().split('.').last,
    'useSystemFont': useSystemFont,
    'fontSize': fontSize,
    'reduceMotion': reduceMotion,
    'highContrast': highContrast,
  };

  String get themeName {
    switch (theme) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.system:
        return 'System';
    }
  }

  String get languageName {
    switch (language) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.spanish:
        return 'Español';
      case AppLanguage.french:
        return 'Français';
      case AppLanguage.german:
        return 'Deutsch';
      case AppLanguage.chinese:
        return '中文';
      case AppLanguage.japanese:
        return '日本語';
    }
  }

  String get languageCode {
    switch (language) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.spanish:
        return 'es';
      case AppLanguage.french:
        return 'fr';
      case AppLanguage.german:
        return 'de';
      case AppLanguage.chinese:
        return 'zh';
      case AppLanguage.japanese:
        return 'ja';
    }
  }
}

abstract class IAppearanceService {
  Future<void> initialize();
  Future<AppearanceSettings> getAppearanceSettings(String userId);
  Future<void> updateAppearanceSettings(String userId, Map<String, dynamic> settings);
  Future<void> resetToDefaults(String userId);
  Future<List<AppTheme>> getAvailableThemes();
  Future<List<AppLanguage>> getAvailableLanguages();
}

class AppearanceService implements IAppearanceService {
  // TODO: FIREBASE INTEGRATION
  // When ready to integrate Firebase, uncomment:
  // final _firestore = FirebaseFirestore.instance;

  // Mock data storage
  final Map<String, AppearanceSettings> _mockSettings = {};

  @override
  Future<void> initialize() async {
    // Implementation needed
  }

  @override
  Future<AppearanceSettings> getAppearanceSettings(String userId) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final doc = await _firestore.collection('appearance_settings').doc(userId).get();
    // if (!doc.exists) {
    //   return AppearanceSettings(userId: userId);
    // }
    // return AppearanceSettings.fromMap(userId, doc.data()!);

    return _mockSettings[userId] ?? AppearanceSettings(userId: userId);
  }

  @override
  Future<void> updateAppearanceSettings(String userId, Map<String, dynamic> settings) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // await _firestore.collection('appearance_settings').doc(userId).set(settings, SetOptions(merge: true));

    final existing = _mockSettings[userId] ?? AppearanceSettings(userId: userId);
    
    AppTheme theme = existing.theme;
    if (settings['theme'] != null) {
      theme = AppTheme.values.firstWhere(
        (t) => t.toString() == 'AppTheme.${settings['theme']}',
        orElse: () => existing.theme,
      );
    }

    AppLanguage language = existing.language;
    if (settings['language'] != null) {
      language = AppLanguage.values.firstWhere(
        (l) => l.toString() == 'AppLanguage.${settings['language']}',
        orElse: () => existing.language,
      );
    }

    _mockSettings[userId] = AppearanceSettings(
      userId: userId,
      theme: theme,
      language: language,
      useSystemFont: settings['useSystemFont'] ?? existing.useSystemFont,
      fontSize: (settings['fontSize'] ?? existing.fontSize).toDouble(),
      reduceMotion: settings['reduceMotion'] ?? existing.reduceMotion,
      highContrast: settings['highContrast'] ?? existing.highContrast,
    );
  }

  @override
  Future<void> resetToDefaults(String userId) async {
    // TODO: FIREBASE INTEGRATION
    // When ready to integrate Firebase, replace with:
    // final defaultSettings = AppearanceSettings(userId: userId);
    // await _firestore.collection('appearance_settings').doc(userId).set(defaultSettings.toMap());

    _mockSettings[userId] = AppearanceSettings(userId: userId);
  }

  @override
  Future<List<AppTheme>> getAvailableThemes() async {
    return AppTheme.values.toList();
  }

  @override
  Future<List<AppLanguage>> getAvailableLanguages() async {
    return AppLanguage.values.toList();
  }
}

class MockAppearanceService implements IAppearanceService {
  final Map<String, AppearanceSettings> _mockSettings = {};

  @override
  Future<void> initialize() async {
    // Implementation needed
  }

  @override
  Future<AppearanceSettings> getAppearanceSettings(String userId) async {
    return _mockSettings[userId] ?? AppearanceSettings(userId: userId);
  }

  @override
  Future<void> updateAppearanceSettings(String userId, Map<String, dynamic> settings) async {
    final existing = _mockSettings[userId] ?? AppearanceSettings(userId: userId);
    
    AppTheme theme = existing.theme;
    if (settings['theme'] != null) {
      theme = AppTheme.values.firstWhere(
        (t) => t.toString() == 'AppTheme.${settings['theme']}',
        orElse: () => existing.theme,
      );
    }

    AppLanguage language = existing.language;
    if (settings['language'] != null) {
      language = AppLanguage.values.firstWhere(
        (l) => l.toString() == 'AppLanguage.${settings['language']}',
        orElse: () => existing.language,
      );
    }

    _mockSettings[userId] = AppearanceSettings(
      userId: userId,
      theme: theme,
      language: language,
      useSystemFont: settings['useSystemFont'] ?? existing.useSystemFont,
      fontSize: (settings['fontSize'] ?? existing.fontSize).toDouble(),
      reduceMotion: settings['reduceMotion'] ?? existing.reduceMotion,
      highContrast: settings['highContrast'] ?? existing.highContrast,
    );
  }

  @override
  Future<void> resetToDefaults(String userId) async {
    _mockSettings[userId] = AppearanceSettings(userId: userId);
  }

  @override
  Future<List<AppTheme>> getAvailableThemes() async {
    return AppTheme.values.toList();
  }

  @override
  Future<List<AppLanguage>> getAvailableLanguages() async {
    return AppLanguage.values.toList();
  }
} 