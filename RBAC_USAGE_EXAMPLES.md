# RBAC Usage Examples

This document provides practical examples of how to integrate the RBAC system into your existing Law Office Management System.

## 1. Dashboard Integration

Here's how to update your dashboard to show different content based on user role and permissions:

```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is UserLoaded) {
          final user = state.user;
          return _buildDashboardContent(context, user);
        } else if (state is UserError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return Center(child: Text('Please log in'));
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, UserModel user) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.name}'),
        actions: [
          // Show user management for managers only
          if (user.isManager)
            IconButton(
              icon: Icon(Icons.people),
              onPressed: () => context.go('/users'),
            ),
          // Show actions log for all users
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => context.go('/users/actions'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Role-based welcome message
          _buildWelcomeCard(user),
          
          // Permission-based quick actions
          _buildQuickActions(context, user),
          
          // Permission-based statistics
          if (user.hasPermission('casesRead') || user.hasPermission('clientsRead'))
            _buildStatistics(context, user),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(UserModel user) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.isManager ? 'Manager Dashboard' : 'Lawyer Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text('Role: ${user.role.value}'),
            if (user.isLawyer) ...[
              SizedBox(height: 8),
              Text('Permissions: ${_getPermissionSummary(user.permissions)}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, UserModel user) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                if (user.hasPermission('casesWrite'))
                  ElevatedButton.icon(
                    onPressed: () => context.go('/cases/add'),
                    icon: Icon(Icons.add),
                    label: Text('Add Case'),
                  ),
                if (user.hasPermission('clientsWrite'))
                  ElevatedButton.icon(
                    onPressed: () => context.go('/clients/add'),
                    icon: Icon(Icons.person_add),
                    label: Text('Add Client'),
                  ),
                if (user.hasPermission('documentsWrite'))
                  ElevatedButton.icon(
                    onPressed: () => context.go('/documents/upload'),
                    icon: Icon(Icons.upload),
                    label: Text('Upload Document'),
                  ),
                if (user.isManager)
                  ElevatedButton.icon(
                    onPressed: () => context.go('/users/add-lawyer'),
                    icon: Icon(Icons.person_add),
                    label: Text('Add Lawyer'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPermissionSummary(UserPermissions permissions) {
    final List<String> granted = [];
    if (permissions.casesRead) granted.add('Cases Read');
    if (permissions.casesWrite) granted.add('Cases Write');
    if (permissions.clientsRead) granted.add('Clients Read');
    if (permissions.clientsWrite) granted.add('Clients Write');
    if (permissions.documentsRead) granted.add('Documents Read');
    if (permissions.documentsWrite) granted.add('Documents Write');
    return granted.join(', ');
  }
}
```

## 2. Navigation Drawer Integration

Update your navigation drawer to show different menu items based on permissions:

```dart
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoaded) {
          return _buildDrawer(context, state.user);
        }
        return Drawer(child: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildDrawer(BuildContext context, UserModel user) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(user.name[0].toUpperCase()),
                ),
                SizedBox(height: 8),
                Text(
                  user.name,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  user.role.value.toUpperCase(),
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          
          // Dashboard - available to all
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () => context.go('/dashboard'),
          ),
          
          // Cases - based on permission
          if (user.hasPermission('casesRead'))
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('Cases'),
              onTap: () => context.go('/cases'),
            ),
          
          // Clients - based on permission
          if (user.hasPermission('clientsRead'))
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Clients'),
              onTap: () => context.go('/clients'),
            ),
          
          // Documents - based on permission
          if (user.hasPermission('documentsRead'))
            ListTile(
              leading: Icon(Icons.description),
              title: Text('Documents'),
              onTap: () => context.go('/documents'),
            ),
          
          // Reports - based on permission
          if (user.hasPermission('reportsRead'))
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text('Reports'),
              onTap: () => context.go('/reports'),
            ),
          
          Divider(),
          
          // User Management - managers only
          if (user.isManager) ...[
            ListTile(
              leading: Icon(Icons.people_outline),
              title: Text('User Management'),
              onTap: () => context.go('/users'),
            ),
          ],
          
          // Action Logs - all users
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Action Logs'),
            onTap: () => context.go('/users/actions'),
          ),
          
          Divider(),
          
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().signOut();
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
```

## 3. Case Management Integration

Update your case management screens to include action logging:

