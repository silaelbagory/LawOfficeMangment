import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lawofficemanagementsystem/core/services/firestore_service.dart';
import 'package:lawofficemanagementsystem/presentation/screens/managers/lawyer_actions_screen.dart';
import 'package:lawofficemanagementsystem/presentation/screens/managers/manager_lawers.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/user_cubit/user_cubit.dart';
import '../../../logic/user_cubit/user_state.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().getMyLawyers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
            backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.usersManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context,'/users/add-lawyer'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<UserCubit>().getMyLawyers();
            },
          ),
        ],
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserCubit>().getMyLawyers();
                    },
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          } else if (state is UsersLoaded) {
            final lawyers = state.users;
            
            if (lawyers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      AppLocalizations.of(context)!.noLawyersFound,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context,'/add_lawyer'),
                      icon: const Icon(Icons.add),
                      label: Text(AppLocalizations.of(context)!.addLawyer),
                    ),
                  ],
                ),
              );
            }

            return ResponsiveWidget(
              mobile: ListView.builder(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
                itemCount: lawyers.length,
                itemBuilder: (context, index) {
                  final lawyer = lawyers[index];
                  return _buildLawyerCard(lawyer, theme);
                },
              ),
              tablet: _buildTabletView(lawyers, theme),
              desktop: _buildDesktopView(lawyers, theme),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTabletView(List<UserModel> lawyers, ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Name')),
          const DataColumn(label: Text('Email')),
          const DataColumn(label: Text('Status')),
          const DataColumn(label: Text('Joined')),
          const DataColumn(label: Text('Actions')),
        ],
        rows: lawyers.map((lawyer) => _buildDataTableRow(lawyer, theme)).toList(),
      ),
    );
  }

  Widget _buildDesktopView(List<UserModel> lawyers, ThemeData theme) {
    return ResponsiveContainer(
       child: ListView.builder(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
                itemCount: lawyers.length,
                itemBuilder: (context, index) {
                  final lawyer = lawyers[index];
                  return _buildLawyerCard(lawyer, theme);
                },
              ),
    /*  child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: ResponsiveUtils.getResponsivePadding(context),
          columns: [
            const DataColumn(label: Text('Name')),
            const DataColumn(label: Text('Email')),
            const DataColumn(label: Text('Status')),
            const DataColumn(label: Text('Joined')),
            const DataColumn(label: Text('Permissions')),
            const DataColumn(label: Text('Actions')),
          ],
          rows: lawyers.map((lawyer) => _buildDesktopDataTableRow(lawyer, theme)).toList(),
        ),*/

      )
    ;
  }

  DataRow _buildDataTableRow(UserModel lawyer, ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                lawyer.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(lawyer.email)),
        DataCell(_buildStatusChip(lawyer.isActive, theme)),
        DataCell(Text(dateFormat.format(lawyer.createdAt))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editLawyer(lawyer),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteLawyer(lawyer),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildDesktopDataTableRow(UserModel lawyer, ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                lawyer.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(lawyer.email)),
        DataCell(_buildStatusChip(lawyer.isActive, theme)),
        DataCell(Text(dateFormat.format(lawyer.createdAt))),
        DataCell(Text(_getPermissionsSummary(lawyer.permissions))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () => _viewLawyer(lawyer),
                tooltip: 'View',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editLawyer(lawyer),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteLawyer(lawyer),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getPermissionsSummary(UserPermissions permissions) {
    final activePermissions = <String>[];
    if (permissions.casesRead) activePermissions.add('Cases');
    if (permissions.clientsRead) activePermissions.add('Clients');
    if (permissions.documentsRead) activePermissions.add('Documents');
    if (permissions.usersRead) activePermissions.add('Users');
    
    return activePermissions.isEmpty ? 'No permissions' : activePermissions.join(', ');
  }

  void _viewLawyer(UserModel lawyer) {
    // Navigate to lawyer details view
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LawyerActionsScreen(lawyer: lawyer),
      ),
    );
  }

  void _editLawyer(UserModel lawyer) {
    // Navigate to edit lawyer screen
    Navigator.pushNamed(
      context,
      '/edit-lawyer',
      arguments: lawyer,
    );
  }

  void _deleteLawyer(UserModel lawyer) {
    // Show confirmation dialog and delete lawyer
    final firestoreService = FirestoreService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Lawyer'),
        content: Text('Are you sure you want to delete ${lawyer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              firestoreService.deleteUser(lawyer.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('you deleted the lawyer')),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildLawyerCard(UserModel lawyer, ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return GestureDetector(
      onTap: () {
        final user = context.read<AuthCubit>().currentUser;
        if (user != null && user.role == UserRole.manager) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LawyerActionsScreen(lawyer: lawyer),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyLawyersScreen(),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.primary,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lawyer.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          lawyer.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          '${AppLocalizations.of(context)!.joined}: ${dateFormat.format(lawyer.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(lawyer.isActive, theme),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildPermissionsList(lawyer.permissions, theme),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editLawyerPermissions(lawyer),
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text(AppLocalizations.of(context)!.editPermissions),
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleLawyerStatus(lawyer),
                      icon: Icon(
                        lawyer.isActive ? Icons.person_off : Icons.person,
                        size: 16,
                      ),
                      label: Text(
                        lawyer.isActive 
                            ? AppLocalizations.of(context)!.deactivate
                            : AppLocalizations.of(context)!.activate,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: lawyer.isActive 
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isActive 
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive 
            ? AppLocalizations.of(context)!.active
            : AppLocalizations.of(context)!.inactive,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isActive 
              ? theme.colorScheme.primary
              : theme.colorScheme.error,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPermissionsList(UserPermissions permissions, ThemeData theme) {
    final permissionItems = <String>[];
    
    if (permissions.casesRead) permissionItems.add(AppLocalizations.of(context)!.readCases);
    if (permissions.casesWrite) permissionItems.add(AppLocalizations.of(context)!.writeCases);
    if (permissions.clientsRead) permissionItems.add(AppLocalizations.of(context)!.readClients);
    if (permissions.clientsWrite) permissionItems.add(AppLocalizations.of(context)!.writeClients);
    if (permissions.documentsRead) permissionItems.add(AppLocalizations.of(context)!.readDocuments);
    if (permissions.documentsWrite) permissionItems.add(AppLocalizations.of(context)!.writeDocuments);
    if (permissions.reportsRead) permissionItems.add(AppLocalizations.of(context)!.readReports);
    if (permissions.reportsWrite) permissionItems.add(AppLocalizations.of(context)!.writeReports);
    if (permissions.usersRead) permissionItems.add(AppLocalizations.of(context)!.readUsers);
    if (permissions.usersWrite) permissionItems.add(AppLocalizations.of(context)!.writeUsers);

    if (permissionItems.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.noPermissions,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: AppConstants.smallPadding,
      runSpacing: AppConstants.smallPadding,
      children: permissionItems.map((permission) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.smallPadding,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            permission,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _editLawyerPermissions(UserModel lawyer) {
    showDialog(
      context: context,
      builder: (context) => _PermissionsEditDialog(lawyer: lawyer),
    );
  }

  void _toggleLawyerStatus(UserModel lawyer) {
    final action = lawyer.isActive 
        ? AppLocalizations.of(context)!.deactivate
        : AppLocalizations.of(context)!.activate;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action ${lawyer.name}?'),
        content: Text(
          lawyer.isActive
              ? AppLocalizations.of(context)!.deactivateLawyerConfirmation
              : AppLocalizations.of(context)!.activateLawyerConfirmation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (lawyer.isActive) {
                context.read<UserCubit>().deactivateLawyer(lawyer.id);
              } else {
                context.read<UserCubit>().activateLawyer(lawyer.id);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: lawyer.isActive 
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}

class _PermissionsEditDialog extends StatefulWidget {
  final UserModel lawyer;

  const _PermissionsEditDialog({required this.lawyer});

  @override
  State<_PermissionsEditDialog> createState() => _PermissionsEditDialogState();
}

class _PermissionsEditDialogState extends State<_PermissionsEditDialog> {
  late UserPermissions _permissions;

  @override
  void initState() {
    super.initState();
    _permissions = widget.lawyer.permissions;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.editPermissions),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPermissionGroup(
                title: AppLocalizations.of(context)!.cases,
                permissions: [
                  _buildPermissionTile(
                    title: AppLocalizations.of(context)!.readCases,
                    value: _permissions.casesRead,
                    onChanged: (value) {
                      setState(() {
                        _permissions = _permissions.copyWith(casesRead: value);
                      });
                    },
                  ),
                  _buildPermissionTile(
                    title: AppLocalizations.of(context)!.writeCases,
                    value: _permissions.casesWrite,
                    onChanged: (value) {
                      setState(() {
                        _permissions = _permissions.copyWith(casesWrite: value);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildPermissionGroup(
                title: AppLocalizations.of(context)!.clients,
                permissions: [
                  _buildPermissionTile(
                    title: AppLocalizations.of(context)!.readClients,
                    value: _permissions.clientsRead,
                    onChanged: (value) {
                      setState(() {
                        _permissions = _permissions.copyWith(clientsRead: value);
                      });
                    },
                  ),
                  _buildPermissionTile(
                    title: AppLocalizations.of(context)!.writeClients,
                    value: _permissions.clientsWrite,
                    onChanged: (value) {
                      setState(() {
                        _permissions = _permissions.copyWith(clientsWrite: value);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildPermissionGroup(
                title: AppLocalizations.of(context)!.documents,
                permissions: [
                  _buildPermissionTile(
                    title: AppLocalizations.of(context)!.readDocuments,
                    value: _permissions.documentsRead,
                    onChanged: (value) {
                      setState(() {
                        _permissions = _permissions.copyWith(documentsRead: value);
                      });
                    },
                  ),
                  _buildPermissionTile(
                    title: AppLocalizations.of(context)!.writeDocuments,
                    value: _permissions.documentsWrite,
                    onChanged: (value) {
                      setState(() {
                        _permissions = _permissions.copyWith(documentsWrite: value);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildPermissionGroup(
                title: AppLocalizations.of(context)!.reports,
                permissions: [
                  _buildPermissionTile(
                    title: AppLocalizations.of(context)!.readReports,
                    value: _permissions.reportsRead,
                    onChanged: (value) {
                      setState(() {
                        _permissions = _permissions.copyWith(reportsRead: value);
                      });
                    },
                  ),
                  _buildPermissionTile(
                    title: AppLocalizations.of(context)!.writeReports,
                    value: _permissions.reportsWrite,
                    onChanged: (value) {
                      setState(() {
                        _permissions = _permissions.copyWith(reportsWrite: value);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildPermissionGroup(
                title: AppLocalizations.of(context)!.users,
                permissions: [
                  _buildPermissionTile(
                    title: AppLocalizations.of(context)!.readUsers,
                    value: _permissions.usersRead,
                    onChanged: (value) {
                      setState(() {
                        _permissions = _permissions.copyWith(usersRead: value);
                      });
                    },
                  ),
                  _buildPermissionTile(
                    title: AppLocalizations.of(context)!.writeUsers,
                    value: _permissions.usersWrite,
                    onChanged: (value) {
                      setState(() {
                        _permissions = _permissions.copyWith(usersWrite: value);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<UserCubit>().updateLawyerPermissions(
              lawyerId: widget.lawyer.id,
              permissions: _permissions,
            );
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }

  Widget _buildPermissionGroup({
    required String title,
    required List<Widget> permissions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        ...permissions,
      ],
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: (bool? newValue) => onChanged(newValue ?? false),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
