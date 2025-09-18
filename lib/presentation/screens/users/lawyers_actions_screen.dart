import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/constants.dart';
import '../../../data/models/lawyer_action_model.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/action_cubit/action_cubit.dart';
import '../../../logic/action_cubit/action_state.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';

class LawyersActionsScreen extends StatefulWidget {
  const LawyersActionsScreen({super.key});

  @override
  State<LawyersActionsScreen> createState() => _LawyersActionsScreenState();
}

class _LawyersActionsScreenState extends State<LawyersActionsScreen> {
  String _selectedFilter = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Load actions based on user role
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      if (user.role == UserRole.manager) {
        // Manager sees all actions from their team
        context.read<ActionCubit>().loadActionsByManager(user.id);
      } else {
        // Lawyer sees only their own actions
        context.read<ActionCubit>().loadActionsByLawyer(user.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
            backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.lawyersActions),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ActionCubit>().loadAllActions();
            },
          ),
        ],
      ),
      body: BlocBuilder<ActionCubit, ActionState>(
        builder: (context, state) {
          if (state is ActionLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                    state.message,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ActionCubit>().loadAllActions();
                    },
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          } else if (state is ActionsLoaded) {
            final actions = _filterActions(state.actions);
            
            if (actions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      AppLocalizations.of(context)!.noActionsFound,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildFilterChips(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: actions.length,
                    itemBuilder: (context, index) {
                      final action = actions[index];
                      return _buildActionCard(action, theme);
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', AppLocalizations.of(context)!.all),
            const SizedBox(width: AppConstants.smallPadding),
            _buildFilterChip('create_case', AppLocalizations.of(context)!.caseCreation),
            const SizedBox(width: AppConstants.smallPadding),
            _buildFilterChip('update_case', AppLocalizations.of(context)!.caseUpdate),
            const SizedBox(width: AppConstants.smallPadding),
            _buildFilterChip('create_client', AppLocalizations.of(context)!.clientCreation),
            const SizedBox(width: AppConstants.smallPadding),
            _buildFilterChip('upload_document', AppLocalizations.of(context)!.documentUpload),
            const SizedBox(width: AppConstants.smallPadding),
            _buildFilterChip('add_lawyer', AppLocalizations.of(context)!.addLawyer),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
      },
    );
  }

  Widget _buildActionCard(LawyerActionModel action, ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    _getActionIcon(action.metadata?['actionType']),
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.lawyerName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        action.action,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dateFormat.format(action.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      timeFormat.format(action.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (action.metadata != null) ...[
              const SizedBox(height: AppConstants.smallPadding),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  action.metadata!['actionType'] ?? 'unknown',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getActionIcon(String? actionType) {
    switch (actionType) {
      case 'create_case':
        return Icons.add_circle_outline;
      case 'update_case':
        return Icons.edit_outlined;
      case 'delete_case':
        return Icons.delete_outline;
      case 'create_client':
        return Icons.person_add_outlined;
      case 'update_client':
        return Icons.person_outline;
      case 'upload_document':
        return Icons.upload_file;
      case 'delete_document':
        return Icons.delete_outline;
      case 'add_lawyer':
        return Icons.person_add;
      case 'update_lawyer_permissions':
        return Icons.security;
      case 'deactivate_lawyer':
        return Icons.person_off;
      case 'activate_lawyer':
        return Icons.person;
      case 'update_profile':
        return Icons.account_circle;
      case 'change_password':
        return Icons.lock_outline;
      default:
        return Icons.history;
    }
  }

  List<LawyerActionModel> _filterActions(List<LawyerActionModel> actions) {
    List<LawyerActionModel> filtered = actions;

    // Filter by action type
    if (_selectedFilter != 'all') {
      filtered = filtered.where((action) {
        return action.metadata?['actionType'] == _selectedFilter;
      }).toList();
    }

    // Filter by date range
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((action) {
        return action.timestamp.isAfter(_startDate!) &&
               action.timestamp.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.filterActions),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.selectDateRange),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateRange,
            ),
            if (_startDate != null && _endDate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.clear),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      Navigator.of(context).pop();
    }
  }
}