```dart
class CasesListScreen extends StatefulWidget {
  @override
  _CasesListScreenState createState() => _CasesListScreenState();
}

class _CasesListScreenState extends State<CasesListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        if (userState is UserLoaded) {
          final user = userState.user;
          
          // Check if user can read cases
          if (!user.hasPermission('casesRead')) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('You do not have permission to view cases'),
                ],
              ),
            );
          }
          
          return _buildCasesList(context, user);
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCasesList(BuildContext context, UserModel user) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cases'),
        actions: [
          // Only show add button if user has write permission
          if (user.hasPermission('casesWrite'))
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _navigateToAddCase(context, user),
            ),
        ],
      ),
      body: BlocBuilder<CaseCubit, CaseState>(
        builder: (context, state) {
          if (state is CaseLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is CaseLoaded) {
            return ListView.builder(
              itemCount: state.cases.length,
              itemBuilder: (context, index) {
                final caseModel = state.cases[index];
                return _buildCaseCard(context, caseModel, user);
              },
            );
          }
          return Center(child: Text('No cases found'));
        },
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, CaseModel caseModel, UserModel user) {
    return Card(
      child: ListTile(
        title: Text(caseModel.title),
        subtitle: Text(caseModel.description),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            // View - available to all with read permission
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View'),
                ],
              ),
            ),
            // Edit - only if user has write permission
            if (user.hasPermission('casesWrite'))
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
            // Delete - only if user has write permission
            if (user.hasPermission('casesWrite'))
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
          onSelected: (value) => _handleCaseAction(context, value, caseModel, user),
        ),
      ),
    );
  }

  void _navigateToAddCase(BuildContext context, UserModel user) {
    context.go('/cases/add');
  }

  void _handleCaseAction(BuildContext context, String action, CaseModel caseModel, UserModel user) {
    switch (action) {
      case 'view':
        context.go('/cases/${caseModel.id}');
        break;
      case 'edit':
        if (user.hasPermission('casesWrite')) {
          context.go('/cases/${caseModel.id}/edit');
        }
        break;
      case 'delete':
        if (user.hasPermission('casesWrite')) {
          _deleteCase(context, caseModel, user);
        }
        break;
    }
  }

  void _deleteCase(BuildContext context, CaseModel caseModel, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Case'),
        content: Text('Are you sure you want to delete "${caseModel.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Delete the case
              await context.read<CaseCubit>().deleteCase(caseModel.id, user.id);
              
              // Log the action
              await context.read<ActionCubit>().logCaseDeletion(
                lawyerId: user.id,
                lawyerName: user.name,
                caseTitle: caseModel.title,
                caseId: caseModel.id,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
```

## 4. Permission Checking Utility

Create a utility widget for easy permission checking:

```dart
class PermissionGate extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;

  const PermissionGate({
    Key? key,
    required this.permission,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoaded) {
          final user = state.user;
          
          // Managers can do everything
          if (user.isManager) {
            return child;
          }
          
          // Check specific permission
          if (user.hasPermission(permission)) {
            return child;
          }
          
          // Return fallback or empty widget
          return fallback ?? SizedBox.shrink();
        }
        
        return fallback ?? SizedBox.shrink();
      },
    );
  }
}

// Usage example:
PermissionGate(
  permission: 'casesWrite',
  child: FloatingActionButton(
    onPressed: () => context.go('/cases/add'),
    child: Icon(Icons.add),
  ),
  fallback: SizedBox.shrink(),
)
```

## 5. Action Logging Integration

Here's how to integrate action logging into your existing operations:

```dart
// In your case creation method
Future<void> createCase(CaseModel caseModel) async {
  try {
    // Get current user
    final currentUser = await context.read<UserCubit>().getCurrentUser();
    if (currentUser == null) return;
    
    // Check permission
    if (!currentUser.hasPermission('casesWrite')) {
      throw Exception('You do not have permission to create cases');
    }
    
    // Create the case
    await context.read<CaseCubit>().createCase(caseModel);
    
    // Log the action
    await context.read<ActionCubit>().logCaseCreation(
      lawyerId: currentUser.id,
      lawyerName: currentUser.name,
      caseTitle: caseModel.title,
      caseId: caseModel.id,
    );
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Case created successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

// In your client creation method
Future<void> createClient(ClientModel clientModel) async {
  try {
    final currentUser = await context.read<UserCubit>().getCurrentUser();
    if (currentUser == null) return;
    
    if (!currentUser.hasPermission('clientsWrite')) {
      throw Exception('You do not have permission to create clients');
    }
    
    await context.read<ClientCubit>().createClient(clientModel);
    
    await context.read<ActionCubit>().logClientCreation(
      lawyerId: currentUser.id,
      lawyerName: currentUser.name,
      clientName: clientModel.name,
      clientId: clientModel.id,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Client created successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

## 6. Login Flow Integration

Update your login flow to work with the RBAC system:

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // User is authenticated, now get their role and permissions
          context.read<UserCubit>().getCurrentUser();
        }
      },
      child: BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            // User data loaded, navigate to dashboard
            context.go('/dashboard');
          } else if (state is UserError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: _buildLoginForm(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) => _email = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (value) => _password = value,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    try {
      await context.read<AuthCubit>().signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }
}
```

These examples show how to integrate the RBAC system into your existing application. The key points are:

1. **Always check permissions** before showing UI elements or allowing actions
2. **Log all actions** performed by lawyers for audit purposes
3. **Use BlocBuilder** to reactively update UI based on user state
4. **Provide fallbacks** for users without permissions
5. **Show appropriate error messages** when permissions are denied

Remember to deploy the Firestore security rules and test thoroughly with different user roles and permissions!
