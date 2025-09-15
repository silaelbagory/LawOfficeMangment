import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawofficemanagementsystem/logic/auth_cubit/auth_cubit.dart';
import 'package:lawofficemanagementsystem/logic/auth_cubit/auth_state.dart';
import 'package:lawofficemanagementsystem/presentation/screens/auth/login_screen.dart';

class LogoutDialog  {



 
    void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        child: AlertDialog(
          title: Text(AppLocalizations.of(context)!.logout),
          content: Text(AppLocalizations.of(context)!.logoutConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state is AuthLoading
                      ? null
                      : () => context.read<AuthCubit>().signOut(),
                  child: state is AuthLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppLocalizations.of(context)!.logout),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
}