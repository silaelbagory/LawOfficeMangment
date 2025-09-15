import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lawofficemanagementsystem/core/services/firestore_service.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/case_model.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/case_cubit/case_cubit.dart';
import '../../../logic/case_cubit/case_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'edit_case_screen.dart';

class CasesListScreen extends StatefulWidget {
  const CasesListScreen({super.key});

  @override
  State<CasesListScreen> createState() => _CasesListScreenState();
}

class _CasesListScreenState extends State<CasesListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  CaseStatus? _selectedStatus;
  CasePriority? _selectedPriority;
  String _sortBy = 'createdAt';
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCases() {
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      if (user.role == UserRole.manager) {
        // Manager sees all cases from their team
        context.read<CaseCubit>().loadCasesByManager(user.id);
      } else {
        // Lawyer sees only their own cases
        context.read<CaseCubit>().loadCases(user.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.cases),
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
            onPressed: _loadCases,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(theme),
          Expanded(
            child: BlocBuilder<CaseCubit, CaseState>(
              builder: (context, state) {
                if (state is CaseLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CaseError) {
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
                          AppLocalizations.of(context)!.errorLoadingCases,
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
                          text: AppLocalizations.of(context)!.retry,
                          onPressed: _loadCases,
                        ),
                      ],
                    ),
                  );
                } else if (state is CaseLoaded) {
                  final cases = _filterAndSortCases(state.cases);
                  
                  if (cases.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return ResponsiveWidget(
                    mobile: _buildMobileView(theme, cases),
                    tablet: _buildTabletView(theme, cases),
                    desktop: _buildDesktopView(theme, cases),
                  );
                }
                
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context,'/add-case'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return ResponsiveContainer(
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
          SizedBox(height: AppConstants.smallPadding),
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
          _buildFilterChip(theme, AppLocalizations.of(context)!.all, null, _selectedStatus == null),
          const SizedBox(width: AppConstants.smallPadding),
          ...CaseStatus.values.map((status) => Padding(
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

  Widget _buildFilterChip(ThemeData theme, String label, CaseStatus? status, bool isSelected) {
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
            Icons.folder_open,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            AppLocalizations.of(context)!.noCasesFound,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            AppLocalizations.of(context)!.startByCreatingFirstCase,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          PrimaryButton(
            text: AppLocalizations.of(context)!.addCase,
            onPressed: () => Navigator.pushNamed(context, '/add-case'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView(ThemeData theme, List<CaseModel> cases) {
    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
      itemCount: cases.length,
      itemBuilder: (context, index) {
        final caseModel = cases[index];
        return _buildCaseCard(theme, caseModel);
      },
    );
  }

  Widget _buildTabletView(ThemeData theme, List<CaseModel> cases) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
      child: DataTable(
        columns: [
          DataColumn(label: Text(AppLocalizations.of(context)!.title)),
          DataColumn(label: Text(AppLocalizations.of(context)!.client)),
          DataColumn(label: Text(AppLocalizations.of(context)!.status)),
          DataColumn(label: Text(AppLocalizations.of(context)!.priority)),
          DataColumn(label: Text(AppLocalizations.of(context)!.dueDate)),
          DataColumn(label: Text(AppLocalizations.of(context)!.actions)),
        ],
        rows: cases.map((caseModel) => _buildDataTableRow(theme, caseModel)).toList(),
      ),
    );
  }

  Widget _buildDesktopView(ThemeData theme, List<CaseModel> cases) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: ResponsiveUtils.getResponsivePadding(context),
          columns: [
            DataColumn(label: Text(AppLocalizations.of(context)!.title)),
            DataColumn(label: Text(AppLocalizations.of(context)!.client)),
            DataColumn(label: Text(AppLocalizations.of(context)!.status)),
            DataColumn(label: Text(AppLocalizations.of(context)!.priority)),
            DataColumn(label: Text(AppLocalizations.of(context)!.dueDate)),
            DataColumn(label: Text(AppLocalizations.of(context)!.hearingDate)),
            DataColumn(label: Text(AppLocalizations.of(context)!.actions)),
          ],
          rows: cases.map((caseModel) => _buildDesktopDataTableRow(theme, caseModel)).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataTableRow(ThemeData theme, CaseModel caseModel) {
    final firestoreService = FirestoreService();
    return DataRow(
      cells: [
        DataCell(
          Text(
           caseModel.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
DataCell(
  FutureBuilder<String?>(
    future: firestoreService.getClientNameById(caseModel.clientId ?? ''),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text("Loading..."); // show loading text
      }
      if (snapshot.hasError) {
        return const Text("Error");
      }
      if (!snapshot.hasData || snapshot.data == null) {
        return Text(AppLocalizations.of(context)!.noClient);
      }
      return Text(snapshot.data!);
    },
  ),
),
        DataCell(_buildStatusChip(theme, caseModel.status)),
        DataCell(_buildPriorityChip(theme, caseModel.priority)),
        DataCell(Text(caseModel.dueDateFormatted)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editCase(caseModel),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteCase(caseModel),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildDesktopDataTableRow(ThemeData theme, CaseModel caseModel) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            caseModel.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        DataCell(Text(caseModel.clientId ?? AppLocalizations.of(context)!.noClient)),
        DataCell(_buildStatusChip(theme, caseModel.status)),
        DataCell(_buildPriorityChip(theme, caseModel.priority)),
        DataCell(Text(caseModel.dueDateFormatted)),
        DataCell(Text(caseModel.hearingDate?.toString() ?? 'N/A')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () => _viewCase(caseModel),
                tooltip: 'View',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editCase(caseModel),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteCase(caseModel),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaseCard(ThemeData theme, CaseModel caseModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: InkWell(
        onTap: () => _viewCase(caseModel),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      caseModel.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusChip(theme, caseModel.status),
                ],
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                caseModel.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Row(
                children: [
                  _buildPriorityChip(theme, caseModel.priority),
                  const Spacer(),
                  if (caseModel.dueDate != null)
                    Text(
                      '${AppLocalizations.of(context)!.due}${caseModel.dueDateFormatted}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: caseModel.isOverdue
                            ? theme.colorScheme.error
                            : caseModel.isDueSoon
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Row(
                children: [
                                      Text(
                      '${AppLocalizations.of(context)!.created}${caseModel.createdAtFormatted}',
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
                        onPressed: () => _editCase(caseModel),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteCase(caseModel),
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

  Widget _buildStatusChip(ThemeData theme, CaseStatus status) {
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

  Widget _buildPriorityChip(ThemeData theme, CasePriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getPriorityColor(theme, priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPriorityColor(theme, priority),
          width: 1,
        ),
      ),
      child: Text(
        priority.displayText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: _getPriorityColor(theme, priority),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(ThemeData theme, CaseStatus status) {
    switch (status) {
      case CaseStatus.open:
        return AppColors.caseOpen;
      case CaseStatus.inProgress:
        return AppColors.caseInProgress;
      case CaseStatus.onHold:
        return AppColors.caseOnHold;
      case CaseStatus.closed:
        return AppColors.caseClosed;
    }
  }

  Color _getPriorityColor(ThemeData theme, CasePriority priority) {
    switch (priority) {
      case CasePriority.low:
        return AppColors.success;
      case CasePriority.medium:
        return AppColors.info;
      case CasePriority.high:
        return AppColors.warning;
      case CasePriority.urgent:
        return AppColors.errorLight;
    }
  }

  List<CaseModel> _filterAndSortCases(List<CaseModel> cases) {
    var filteredCases = cases.where((caseModel) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!caseModel.title.toLowerCase().contains(query) &&
            !caseModel.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filter by status
      if (_selectedStatus != null && caseModel.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();

    // Sort cases
    filteredCases.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'status':
          comparison = a.status.name.compareTo(b.status.name);
          break;
        case 'priority':
          comparison = a.priority.index.compareTo(b.priority.index);
          break;
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) {
            comparison = 0;
          } else if (a.dueDate == null) {
            comparison = 1;
          } else if (b.dueDate == null) {
            comparison = -1;
          } else {
            comparison = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case 'createdAt':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return _sortDescending ? -comparison : comparison;
    });

    return filteredCases;
  }

  void _viewCase(CaseModel caseModel) {
    // TODO: Implement case details view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppLocalizations.of(context)!.viewCase}${caseModel.title}')),
    );
  }

  void _editCase(CaseModel caseModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCaseScreen(caseModel: caseModel),
      ),
    );
  }

  void _deleteCase(CaseModel caseModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteCase),
        content: Text(AppLocalizations.of(context)!.deleteCaseConfirmation(caseModel.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          BlocConsumer<CaseCubit, CaseState>(
            listener: (context, state) {
              if (state is CaseDeleted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.caseDeletedSuccessfully)),
                );
              } else if (state is CaseError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              return TextButton(
                onPressed: state is CaseLoading
                    ? null
                    : () {
                        final user = context.read<AuthCubit>().currentUser;
                        if (user != null) {
                          context.read<CaseCubit>().deleteCase(caseModel.id, user.id);
                        }
                      },
                child: state is CaseLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(AppLocalizations.of(context)!.delete),
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
        title: Text(AppLocalizations.of(context)!.filterCases),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<CaseStatus?>(
              value: _selectedStatus,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.status),
              items: [
                DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context)!.all)),
                ...CaseStatus.values.map((status) => DropdownMenuItem(
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
            DropdownButtonFormField<CasePriority?>(
              value: _selectedPriority,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.priority),
              items: [
                DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context)!.all)),
                ...CasePriority.values.map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority.displayText),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.sortCases),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.sortBy),
                              items: [
                  DropdownMenuItem(value: 'createdAt', child: Text(AppLocalizations.of(context)!.createdDate)),
                  DropdownMenuItem(value: 'title', child: Text(AppLocalizations.of(context)!.title)),
                  DropdownMenuItem(value: 'status', child: Text(AppLocalizations.of(context)!.status)),
                  DropdownMenuItem(value: 'priority', child: Text(AppLocalizations.of(context)!.priority)),
                  DropdownMenuItem(value: 'dueDate', child: Text(AppLocalizations.of(context)!.dueDate)),
                ],
              onChanged: (value) {
                setState(() {
                  _sortBy = value ?? 'createdAt';
                });
              },
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.descending),
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
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }
}
