# Firebase Setup Guide

This guide will help you set up Firebase for your OBD2 Scanner application.

## Prerequisites

1. A Google account
2. Flutter project with Firebase dependencies
3. FlutterFire CLI (optional but recommended)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter a project name (e.g., "obd2-scanner-app")
4. Choose whether to enable Google Analytics (recommended)
5. Click "Create project"

## Step 2: Add Firebase to Your App

### Option A: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase for your Flutter app:
   ```bash
   flutterfire configure
   ```

3. This will:
   - Create the `firebase_options.dart` file
   - Add platform-specific configurations
   - Update your `pubspec.yaml` with Firebase dependencies

### Option B: Manual Configuration

1. In Firebase Console, click "Add app" and select your platform (iOS/Android/Web)
2. Follow the setup instructions for each platform
3. Download the configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
   - Web configuration for web

## Step 3: Update Configuration Files

### Update firebase_options.dart

Replace the placeholder values in `firebase_options.dart` with your actual Firebase project values:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-web-api-key',
  appId: 'your-actual-web-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  authDomain: 'your-actual-project-id.firebaseapp.com',
  storageBucket: 'your-actual-project-id.appspot.com',
  measurementId: 'your-actual-measurement-id',
);
```

### Update pubspec.yaml

Ensure you have the required Firebase dependencies:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  firebase_messaging: ^14.7.10
  firebase_analytics: ^10.7.4
```

## Step 4: Set Up Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (we'll add security rules later)
4. Select a location for your database
5. Click "Done"

## Step 5: Set Up Firebase Storage

1. In Firebase Console, go to "Storage"
2. Click "Get started"
3. Choose "Start in test mode" (we'll add security rules later)
4. Select a location for your storage
5. Click "Done"

## Step 6: Configure Security Rules

### Firestore Security Rules

1. In Firebase Console, go to "Firestore Database" > "Rules"
2. Replace the default rules with the rules from `lib/backend/config/firebase_config.dart`
3. Click "Publish"

### Storage Security Rules

1. In Firebase Console, go to "Storage" > "Rules"
2. Replace the default rules with the rules from `lib/backend/config/firebase_config.dart`
3. Click "Publish"

## Step 7: Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Enable the sign-in methods you want to use:
   - Email/Password (recommended)
   - Google Sign-In
   - Apple Sign-In (for iOS)
4. Configure each method as needed

## Step 8: Update App Configuration

### Update main.dart

Ensure Firebase is initialized in your `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await FirebaseConfig.initialize();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  
  runApp(MyApp());
}
```

### Update ServiceManager

In `lib/backend/services/service_manager.dart`, set `useMockServices` to `false` for production:

```dart
ServiceManagerProvider(
  useMockServices: false, // Set to false for production
),
```

## Step 9: Test Firebase Integration

1. Run your app
2. Check the console for Firebase initialization messages
3. Test basic Firebase operations (auth, firestore, storage)

## Step 10: Environment Configuration

### Development vs Production

For different environments, you can:

1. Use different Firebase projects
2. Use Firebase project aliases
3. Use environment variables

### Example: Environment-Specific Configuration

```dart
class FirebaseConfig {
  static Future<void> initialize({String? environment}) async {
    FirebaseOptions options;
    
    switch (environment) {
      case 'development':
        options = DefaultFirebaseOptions.development;
        break;
      case 'production':
        options = DefaultFirebaseOptions.production;
        break;
      default:
        options = DefaultFirebaseOptions.currentPlatform;
    }
    
    await Firebase.initializeApp(options: options);
  }
}
```

## Troubleshooting

### Common Issues

1. **Firebase not initialized**: Check that `Firebase.initializeApp()` is called before using any Firebase services
2. **Permission denied**: Ensure security rules are properly configured
3. **Network errors**: Check internet connection and Firebase project settings
4. **Platform-specific issues**: Ensure platform-specific configuration files are properly set up

### Debug Mode

Enable Firebase debug mode for development:

```dart
// In main.dart
if (kDebugMode) {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
```

## Security Best Practices

1. **Never commit API keys**: Use environment variables or secure key management
2. **Use proper security rules**: Always implement proper Firestore and Storage security rules
3. **Validate data**: Always validate data on both client and server side
4. **Use authentication**: Require authentication for sensitive operations
5. **Monitor usage**: Set up Firebase monitoring and alerts

## Next Steps

1. Implement user authentication flow
2. Set up data models and collections
3. Implement CRUD operations
4. Add real-time listeners
5. Set up push notifications
6. Configure analytics and monitoring

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Firebase Console](https://console.firebase.google.com/) 