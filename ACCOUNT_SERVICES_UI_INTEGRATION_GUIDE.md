# Account Services UI Integration Guide

## Overview
This guide covers the implementation of dedicated UI screens for each service under the Account tab in the profile section. Each screen provides a comprehensive, modern interface for managing different aspects of the user's account.

## New Account Service Screens

### 1. Subscription Details Screen (`subscription_details_screen.dart`)

#### Features:
- **Subscription Status Card**: Shows current plan status with gradient design
- **Current Plan Information**: Displays plan details, billing cycle, and pricing
- **Billing History**: Shows past payments with status indicators
- **Usage Statistics**: Displays current usage vs limits
- **Action Buttons**: Manage subscription, cancel, download invoices

#### Key Components:
```dart
// Subscription status with dynamic colors
Widget _buildSubscriptionStatusCard(bool isPro, bool isTrial, int remainingTrialDays, int remainingSubscriptionDays)

// Plan information display
Widget _buildCurrentPlanCard(SubscriptionService subscriptionService)

// Billing history with status indicators
Widget _buildBillingHistoryCard()

// Usage statistics with progress indicators
Widget _buildUsageStatsCard()

// Action buttons for subscription management
Widget _buildActionsCard(bool isPro, bool isTrial)
```

#### Integration Points:
- Connects to `SubscriptionService` for real-time data
- Handles subscription upgrades, cancellations, and management
- Supports both Pro and Free user states
- Provides billing history and usage tracking

### 2. Payment Methods Screen (`payment_methods_screen.dart`)

#### Features:
- **Billing Address Management**: Display and edit billing information
- **Payment Method Cards**: Visual representation of saved cards
- **Add New Payment Method**: Modal form for adding cards
- **Billing History**: Payment history with method details
- **Security Settings**: Two-factor auth, notifications, alerts

#### Key Components:
```dart
// Billing address display and editing
Widget _buildBillingAddressCard()

// Payment method list with actions
Widget _buildPaymentMethodsCard()

// Billing history with payment methods
Widget _buildBillingHistoryCard()

// Security settings with toggles
Widget _buildSecurityCard()

// Add payment method modal
Widget _buildAddPaymentMethodSheet()
```

#### Integration Points:
- Supports multiple payment methods (Visa, Mastercard, etc.)
- Form validation for card details
- Security settings management
- Billing address management
- Payment method actions (set default, edit, remove)

### 3. Account History Screen (`account_history_screen.dart`)

#### Features:
- **Filterable Activity Log**: Filter by activity type (Logins, Scans, Settings, Billing)
- **Detailed Activity Items**: Shows location, IP, timestamp, and status
- **Activity Details Modal**: Detailed view of each activity
- **Export Functionality**: Export history as CSV or PDF
- **Security Reporting**: Report suspicious activities

#### Key Components:
```dart
// Filter chips for activity types
Widget _buildFilterChips()

// Activity list with filtering
Widget _buildHistoryList(List<Map<String, dynamic>> history)

// Individual activity item
Widget _buildHistoryItem(Map<String, dynamic> item)

// Activity details modal
Widget _buildActivityDetailsSheet(Map<String, dynamic> item)

// Export functionality
void _exportHistory()
```

#### Integration Points:
- Real-time activity logging
- Location and IP tracking
- Export functionality for compliance
- Security monitoring and reporting
- Activity filtering and search

## Navigation Integration

### Route Configuration
All new screens are integrated into the GoRouter configuration in `main.dart`:

```dart
GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/authWelcomeScreen',
    routes: [
      // ... existing routes ...
      GoRoute(
        path: '/subscription-details',
        builder: (context, state) => const SubscriptionDetailsScreen(),
      ),
      GoRoute(
        path: '/payment-methods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/account-history',
        builder: (context, state) => const AccountHistoryScreen(),
      ),
    ],
  );
}
```

### Profile Screen Integration
The profile screen now navigates to dedicated screens instead of showing placeholder messages:

```dart
void _showSubscriptionDetails() {
  context.push('/subscription-details');
}

void _showPaymentMethods() {
  context.push('/payment-methods');
}

void _showAccountHistory() {
  context.push('/account-history');
}
```

## UI Design System

### Consistent Design Elements
All screens follow the same design system:

1. **App Bar**: Consistent back button and title styling
2. **Card Layout**: Rounded corners with subtle borders
3. **Color Scheme**: Uses FlutterFlow theme system
4. **Typography**: Consistent text styles and hierarchy
5. **Icons**: Material Design and FontAwesome icons
6. **Spacing**: Consistent padding and margins

### Common Components
```dart
// Section card wrapper
Widget _buildSectionCard(String title, IconData icon, List<Widget> children)

// Action button with icon
Widget _buildActionButton(String text, IconData icon, VoidCallback onTap)

// Status indicators
Widget _buildStatusIndicator(String status)

// Form fields with validation
Widget _buildFormField(String label, String hint, IconData icon)
```

