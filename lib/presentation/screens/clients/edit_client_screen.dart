import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/case_model.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/lawyer_action_model.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/action_cubit/action_cubit.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/case_cubit/case_cubit.dart';
import '../../../logic/case_cubit/case_state.dart';
import '../../../logic/client_cubit/client_cubit.dart';
import '../../../logic/client_cubit/client_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../cases/edit_case_screen.dart';

class EditClientScreen extends StatefulWidget {
  final ClientModel clientModel;

  const EditClientScreen({super.key, required this.clientModel});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();

  ClientType _selectedType = ClientType.individual;
  ClientStatus _selectedStatus = ClientStatus.active;
  DateTime? _dateOfBirth;
  String? _gender;
  String? _occupation;
  String? _emergencyContact;
  String? _emergencyPhone;
  bool _isVip = false;
  List<CaseModel> _cases = [];

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadCases();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _companyNameController.dispose();
    _contactPersonController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    _nameController.text = widget.clientModel.name;
    _emailController.text = widget.clientModel.email;
    _phoneController.text = widget.clientModel.phoneNumber ?? '';
    _addressController.text = widget.clientModel.address ?? '';
    _cityController.text = widget.clientModel.city ?? '';
    _stateController.text = widget.clientModel.state ?? '';
    _zipCodeController.text = widget.clientModel.zipCode ?? '';
    _countryController.text = widget.clientModel.country ?? '';
    _companyNameController.text = widget.clientModel.companyName ?? '';
    _contactPersonController.text = widget.clientModel.contactPerson ?? '';
    _websiteController.text = widget.clientModel.website ?? '';
    _notesController.text = widget.clientModel.notes ?? '';
    
