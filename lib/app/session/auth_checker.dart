import 'dart:async';

import 'package:dfi_flutter_admin_panel/app/pages/dashboard/pages/_ecommerce_admin_dashboard/_ecommerce_admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/authentication/signin_view.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late StreamSubscription<User?> _authStateSubscription;
  bool _isLoading = true;
  String? _errorMessage;
  Widget _redirectWidget = const SizedBox(); // Initialize with SizedBox
  static const String _authError = "Error checking authentication";

  @override
  void initState() {
    super.initState();
    _authStateSubscription = _auth.authStateChanges().listen(_handleAuthState);
    // No need to call _checkAuth() anymore.
  }

  void _handleAuthState(User? user) {
    setState(() {
      _isLoading = false;
      if (user == null) {
        _redirectWidget = const SigninView();
      } else {
        _redirectWidget = const ECommerceAdminDashboardView();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Checking Authentication Status..."),
            ],
          ),
        ),
      );
    } else if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retryAuthCheck,
                child: const Text("Try Again"),
              ),
            ],
          ),
        ),
      );
    } else {
      return _redirectWidget;
    }
  }

  //Retry check if there is an error
  void _retryAuthCheck() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _authStateSubscription = _auth.authStateChanges().listen(_handleAuthState);
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
