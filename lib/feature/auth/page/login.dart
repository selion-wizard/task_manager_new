import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'register.dart';
import 'package:taskmanager/feature/task/page/task_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String route = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthorized) {
          context.go(TasksPage.route);
        } else if (state is AuthUnauthorized && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible 
                      ? Icons.visibility 
                      : Icons.visibility_off),
                    onPressed: () => setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    }),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is AuthLoading 
                      ? null 
                      : () => _handleLogin(context),
                    child: state is AuthLoading
                      ? const CircularProgressIndicator()
                      : const Text('Войти'),
                  );
                },
              ),
              TextButton(
                onPressed: () => context.go(RegisterPage.route),
                child: const Text('Регистрация'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }
    
    context.read<AuthCubit>().signInWithEmail(email, password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}