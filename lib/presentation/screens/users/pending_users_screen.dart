/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/constants.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/user_cubit/user_cubit.dart';
import '../../../logic/user_cubit/user_state.dart';
import '../../widgets/custom_button.dart';

class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({super.key});

  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();
}

class _PendingUsersScreenState extends State<PendingUsersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().loadPendingUsers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > AppConstants.mobileBreakpoint;
    final isDesktop = size.width > AppConstants.tabletBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<UserCubit>().loadPendingUsers(),
          ),
        ],
      ),
      body: BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User updated successfully'),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UsersLoaded) {
              final pendingUsers = state.users;
              
              if (pendingUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pending_actions,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Pending Users',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'There are no users waiting for approval at the moment.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return _buildPendingUsersList(context, pendingUsers, isTablet, isDesktop);
            } else if (state is UserError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Users',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Retry',
                      onPressed: () => context.read<UserCubit>().loadPendingUsers(),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildPendingUsersList(
    BuildContext context,
    List<UserModel> pendingUsers,
    bool isTablet,
    bool isDesktop,
  ) {
    if (isDesktop) {
      return _buildDesktopTable(context, pendingUsers);
    } else if (isTablet) {
      return _buildTabletGrid(context, pendingUsers);
    } else {
      return _buildMobileList(context, pendingUsers);
    }
  }

  Widget _buildDesktopTable(BuildContext context, List<UserModel> pendingUsers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Card(
        child: DataTable(
          columns: [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Requested Role')),
            DataColumn(label: Text('Requested At')),
            DataColumn(label: Text('Actions')),
          ],
          rows: pendingUsers.map((user) {
            return DataRow(
              cells: [
                DataCell(Text(user.name)),
                DataCell(Text(user.email)),
                DataCell(Text(user.role.value)),
                DataCell(Text(_formatDate(user.createdAt))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _showApproveDialog(context, user),
                        tooltip: 'Approve',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _showRejectDialog(context, user),
                        tooltip: 'Reject',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabletGrid(BuildContext context, List<UserModel> pendingUsers) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: pendingUsers.length,
      itemBuilder: (context, index) {
        final user = pendingUsers[index];
        return _buildUserCard(context, user);
      },
    );
  }

  Widget _buildMobileList(BuildContext context, List<UserModel> pendingUsers) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: pendingUsers.length,
      itemBuilder: (context, index) {
        final user = pendingUsers[index];
        return _buildUserCard(context, user);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(user.name[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        user.email,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  'Requested Role: ${user.role.value}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  'Requested At: ${_formatDate(user.createdAt)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Approve',
                    onPressed: () => _showApproveDialog(context, user),
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'Reject',
                    onPressed: () => _showRejectDialog(context, user),
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => _ApproveUserDialog(user: user),
    );
  }

  void _showRejectDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject User'),
        content: Text('Are you sure you want to reject ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserCubit>().rejectUser(user.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ApproveUserDialog extends StatefulWidget {
  final UserModel user;

  const _ApproveUserDialog({required this.user});

  @override
  State<_ApproveUserDialog> createState() => _ApproveUserDialogState();
}

class _ApproveUserDialogState extends State<_ApproveUserDialog> {
  UserRole _selectedRole = UserRole.lawyer;
  UserPermissions _permissions = UserPermissions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Approve User'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to approve ${widget.user.name}?'),
            const SizedBox(height: 16),
            Text('Select Role', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Text('Select Permissions', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildPermissionCheckbox('Read Cases', 'casesRead'),
            _buildPermissionCheckbox('Write Cases', 'casesWrite'),
            _buildPermissionCheckbox('Read Clients', 'clientsRead'),
            _buildPermissionCheckbox('Write Clients', 'clientsWrite'),
            _buildPermissionCheckbox('Read Documents', 'documentsRead'),
            _buildPermissionCheckbox('Write Documents', 'documentsWrite'),
            _buildPermissionCheckbox('Read Reports', 'reportsRead'),
            _buildPermissionCheckbox('Write Reports', 'reportsWrite'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<UserCubit>().approveUser(widget.user.id, _selectedRole, _permissions);
          },
          child: Text('Approve'),
        ),
      ],
    );
  }

  Widget _buildPermissionCheckbox(String title, String permission) {
    return CheckboxListTile(
      title: Text(title),
      value: _getPermissionValue(permission),
      onChanged: (bool? value) {
        setState(() {
          _setPermissionValue(permission, value ?? false);
        });
      },
      dense: true,
    );
  }

  bool _getPermissionValue(String permission) {
    switch (permission) {
      case 'casesRead':
        return _permissions.casesRead;
      case 'casesWrite':
        return _permissions.casesWrite;
      case 'clientsRead':
        return _permissions.clientsRead;
      case 'clientsWrite':
        return _permissions.clientsWrite;
      case 'documentsRead':
        return _permissions.documentsRead;
      case 'documentsWrite':
        return _permissions.documentsWrite;
      case 'reportsRead':
        return _permissions.reportsRead;
      case 'reportsWrite':
        return _permissions.reportsWrite;
      default:
        return false;
    }
  }

  void _setPermissionValue(String permission, bool value) {
    switch (permission) {
      case 'casesRead':
        _permissions = _permissions.copyWith(casesRead: value);
        break;
      case 'casesWrite':
        _permissions = _permissions.copyWith(casesWrite: value);
        break;
      case 'clientsRead':
        _permissions = _permissions.copyWith(clientsRead: value);
        break;
      case 'clientsWrite':
        _permissions = _permissions.copyWith(clientsWrite: value);
        break;
      case 'documentsRead':
        _permissions = _permissions.copyWith(documentsRead: value);
        break;
      case 'documentsWrite':
        _permissions = _permissions.copyWith(documentsWrite: value);
        break;
      case 'reportsRead':
        _permissions = _permissions.copyWith(reportsRead: value);
        break;
      case 'reportsWrite':
        _permissions = _permissions.copyWith(reportsWrite: value);
        break;
    }
  }
}*/