import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/utils/constants.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/client_cubit/client_cubit.dart';
import '../../../logic/client_cubit/client_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'edit_client_screen.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ClientStatus? _selectedStatus;
  ClientType? _selectedType;
  String _sortBy = 'createdAt';
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadClients() {
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      if (user.role == UserRole.manager) {
        // Manager sees all clients from their team
        context.read<ClientCubit>().loadClientsByManager(user.id);
      } else {
        // Lawyer sees only their own clients
        context.read<ClientCubit>().loadClients(user.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > AppConstants.mobileBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.clients),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClients,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(theme),
          Expanded(
            child: BlocBuilder<ClientCubit, ClientState>(
              builder: (context, state) {
                if (state is ClientLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ClientError) {
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
                          'Error loading clients',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          state.message,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        PrimaryButton(
                          text: 'Retry',
                          onPressed: _loadClients,
                        ),
                      ],
                    ),
                  );
                } else if (state is ClientLoaded) {
                  final clients = _filterAndSortClients(state.clients);
                  
                  if (clients.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return isTablet
                      ? _buildTabletView(theme, clients)
                      : _buildMobileView(theme, clients);
                }
                
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context,'/add-client'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          SearchTextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildFilterChips(theme),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(theme, 'All', null, _selectedStatus == null),
          const SizedBox(width: AppConstants.smallPadding),
          ...ClientStatus.values.map((status) => Padding(
            padding: const EdgeInsets.only(right: AppConstants.smallPadding),
            child: _buildFilterChip(
              theme,
              status.displayText,
              status,
              _selectedStatus == status,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, ClientStatus? status, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No clients found',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Start by adding your first client',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          PrimaryButton(
            text: 'Add Client',
            onPressed: () => Navigator.pushNamed(context,'/add-client'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView(ThemeData theme, List<ClientModel> clients) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return _buildClientCard(theme, client);
      },
    );
  }

  Widget _buildTabletView(ThemeData theme, List<ClientModel> clients) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Name')),
          const DataColumn(label: Text('Email')),
          const DataColumn(label: Text('Phone')),
          const DataColumn(label: Text('Type')),
          const DataColumn(label: Text('Status')),
          const DataColumn(label: Text('Actions')),
        ],
        rows: clients.map((client) => _buildDataTableRow(theme, client)).toList(),
      ),
    );
  }

  DataRow _buildDataTableRow(ThemeData theme, ClientModel client) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  client.initials,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                client.displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(client.email)),
        DataCell(Text(client.phoneNumber ?? 'No phone')),
        DataCell(Text(client.typeDisplayText)),
        DataCell(_buildStatusChip(theme, client.status)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editClient(client),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteClient(client),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientCard(ThemeData theme, ClientModel client) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: InkWell(
        onTap: () => _viewClient(client),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      client.initials,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(theme, client.status),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    client.phoneNumber ?? 'No phone',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Icon(
                    Icons.business,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    client.typeDisplayText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (client.hasCases) ...[
                const SizedBox(height: AppConstants.smallPadding),
                Row(
                  children: [
                    Icon(
                      Icons.folder,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${client.caseCount} case${client.caseCount == 1 ? '' : 's'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppConstants.smallPadding),
              Row(
                children: [
                  Text(
                    'Created: ${client.createdAtFormatted}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editClient(client),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteClient(client),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, ClientStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(theme, status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(theme, status),
          width: 1,
        ),
      ),
      child: Text(
        status.displayText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: _getStatusColor(theme, status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(ThemeData theme, ClientStatus status) {
    switch (status) {
      case ClientStatus.active:
        return AppColors.success;
      case ClientStatus.inactive:
        return AppColors.warning;
      case ClientStatus.potential:
        return AppColors.info;
      case ClientStatus.former:
        return AppColors.caseClosed;
    }
  }

  List<ClientModel> _filterAndSortClients(List<ClientModel> clients) {
    var filteredClients = clients.where((client) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!client.name.toLowerCase().contains(query) &&
            !client.email.toLowerCase().contains(query) &&
            !(client.companyName?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Filter by status
      if (_selectedStatus != null && client.status != _selectedStatus) {
        return false;
      }

      // Filter by type
      if (_selectedType != null && client.type != _selectedType) {
        return false;
      }

      return true;
    }).toList();

    // Sort clients
    filteredClients.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'name':
          comparison = a.displayName.compareTo(b.displayName);
          break;
        case 'email':
          comparison = a.email.compareTo(b.email);
          break;
        case 'status':
          comparison = a.status.name.compareTo(b.status.name);
          break;
        case 'type':
          comparison = a.type.name.compareTo(b.type.name);
          break;
        case 'createdAt':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return _sortDescending ? -comparison : comparison;
    });

    return filteredClients;
  }

  void _viewClient(ClientModel client) {
    // TODO: Implement client details view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View client: ${client.displayName}')),
    );
  }

  void _editClient(ClientModel client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditClientScreen(clientModel: client),
      ),
    );
  }

  void _deleteClient(ClientModel client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete "${client.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          BlocConsumer<ClientCubit, ClientState>(
            listener: (context, state) {
              if (state is ClientDeleted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Client deleted successfully')),
                );
              } else if (state is ClientError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              return TextButton(
                onPressed: state is ClientLoading
                    ? null
                    : () {
                        final user = context.read<AuthCubit>().currentUser;
                        if (user != null) {
                          context.read<ClientCubit>().deleteClient(client.id, user.id);
                        }
                      },
                child: state is ClientLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Delete'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Clients'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ClientStatus?>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...ClientStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.displayText),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            DropdownButtonFormField<ClientType?>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...ClientType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayText),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Clients'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: const InputDecoration(labelText: 'Sort by'),
              items: const [
                DropdownMenuItem(value: 'createdAt', child: Text('Created Date')),
                DropdownMenuItem(value: 'name', child: Text('Name')),
                DropdownMenuItem(value: 'email', child: Text('Email')),
                DropdownMenuItem(value: 'status', child: Text('Status')),
                DropdownMenuItem(value: 'type', child: Text('Type')),
              ],
              onChanged: (value) {
                setState(() {
                  _sortBy = value ?? 'createdAt';
                });
              },
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            SwitchListTile(
              title: const Text('Descending'),
              value: _sortDescending,
              onChanged: (value) {
                setState(() {
                  _sortDescending = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}


