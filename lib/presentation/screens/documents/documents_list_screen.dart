import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lawofficemanagementsystem/core/utils/them_background.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/document_model.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/document_cubit/document_cubit.dart';
import '../../../logic/document_cubit/document_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class DocumentsListScreen extends StatefulWidget {
  const DocumentsListScreen({super.key});

  @override
  State<DocumentsListScreen> createState() => _DocumentsListScreenState();
}

class _DocumentsListScreenState extends State<DocumentsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  DocumentType? _selectedType;
  DocumentStatus? _selectedStatus;
  String _sortBy = 'createdAt';
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDocuments() {
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      if (user.role == UserRole.manager) {
        // Manager sees all documents from their team
        context.read<DocumentCubit>().loadDocumentsByManager(user.id);
      } else {
        // Lawyer sees only their own documents
        context.read<DocumentCubit>().loadDocuments(user.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
final user=context.read<AuthCubit>().currentUser;
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.documents),
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
              onPressed: _loadDocuments,
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchAndFilters(theme),
            Expanded(
              child: BlocBuilder<DocumentCubit, DocumentState>(
                builder: (context, state) {
                  if (state is DocumentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is DocumentError) {
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
                            AppLocalizations.of(context)!.errorLoadingDocuments,
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
                            onPressed: _loadDocuments,
                          ),
                        ],
                      ),
                    );
                  } else if (state is DocumentLoaded) {
                    final documents = _filterAndSortDocuments(state.documents);
                    
                    if (documents.isEmpty) {
                      return _buildEmptyState(theme);
                    }
      
                    return ResponsiveWidget(
                      mobile: _buildMobileView(theme, documents),
                      tablet: _buildTabletView(theme, documents),
                      desktop: _buildDesktopView(theme, documents),
                    );
                  }
                  
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
        floatingActionButton:user!.hasPermission('documentsWrite')? FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context,'/upload-document'),
          child: const Icon(Icons.upload),
        ):SizedBox.shrink(),
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
          ...DocumentStatus.values.map((status) => Padding(
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

  Widget _buildFilterChip(ThemeData theme, String label, DocumentStatus? status, bool isSelected) {
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
                        final user = context.read<AuthCubit>().currentUser;
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
            AppLocalizations.of(context)!.noDocumentsFound,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            AppLocalizations.of(context)!.startByUploadingFirstDocument,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
     user!.hasPermission('documentsWrite')?     PrimaryButton(
            text: AppLocalizations.of(context)!.uploadDocument,
            onPressed: () => Navigator.pushNamed(context,'/upload-document'),
          ):SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildMobileView(ThemeData theme, List<DocumentModel> documents) {
    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return _buildDocumentCard(theme, document);
      },
    );
  }

  Widget _buildTabletView(ThemeData theme, List<DocumentModel> documents) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
      child: DataTable(
        columns: [
          DataColumn(label: Text(AppLocalizations.of(context)!.clientName)),
          DataColumn(label: Text(AppLocalizations.of(context)!.documentType)),
          DataColumn(label: Text(AppLocalizations.of(context)!.status)),
          DataColumn(label: Text(AppLocalizations.of(context)!.documentSize)),
          DataColumn(label: Text(AppLocalizations.of(context)!.documentDate)),
          DataColumn(label: Text(AppLocalizations.of(context)!.actions)),
        ],
        rows: documents.map((document) => _buildDataTableRow(theme, document)).toList(),
      ),
    );
  }

  Widget _buildDesktopView(ThemeData theme, List<DocumentModel> documents) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: ResponsiveUtils.getResponsivePadding(context),
          columns: [
            DataColumn(label: Text(AppLocalizations.of(context)!.clientName)),
            DataColumn(label: Text(AppLocalizations.of(context)!.documentType)),
            DataColumn(label: Text(AppLocalizations.of(context)!.status)),
            DataColumn(label: Text(AppLocalizations.of(context)!.documentSize)),
            DataColumn(label: Text(AppLocalizations.of(context)!.documentDate)),
            DataColumn(label: Text('Case')),
            DataColumn(label: Text('Tags')),
            DataColumn(label: Text(AppLocalizations.of(context)!.actions)),
          ],
          rows: documents.map((document) => _buildDesktopDataTableRow(theme, document)).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataTableRow(ThemeData theme, DocumentModel document) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Icon(
                _getDocumentIcon(document),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  document.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(document.typeDisplayText)),
        DataCell(_buildStatusChip(theme, document.status)),
        DataCell(Text(document.fileSizeFormatted)),
        DataCell(Text(document.createdAtFormatted)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _downloadDocument(document),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editDocument(document),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteDocument(document),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildDesktopDataTableRow(ThemeData theme, DocumentModel document) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Icon(
                _getDocumentIcon(document),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  document.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(document.typeDisplayText)),
        DataCell(_buildStatusChip(theme, document.status)),
        DataCell(Text(document.fileSizeFormatted)),
        DataCell(Text(document.createdAtFormatted)),
        DataCell(Text(document.caseId ?? 'N/A')),
        DataCell(Text(document.tags.join(', '))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () => _viewDocument(document),
                tooltip: 'View',
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _downloadDocument(document),
                tooltip: 'Download',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editDocument(document),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteDocument(document),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(ThemeData theme, DocumentModel document) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: InkWell(
        onTap: () => _viewDocument(document),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getDocumentIcon(document),
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          document.typeDisplayText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(theme, document.status),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                document.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Row(
                children: [
                  Icon(
                    Icons.storage,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    document.fileSizeFormatted,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Icon(
                    Icons.download,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${document.downloadCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    document.createdAtFormatted,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Row(
                children: [
                  if (document.hasTags) ...[
                    Icon(
                      Icons.label,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${document.tagCount} tag${document.tagCount == 1 ? '' : 's'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                  ],
                  if (document.isExpired) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.expired,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else if (document.expiresSoon) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.expiresSoon,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => _downloadDocument(document),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editDocument(document),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteDocument(document),
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

  Widget _buildStatusChip(ThemeData theme, DocumentStatus status) {
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

  IconData _getDocumentIcon(DocumentModel document) {
    if (document.isImage) return Icons.image;
    if (document.isPdf) return Icons.picture_as_pdf;
    if (document.isDocument) return Icons.description;
    if (document.isText) return Icons.text_snippet;
    return Icons.insert_drive_file;
  }

  Color _getStatusColor(ThemeData theme, DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return AppColors.caseClosed;
      case DocumentStatus.pending:
        return AppColors.warning;
      case DocumentStatus.approved:
        return AppColors.success;
      case DocumentStatus.rejected:
        return AppColors.errorLight;
      case DocumentStatus.archived:
        return AppColors.info;
    }
  }

  List<DocumentModel> _filterAndSortDocuments(List<DocumentModel> documents) {
    var filteredDocuments = documents.where((document) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!document.name.toLowerCase().contains(query) &&
            !document.description.toLowerCase().contains(query) &&
            !document.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Filter by type
      if (_selectedType != null && document.type != _selectedType) {
        return false;
      }

      // Filter by status
      if (_selectedStatus != null && document.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();

    // Sort documents
    filteredDocuments.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'type':
          comparison = a.type.name.compareTo(b.type.name);
          break;
        case 'status':
          comparison = a.status.name.compareTo(b.status.name);
          break;
        case 'size':
          comparison = a.fileSize.compareTo(b.fileSize);
          break;
        case 'createdAt':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return _sortDescending ? -comparison : comparison;
    });

    return filteredDocuments;
  }

  void _viewDocument(DocumentModel document) {
    // TODO: Implement document viewer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View document: ${document.name}')),
    );
  }

  void _downloadDocument(DocumentModel document) {
    // TODO: Implement document download
    context.read<DocumentCubit>().incrementDownloadCount(document.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading: ${document.name}')),
    );
  }

  void _editDocument(DocumentModel document) {
    // TODO: Implement document edit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit document: ${document.name}')),
    );
  }

  void _deleteDocument(DocumentModel document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteDocument),
        content: Text(AppLocalizations.of(context)!.deleteDocumentConfirmation(document.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          BlocConsumer<DocumentCubit, DocumentState>(
            listener: (context, state) {
              if (state is DocumentDeleted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.documentDeletedSuccessfully)),
                );
              } else if (state is DocumentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              return TextButton(
                onPressed: state is DocumentLoading
                    ? null
                    : () {
                        final user = context.read<AuthCubit>().currentUser;
                        if (user != null) {
                          context.read<DocumentCubit>().deleteDocument(document.id, user.id);
                        }
                      },
                child: state is DocumentLoading
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
        title: Text(AppLocalizations.of(context)!.filterDocuments),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<DocumentType?>(
              value: _selectedType,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.documentType),
              items: [
                DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context)!.all)),
                ...DocumentType.values.map((type) => DropdownMenuItem(
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
            const SizedBox(height: AppConstants.defaultPadding),
            DropdownButtonFormField<DocumentStatus?>(
              value: _selectedStatus,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.status),
              items: [
                DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context)!.all)),
                ...DocumentStatus.values.map((status) => DropdownMenuItem(
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
        title: Text(AppLocalizations.of(context)!.sortDocuments),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.sortBy),
              items: [
                DropdownMenuItem(value: 'createdAt', child: Text(AppLocalizations.of(context)!.createdDate)),
                DropdownMenuItem(value: 'name', child: Text(AppLocalizations.of(context)!.documentName)),
                DropdownMenuItem(value: 'type', child: Text(AppLocalizations.of(context)!.documentType)),
                DropdownMenuItem(value: 'status', child: Text(AppLocalizations.of(context)!.status)),
                DropdownMenuItem(value: 'size', child: Text(AppLocalizations.of(context)!.documentSize)),
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