## Backend Integration Points

### Current State
- All screens use mock data for demonstration
- Placeholder methods for backend integration
- Form validation implemented
- Error handling structure in place

### Future Integration Requirements

#### Subscription Details Screen:
```dart
// Required backend endpoints
- GET /api/subscription/status
- GET /api/subscription/plan
- GET /api/subscription/billing-history
- GET /api/subscription/usage-stats
- POST /api/subscription/cancel
- POST /api/subscription/upgrade
```

#### Payment Methods Screen:
```dart
// Required backend endpoints
- GET /api/payment-methods
- POST /api/payment-methods
- PUT /api/payment-methods/{id}
- DELETE /api/payment-methods/{id}
- GET /api/billing-address
- PUT /api/billing-address
- POST /api/payment-methods/{id}/set-default
```

#### Account History Screen:
```dart
// Required backend endpoints
- GET /api/account/history
- GET /api/account/history/export
- POST /api/account/history/report
- GET /api/account/history/filter
```

## Data Models

### Subscription Data Model
```dart
class SubscriptionData {
  final bool isPro;
  final bool isTrialActive;
  final int remainingTrialDays;
  final int remainingSubscriptionDays;
  final String? currentPlan;
  final String? nextBillingDate;
  final bool autoRenewal;
  final List<BillingHistoryItem> billingHistory;
  final Map<String, dynamic> usageStats;
}
```

### Payment Method Data Model
```dart
class PaymentMethod {
  final String id;
  final String type; // 'visa', 'mastercard', etc.
  final String last4;
  final String expiry;
  final String name;
  final bool isDefault;
  final String? billingAddress;
}
```

### Account History Data Model
```dart
class AccountActivity {
  final String id;
  final String type; // 'login', 'scan', 'settings', 'billing'
  final String title;
  final String description;
  final String location;
  final String ip;
  final DateTime timestamp;
  final String status; // 'success', 'failed', 'warning'
}
```

## Error Handling

### Common Error Scenarios
1. **Network Errors**: Show retry options
2. **Validation Errors**: Display field-specific messages
3. **Permission Errors**: Guide user to settings
4. **Server Errors**: Show generic error with support contact

### Error Handling Implementation
```dart
try {
  // API call
  final result = await apiService.getData();
  // Handle success
} catch (e) {
  if (e is NetworkException) {
    _showNetworkError();
  } else if (e is ValidationException) {
    _showValidationError(e.message);
  } else {
    _showGenericError();
  }
}
```

## Testing Strategy

### Unit Tests
- Test individual components
- Test form validation
- Test navigation logic
- Test error handling

### Integration Tests
- Test screen navigation
- Test data flow between screens
- Test user interactions
- Test responsive design

### Manual Testing Checklist
- [ ] Navigation between screens
- [ ] Form validation and submission
- [ ] Error handling and recovery
- [ ] Responsive design on different screen sizes
- [ ] Accessibility features
- [ ] Performance on slow networks

## Performance Considerations

### Optimization Techniques
1. **Lazy Loading**: Load data only when needed
2. **Caching**: Cache frequently accessed data
3. **Pagination**: Load large lists in chunks
4. **Image Optimization**: Compress and cache images
5. **State Management**: Efficient state updates

### Memory Management
```dart
@override
void dispose() {
  // Clean up controllers
  _tabController.dispose();
  _formKey.currentState?.dispose();
  super.dispose();
}
```

## Security Considerations

### Data Protection
1. **Sensitive Data**: Never log or display sensitive information
2. **Input Validation**: Validate all user inputs
3. **API Security**: Use secure API endpoints
4. **Local Storage**: Encrypt sensitive local data

### Privacy Compliance
1. **GDPR Compliance**: Handle user data requests
2. **Data Retention**: Implement data retention policies
3. **User Consent**: Get explicit consent for data collection
4. **Data Export**: Allow users to export their data

## Future Enhancements

### Planned Features
1. **Real-time Updates**: Live subscription status updates
2. **Push Notifications**: Payment and security alerts
3. **Advanced Analytics**: Detailed usage analytics
4. **Multi-language Support**: Internationalization
5. **Dark Mode**: Enhanced theme support
6. **Offline Support**: Basic offline functionality

### Technical Improvements
1. **State Management**: Implement proper state management
2. **API Integration**: Connect to real backend services
3. **Testing**: Comprehensive test coverage
4. **Documentation**: API documentation
5. **Monitoring**: Error tracking and analytics

## Troubleshooting

### Common Issues
1. **Navigation Errors**: Check route configuration
2. **Data Loading**: Verify API endpoints
3. **UI Rendering**: Check theme configuration
4. **Performance**: Monitor memory usage

### Debug Tips
- Use Flutter DevTools for debugging
- Check console for error messages
- Verify network connectivity
- Test on different devices

This comprehensive UI system provides a solid foundation for account management and can be easily extended as new features are added to the app. 