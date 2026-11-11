import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.authService, required this.user});

  final AuthService authService;
  final User user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    await widget.authService.signOut();
    // AuthGate rebuilds to the sign-in screen; nothing else to do.
  }

  Future<void> _openChangePassword() async {
    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ChangePasswordDialog(authService: widget.authService),
    );
    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.user.email ?? '(no email)';
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Text(email.isNotEmpty ? email[0].toUpperCase() : '?',
                        style: theme.textTheme.headlineMedium),
                  ),
                  const SizedBox(height: 16),
                  Text('Signed in as', textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(email,
                      key: const Key('profileEmail'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: _signingOut ? null : _openChangePassword,
                    icon: const Icon(Icons.password),
                    label: const Text('Change password'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _signingOut ? null : _signOut,
                    icon: _signingOut
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.logout),
                    label: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Step 1: new password. If Firebase returns requires-recent-login,
/// step 2 asks for the current password, reauthenticates, and retries.
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({required this.authService});
  final AuthService authService;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _currentCtrl = TextEditingController();

  bool _loading = false;
  bool _needsReauth = false;
  String? _error;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    _currentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (_needsReauth) {
        await widget.authService.reauthenticateAndUpdate(
          currentPassword: _currentCtrl.text,
          newPassword: _newCtrl.text,
        );
      } else {
        await widget.authService.updatePassword(_newCtrl.text);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.requiresRecentLogin) _needsReauth = true;
        _error = e.message;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_needsReauth ? 'Confirm it\'s you' : 'Change password'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _newCtrl,
                enabled: !_loading,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'New password', helperText: 'At least 6 characters'),
                validator: Validators.password,
              ),
              TextFormField(
                controller: _confirmCtrl,
                enabled: !_loading,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm new password'),
                validator: (v) => v != _newCtrl.text ? 'Passwords do not match.' : null,
              ),
              if (_needsReauth)
                TextFormField(
                  controller: _currentCtrl,
                  enabled: !_loading,
                  obscureText: true,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Current password'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter your current password.' : null,
                ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_needsReauth ? 'Confirm & update' : 'Update'),
        ),
      ],
    );
  }
}
