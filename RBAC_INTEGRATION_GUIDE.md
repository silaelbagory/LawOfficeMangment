# Role-Based Access Control (RBAC) Integration Guide

This guide explains how to integrate the RBAC system into your existing Law Office Management System.

## Overview

The RBAC system provides:
- **Manager Role**: Full access to all features and user management
- **Lawyer Role**: Limited access based on assigned permissions
- **Action Logging**: Automatic logging of all lawyer actions
- **Permission-based UI**: Dynamic UI based on user permissions

## Files Added/Modified

### New Models
- `lib/data/models/user_model.dart` - User model with roles and permissions
- `lib/data/models/lawyer_action_model.dart` - Action logging model

### New Repositories
- `lib/data/repositories/user_repository.dart` - User management operations
- `lib/data/repositories/action_repository.dart` - Action logging operations

### New Services
- `lib/core/services/user_management_service.dart` - User management business logic

### New Cubits
- `lib/logic/user_cubit/user_cubit.dart` - User state management
- `lib/logic/user_cubit/user_state.dart` - User state definitions
- `lib/logic/action_cubit/action_cubit.dart` - Action state management
- `lib/logic/action_cubit/action_state.dart` - Action state definitions

### New UI Screens
- `lib/presentation/screens/users/add_lawyer_screen.dart` - Add new lawyer
- `lib/presentation/screens/users/users_management_screen.dart` - Manage lawyers
- `lib/presentation/screens/users/lawyers_actions_screen.dart` - View action logs

### Security
- `firestore.rules` - Firestore security rules for RBAC

## Integration Steps

### 1. Update main.dart
The main.dart file has been updated to include the new repositories and cubits:

```dart
// Add new imports
import 'data/repositories/user_repository.dart';
import 'data/repositories/action_repository.dart';
import 'logic/user_cubit/user_cubit.dart';
import 'logic/action_cubit/action_cubit.dart';

// Add new repositories
RepositoryProvider(create: (_) => UserRepository(FirestoreService())),
RepositoryProvider(create: (_) => ActionRepository(FirestoreService())),

// Add new cubits
BlocProvider(create: (context) => UserCubit(context.read<UserRepository>())),
BlocProvider(create: (context) => ActionCubit(context.read<ActionRepository>())),
```

### 2. Update Navigation
Add new routes to your navigation system:

```dart
// Add these routes to your GoRouter or Navigator
'/users': (context) => UsersManagementScreen(),
'/users/add-lawyer': (context) => AddLawyerScreen(),
'/users/actions': (context) => LawyersActionsScreen(),
```

### 3. Update Drawer/Navigation
Add new menu items to your navigation drawer:

```dart
// For managers only
if (currentUser.isManager) ...[
  ListTile(
    leading: Icon(Icons.people),
    title: Text(AppLocalizations.of(context)!.usersManagement),
    onTap: () => context.go('/users'),
  ),
  ListTile(
    leading: Icon(Icons.history),
    title: Text(AppLocalizations.of(context)!.lawyersActions),
    onTap: () => context.go('/users/actions'),
  ),
],
```

### 4. Integrate Permission Checks
Update your existing screens to check permissions:

```dart
// Example: In your cases screen
BlocBuilder<UserCubit, UserState>(
  builder: (context, state) {
    if (state is UserLoaded) {
      final user = state.user;
      
      return Column(
        children: [
          if (user.hasPermission('casesRead')) ...[
            // Show cases list
          ],
          if (user.hasPermission('casesWrite')) ...[
            FloatingActionButton(
              onPressed: () => context.go('/cases/add'),
              child: Icon(Icons.add),
            ),
          ],
        ],
      );
    }
    return CircularProgressIndicator();
  },
)
```

### 5. Add Action Logging
Integrate action logging into your existing operations:

```dart
// Example: When creating a case
Future<void> createCase(CaseModel caseModel) async {
  try {
    // Your existing case creation logic
    final caseId = await _caseRepository.createCase(caseModel);
    
    // Log the action
    final currentUser = await _userRepository.getCurrentUser();
    if (currentUser != null) {
      await _actionRepository.logCaseCreation(
        lawyerId: currentUser.id,
        lawyerName: currentUser.name,
        caseTitle: caseModel.title,
        caseId: caseId,
      );
    }
  } catch (e) {
    // Handle error
  }
}
```

