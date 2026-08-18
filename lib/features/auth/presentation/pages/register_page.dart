import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/input_validators.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';

/// Modern, distraction-free registration screen matching the login page design.
///
/// Features:
/// - Full dark-mode support
/// - Branded, edge-to-edge layout with logo mark and headline
/// - Role selection with modern chip design
/// - Bordered form panel consistent with login page
/// - Clean navigation to sign in page
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key, this.initialRole});

  final String? initialRole;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>(),
      child: _RegisterFormView(initialRole: initialRole),
    );
  }
}

class _RegisterFormView extends StatefulWidget {
  const _RegisterFormView({this.initialRole});

  final String? initialRole;

  @override
  State<_RegisterFormView> createState() => _RegisterFormViewState();
}

class _RegisterFormViewState extends State<_RegisterFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late String _selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole == AppConstants.roleInvestor
        ? AppConstants.roleInvestor
        : AppConstants.roleFounder;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.backgroundDark
        : AppColors.background;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.secondary;
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            );
          } else if (state is EmailConfirmationRequired) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Account created. Confirm it from your email, then sign in.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppConstants.routeLogin,
              (route) => false,
            );
          } else if (state is Authenticated) {
            final destination = AppRouter.dashboardRouteForRole(
              state.user.role,
            );
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(destination, (route) => false);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xl,
                  vertical: AppSizes.xl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSizes.xl),
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.rocket_launch_outlined,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Text(
                        'Create your account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        'Join ${AppConstants.appName} and start your journey.',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: subtitleColor),
                      ),
                      const SizedBox(height: AppSizes.xl),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.xl),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                          border: Border.all(color: borderColor),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Role selection
                              Text(
                                'I am a',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: titleColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: AppSizes.sm),
                              Row(
                                children: [
                                  Expanded(
                                    child: _RoleChip(
                                      label: 'Founder',
                                      icon: Icons.lightbulb_outline,
                                      isSelected:
                                          _selectedRole ==
                                          AppConstants.roleFounder,
                                      onTap: isLoading
                                          ? null
                                          : () => setState(
                                              () => _selectedRole =
                                                  AppConstants.roleFounder,
                                            ),
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.md),
                                  Expanded(
                                    child: _RoleChip(
                                      label: 'Investor',
                                      icon: Icons.trending_up_outlined,
                                      isSelected:
                                          _selectedRole ==
                                          AppConstants.roleInvestor,
                                      onTap: isLoading
                                          ? null
                                          : () => setState(
                                              () => _selectedRole =
                                                  AppConstants.roleInvestor,
                                            ),
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.lg),
                              AuthTextField(
                                controller: _nameController,
                                labelText: 'Full Name',
                                hintText: 'Abebe Bikila',
                                prefixIcon: const Icon(Icons.person_outline),
                                textInputAction: TextInputAction.next,
                                validator: (v) => InputValidators.notEmpty(
                                  v,
                                  field: 'Full name',
                                ),
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: AppSizes.md),
                              AuthTextField(
                                controller: _emailController,
                                labelText: 'Email Address',
                                hintText: 'name@example.com',
                                prefixIcon: const Icon(Icons.email_outlined),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: InputValidators.email,
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: AppSizes.md),
                              AuthTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                validator: InputValidators.password,
                                enabled: !isLoading,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSizes.md),
                              AuthTextField(
                                controller: _confirmPasswordController,
                                labelText: 'Confirm Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                validator: (v) =>
                                    InputValidators.confirmPassword(
                                      v,
                                      _passwordController.text,
                                    ),
                                onFieldSubmitted: (_) => _submit(),
                                enabled: !isLoading,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSizes.lg),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.secondary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMd,
                                      ),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.secondary,
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          'Create account',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.of(context)
                                      .pushReplacementNamed(
                                        AppConstants.routeLogin,
                                      ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom chip widget for role selection with modern design
class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? AppColors.primary.withOpacity(0.12)
        : (isDark ? AppColors.surfaceDark : AppColors.surface);
    final borderColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.borderDark : AppColors.border);
    final textColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.md,
          horizontal: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(height: AppSizes.xs),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
