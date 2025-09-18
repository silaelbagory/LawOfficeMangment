import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/case_model.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/document_model.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/action_cubit/action_cubit.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/case_cubit/case_cubit.dart';
import '../../../logic/case_cubit/case_state.dart';
import '../../../logic/client_cubit/client_cubit.dart';
import '../../../logic/client_cubit/client_state.dart';
import '../../../logic/document_cubit/document_cubit.dart';
import '../../../logic/document_cubit/document_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditCaseScreen extends StatefulWidget {
  final CaseModel caseModel;

  const EditCaseScreen({super.key, required this.caseModel});

  @override
  State<EditCaseScreen> createState() => _EditCaseScreenState();
}

class _EditCaseScreenState extends State<EditCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _courtNameController = TextEditingController();
  final _caseTypeController = TextEditingController();
  final _opposingPartyController = TextEditingController();
  final _opposingCounselController = TextEditingController();
  final _estimatedHoursController = TextEditingController();

  CaseStatus _selectedStatus = CaseStatus.open;
  CasePriority _selectedPriority = CasePriority.medium;
  DateTime? _dueDate;
  DateTime? _hearingDate;
  String? _selectedClientId;
  List<ClientModel> _clients = [];
  List<DocumentModel> _documents = [];

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadClients();
    _loadDocuments();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _caseNumberController.dispose();
    _courtNameController.dispose();
    _caseTypeController.dispose();
    _opposingPartyController.dispose();
    _opposingCounselController.dispose();
    _estimatedHoursController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    _titleController.text = widget.caseModel.title;
    _descriptionController.text = widget.caseModel.description;
    _notesController.text = widget.caseModel.notes ?? '';
    _caseNumberController.text = widget.caseModel.caseNumber ?? '';
    _courtNameController.text = widget.caseModel.courtName ?? '';
    _caseTypeController.text = widget.caseModel.caseType ?? '';
    _opposingPartyController.text = widget.caseModel.opposingParty ?? '';
    _opposingCounselController.text = widget.caseModel.opposingCounsel ?? '';
    _estimatedHoursController.text = widget.caseModel.estimatedHours?.toString() ?? '';
    
    _selectedStatus = widget.caseModel.status;
    _selectedPriority = widget.caseModel.priority;
    _dueDate = widget.caseModel.dueDate;
    _hearingDate = widget.caseModel.hearingDate;
    _selectedClientId = widget.caseModel.clientId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
            backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: Text('Edit Case: ${widget.caseModel.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateCase,
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CaseCubit, CaseState>(
            listener: (context, state) {
              if (state is CaseUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Case updated successfully')),
                );
                if (!mounted) return;
                Navigator.of(context).pop();
              } else if (state is CaseError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
          ),
          BlocListener<ClientCubit, ClientState>(
            listener: (context, state) {
              if (state is ClientLoaded) {
                setState(() {
                  _clients = state.clients;
                });
              }
            },
          ),
          BlocListener<DocumentCubit, DocumentState>(
            listener: (context, state) {
              if (state is DocumentLoaded) {
                setState(() {
                  _documents = state.documents;
                });
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBasicInfoSection(theme),
                const SizedBox(height: AppConstants.largePadding),
                _buildCaseDetailsSection(theme),
                const SizedBox(height: AppConstants.largePadding),
                _buildLegalDetailsSection(theme),
                const SizedBox(height: AppConstants.largePadding),
                _buildAdditionalInfoSection(theme),
                const SizedBox(height: AppConstants.largePadding),
                _buildDocumentsSection(theme),
                const SizedBox(height: AppConstants.largePadding),
                _buildActionButtons(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
Widget _buildBasicInfoSection(ThemeData theme) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Case Title',
            hint: 'Enter case title',
            controller: _titleController,
            validator: Validators.validateCaseTitle,
            isRequired: true,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          MultilineTextField(
            label: 'Case Description',
            hint: 'Enter case description',
            controller: _descriptionController,
            validator: Validators.validateCaseDescription,
            isRequired: true,
            maxLines: 4,
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          /// ✅ هنا التعديل
          DropdownButtonFormField<String?>(
            value: (_selectedClientId != null &&
                    _clients.any((c) => c.id == _selectedClientId))
                ? _selectedClientId
                : null,
            decoration: const InputDecoration(
              labelText: 'Client',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Select a client (optional)'),
              ),
              ..._clients.map((client) => DropdownMenuItem<String?>(
                    value: client.id,
                    child: Text(client.displayName),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedClientId = value;
              });
            },
          ),

          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<CaseStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Case Status',
                    border: OutlineInputBorder(),
                  ),
                  items: CaseStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayText),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value ?? CaseStatus.open;
                    });
                  },
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: DropdownButtonFormField<CasePriority>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Case Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: CasePriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.displayText),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value ?? CasePriority.medium;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


  Widget _buildCaseDetailsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Case Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: 'Case Number',
              hint: 'Enter case number',
              controller: _caseNumberController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: 'Court Name',
              hint: 'Enter court name',
              controller: _courtNameController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: 'Case Type',
              hint: 'Enter case type',
              controller: _caseTypeController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dueDate != null
                            ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                            : 'Select due date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hearing Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _hearingDate != null
                            ? '${_hearingDate!.day}/${_hearingDate!.month}/${_hearingDate!.year}'
                            : 'Select hearing date',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalDetailsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legal Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: 'Opposing Party',
              hint: 'Enter opposing party',
              controller: _opposingPartyController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: 'Opposing Counsel',
              hint: 'Enter opposing counsel',
              controller: _opposingCounselController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: 'Estimated Hours',
              hint: 'Enter estimated hours',
              controller: _estimatedHoursController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            MultilineTextField(
              label: 'Notes',
              hint: 'Enter additional notes',
              controller: _notesController,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Documents',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => Navigator.pushNamed(context, '/upload-document'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            if (_documents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.largePadding),
                  child: Text('No documents attached to this case'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _documents.length,
                itemBuilder: (context, index) {
                  final document = _documents[index];
                  return ListTile(
                    leading: Icon(_getDocumentIcon(document)),
                    title: Text(document.name),
                    subtitle: Text('${document.fileSizeFormatted} • ${document.typeDisplayText}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeDocument(document),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return BlocBuilder<CaseCubit, CaseState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: OutlineButton(
                text: 'Cancel',
                onPressed: state is CaseLoading ? null : () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: PrimaryButton(
                text: 'Update Case',
                onPressed: state is CaseLoading ? null : _updateCase,
                isLoading: state is CaseLoading,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isDueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? (_dueDate ?? DateTime.now()) : (_hearingDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _hearingDate = picked;
        }
      });
    }
  }

  void _updateCase() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = context.read<AuthCubit>().currentUser;
      if (user != null) {
        final updatedCase = widget.caseModel.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          clientId: _selectedClientId,
          status: _selectedStatus,
          priority: _selectedPriority,
          updatedAt: DateTime.now(),
          dueDate: _dueDate,
          hearingDate: _hearingDate,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
          estimatedHours: _estimatedHoursController.text.isNotEmpty
              ? double.tryParse(_estimatedHoursController.text)
              : null,
          caseNumber: _caseNumberController.text.trim().isNotEmpty
              ? _caseNumberController.text.trim()
              : null,
          courtName: _courtNameController.text.trim().isNotEmpty
              ? _courtNameController.text.trim()
              : null,
          caseType: _caseTypeController.text.trim().isNotEmpty
              ? _caseTypeController.text.trim()
              : null,
          opposingParty: _opposingPartyController.text.trim().isNotEmpty
              ? _opposingPartyController.text.trim()
              : null,
          opposingCounsel: _opposingCounselController.text.trim().isNotEmpty
              ? _opposingCounselController.text.trim()
              : null,
        );

        try {
          await context.read<CaseCubit>().updateCase(widget.caseModel.id, updatedCase);
          
          if (!mounted) return;
          
          await context.read<ActionCubit>().logCaseUpdate(
            lawyerId: user.id,
            lawyerName: user.name,
            managerId: user.role == UserRole.manager ? user.id : user.createdBy ?? user.id,
            caseTitle: updatedCase.title,
            caseId: updatedCase.id,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      }
    }
  }

  void _removeDocument(DocumentModel document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Document'),
        content: Text('Are you sure you want to remove "${document.name}" from this case?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement document removal from case
            },
            child: const Text('Remove'),
          ),
        ],
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

  void _loadClients() {
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      if (user.role == UserRole.manager) {
        context.read<ClientCubit>().loadClientsByManager(user.id);
      } else {
        context.read<ClientCubit>().loadClients(user.id);
      }
    }
  }

  void _loadDocuments() {
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      context.read<DocumentCubit>().loadDocumentsByCase(user.id, widget.caseModel.id);
    }
  }
}
