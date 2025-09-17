import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/auth_cubit/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  bool _acceptTerms = false;


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(context,'/dashboard', (route) => false);
          } else if (state is AuthAccountCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Account created successfully! Your account is pending approval. You will be notified once approved.'),
                backgroundColor: theme.colorScheme.primary,
                duration: Duration(seconds: 5),
              ),
            );
            // Navigate back to login after showing success message
            Future.delayed(Duration(seconds: 2), () {
              if(mounted){
                  Navigator.pushNamedAndRemoveUntil(context,'/login', (route) => false);
              }
           
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: ResponsiveContainer(
              maxWidth: ResponsiveUtils.getFormFieldWidth(context),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(theme),
                    SizedBox(height: ResponsiveUtils.getResponsivePadding(context) * 2),
                    _buildRegisterForm(theme),
                    SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
                    _buildFooter(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.person_add,
            size: 40,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.largePadding),
        Text(
          AppLocalizations.of(context)!.register,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          AppLocalizations.of(context)!.createAccountToGetStarted,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: AppLocalizations.of(context)!.fullName,
            hint: AppLocalizations.of(context)!.enterFullName,
            controller: _nameController,
            validator: Validators.validateName,
            enabled: !context.read<AuthCubit>().isLoading,
            prefixIcon: const Icon(Icons.person),
            isRequired: true,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          EmailTextField(
            controller: _emailController,
            validator: Validators.validateEmail,
            enabled: !context.read<AuthCubit>().isLoading,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          PhoneTextField(
            controller: _phoneController,
            validator: Validators.validatePhone,
            enabled: !context.read<AuthCubit>().isLoading,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Address',
            hint: 'Enter your address',
            controller: _addressController,
            validator: (value) => Validators.validateAddress(value),
            enabled: !context.read<AuthCubit>().isLoading,
            prefixIcon: const Icon(Icons.location_on),
            isRequired: true,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          PasswordTextField(
            controller: _passwordController,
            validator: Validators.validatePassword,
            enabled: !context.read<AuthCubit>().isLoading,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          CustomTextField(
            label: 'Confirm Password',
            hint: 'Confirm your password',
            controller: _confirmPasswordController,
            validator: (value) => Validators.validateConfirmPassword(
              value,
              _passwordController.text,
            ),
            enabled: !context.read<AuthCubit>().isLoading,
            prefixIcon: const Icon(Icons.lock),
            obscureText: true,
            isRequired: true,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildTermsAndConditions(theme),
          const SizedBox(height: AppConstants.largePadding),
          _buildRegisterButton(theme),
          const SizedBox(height: AppConstants.defaultPadding),
        //  _buildGoogleSignInButton(theme),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions(ThemeData theme) {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(ThemeData theme) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return PrimaryButton(
          text: AppLocalizations.of(context)!.register,
          onPressed: state is AuthLoading ? null : _handleRegister,
          isLoading: state is AuthLoading,
          size: ButtonSize.large,
          width: double.infinity,
        );
      },
    );
  }


  Widget _buildFooter(ThemeData theme) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.alreadyHaveAccount,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextButton(
          onPressed: () => Navigator.pushNamed(context,'/login'),
          child: Text(
            AppLocalizations.of(context)!.login,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please accept the terms and conditions'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      context.read<AuthCubit>().createUserAccount(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

}
