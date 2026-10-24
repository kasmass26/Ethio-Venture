import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RoleModeSwitch extends StatelessWidget {
  const RoleModeSwitch({
    super.key,
    required this.currentRole,
    required this.onRoleChanged,
  });

  final String currentRole;
  final ValueChanged<String> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    final isFounder = currentRole.toLowerCase() != 'investor';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Founder Mode Tab
          Expanded(
            child: InkWell(
              onTap: () => onRoleChanged('founder'),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isFounder ? AppColors.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isFounder
                      ? [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.rocket_launch_rounded,
                      size: 15,
                      color: isFounder ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Founder Co-Pilot',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isFounder ? FontWeight.w700 : FontWeight.w600,
                        color: isFounder ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Investor Mode Tab
          Expanded(
            child: InkWell(
              onTap: () => onRoleChanged('investor'),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !isFounder ? AppColors.violet : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !isFounder
                      ? [
                          BoxShadow(
                            color: AppColors.violet.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      size: 15,
                      color: !isFounder ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Investor Analyst',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: !isFounder ? FontWeight.w700 : FontWeight.w600,
                        color: !isFounder ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
