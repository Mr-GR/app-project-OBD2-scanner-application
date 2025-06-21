# Profile UI Tabbed Integration Guide

## Overview
The profile screen has been redesigned with a modern tabbed interface that organizes user settings and account management into logical sections. This provides a cleaner, more organized user experience.

## New Tab Structure

### 1. Personal Tab
- **Purpose**: User's personal information and preferences
- **Features**:
  - Personal Information (name, email, phone)
  - Location settings
  - Notification preferences
- **Icon**: `Icons.person_outline`

### 2. Settings Tab
- **Purpose**: App configuration and technical settings
- **Features**:
  - OBD2 Connection settings
  - Data & Storage management
  - Privacy & Security settings
  - Appearance customization
- **Icon**: `Icons.settings_outlined`

### 3. Support Tab
- **Purpose**: Help and support resources
- **Features**:
  - Help Center
  - Contact Support
  - Bug Report
  - Send Feedback
- **Icon**: `Icons.help_outline`

### 4. Account Tab
- **Purpose**: Account management and subscription
- **Features**:
  - Subscription details
  - Payment methods
  - Account history
  - Sign out functionality
- **Icon**: `Icons.account_circle_outlined`

## UI Components

### Profile Header
- Compact design with user avatar, name, email, and plan status
- Edit button for quick profile access
- Gradient background with theme colors
- Responsive layout that adapts to different screen sizes

### Tab Bar
- Custom styled tab bar with rounded corners
- Active tab indicator with primary theme color
- Icons and labels for each tab
- Smooth transitions between tabs

### Pro Upgrade Card
- Conditional display based on subscription status
- Compact design for Pro users showing active status
- Upgrade prompt for free users with call-to-action button
- Gradient design with crown icon

### Content Sections
- Each tab contains organized sections with clear titles
- Consistent card-based design with rounded corners
- Icon-based navigation items with descriptions
- Proper spacing and typography hierarchy

## Implementation Details

### TabController Setup
```dart
late TabController _tabController;
int _currentTabIndex = 0;

@override
void initState() {
  super.initState();
  _tabController = TabController(length: 4, vsync: this);
  _tabController.addListener(() {
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  });
}
```

### Tab Bar Structure
```dart
TabBar(
  controller: _tabController,
  indicator: BoxDecoration(
    color: FlutterFlowTheme.of(context).primary,
    borderRadius: BorderRadius.circular(10),
  ),
  indicatorSize: TabBarIndicatorSize.tab,
  labelColor: Colors.white,
  unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
  tabs: [
    Tab(icon: Icon(Icons.person_outline), text: 'Personal'),
    Tab(icon: Icon(Icons.settings_outlined), text: 'Settings'),
    Tab(icon: Icon(Icons.help_outline), text: 'Support'),
    Tab(icon: Icon(Icons.account_circle_outlined), text: 'Account'),
  ],
)
```

### Tab Content Structure
```dart
TabBarView(
  controller: _tabController,
  children: [
    _buildPersonalTab(),
    _buildSettingsTab(),
    _buildSupportTab(),
    _buildAccountTab(),
  ],
)
```

## Backend Integration Points

### Current State
- All profile actions currently show placeholder snackbar messages
- Subscription service integration is already implemented
- Mock data is used for demonstration

### Future Integration
1. **Personal Tab**:
   - Connect to user profile API
   - Implement location services
   - Add notification preferences storage

2. **Settings Tab**:
   - Connect to OBD2 service
   - Implement data storage management
   - Add privacy settings persistence

3. **Support Tab**:
   - Connect to help center API
   - Implement support ticket system
   - Add feedback submission

4. **Account Tab**:
   - Connect to authentication service
   - Implement payment processing
   - Add account activity logging

## Customization Options

### Theme Integration
- All colors use FlutterFlow theme system
- Consistent with app's design language
- Supports light/dark mode

### Responsive Design
- Adapts to different screen sizes
- Proper spacing on mobile and tablet
- Touch-friendly interface elements

### Accessibility
- Proper contrast ratios
- Screen reader support
- Keyboard navigation ready

## Usage Examples

### Adding New Tab Items
```dart
_buildProfileItem(
  icon: Icons.new_feature,
  title: 'New Feature',
  subtitle: 'Description of the new feature',
  onTap: () => _handleNewFeature(),
)
```

### Custom Tab Actions
```dart
void _handleNewFeature() {
  // Implement your custom logic here
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('New feature coming soon!')),
  );
}
```

### Conditional Content
```dart
if (isProUser) ...[
  _buildProfileItem(
    icon: Icons.premium,
    title: 'Premium Feature',
    subtitle: 'Only available for Pro users',
    onTap: () => _handlePremiumFeature(),
  ),
]
```

## Best Practices

1. **Consistent Design**: Use the existing `_buildProfileItem` method for new items
2. **Proper Icons**: Choose appropriate Material Design icons
3. **Clear Descriptions**: Provide helpful subtitle text
4. **Error Handling**: Implement proper error handling for all actions
5. **Loading States**: Show loading indicators for async operations
6. **User Feedback**: Provide clear feedback for user actions

## Future Enhancements

1. **Animations**: Add smooth transitions between tabs
2. **Search**: Add search functionality across all settings
3. **Quick Actions**: Add quick action buttons for common tasks
4. **Customization**: Allow users to reorder or hide tabs
5. **Analytics**: Track user interaction with different sections
6. **Offline Support**: Cache settings for offline access

## Troubleshooting

### Common Issues
1. **Tab not switching**: Check TabController initialization
2. **Content not scrolling**: Ensure SingleChildScrollView is used
3. **Theme issues**: Verify FlutterFlow theme integration
4. **Navigation errors**: Check GoRouter setup

### Debug Tips
- Use `print` statements to debug tab switching
- Check console for any error messages
- Verify all required imports are present
- Test on different screen sizes

This tabbed UI provides a solid foundation for profile management and can be easily extended as new features are added to the app. 