    _selectedType = widget.clientModel.type;
    _selectedStatus = widget.clientModel.status;
    _dateOfBirth = widget.clientModel.dateOfBirth;
    _gender = widget.clientModel.gender;
    _occupation = widget.clientModel.occupation;
    _emergencyContact = widget.clientModel.emergencyContact;
    _emergencyPhone = widget.clientModel.emergencyPhone;
    _isVip = widget.clientModel.isVip;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
            backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: Text('Edit Client: ${widget.clientModel.displayName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateClient,
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ClientCubit, ClientState>(
            listener: (context, state) {
              if (state is ClientUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Client updated successfully')),
                );
                if (!mounted) return;
                Navigator.of(context).pop();
              } else if (state is ClientError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
          ),
          BlocListener<CaseCubit, CaseState>(
            listener: (context, state) {
              if (state is CaseLoaded) {
                setState(() {
                  _cases = state.cases;
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
                _buildContactInfoSection(theme),
                const SizedBox(height: AppConstants.largePadding),
                _buildAdditionalInfoSection(theme),
                const SizedBox(height: AppConstants.largePadding),
                _buildCasesSection(theme),
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
              label: 'Name',
              hint: 'Enter client name',
              controller: _nameController,
              validator: Validators.validateName,
              isRequired: true,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: 'Email',
              hint: 'Enter email address',
              controller: _emailController,
              validator: Validators.validateEmail,
              isRequired: true,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ClientType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Client Type',
                      border: OutlineInputBorder(),
                    ),
                    items: ClientType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayText),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value ?? ClientType.individual;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: DropdownButtonFormField<ClientStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ClientStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.displayText),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value ?? ClientStatus.active;
                      });
                    },
                  ),
                ),
              ],
            ),
            if (_selectedType == ClientType.company) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              CustomTextField(
                label: 'Company Name',
                hint: 'Enter company name',
                controller: _companyNameController,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              CustomTextField(
                label: 'Contact Person',
                hint: 'Enter contact person name',
                controller: _contactPersonController,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: 'Phone Number',
              hint: 'Enter phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: 'Address',
              hint: 'Enter address',
              controller: _addressController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'City',
                    hint: 'Enter city',
                    controller: _cityController,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: CustomTextField(
                    label: 'State',
                    hint: 'Enter state',
                    controller: _stateController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'ZIP Code',
                    hint: 'Enter ZIP code',
                    controller: _zipCodeController,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: CustomTextField(
                    label: 'Country',
                    hint: 'Enter country',
                    controller: _countryController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: 'Website',
              hint: 'Enter website URL',
              controller: _websiteController,
              keyboardType: TextInputType.url,
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
            if (_selectedType == ClientType.individual) ...[
              InkWell(
                onTap: () => _selectDateOfBirth(),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dateOfBirth != null
                        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                        : 'Select date of birth',
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Select gender')),
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: CustomTextField(
                      label: 'Occupation',
                      hint: 'Enter occupation',
                      controller: TextEditingController(text: _occupation ?? ''),
                      onChanged: (value) => _occupation = value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
            ],
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Emergency Contact',
                    hint: 'Enter emergency contact name',
                    controller: TextEditingController(text: _emergencyContact ?? ''),
                    onChanged: (value) => _emergencyContact = value,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: CustomTextField(
                    label: 'Emergency Phone',
                    hint: 'Enter emergency phone',
                    controller: TextEditingController(text: _emergencyPhone ?? ''),
                    onChanged: (value) => _emergencyPhone = value,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            SwitchListTile(
              title: const Text('VIP Client'),
              subtitle: const Text('Mark this client as VIP'),
              value: _isVip,
              onChanged: (value) {
                setState(() {
                  _isVip = value;
                });
              },
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

  Widget _buildCasesSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Cases',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => Navigator.pushNamed(context, '/add-case'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            if (_cases.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.largePadding),
                  child: Text('No cases associated with this client'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cases.length,
                itemBuilder: (context, index) {
                  final caseModel = _cases[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(theme, caseModel.status),
                      child: Text(
                        caseModel.title[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(caseModel.title),
                    subtitle: Text('${caseModel.status.displayText} • ${caseModel.priority.displayText}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editCase(caseModel),
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
    return BlocBuilder<ClientCubit, ClientState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: OutlineButton(
                text: 'Cancel',
                onPressed: state is ClientLoading ? null : () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: PrimaryButton(
                text: 'Update Client',
                onPressed: state is ClientLoading ? null : _updateClient,
                isLoading: state is ClientLoading,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _updateClient() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = context.read<AuthCubit>().currentUser;
      if (user != null) {
        final updatedClient = widget.clientModel.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
          city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
          state: _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : null,
          zipCode: _zipCodeController.text.trim().isNotEmpty ? _zipCodeController.text.trim() : null,
          country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : null,
          type: _selectedType,
          status: _selectedStatus,
          companyName: _companyNameController.text.trim().isNotEmpty ? _companyNameController.text.trim() : null,
          contactPerson: _contactPersonController.text.trim().isNotEmpty ? _contactPersonController.text.trim() : null,
          website: _websiteController.text.trim().isNotEmpty ? _websiteController.text.trim() : null,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
          dateOfBirth: _dateOfBirth,
          gender: _gender,
          occupation: _occupation,
          emergencyContact: _emergencyContact,
          emergencyPhone: _emergencyPhone,
          isVip: _isVip,
          updatedAt: DateTime.now(),
        );

        try {
          await context.read<ClientCubit>().updateClient(widget.clientModel.id, updatedClient);
          
          if (!mounted) return;
          
          // Log the action
          await context.read<ActionCubit>().logAction(
            LawyerActionModel(
              id: '',
              lawyerId: user.id,
              lawyerName: user.name,
              managerId: user.role == UserRole.manager ? user.id : user.createdBy ?? user.id,
              action: 'Updated client: ${updatedClient.displayName}',
              timestamp: DateTime.now(),
              metadata: {
                'clientId': updatedClient.id,
                'clientName': updatedClient.displayName,
                'actionType': 'client_update',
              },
            ),
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

  void _editCase(CaseModel caseModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCaseScreen(caseModel: caseModel),
      ),
    );
  }

  Color _getStatusColor(ThemeData theme, CaseStatus status) {
    switch (status) {
      case CaseStatus.open:
        return Colors.blue;
      case CaseStatus.inProgress:
        return Colors.orange;
      case CaseStatus.onHold:
        return Colors.yellow;
      case CaseStatus.closed:
        return Colors.green;
    }
  }

  void _loadCases() {
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      context.read<CaseCubit>().loadCasesByClient(user.id, widget.clientModel.id);
    }
  }
}
