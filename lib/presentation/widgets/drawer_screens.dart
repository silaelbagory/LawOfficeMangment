import 'package:flutter/material.dart';
import 'package:lawofficemanagementsystem/core/utils/responcive.dart';
import 'package:lawofficemanagementsystem/presentation/screens/cases/cases_list_screen.dart';
import 'package:lawofficemanagementsystem/presentation/screens/clients/clients_list_screen.dart';
import 'package:lawofficemanagementsystem/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:lawofficemanagementsystem/presentation/screens/documents/documents_list_screen.dart';
import 'package:lawofficemanagementsystem/presentation/screens/users/add_lawyer_screen.dart';

 // Your ResponsiveBuilder + AppDrawer

class MainScaffold extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;
  final String currentLanguage;
  final VoidCallback? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final VoidCallback? onLogout;

  const MainScaffold({
    super.key,
    required this.child,
    required this.isDarkMode,
    required this.currentLanguage,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      isLoggedIn: true,
      isDarkMode: isDarkMode,
      currentLanguage: currentLanguage,
      onThemeChanged: onThemeChanged,
      onLanguageChanged: onLanguageChanged,
      onLogout: onLogout,
      child: child,
    );
  }
}


class DashboardPage extends StatelessWidget {
  final bool isDarkMode;
  final String currentLanguage;
  final VoidCallback? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final VoidCallback? onLogout;

  const DashboardPage({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      isDarkMode: isDarkMode,
      currentLanguage: currentLanguage,
      onThemeChanged: onThemeChanged,
      onLanguageChanged: onLanguageChanged,
      onLogout: onLogout,
      child: const DashboardScreen(),
    );
  }
}


class CasesPage extends StatelessWidget {
  final bool isDarkMode;
  final String currentLanguage;
  final VoidCallback? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final VoidCallback? onLogout;

  const CasesPage({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      isDarkMode: isDarkMode,
      currentLanguage: currentLanguage,
      onThemeChanged: onThemeChanged,
      onLanguageChanged: onLanguageChanged,
      onLogout: onLogout,
      child: const CasesListScreen(),
    );
  }
}

class ClientsPage extends StatelessWidget {
  final bool isDarkMode;
  final String currentLanguage;
  final VoidCallback? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final VoidCallback? onLogout;

  const ClientsPage({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      isDarkMode: isDarkMode,
      currentLanguage: currentLanguage,
      onThemeChanged: onThemeChanged,
      onLanguageChanged: onLanguageChanged,
      onLogout: onLogout,
      child: const ClientsListScreen(),
    );
  }
}

class DocumentsPage extends StatelessWidget {
  final bool isDarkMode;
  final String currentLanguage;
  final VoidCallback? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final VoidCallback? onLogout;

  const DocumentsPage({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      isDarkMode: isDarkMode,
      currentLanguage: currentLanguage,
      onThemeChanged: onThemeChanged,
      onLanguageChanged: onLanguageChanged,
      onLogout: onLogout,
      child: const DocumentsListScreen(),
    );
  }
}
class Addlawyerpage extends StatelessWidget {
  final bool isDarkMode;
  final String currentLanguage;
  final VoidCallback? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final VoidCallback? onLogout;

  

  const Addlawyerpage({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      isDarkMode: isDarkMode,
      currentLanguage: currentLanguage,
      onThemeChanged: onThemeChanged,
      onLanguageChanged: onLanguageChanged,
      onLogout: onLogout,
      child: const AddLawyerScreen(),
    );
  }
}
