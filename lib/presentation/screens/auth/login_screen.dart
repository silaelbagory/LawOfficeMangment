import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lawofficemanagementsystem/core/utils/them_background.dart';
import 'package:lawofficemanagementsystem/presentation/widgets/custom_button.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/auth_cubit/auth_state.dart';
import '../../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(context,'/dashboard', (route) => false);
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
                    _buildLoginForm(theme),
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
          width: ResponsiveUtils.getResponsiveValue(
            context,
            mobile: 80.0,
            tablet: 100.0,
            desktop: 120.0,
          ),
          height: ResponsiveUtils.getResponsiveValue(
            context,
            mobile: 80.0,
            tablet: 100.0,
            desktop: 120.0,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.login,
            size: ResponsiveUtils.getResponsiveValue(
              context,
              mobile: 40.0,
              tablet: 50.0,
              desktop: 60.0,
            ),
            color: theme.colorScheme.onPrimary,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
        Text(
           AppLocalizations.of(context)!.login,
          style: theme.textTheme.headlineMedium?.copyWith(
            
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 24.0,
              tablet: 28.0,
              desktop: 32.0,
            ),
          ),
        ),
        SizedBox(height: AppConstants.smallPadding),
        Text(
          AppLocalizations.of(context)!.welcomeBackTo(AppLocalizations.of(context)!.appTitle),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 14.0,
              tablet: 16.0,
              desktop: 18.0,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmailTextField(
            controller: _emailController,
            validator: Validators.validateEmail,
            enabled: !context.read<AuthCubit>().isLoading,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          PasswordTextField(
            controller: _passwordController,
            validator: Validators.validatePassword,
            enabled: !context.read<AuthCubit>().isLoading,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildRememberMeAndForgotPassword(theme),
          const SizedBox(height: AppConstants.largePadding),
          _buildLoginButton(theme),
          const SizedBox(height: AppConstants.defaultPadding),
     //     _buildGoogleSignInButton(theme),
        ],
      ),
    );
  }

  Widget _buildRememberMeAndForgotPassword(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
            Text(
              AppLocalizations.of(context)!.rememberMe,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        TextButton(
          onPressed: () => _showForgotPasswordDialog(),
          child: Text(
            AppLocalizations.of(context)!.forgotPassword,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(ThemeData theme) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return PrimaryButton(
          text: AppLocalizations.of(context)!.login,
          onPressed: state is AuthLoading ? null : _handleLogin,
          isLoading: state is AuthLoading,
          size: ButtonSize.large,
          width: double.infinity,
        );
      },
    );
  }

  Widget _buildGoogleSignInButton(ThemeData theme) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return OutlineButton(
          text: AppLocalizations.of(context)!.signInWithGoogle,
       //   icon: Icons.login,
          onPressed: state is AuthLoading ? null : _handleGoogleSignIn,
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
          AppLocalizations.of(context)!.dontHaveAccount,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextButton(
          onPressed: () => Navigator.pushNamed(context,'/register'),
          child: Text(
            AppLocalizations.of(context)!.register,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _handleGoogleSignIn() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.resetPassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.enterEmailForReset),
            const SizedBox(height: AppConstants.defaultPadding),
            EmailTextField(
              controller: emailController,
              validator: Validators.validateEmail,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthPasswordResetSent) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password reset email sent to ${state.email}'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return TextButton(
                onPressed: state is AuthLoading
                    ? null
                    : () {
                        if (Validators.validateEmail(emailController.text) == null) {
                          context.read<AuthCubit>().sendPasswordResetEmail(
                            emailController.text.trim(),
                          );
                        }
                      },
                child: state is AuthLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(AppLocalizations.of(context)!.send),
              );
            },
          ),
        ],
      ),
    );
  }
}
