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

/// Modern, distraction-free sign-in screen.
///
/// Changes from the previous version:
/// - Full dark-mode support (the old page ignored brightness entirely).
/// - Replaced the generic AppBar + Card with a branded, edge-to-edge layout
///   (logo mark, headline, bordered form panel) matching the Register page.
/// - Added a "Forgot password?" entry point (stubbed until a route exists).
/// - Unfocuses the keyboard on submit, and the success snackbar was removed
///   since the immediate navigation away makes it get cut off anyway.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>(),
      child: const _LoginFormView(),
    );
  }
}

class _LoginFormView extends StatefulWidget {
  const _LoginFormView();

  @override
  State<_LoginFormView> createState() => _LoginFormViewState();
}

class _LoginFormViewState extends State<_LoginFormView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
  

    return Scaffold(
      backgroundColor: AppColors.white,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.xxl * 2,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                          
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'Sign in to continue to ${AppConstants.appName}.',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSizes.xl),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                              textInputAction: TextInputAction.done,
                              validator: InputValidators.password,
                              onFieldSubmitted: (_) => _submit(),
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
                            const SizedBox(height: AppSizes.sm),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        // TODO: point this at a real
                                        // forgot-password route once one
                                        // exists in AppRouter/AppConstants.
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Password reset coming soon.',
                                            ),
                                          ),
                                        );
                                      },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Forgot password?'),
                              ),
                            ),
                            const SizedBox(height: AppSizes.md),
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
                                        'Sign in',
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
                          "Don't have an account? ",
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(
                                  context,
                                ).pushNamed(AppConstants.routeRegister),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Create one',
                            style: TextStyle(fontWeight: FontWeight.w700),
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
      ),
    );
  }
}
