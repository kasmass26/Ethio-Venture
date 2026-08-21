import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fog,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: const Text(
          'System Reports',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: const Center(
        child: Text(
          'Reports section',
          style: TextStyle(color: AppColors.slate),
        ),
      ),
    );
  }
}
