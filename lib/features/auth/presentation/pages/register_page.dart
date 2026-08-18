import 'package:flutter/material.dart';

/// Same pattern as LoginPage: `BlocProvider(sl<AuthCubit>())` wrapping a
/// Form that calls `context.read<AuthCubit>().register(...)`. Add a
/// role toggle (founder / investor) here per the actor model.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Register page — mirrors LoginPage pattern')),
    );
  }
}
