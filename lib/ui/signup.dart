import 'package:flutter/material.dart';
import 'signin.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});
  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFF4C8), Color(0xFFFFFFFF)],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Container(
              height: 92,
              width: 92,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('P', style: TextStyle(color: Colors.white, fontSize: 44))),
            ),
            const SizedBox(height: 14),
            const Text('ParkHive', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            const Text('Sign Up', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))],
              ),
              child: Column(
                children: [
                  TextField(decoration: InputDecoration(labelText: 'Email', hintText: 'Enter your email')),
                  const SizedBox(height: 12),
                  TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password', hintText: 'Enter your password')),
                  const SizedBox(height: 12),
                  TextField(obscureText: true, decoration: InputDecoration(labelText: 'Confirm Password', hintText: 'Confirm your password')),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () { Navigator.of(context).pop(); },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Sign Up'),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () { Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SignInPage())); },
              child: const Text.rich(TextSpan(text: 'Already have an account? ', children: [TextSpan(text: 'Sign In', style: TextStyle(fontWeight: FontWeight.w700))])),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
