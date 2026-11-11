import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/validators.dart';

/// One screen, two modes (Sign in / Register) toggled by a segmented button.
class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isRegister = false;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return; // block duplicate submissions
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (_isRegister) {
        await widget.authService.register(_emailCtrl.text, _passwordCtrl.text);
      } else {
        await widget.authService.signIn(_emailCtrl.text, _passwordCtrl.text);
      }
      // Success: AuthGate's stream swaps to ProfileScreen automatically.
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _switchMode(bool register) {
    setState(() {
      _isRegister = register;
      _error = null;
      _confirmCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'Create account' : 'Sign in')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.lock_outline, size: 56, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Sign in')),
                        ButtonSegment(value: true, label: Text('Register')),
                      ],
                      selected: {_isRegister},
                      onSelectionChanged:
                          _loading ? null : (s) => _switchMode(s.first),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const Key('emailField'),
                      controller: _emailCtrl,
                      enabled: !_loading,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('passwordField'),
                      controller: _passwordCtrl,
                      enabled: !_loading,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        helperText: _isRegister ? 'At least 6 characters' : null,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.key_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscure = !_obscure),
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    if (_isRegister) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmCtrl,
                        enabled: !_loading,
                        obscureText: _obscure,
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.key_outlined),
                        ),
                        validator: (v) =>
                            v != _passwordCtrl.text ? 'Passwords do not match.' : null,
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      _ErrorBanner(message: _error!),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_isRegister ? 'Create account' : 'Sign in'),
                      ),
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: cs.onErrorContainer))),
        ],
      ),
    );
  }
}
