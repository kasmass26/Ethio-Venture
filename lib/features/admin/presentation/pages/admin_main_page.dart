import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import 'admin_dashboard_page.dart';
import 'admin_analytics_page.dart';
import 'admin_users_page.dart';
import 'admin_reports_page.dart';


/// Main admin page with navigation drawer and multiple sections
class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0;

  final List<_AdminSection> _sections = [
    _AdminSection(
      title: 'Dashboard',
      icon: Icons.dashboard_rounded,
      page: const AdminDashboardPage(),
    ),
    _AdminSection(
      title: 'Analytics',
      icon: Icons.analytics_rounded,
      page: const AdminAnalyticsPage(),
    ),
    _AdminSection(
      title: 'Users',
      icon: Icons.people_rounded,
      page: const AdminUsersPage(),
    ),
    _AdminSection(
      title: 'Reports',
      icon: Icons.assessment_rounded,
      page: const AdminReportsPage(),
    ),
  
  ];

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 840;

    return Scaffold(
      backgroundColor: AppColors.fog,
      body: Row(
        children: [
          // Persistent navigation rail on wide screens
          if (isWideScreen)
            NavigationRail(
              backgroundColor: AppColors.secondary,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(
                color: AppColors.primary,
                size: 28,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              unselectedIconTheme: const IconThemeData(
                color: AppColors.primarySoft,
                size: 24,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: AppColors.primarySoft,
              ),
              leading: Column(
                children: [
                  const SizedBox(height: AppSizes.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    'ADMIN',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
              trailing: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      color: AppColors.primarySoft,
                      onPressed: () => _handleLogout(context),
                      tooltip: 'Logout',
                    ),
                    const SizedBox(height: AppSizes.md),
                  ],
                ),
              ),
              destinations: _sections
                  .map((section) => NavigationRailDestination(
                        icon: Icon(section.icon),
                        label: Text(section.title),
                      ))
                  .toList(),
            ),
          // Main content area
          Expanded(
            child: _sections[_selectedIndex].page,
          ),
        ],
      ),
      // Bottom navigation for mobile
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              backgroundColor: AppColors.white,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              indicatorColor: AppColors.primary.withOpacity(0.2),
              destinations: _sections
                  .map((section) => NavigationDestination(
                        icon: Icon(section.icon),
                        label: section.title,
                        selectedIcon: Icon(section.icon, color: AppColors.primary),
                      ))
                  .toList(),
            ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppConstants.routeLogin,
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _AdminSection {
  final String title;
  final IconData icon;
  final Widget page;

  _AdminSection({
    required this.title,
    required this.icon,
    required this.page,
  });
}
