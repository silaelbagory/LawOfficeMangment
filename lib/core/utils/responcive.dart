import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget child;
  final VoidCallback? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final bool? isDarkMode;
  final String? currentLanguage;
  final VoidCallback? onLogout;
  final bool isLoggedIn;
  const ResponsiveBuilder({
    super.key,
    required this.child,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.isDarkMode,
    this.currentLanguage,
    this.onLogout,
    required this.isLoggedIn,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return DesktopLayout(
            child: child,
            onThemeChanged: onThemeChanged,
            onLanguageChanged: onLanguageChanged,
            isDarkMode: isDarkMode,
            currentLanguage: currentLanguage,
            isLoggedIn: isLoggedIn,
            onLogout: onLogout,
          );
        } else if (constraints.maxWidth > 600) {
          return TabletLayout(
            child: child,
            onThemeChanged: onThemeChanged,
            onLanguageChanged: onLanguageChanged,
            isDarkMode: isDarkMode,
            currentLanguage: currentLanguage,
            isLoggedIn: isLoggedIn,
            onLogout: onLogout,
          );
        } else {
          return MobileLayout(
            child: child,
            onThemeChanged: onThemeChanged,
            onLanguageChanged: onLanguageChanged,
            isDarkMode: isDarkMode,
            currentLanguage: currentLanguage,
            isLoggedIn: isLoggedIn,
            onLogout: onLogout,
          );
        }
      },
    );
  }
}

class DesktopLayout extends StatelessWidget {
  final Widget child;
  final VoidCallback? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final bool? isDarkMode;
  final String? currentLanguage;
  final VoidCallback? onLogout;
  final bool isLoggedIn;
  DesktopLayout({
    super.key,
    required this.child,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.isDarkMode,
    this.currentLanguage,
    this.onLogout,
    required this.isLoggedIn,
  });
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar:
          isLoggedIn
              ? AppBar(
                title: const Text('Law Office Management'),
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              )
              : null,
      drawer:
          isLoggedIn
              ? AppDrawer(
                isDarkMode: isDarkMode,
                currentLanguage: currentLanguage,
                onThemeChanged: onThemeChanged,
                onLanguageChanged: onLanguageChanged,
                onLogout: onLogout,
              )
              : null,
      body: child,
    );
  }
}

class TabletLayout extends StatelessWidget {
  final Widget child;
  final VoidCallback? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final bool? isDarkMode;
  final String? currentLanguage;
  final VoidCallback? onLogout;
  final bool isLoggedIn;
  TabletLayout({
    super.key,
    required this.child,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.isDarkMode,
    this.currentLanguage,
    this.onLogout,
    required this.isLoggedIn,
  });
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar:
          isLoggedIn
              ? AppBar(
                title: const Text('Law Office Management'),
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                actions: [
                  if (onThemeChanged != null)
                    IconButton(
                      icon: Icon(
                        (isDarkMode ?? false)
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: onThemeChanged,
                    ),
                  if (onLanguageChanged != null)
                    IconButton(
                      icon: const Icon(Icons.language),
                      onPressed:
                          () => onLanguageChanged!(
                            (currentLanguage ?? 'ar') == 'ar' ? 'en' : 'ar',
                          ),
                    ),
                ],
              )
              : null,
      drawer:
          isLoggedIn
              ? AppDrawer(
                isDarkMode: isDarkMode,
                currentLanguage: currentLanguage,
                onThemeChanged: onThemeChanged,
                onLanguageChanged: onLanguageChanged,
                onLogout: onLogout,
              )
              : null,
      body: child,
    );
  }
}

class MobileLayout extends StatelessWidget {
  final Widget child;
  final VoidCallback? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final bool? isDarkMode;
  final String? currentLanguage;
  final VoidCallback? onLogout;
  final bool isLoggedIn;
  MobileLayout({
    super.key,
    required this.child,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.isDarkMode,
    this.currentLanguage,
    this.onLogout,
    required this.isLoggedIn,
  });
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar:
          isLoggedIn
              ? AppBar(
                title: const Text('Law Office Management'),
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                actions: [
                  if (onThemeChanged != null)
                    IconButton(
                      icon: Icon(
                        (isDarkMode ?? false)
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: onThemeChanged,
                    ),
                  if (onLanguageChanged != null)
                    IconButton(
                      icon: const Icon(Icons.language),
                      onPressed:
                          () => onLanguageChanged!(
                            (currentLanguage ?? 'ar') == 'ar' ? 'en' : 'ar',
                          ),
                    ),
                ],
              )
              : null,
      drawer:
          isLoggedIn
              ? AppDrawer(
                isDarkMode: isDarkMode,
                currentLanguage: currentLanguage,
                onThemeChanged: onThemeChanged,
                onLanguageChanged: onLanguageChanged,
                onLogout: onLogout,
              )
              : null,
      body: child,
    );
  }
}

/* ---------------- Drawer Widget ---------------- */
class AppDrawer extends StatelessWidget {
  final bool? isDarkMode;
  final String? currentLanguage;
  final VoidCallback? onThemeChanged;
  final Function(String)? onLanguageChanged;
  final VoidCallback? onLogout;
  const AppDrawer({
    super.key,
    this.isDarkMode,
    this.currentLanguage,
    this.onThemeChanged,
    this.onLanguageChanged,
    this.onLogout,
  });
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(child: Text('Navigation')),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              // close drawer
              Navigator.pushNamed(
                context,'/dashboard'
               
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Cases'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
               '/cases'
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clients'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
               '/clients'
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Documents'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
               '/documents'
              );
              
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Add Lawyer'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
               '/add_lawyer'
              );
              
            },
          ),
          const Divider(),
          if (onThemeChanged != null)
            ListTile(
              leading: Icon(
                (isDarkMode ?? false) ? Icons.light_mode : Icons.dark_mode,
              ),
              title: Text((isDarkMode ?? false) ? 'Light Mode' : 'Dark Mode'),
              onTap: onThemeChanged,
            ),
          if (onLanguageChanged != null)
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                (currentLanguage ?? 'ar') == 'ar' ? 'English' : 'Arabic',
              ),
              onTap:
                  () => onLanguageChanged!(
                    (currentLanguage ?? 'ar') == 'ar' ? 'en' : 'ar',
                  ),
            ),
          const Divider(),
          if (onLogout != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                onLogout!();
              },
            ),
        ],
      ),
    );
  }
}
