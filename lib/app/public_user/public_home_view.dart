import 'package:flutter/material.dart';
import '/app/pages/authentication/signin_view.dart'; // Import SigninView


class PublicHomeView extends StatelessWidget {
  const PublicHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SigninView(), // Use SigninView here
    );
  }
}
