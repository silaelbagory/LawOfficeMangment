import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/constants.dart';
import '../../../data/models/lawyer_action_model.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/action_cubit/action_cubit.dart';
import '../../../logic/action_cubit/action_state.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';

class LawyerActionsScreen extends StatefulWidget {
  final UserModel lawyer;

  const LawyerActionsScreen({super.key, required this.lawyer});

  @override
  State<LawyerActionsScreen> createState() => _LawyerActionsScreenState();
}

class _LawyerActionsScreenState extends State<LawyerActionsScreen> {
  String _selectedFilter = 'all';
  String _selectedTimeRange = 'week';

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
            backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: Text('${widget.lawyer.name} - Actions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActions,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(theme),
          Expanded(
            child: BlocBuilder<ActionCubit, ActionState>(
              builder: (context, state) {
                if (state is ActionLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ActionError) {
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
                          'Error loading actions',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          state.message,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        ElevatedButton(
                          onPressed: _loadActions,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (state is ActionsLoaded) {
                  final actions = _filterActions(state.actions);
                  
                  if (actions.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: actions.length,
                    itemBuilder: (context, index) {
                      final action = actions[index];
                      return _buildActionCard(action, theme);
                    },
                  );
                }
                
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Filter by Action',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Actions')),
                DropdownMenuItem(value: 'case_creation', child: Text('Case Creation')),
                DropdownMenuItem(value: 'case_update', child: Text('Case Update')),
                DropdownMenuItem(value: 'case_deletion', child: Text('Case Deletion')),
                DropdownMenuItem(value: 'client_creation', child: Text('Client Creation')),
                DropdownMenuItem(value: 'client_update', child: Text('Client Update')),
                DropdownMenuItem(value: 'document_upload', child: Text('Document Upload')),
                DropdownMenuItem(value: 'document_deletion', child: Text('Document Deletion')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value ?? 'all';
                });
              },
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedTimeRange,
              decoration: const InputDecoration(
                labelText: 'Time Range',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'day', child: Text('Today')),
                DropdownMenuItem(value: 'week', child: Text('This Week')),
                DropdownMenuItem(value: 'month', child: Text('This Month')),
                DropdownMenuItem(value: 'all', child: Text('All Time')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTimeRange = value ?? 'week';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No actions found',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'No actions match the current filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(LawyerActionModel action, ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getActionColor(action).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getActionIcon(action),
                    color: _getActionColor(action),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.action,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(action.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getActionColor(action).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getActionTypeLabel(action),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getActionColor(action),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (action.metadata != null && action.metadata!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.smallPadding),
              Container(
                padding: const EdgeInsets.all(AppConstants.smallPadding),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: action.metadata!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              '${entry.key}:',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<LawyerActionModel> _filterActions(List<LawyerActionModel> actions) {
    var filteredActions = actions.where((action) {
      // Filter by action type
      if (_selectedFilter != 'all') {
        final actionType = action.metadata?['actionType'] ?? '';
        if (actionType != _selectedFilter) {
          return false;
        }
      }

      // Filter by time range
      final now = DateTime.now();
      switch (_selectedTimeRange) {
        case 'day':
          return action.timestamp.isAfter(now.subtract(const Duration(days: 1)));
        case 'week':
          return action.timestamp.isAfter(now.subtract(const Duration(days: 7)));
        case 'month':
          return action.timestamp.isAfter(now.subtract(const Duration(days: 30)));
        case 'all':
        default:
          return true;
      }
    }).toList();

    // Sort by timestamp (newest first)
    filteredActions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filteredActions;
  }

  Color _getActionColor(LawyerActionModel action) {
    final actionType = action.metadata?['actionType'] ?? '';
    switch (actionType) {
      case 'case_creation':
        return Colors.green;
      case 'case_update':
        return Colors.blue;
      case 'case_deletion':
        return Colors.red;
      case 'client_creation':
        return Colors.purple;
      case 'client_update':
        return Colors.orange;
      case 'document_upload':
        return Colors.teal;
      case 'document_deletion':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(LawyerActionModel action) {
    final actionType = action.metadata?['actionType'] ?? '';
    switch (actionType) {
      case 'case_creation':
        return Icons.add_circle;
      case 'case_update':
        return Icons.edit;
      case 'case_deletion':
        return Icons.delete;
      case 'client_creation':
        return Icons.person_add;
      case 'client_update':
        return Icons.person;
      case 'document_upload':
        return Icons.upload;
      case 'document_deletion':
        return Icons.delete_forever;
      default:
        return Icons.info;
    }
  }

  String _getActionTypeLabel(LawyerActionModel action) {
    final actionType = action.metadata?['actionType'] ?? '';
    switch (actionType) {
      case 'case_creation':
        return 'Case Created';
      case 'case_update':
        return 'Case Updated';
      case 'case_deletion':
        return 'Case Deleted';
      case 'client_creation':
        return 'Client Created';
      case 'client_update':
        return 'Client Updated';
      case 'document_upload':
        return 'Document Uploaded';
      case 'document_deletion':
        return 'Document Deleted';
      default:
        return 'Action';
    }
  }

  void _loadActions() {
    final user = context.read<AuthCubit>().currentUser;
    if (user != null && user.role == UserRole.manager) {
      context.read<ActionCubit>().loadActionsByLawyer(widget.lawyer.id);
    }
  }
}
