import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/input_validators.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';

/// Registration page allowing users to create an account as a founder or investor.
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Account created successfully for ${state.user.name}!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.xl),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Create an Account',
                            style: theme.textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            'Join the Ethiopian venture ecosystem',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.lg),
                          Text(
                            'I want to join as:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xs),
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Center(
                                    child: Text('Startup Founder'),
                                  ),
                                  selected: _selectedRole == AppConstants.roleFounder,
                                  onSelected: isLoading
                                      ? null
                                      : (selected) {
                                          if (selected) {
                                            setState(() {
                                              _selectedRole = AppConstants.roleFounder;
                                            });
                                          }
                                        },
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Center(
                                    child: Text('Investor'),
                                  ),
                                  selected: _selectedRole == AppConstants.roleInvestor,
                                  onSelected: isLoading
                                      ? null
                                      : (selected) {
                                          if (selected) {
                                            setState(() {
                                              _selectedRole = AppConstants.roleInvestor;
                                            });
                                          }
                                        },
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
                            validator: (v) => InputValidators.notEmpty(v, field: 'Full name'),
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
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSizes.md),
                          AuthTextField(
                            controller: _confirmPasswordController,
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            validator: (v) => InputValidators.confirmPassword(
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
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),
                          ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.secondary,
                                      ),
                                    ),
                                  )
                                : const Text('Create Account'),
                          ),
                          const SizedBox(height: AppSizes.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: theme.textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        Navigator.of(context).pushReplacementNamed(
                                          AppConstants.routeLogin,
                                        );
                                      },
                                child: const Text('Sign In'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
