import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/case_model.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/action_cubit/action_cubit.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/case_cubit/case_cubit.dart';
import '../../../logic/case_cubit/case_state.dart';
import '../../../logic/client_cubit/client_cubit.dart';
import '../../../logic/client_cubit/client_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
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

  @override
  void initState() {
    super.initState();
    _loadClients();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);



    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addCase),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCase,
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CaseCubit, CaseState>(
            listener: (context, state) {
              if (state is CaseCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.caseCreated)),
                );
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil('/cases', (route) => route.settings.name == '/dashboard' || route.isFirst);
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
          BlocListener<ClientCubit, dynamic>(
            listener: (context, state) {
              if (state is ClientLoaded) {
                setState(() {
                  _clients = state.clients;
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
              AppLocalizations.of(context)!.basicInformation,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.caseTitle,
              hint: AppLocalizations.of(context)!.enterCaseTitle,
              controller: _titleController,
              validator: Validators.validateCaseTitle,
              isRequired: true,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            MultilineTextField(
              label: AppLocalizations.of(context)!.caseDescription,
              hint: AppLocalizations.of(context)!.enterCaseDescription,
              controller: _descriptionController,
              validator: Validators.validateCaseDescription,
              isRequired: true,
              maxLines: 4,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            DropdownButtonFormField<String?>(
              value: _selectedClientId,
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
                    decoration:  InputDecoration(
                      labelText: AppLocalizations.of(context)!.caseStatus,
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
                    decoration:  InputDecoration(
                      labelText: AppLocalizations.of(context)!.casePriority,
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
              AppLocalizations.of(context)!.caseDetails,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.caseNumber,
              hint: AppLocalizations.of(context)!.enterCaseNumber,
              controller: _caseNumberController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.courtName,
              hint: AppLocalizations.of(context)!.enterCourtName,
              controller: _courtNameController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.caseType,
              hint: AppLocalizations.of(context)!.enterCaseType,
              controller: _caseTypeController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration:  InputDecoration(
                        labelText: AppLocalizations.of(context)!.dueDate,
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dueDate != null
                            ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                            : AppLocalizations.of(context)!.selectDueDate,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration:  InputDecoration(
                        labelText: AppLocalizations.of(context)!.hearingDate,
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _hearingDate != null
                            ? '${_hearingDate!.day}/${_hearingDate!.month}/${_hearingDate!.year}'
                            : AppLocalizations.of(context)!.selectHearingDate,
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
              AppLocalizations.of(context)!.legalDetails,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.opposingParty,
              hint: AppLocalizations.of(context)!.enterOpposingParty,
              controller: _opposingPartyController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.opposingCounsel,
              hint: AppLocalizations.of(context)!.enterOpposingCounsel,
              controller: _opposingCounselController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.estimatedHours,
              hint: AppLocalizations.of(context)!.enterEstimatedHours,
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
              AppLocalizations.of(context)!.additionalInformation,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            MultilineTextField(
              label: AppLocalizations.of(context)!.enterAdditionalNotes,
              hint: AppLocalizations.of(context)!.enterAdditionalNotes,
              controller: _notesController,
              maxLines: 3,
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
                text: AppLocalizations.of(context)!.cancel,
                onPressed: state is CaseLoading
                    ? null
                    : () {
                        if (!mounted) return;
                        Navigator.of(context).popUntil((route) => route.settings.name == '/cases' || route.isFirst);
                      },
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: PrimaryButton(
                text: AppLocalizations.of(context)!.saveCase,
                onPressed: state is CaseLoading ? null : _saveCase,
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

  void _saveCase() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = context.read<AuthCubit>().currentUser;
      if (user != null) {
        final caseModel = CaseModel(
          id: '', // Will be set by Firestore
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          userId: user.id,
          managerId: user.role == UserRole.manager ? user.id : user.createdBy ?? user.id,
          clientId: _selectedClientId,
          status: _selectedStatus,
          priority: _selectedPriority,
          createdAt: DateTime.now(),
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
          // Create the case
          await context.read<CaseCubit>().createCase(caseModel);
          
          // Check if widget is still mounted before accessing context
          if (!mounted) return;
          
          // Log the action
          await context.read<ActionCubit>().logCaseCreation(
            lawyerId: user.id,
            lawyerName: user.name,
            managerId: user.role == UserRole.manager ? user.id : user.createdBy ?? user.id,
            caseTitle: caseModel.title,
            caseId: caseModel.id,
          );
        } catch (e) {
          // Handle any errors gracefully
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      }
    }
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
}
