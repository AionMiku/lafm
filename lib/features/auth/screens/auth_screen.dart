import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/settings/theme_controller.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _authService.signInWithEmail(_emailCtrl.text.trim(), _passwordCtrl.text);
      } else {
        await _authService.registerWithEmail(_emailCtrl.text.trim(), _passwordCtrl.text);
      }
      if (mounted) Navigator.pop(context); // Go back to profile on success
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Authentication Failed', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In Failed: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = context.watch<ThemeController>();
    final primaryColor = themeCtrl.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Welcome Back' : 'Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withValues(alpha: 0.3),
              const Color(0xFF021210),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card( // Uses the global glassmorphic CardTheme
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 64, color: primaryColor),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? CircularProgressIndicator(color: primaryColor)
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _submit,
                              child: Text(
                                _isLogin ? 'Login' : 'Sign Up',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    const Divider(height: 32, color: Colors.white24),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _googleSignIn,
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.white),
                      label: const Text('Continue with Google', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
