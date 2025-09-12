import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/action_cubit/action_cubit.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/client_cubit/client_cubit.dart';
import '../../../logic/client_cubit/client_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
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
  final _taxIdController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _occupationController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  ClientType _selectedType = ClientType.individual;
  ClientStatus _selectedStatus = ClientStatus.active;
  DateTime? _dateOfBirth;
  String? _selectedGender;
  String? _selectedPreferredLanguage;
  String? _selectedTimeZone;
  String? _selectedPaymentTerms;
  bool _isVip = false;
  double? _creditLimit;

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
    _taxIdController.dispose();
    _registrationNumberController.dispose();
    _occupationController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);



    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addClient),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveClient,
          ),
        ],
      ),
      body: BlocListener<ClientCubit, ClientState>(
        listener: (context, state) {
          if (state is ClientCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.clientCreated)),
            );
           Navigator.pushNamed(context,'/clients');
          } else if (state is ClientError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
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
                _buildAddressSection(theme),
                const SizedBox(height: AppConstants.largePadding),
                _buildCompanyInfoSection(theme),
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
              label: AppLocalizations.of(context)!.fullName,
              hint: AppLocalizations.of(context)!.enterClientFullName,
              controller: _nameController,
              validator: Validators.validateName,
              isRequired: true,
              prefixIcon: const Icon(Icons.person),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            EmailTextField(
              controller: _emailController,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            PhoneTextField(
              controller: _phoneController,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ClientType>(
                    value: _selectedType,
                    decoration:  InputDecoration(
                      labelText: AppLocalizations.of(context)!.clientType,
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
                    decoration:  InputDecoration(
                      labelText: AppLocalizations.of(context)!.status,
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
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDateOfBirth(),
                    child: InputDecorator(
                      decoration:  InputDecoration(
                        labelText: AppLocalizations.of(context)!.dateOfBirth,
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dateOfBirth != null
                            ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                            : AppLocalizations.of(context)!.selectDateOfBirth,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration:  InputDecoration(
                      labelText: AppLocalizations.of(context)!.gender,
                      border: OutlineInputBorder(),
                    ),
                    items:  [
                      DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context)!.selectGender)),
                      DropdownMenuItem(value: 'Male', child: Text(AppLocalizations.of(context)!.male)),
                      DropdownMenuItem(value: 'Female', child: Text(AppLocalizations.of(context)!.female)),
                      DropdownMenuItem(value: 'Other', child: Text(AppLocalizations.of(context)!.other)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.occupation,
              hint: AppLocalizations.of(context)!.enterOccupation,
              controller: _occupationController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.vipClient),
              subtitle: Text(AppLocalizations.of(context)!.markAsVipClient),
              value: _isVip,
              onChanged: (value) {
                setState(() {
                  _isVip = value;
                });
              },
            ),
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
              AppLocalizations.of(context)!.contactInformation,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.emergencyContact,
              hint: AppLocalizations.of(context)!.enterEmergencyContact,
              controller: _emergencyContactController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            PhoneTextField(
              label: AppLocalizations.of(context)!.emergencyPhone,
              hint: AppLocalizations.of(context)!.enterEmergencyPhone,
              controller: _emergencyPhoneController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPreferredLanguage,
                    decoration:  InputDecoration(
                      labelText: AppLocalizations.of(context)!.preferredLanguage,
                      border: OutlineInputBorder(),
                    ),
                    items:  [
                      DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context)!.selectLanguage)),
                      DropdownMenuItem(value: 'en', child: Text(AppLocalizations.of(context)!.english)),
                      DropdownMenuItem(value: 'ar', child: Text(AppLocalizations.of(context)!.arabic)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPreferredLanguage = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTimeZone,
                    decoration:  InputDecoration(
                      labelText: AppLocalizations.of(context)!.timeZone,
                      border: OutlineInputBorder(),
                    ),
                    items:  [
                      DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context)!.selectTimezone)),
                      DropdownMenuItem(value: 'UTC', child: Text(AppLocalizations.of(context)!.utc)),
                      DropdownMenuItem(value: 'EST', child: Text(AppLocalizations.of(context)!.easternTime)),
                      DropdownMenuItem(value: 'PST', child: Text(AppLocalizations.of(context)!.pacificTime)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTimeZone = value;
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

  Widget _buildAddressSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.addressInformation,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.address,
              hint: AppLocalizations.of(context)!.enterStreetAddress,
              controller: _addressController,
              validator: (value) => Validators.validateAddress(value),
              isRequired: true,
              prefixIcon: const Icon(Icons.location_on),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: AppLocalizations.of(context)!.city,
                    hint: AppLocalizations.of(context)!.enterCity,
                    controller: _cityController,
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: CustomTextField(
                    label: AppLocalizations.of(context)!.state,
                    hint: AppLocalizations.of(context)!.enterState,
                    controller: _stateController,
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: AppLocalizations.of(context)!.zipCode,
                    hint: AppLocalizations.of(context)!.enterZipCode,
                    controller: _zipCodeController,
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: CustomTextField(
                    label: AppLocalizations.of(context)!.country,
                    hint: AppLocalizations.of(context)!.enterCountry,
                    controller: _countryController,
                    isRequired: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfoSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.companyInformation,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.companyName,
              hint: AppLocalizations.of(context)!.enterCompanyName,
              controller: _companyNameController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.contactPerson,
              hint: AppLocalizations.of(context)!.enterContactPerson,
              controller: _contactPersonController,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.website,
              hint: AppLocalizations.of(context)!.enterWebsiteUrl,
              controller: _websiteController,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return Validators.validateUrl(value);
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: AppLocalizations.of(context)!.taxId,
                    hint: AppLocalizations.of(context)!.enterTaxId,
                    controller: _taxIdController,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: CustomTextField(
                    label: AppLocalizations.of(context)!.registrationNumber,
                    hint: AppLocalizations.of(context)!.enterRegistrationNumber,
                    controller: _registrationNumberController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: AppLocalizations.of(context)!.creditLimit,
                    hint: AppLocalizations.of(context)!.enterCreditLimit,
                    controller: TextEditingController(
                      text: _creditLimit?.toString() ?? '',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (value) {
                      _creditLimit = double.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPaymentTerms,
                    decoration:  InputDecoration(
                      labelText: AppLocalizations.of(context)!.paymentTerms,
                      border: OutlineInputBorder(),
                    ),
                    items:  [
                      DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context)!.selectTerms)),
                      DropdownMenuItem(value: 'Net 30', child: Text(AppLocalizations.of(context)!.net30)),
                      DropdownMenuItem(value: 'Net 60', child: Text(AppLocalizations.of(context)!.net60)),
                      DropdownMenuItem(value: 'Due on Receipt', child: Text(AppLocalizations.of(context)!.dueOnReceipt)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentTerms = value;
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
    return BlocBuilder<ClientCubit, ClientState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: OutlineButton(
                text: AppLocalizations.of(context)!.cancel,
                onPressed: state is ClientLoading ? null : () =>Navigator.pushNamed(context,'/clients'),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: PrimaryButton(
                text: AppLocalizations.of(context)!.saveClient,
                onPressed: state is ClientLoading ? null : _saveClient,
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
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _saveClient() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = context.read<AuthCubit>().currentUser;
      if (user != null) {
        final clientModel = ClientModel(
          id: '', // Will be set by Firestore
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
          userId: user.id,
          managerId: user.role == UserRole.manager ? user.id : user.createdBy ?? user.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          companyName: _companyNameController.text.trim().isNotEmpty ? _companyNameController.text.trim() : null,
          contactPerson: _contactPersonController.text.trim().isNotEmpty ? _contactPersonController.text.trim() : null,
          website: _websiteController.text.trim().isNotEmpty ? _websiteController.text.trim() : null,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
          taxId: _taxIdController.text.trim().isNotEmpty ? _taxIdController.text.trim() : null,
          registrationNumber: _registrationNumberController.text.trim().isNotEmpty ? _registrationNumberController.text.trim() : null,
          dateOfBirth: _dateOfBirth,
          gender: _selectedGender,
          occupation: _occupationController.text.trim().isNotEmpty ? _occupationController.text.trim() : null,
          emergencyContact: _emergencyContactController.text.trim().isNotEmpty ? _emergencyContactController.text.trim() : null,
          emergencyPhone: _emergencyPhoneController.text.trim().isNotEmpty ? _emergencyPhoneController.text.trim() : null,
          preferredLanguage: _selectedPreferredLanguage,
          timeZone: _selectedTimeZone,
          isVip: _isVip,
          creditLimit: _creditLimit,
          paymentTerms: _selectedPaymentTerms,
        );

        try {
          // Create the client
          await context.read<ClientCubit>().createClient(clientModel);
          
          // Check if widget is still mounted before accessing context
          if (!mounted) return;
          
          // Log the action
          await context.read<ActionCubit>().logClientCreation(
            lawyerId: user.id,
            lawyerName: user.name,
            managerId: user.role == UserRole.manager ? user.id : user.createdBy ?? user.id,
            clientName: clientModel.name,
            clientId: clientModel.id,
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
}
