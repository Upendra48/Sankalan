import 'package:flutter/material.dart';
import 'package:trash_map/auth/auth_page.dart';
import 'package:trash_map/main.dart';

class Registerpage extends StatelessWidget {
  const Registerpage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      initialRegisterMode: true,
      onAuthSuccess: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      },
    );
  }
}
