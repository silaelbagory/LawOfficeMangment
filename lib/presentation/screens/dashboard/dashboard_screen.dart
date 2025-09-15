import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lawofficemanagementsystem/core/utils/them_background.dart';
import 'package:lawofficemanagementsystem/logic/auth_cubit/auth_state.dart';
import 'package:lawofficemanagementsystem/presentation/screens/auth/login_screen.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/case_cubit/case_cubit.dart';
import '../../../logic/client_cubit/client_cubit.dart';
import '../../../logic/document_cubit/document_cubit.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
 bool ismanger= false;
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
   
  }
 
  void _loadDashboardData() {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.currentUser;
    
    if (user != null) {
      if (user.role == UserRole.manager) {
        // Manager sees statistics for their entire team
        context.read<CaseCubit>().loadCaseStatisticsByManager(user.id);
        context.read<ClientCubit>().loadClientStatisticsByManager(user.id);
        context.read<DocumentCubit>().loadDocumentStatisticsByManager(user.id);
      } else {
        // Lawyer sees only their own statistics
        context.read<CaseCubit>().loadCaseStatistics(user.id);
        context.read<ClientCubit>().loadClientStatistics(user.id);
        context.read<DocumentCubit>().loadDocumentStatistics(user.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.dashboard),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDashboardData,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(),
            ),
          ],
        ),
        body: BlocBuilder<AuthCubit, dynamic>(
          builder: (context, authState) {
            final user = context.read<AuthCubit>().currentUser;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return RefreshIndicator(
              onRefresh: () async => _loadDashboardData(),
              child: ResponsiveContainer(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(theme, user),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
                      _buildQuickActions(theme, user),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
                      _buildStatisticsSection(theme, user),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context)),
                      _buildRecentActivity(theme, user),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.15),
                child: Icon(
                  user.isManager ? Icons.admin_panel_settings : Icons.person, 
                  size: 36, 
                  color: theme.colorScheme.onPrimary
                ),
              ),
              const SizedBox(width: AppConstants.largePadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.welcomeBack,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      user.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role.value.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            user.isManager 
              ? 'Manager Dashboard - Full Access'
              : 'Lawyer Dashboard - Limited Access',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, UserModel user) {
    final actions = [
      {
        'title': AppLocalizations.of(context)!.addCase,
        'icon': Icons.cases,
        'color': AppColors.caseOpen,
        'route': '/add-case',
        'permission': user.hasPermission('casesWrite'),
      },
      {
        'title': AppLocalizations.of(context)!.documents,
        'icon': Icons.document_scanner,
        'color': const Color.fromARGB(255, 2, 24, 3),
        'route': '/document_list',
        'permission': user.hasPermission('documentsRead'),
      },
      {
        'title': AppLocalizations.of(context)!.addLawyer,
        'icon': Icons.people_sharp,
        'color': const Color.fromARGB(255, 136, 220, 139),
        'route': '/add_lawyer',
        'permission': user.hasPermission('usersWrite'),
      },
      {
        'title': AppLocalizations.of(context)!.uploadDocument,
        'icon': Icons.upload,
        'color': AppColors.info,
        'route': '/upload-document',
        'permission': user.hasPermission('documentsWrite'),
      },
      {
        'title': AppLocalizations.of(context)!.clients,
        'icon': Icons.people,
        'color': const Color.fromARGB(255, 95, 132, 163),
        'route': '/clients',
        'permission': user.hasPermission('clientsRead'),
      },
      {
        'title': AppLocalizations.of(context)!.viewAllCases,
        'icon': Icons.visibility,
        'color': AppColors.warning,
        'route': '/cases',
        'permission': user.hasPermission('casesRead'),
      },
      {
        'title': AppLocalizations.of(context)!.actions,
        'icon': Icons.history,
        'color': const Color.fromARGB(255, 255, 0, 0),
        'route': '/users/actions',
        'permission': user.hasPermission('usersRead') || user.isManager,
      },
      // Manager-specific actions
      if (user.isManager) ...[
        {
          'title': 'Manage Lawyers',
          'icon': Icons.people_outline,
          'color': const Color.fromARGB(255, 76, 175, 80),
          'route': '/my_lawyers',
          'permission': true,
        },
       
      ],
    ];
 final filteredActions =
      actions.where((action) => action['permission'] == true).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.quickActions,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        ResponsiveGrid(
          children: filteredActions.map((action) => _buildActionCard(
            theme,
            action['title'] as String,
            action['icon'] as IconData,
            action['color'] as Color,
            action['route'] as String,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildActionCard(ThemeData theme, String title, IconData icon, Color color, String route) {
    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      curve: Curves.easeInOut,
      child: Card(
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context,route),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(ThemeData theme, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.statistics,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        ResponsiveGrid(
          children: [
            _buildStatCard(
              theme,
              AppLocalizations.of(context)!.cases,
              Icons.folder,
              AppColors.caseOpen,
              () => context.read<CaseCubit>().currentStatistics,
            ),
            _buildStatCard(
              theme,
              AppLocalizations.of(context)!.clients,
              Icons.people,
              AppColors.primaryLight,
              () => context.read<ClientCubit>().currentStatistics,
            ),
            _buildStatCard(
              theme,
              AppLocalizations.of(context)!.documents,
              Icons.description,
              AppColors.info,
              () => context.read<DocumentCubit>().currentStatistics,
            ),
            _buildStatCard(
              theme,
              AppLocalizations.of(context)!.revenue,
              Icons.priority_high,
              AppColors.success,
              () => {'total': 0, 'thisMonth': 0, 'lastMonth': 0},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, IconData icon, Color color, Map<String, int> Function() getStats) {
    return BlocBuilder<CaseCubit, dynamic>(
      builder: (context, state) {
        final stats = getStats();
        final total = stats['total'] ?? 0;
        return AnimatedContainer(
          duration: AppConstants.shortAnimation,
          curve: Curves.easeInOut,
          child: Card(
            elevation: AppConstants.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        total.toString(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity(ThemeData theme, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.recentActivity,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context,'/cases'),
              child: Text(AppLocalizations.of(context)!.viewAll),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Card(
          elevation: AppConstants.cardElevation,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                _buildActivityItem(
                  theme,
                  AppLocalizations.of(context)!.newCaseCreated,
                  'Contract Dispute - John Doe',
                  AppLocalizations.of(context)!.hoursAgo.replaceAll('{hours}', '2'),
                  Icons.folder,
                  AppColors.caseOpen,
                ),
                const Divider(),
                _buildActivityItem(
                  theme,
                  AppLocalizations.of(context)!.clientAdded,
                  'Jane Smith - Corporate Law',
                  AppLocalizations.of(context)!.hoursAgo.replaceAll('{hours}', '4'),
                  Icons.people,
                  AppColors.primaryLight,
                ),
                const Divider(),
                _buildActivityItem(
                  theme,
                  AppLocalizations.of(context)!.documentUploaded,
                  'Contract_Agreement.pdf',
                  AppLocalizations.of(context)!.hoursAgo.replaceAll('{hours}', '6'),
                  Icons.description,
                  AppColors.info,
                ),
                const Divider(),
                _buildActivityItem(
                  theme,
                  AppLocalizations.of(context)!.caseStatusUpdated,
                  'Personal Injury - In Progress',
                  AppLocalizations.of(context)!.daysAgo.replaceAll('{days}', '1'),
                  Icons.flag,
                  AppColors.warning,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(ThemeData theme, String title, String subtitle, String time, IconData icon, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        time,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  void _showLogoutDialog() {
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