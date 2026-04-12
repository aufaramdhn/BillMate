import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/services/auth_service.dart';

class AuthEmailPasswordScreen extends StatefulWidget {
  const AuthEmailPasswordScreen({super.key});

  @override
  State<AuthEmailPasswordScreen> createState() => _AuthEmailPasswordScreenState();
}

class _AuthEmailPasswordScreenState extends State<AuthEmailPasswordScreen> {
  static const _brandPrimary = Color(0xFF3C4BD1);
  static const _brandPrimaryContainer = Color(0xFF8D98FF);
  static const _lightSurfaceBase = Color(0xFFF9F5FF);
  static const _lightSurfaceLayer = Color(0xFFF3EEFF);
  static const _lightFieldFill = Color(0xFFECE8FC);
  static const _lightOnSurface = Color(0xFF2E2A50);
  static const _darkSurfaceBase = Color(0xFF0D072E);
  static const _darkSurfaceLayer = Color(0xFF17103B);
  static const _darkFieldFill = Color(0xFF231A4F);
  static const _darkOnSurface = Color(0xFFD9D4FF);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUpMode = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isSignUpMode) {
        final response = await AuthService.signUpWithEmailPassword(
          email: email,
          password: password,
        );

        if (!mounted) {
          return;
        }

        final requiresEmailConfirmation = response.session == null;
        final message = requiresEmailConfirmation
            ? 'Registration successful. Please confirm your email.'
            : 'Registration successful. You are now signed in.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else {
        await AuthService.signInWithEmailPassword(
          email: email,
          password: password,
        );

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in successfully.')),
        );
      }
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.signInWithGoogle();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in started.')),
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required.';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (!_isSignUpMode) {
      return null;
    }

    if ((value ?? '').isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  void _toggleMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceBase = isDark ? _darkSurfaceBase : _lightSurfaceBase;
    final surfaceLayer = isDark ? _darkSurfaceLayer : _lightSurfaceLayer;
    final fieldFill = isDark ? _darkFieldFill : _lightFieldFill;
    final onSurface = isDark ? _darkOnSurface : _lightOnSurface;
    final title = _isSignUpMode ? 'Daftar Akun' : 'Selamat Datang Kembali';
    final subtitle = _isSignUpMode
      ? 'Buat akun untuk mulai mengelola tagihan bulanan Anda.'
      : 'Masuk untuk mengelola tagihan dan pengeluaran Anda dengan mudah.';
    final submitText = _isSignUpMode ? 'Daftar' : 'Masuk';
    final switchText = _isSignUpMode
      ? 'Sudah punya akun? Masuk'
      : 'Belum punya akun? Daftar Sekarang';

    return Scaffold(
      backgroundColor: surfaceBase,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: _ToneBlob(
              size: 280,
              color: _brandPrimaryContainer.withOpacity(isDark ? 0.22 : 0.40),
            ),
          ),
          Positioned(
            top: 220,
            left: -70,
            child: _ToneBlob(
              size: 180,
              color: _brandPrimary.withOpacity(isDark ? 0.25 : 0.14),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _brandPrimary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _brandPrimary.withOpacity(0.30),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.payments_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'BillMate',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: _brandPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: onSurface.withOpacity(0.72),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceLayer.withOpacity(isDark ? 0.94 : 0.92),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.white.withOpacity(0.72),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: onSurface.withOpacity(isDark ? 0.22 : 0.06),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isSignUpMode ? 'Daftar' : 'Login',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                decoration: _inputDecoration(
                                  'Email',
                                  prefixIcon: Icons.email_outlined,
                                ),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: _inputDecoration(
                                  'Kata Sandi',
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: Icons.visibility_outlined,
                                ),
                                validator: _validatePassword,
                              ),
                              if (_isSignUpMode) ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  decoration: _inputDecoration(
                                    'Konfirmasi kata sandi',
                                    prefixIcon: Icons.lock_outline,
                                  ),
                                  validator: _validateConfirmPassword,
                                ),
                              ],
                              if (!_isSignUpMode) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Lupa sandi?',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: _brandPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_brandPrimary, _brandPrimaryContainer],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: FilledButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    disabledBackgroundColor:
                                        _brandPrimary.withOpacity(0.35),
                                    shadowColor: Colors.transparent,
                                    minimumSize: const Size.fromHeight(54),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(submitText),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: _brandPrimary.withOpacity(0.20),
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      'ATAU',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: onSurface.withOpacity(0.55),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: _brandPrimary.withOpacity(0.20),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _isLoading ? null : _signInWithGoogle,
                                icon: const Icon(Icons.g_mobiledata_rounded),
                                label: const Text('Masuk dengan Google'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _onSurface,
                                  foregroundColor: onSurface,
                                  side: BorderSide(
                                    color: _brandPrimary.withOpacity(0.24),
                                  ),
                                  minimumSize: const Size.fromHeight(52),
                                  backgroundColor: isDark
                                      ? Colors.white.withOpacity(0.06)
                                      : Colors.white.withOpacity(0.60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _isLoading ? null : _toggleMode,
                                child: Text(switchText),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldFill = isDark ? _darkFieldFill : _lightFieldFill;
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: fieldFill,
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, color: _brandPrimary.withOpacity(0.60), size: 19),
      suffixIcon: suffixIcon == null
          ? null
          : Icon(suffixIcon, color: _brandPrimary.withOpacity(0.45), size: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: _brandPrimary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

class _ToneBlob extends StatelessWidget {
  const _ToneBlob({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
