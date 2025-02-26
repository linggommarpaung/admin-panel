import 'package:dfi_flutter_admin_panel/app/pages/dashboard/pages/_ecommerce_admin_dashboard/_ecommerce_admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/authentication/signin_view.dart'; // Ganti dengan path halaman login Anda
import '/app/pages/dashboard/pages/_ecommerce_admin_dashboard/_ecommerce_admin_dashboard.dart'; // Ganti dengan path halaman dashboard Anda

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key, required this.child});
  final Widget child;

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?>? _authStateChanges;
  bool _isLoading = true;
  String? _errorMessage;
  Widget? _redirectWidget;

  @override
  void initState() {
    super.initState();
    _authStateChanges = _auth.authStateChanges();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      _authStateChanges?.listen((User? user) {
        setState(() {
          _isLoading = false;
          if (user == null) {
            _redirectWidget = const SigninView();
          } else {
            _redirectWidget = const ECommerceAdminDashboardView();
          }
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error checking authentication: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(_errorMessage!)),
      );
    } else if (_redirectWidget != null) {
      return _redirectWidget!;
    } else {
      return widget.child;
    }
  }

  @override
  void dispose() {
    _authStateChanges?.cancel(); // Bersihkan stream jika widget di-dispose
    super.dispose();
  }
}
