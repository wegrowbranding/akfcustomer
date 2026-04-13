import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../themes/app_theme.dart';

class LoginPrompt extends StatelessWidget {
  const LoginPrompt({super.key});

  static void show(BuildContext context) {
    showDialog(context: context, builder: (context) => const LoginPrompt());
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = AppTheme.primaryColor;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Login Required',
        style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Please login to access this feature and enjoy a personalized experience.',
        style: TextStyle(color: Colors.black54),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Later',
            style: TextStyle(color: Colors.black.withValues(alpha: 0.4)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Login Now'),
        ),
      ],
    );
  }
}