### 6. Update Authentication Flow
Modify your login process to fetch user role and permissions:

```dart
// In your login success handler
Future<void> _onLoginSuccess() async {
  // Get current user with permissions
  await context.read<UserCubit>().getCurrentUser();
  
  // Navigate based on role
  final userState = context.read<UserCubit>().state;
  if (userState is UserLoaded) {
    if (userState.user.isManager) {
      context.go('/dashboard');
    } else {
      context.go('/dashboard');
    }
  }
}
```

## Permission System

### Available Permissions
- `casesRead` - Read access to cases
- `casesWrite` - Create/update/delete cases
- `clientsRead` - Read access to clients
- `clientsWrite` - Create/update/delete clients
- `documentsRead` - Read access to documents
- `documentsWrite` - Create/update/delete documents
- `reportsRead` - Read access to reports
- `reportsWrite` - Create/update/delete reports
- `usersRead` - Read access to users
- `usersWrite` - Create/update/delete users

### Permission Checking
```dart
// Check if user has permission
final hasPermission = await context.read<UserCubit>().canPerformAction('casesWrite');

// Or check directly from user model
if (user.hasPermission('casesWrite')) {
  // Show write operations
}
```

## Firestore Security Rules

The provided `firestore.rules` file implements:
- Role-based access control
- Permission-based operations
- Secure user management
- Action logging permissions

Deploy these rules to your Firestore project:
```bash
firebase deploy --only firestore:rules
```

## Usage Examples

### Creating a Manager Account
```dart
// Only existing managers can create new managers
final managerUser = UserModel(
  id: 'manager-id',
  name: 'Manager Name',
  email: 'manager@example.com',
  role: UserRole.manager,
  permissions: UserPermissions.manager(),
  createdAt: DateTime.now(),
);
```

### Creating a Lawyer Account
```dart
// Managers can create lawyers with specific permissions
final lawyerPermissions = UserPermissions.lawyer(
  casesRead: true,
  casesWrite: false,
  clientsRead: true,
  clientsWrite: true,
);

await context.read<UserCubit>().addLawyer(
  name: 'Lawyer Name',
  email: 'lawyer@example.com',
  password: 'password123',
  permissions: lawyerPermissions,
);
```

### Logging Actions
```dart
// Log various actions
await context.read<ActionCubit>().logCaseCreation(
  lawyerId: currentUser.id,
  lawyerName: currentUser.name,
  caseTitle: 'Case Title',
  caseId: 'case-id',
);

await context.read<ActionCubit>().logClientCreation(
  lawyerId: currentUser.id,
  lawyerName: currentUser.name,
  clientName: 'Client Name',
  clientId: 'client-id',
);
```

## Testing

### Test User Creation
1. Create a manager account manually in Firebase Console
2. Use the manager account to create lawyer accounts
3. Test permission-based access

### Test Permission System
1. Create lawyers with different permission sets
2. Verify UI elements show/hide based on permissions
3. Test Firestore security rules

### Test Action Logging
1. Perform various actions as a lawyer
2. Check the `lawyer_actions` collection in Firestore
3. Verify the Lawyers Actions screen shows logged actions

## Troubleshooting

### Common Issues
1. **Permission denied errors**: Check Firestore security rules
2. **Missing UI elements**: Verify permission checks in widgets
3. **Action logging not working**: Ensure ActionCubit is properly initialized

### Debug Tips
1. Check user role and permissions in Firestore
2. Verify Firestore security rules are deployed
3. Use Firebase Console to monitor action logs
4. Check console for permission-related errors

## Next Steps

1. **Deploy Firestore Rules**: Upload the security rules to your Firebase project
2. **Create Manager Account**: Set up the first manager account
3. **Test Permissions**: Create test lawyer accounts with different permissions
4. **Integrate Existing Screens**: Add permission checks to your existing UI
5. **Add Action Logging**: Integrate logging into your existing operations

## Support

For issues or questions:
1. Check the Firestore security rules
2. Verify user permissions in the database
3. Review the action logs in the `lawyer_actions` collection
4. Test with different user roles and permissions
