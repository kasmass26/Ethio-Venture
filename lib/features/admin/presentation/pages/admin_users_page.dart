import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fog,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: const Text(
          'User Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: const Center(
        child: Text(
          'User Management section',
          style: TextStyle(color: AppColors.slate),
        ),
      ),
    );
  }
}
