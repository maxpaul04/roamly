import 'package:flutter/material.dart';
import 'package:roamly/main_navigation.dart';
import 'package:roamly/screens/login_page.dart';
import '../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  void _handleSignUp() async {
    if (_usernameController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty || 
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      );

      if(!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false
        );
      });

    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('email-already-in-use')) {
            _errorMessage = 'This email is already registered. Try logging in.';
          } else if (errorString.contains('weak-password')) {
            _errorMessage = 'Password is too weak.';
          } else if (errorString.contains('username-taken')) {
            _errorMessage = 'Username is already taken.';
          } else {
            _errorMessage = 'An error occurred. Please try again.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred.';
        });
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Join the community',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start logging your journey today.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.alternate_email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 5),

              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              
              const SizedBox(height: 20),
              
              _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text('Log in here'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
