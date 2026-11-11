import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'authentication_screen.dart';
import 'profile_screen.dart';

/// Routes purely on auth state: signed-in -> Profile, signed-out -> Auth.
/// Because the profile is only built inside the `user != null` branch,
/// a signed-out user can never reach it (and sign-out returns here
/// automatically — no manual Navigator calls needed).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Could not check sign-in status. Restart the app.')),
          );
        }
        final user = snapshot.data;
        if (user == null) return AuthenticationScreen(authService: authService);
        return ProfileScreen(authService: authService, user: user);
      },
    );
  }
}
