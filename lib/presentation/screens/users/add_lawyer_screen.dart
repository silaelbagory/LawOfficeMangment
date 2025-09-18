import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lawofficemanagementsystem/core/utils/them_background.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/user_cubit/user_cubit.dart';
import '../../../logic/user_cubit/user_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AddLawyerScreen extends StatefulWidget {
  const AddLawyerScreen({super.key});

  @override
  State<AddLawyerScreen> createState() => _AddLawyerScreenState();
}

class _AddLawyerScreenState extends State<AddLawyerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserPermissions _permissions = const UserPermissions();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addLawyer),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveLawyer,
          ),
        ],
      ),
      body: BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.lawyerAddedSuccessfully),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
            Navigator.pushNamed(context,'/dashboard');
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBasicInfoSection(theme),
                  SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
                  _buildPermissionsSection(theme),
                  SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
                  _buildActionButtons(theme),
                ],
              ),
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
              hint: AppLocalizations.of(context)!.enterFullName,
              controller: _nameController,
              validator: Validators.validateName,
              isRequired: true,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.email,
              hint: AppLocalizations.of(context)!.enterEmail,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
              isRequired: true,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.password,
              hint: AppLocalizations.of(context)!.enterPassword,
              controller: _passwordController,
              type: TextFieldType.password,
              validator: Validators.validatePassword,
              isRequired: true,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            CustomTextField(
              label: AppLocalizations.of(context)!.confirmPassword,
              hint: AppLocalizations.of(context)!.enterConfirmPassword,
              controller: _confirmPasswordController,
              type: TextFieldType.password,
              validator: (value) => Validators.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
              isRequired: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.permissions,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _buildActionButtons(ThemeData theme) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: OutlineButton(
                text: AppLocalizations.of(context)!.cancel,
                onPressed: state is UserLoading ? null : () => Navigator.pushNamed(context,'/users'),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: PrimaryButton(
                text: AppLocalizations.of(context)!.addLawyer,
                onPressed: state is UserLoading ? null : _saveLawyer,
                isLoading: state is UserLoading,
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveLawyer() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<UserCubit>().addLawyer(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        permissions: _permissions,
      );
    }
  }
}
