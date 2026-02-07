import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/core/services/auth_service.dart';
import 'package:zoneer_mobile/features/user/models/user_model.dart';
import 'package:zoneer_mobile/features/user/viewmodels/user_mutation_viewmodel.dart';
import 'package:zoneer_mobile/shared/models/enums/verify_status.dart';
import 'package:zoneer_mobile/shared/widgets/google_nav_bar.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool toRegister;

  const AuthScreen({super.key, required this.toRegister});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool isRegister;

  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    isRegister = widget.toRegister;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);

      if (isRegister) {
        final response = await authService.register(
          email: _emailController.text,
          password: _passwordController.text,
          fullname: _fullNameController.text,
        );

        if (response.user != null) {
          try {
            await ref
                .read(userMutationViewModelProvider.notifier)
                .create(
                  UserModel(
                    id: response.user!.id,
                    fullname: _fullNameController.text.trim(),
                    email: _emailController.text.trim(),
                    role: 'tenant',
                    verifyStatus: VerifyStatus.pending,
                  ),
                );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$e')));
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Registration successful! Please check your email to verify your account.',
                ),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GoogleNavBar()),
            );
          }
        }
      } else {
        final response = await authService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (response.user != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GoogleNavBar()),
            );
          }
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isRegister ? 'Register' : 'Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isRegister)
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter your full name'
                      : null,
                ),

              if (isRegister) const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your email' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value == null || value.length < 8
                    ? 'Password must be at least 8 characters'
                    : null,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(isRegister ? 'Register' : 'Login'),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          isRegister = !isRegister;
                          _formKey.currentState?.reset();
                        });
                      },
                child: Text(
                  isRegister
                      ? 'Already have an account? Login'
                      : 'Don’t have an account? Register',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
