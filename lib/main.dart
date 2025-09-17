import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' show Intl;
import 'package:lawofficemanagementsystem/presentation/screens/auth/register_screen.dart';
import 'package:lawofficemanagementsystem/presentation/screens/cases/add_case_screen.dart';
import 'package:lawofficemanagementsystem/presentation/screens/clients/add_client_screen.dart';
import 'package:lawofficemanagementsystem/presentation/screens/documents/documents_list_screen.dart';
import 'package:lawofficemanagementsystem/presentation/screens/documents/upload_document_screen.dart';
import 'package:lawofficemanagementsystem/presentation/screens/managers/manager_lawers.dart';
import 'package:lawofficemanagementsystem/presentation/screens/users/users_management_screen.dart';
import 'package:lawofficemanagementsystem/presentation/widgets/drawer_screens.dart';
import 'package:lawofficemanagementsystem/presentation/widgets/logout_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/services/firebase_auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/supabase_storage_service.dart';
import 'core/services/user_management_service.dart';
import 'core/utils/constants.dart';
import 'data/repositories/action_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/case_repository.dart';
import 'data/repositories/client_repository.dart';
import 'data/repositories/document_repository.dart';
import 'data/repositories/user_repository.dart';
import 'firebase_options.dart';
import 'logic/action_cubit/action_cubit.dart';
import 'logic/auth_cubit/auth_cubit.dart';
import 'logic/auth_cubit/auth_state.dart' as app_auth;
import 'logic/case_cubit/case_cubit.dart';
import 'logic/client_cubit/client_cubit.dart';
import 'logic/document_cubit/document_cubit.dart';
import 'logic/user_cubit/user_cubit.dart';
import 'presentation/screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Intl.defaultLocale = 'ar';
   await Supabase.initialize(
    url: 'https://kfimwgwogtzosvitugqn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRzeG5zYWljcnJrZWtqdGpibGJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3MDY3NjgsImV4cCI6MjA3MzI4Mjc2OH0.Ed5gab8du0sEt63M8H4RZesu0WXNLMYNh2SdjzW2A2Y',
  );
  //FirestoreService _firestoreService=FirestoreService();
  final firestoreService = FirestoreService();
    final storageService = SupabaseStorageService();
  final firebaseAuthService = FirebaseAuthService();
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create:
              (_) => AuthRepository(firebaseAuthService, firestoreService),
        ),
        RepositoryProvider(create: (_) => CaseRepository(firestoreService)),
        RepositoryProvider(create: (_) => ClientRepository(firestoreService)),
        RepositoryProvider(
          create:
              (_) => DocumentRepository(FirestoreService(), storageService),
        ),
        RepositoryProvider(create: (_) => UserRepository(firestoreService)),
        RepositoryProvider(create: (_) => ActionRepository(firestoreService)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) =>
                    AuthCubit(context.read<AuthRepository>(),UserRepository(firestoreService))
                      ..checkAuthStatus(),
          ),
          BlocProvider(
            create: (context) => CaseCubit(context.read<CaseRepository>()),
          ),
          BlocProvider(
            create: (context) => ClientCubit(context.read<ClientRepository>()),
          ),
          BlocProvider(
            create:
                (context) => DocumentCubit(context.read<DocumentRepository>()),
          ),
          BlocProvider(
            create: (context) => UserCubit(
              UserManagementService(
                context.read<UserRepository>(),
                context.read<ActionRepository>(),
              ),
            ),
          ),
          BlocProvider(
            create: (context) => ActionCubit(context.read<ActionRepository>()),
          ),
        ],
        child: const LawOfficeApp(),
      ),
    ),
  );
}

class LawOfficeApp extends StatefulWidget {
  const LawOfficeApp({super.key});
  @override
  State<LawOfficeApp> createState() => _LawOfficeAppState();
}

class _LawOfficeAppState extends State<LawOfficeApp> {
  bool _isDarkMode = false;
  String _currentLanguage = 'ar';
  bool isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _currentLanguage = prefs.getString('language') ?? 'ar';
      Intl.defaultLocale = _currentLanguage;
    });
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = !_isDarkMode);
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _changeLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _currentLanguage = language);
    Intl.defaultLocale = language;
    await prefs.setString('language', language);
  }

  void _logout()async {
   LogoutDialog().showLogoutDialog(context);
    setState(() => isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, app_auth.AuthState>(
      builder: (context, authState) {
        isLoggedIn = authState is app_auth.AuthAuthenticated;
        return MaterialApp(
          title: 'Elattar Official',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme ,
          
          darkTheme: AppThemes.darkTheme,
          
          themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: Locale(_currentLanguage),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routes: {
            '/my_lawyers':(context)=>UsersManagementScreen(),
                        '/document_list':(context)=>DocumentsListScreen(),

         //    '/clients':(context)=>ClientsListScreen(),
            '/add-case': (context) => AddCaseScreen(),
        //     '/my_lawyers': (context) => MyLawyersScreen(),
            '/add-client': (context) => AddClientScreen(),
            '/upload-document': (context) => UploadDocumentScreen(),
            '/register': (context) => RegisterScreen(),
          //  '/pending-users': (context) => PendingUsersScreen(),
'/add_lawyer':
                (context) => Addlawyerpage(
                  isDarkMode: _isDarkMode,
                  currentLanguage: _currentLanguage,
                  onThemeChanged: _toggleTheme,
                  onLanguageChanged: _changeLanguage,
                  onLogout: _logout,
                ),
            '/dashboard':
                (context) => DashboardPage(
                  isDarkMode: _isDarkMode,
                  currentLanguage: _currentLanguage,
                  onThemeChanged: _toggleTheme,
                  onLanguageChanged: _changeLanguage,
                  onLogout: _logout,
                ),
            '/cases':
                (context) => CasesPage(
                  isDarkMode: _isDarkMode,
                  currentLanguage: _currentLanguage,
                  onThemeChanged: _toggleTheme,
                  onLanguageChanged: _changeLanguage,
                  onLogout: _logout,
                ),
            '/clients':
                (context) => ClientsPage(
                  isDarkMode: _isDarkMode,
                  currentLanguage: _currentLanguage,
                  onThemeChanged: _toggleTheme,
                  onLanguageChanged: _changeLanguage,
                  onLogout: _logout,
                ),
            '/documents':
                (context) => DocumentsPage(
                  isDarkMode: _isDarkMode,
                  currentLanguage: _currentLanguage,
                  onThemeChanged: _toggleTheme,
                  onLanguageChanged: _changeLanguage,
                  onLogout: _logout,
                ),
          },

          home:
              isLoggedIn
                  ? DashboardPage(
                    isDarkMode: _isDarkMode,
                    currentLanguage: _currentLanguage,
                    onThemeChanged: _toggleTheme,
                    onLanguageChanged: _changeLanguage,
                    onLogout: () async {
                //      await context.read<AuthCubit>().signOut();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  )
                  : const LoginScreen(),
        );
      },
    );
  }
}
