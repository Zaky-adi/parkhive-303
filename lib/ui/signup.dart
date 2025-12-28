import 'package:flutter/material.dart';
import 'signin.dart';
import '../services/api_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

enum AuthStep {
  signUp,
  forgot,
  verify,
  reset,
}

class AuthFlowPage extends StatefulWidget {
  const AuthFlowPage({super.key});

  @override
  State<AuthFlowPage> createState() => _AuthFlowPageState();
}

class _AuthFlowPageState extends State<AuthFlowPage> {
  final ApiService _apiService = ApiService();
  AuthStep _step = AuthStep.signUp;

  // ===== CONTROLLERS =====
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();

  bool _loading = false;

  // ===== VALIDATION =====
  bool _validName(String v) =>
      RegExp(r'^[a-zA-Z\s]{3,}$').hasMatch(v.trim());

  bool _validEmail(String v) =>
      RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v);

  bool _validPhone(String v) =>
      RegExp(r'^(8)[0-9]{8,11}$').hasMatch(v);

  bool _strongPassword(String v) =>
      RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*#?&]).{8,}$').hasMatch(v);

  void _error(String msg) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title: 'Perhatian',
      desc: msg,
      btnOkOnPress: () {},
    ).show();
  }

  // ===== REGISTER =====
  void _register() async {
    if (!_validName(nameC.text)) {
      _error('Nama minimal 3 huruf');
      return;
    }
    if (!_validEmail(emailC.text)) {
      _error('Email tidak valid');
      return;
    }
    if (!_validPhone(phoneC.text)) {
      _error('Nomor HP tidak valid');
      return;
    }
    if (!_strongPassword(passC.text)) {
      _error('Password harus kuat');
      return;
    }
    if (passC.text != confirmC.text) {
      _error('Password tidak sama');
      return;
    }

    try {
      setState(() => _loading = true);

      await _apiService.registerUser(
        nameC.text,
        emailC.text,
        phoneC.text,
        passC.text,
        confirmC.text,
      );

      setState(() => _loading = false);

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: 'Berhasil',
        desc: 'Akun berhasil dibuat',
        btnOkText: 'Login',
        btnOkOnPress: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SignInPage()),
          );
        },
      ).show();
    } catch (e) {
      setState(() => _loading = false);
      _error(e.toString());
    }
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4C8), Colors.white],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: _card(
              child: _buildStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case AuthStep.signUp:
        return Column(
          children: [
            _title('Sign Up'),
            _input(nameC, 'Nama Lengkap'),
            _space(),
            _input(emailC, 'Email'),
            _space(),
            _input(phoneC, 'Nomor HP'),
            _space(),
            _input(passC, 'Password', obscure: true),
            _space(),
            _input(confirmC, 'Confirm Password', obscure: true),
            const SizedBox(height: 18),
            _button('Sign Up', _register),
            _textButton(
              'Already have an account? Sign In',
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignInPage()),
              ),
            ),
            _textButton(
              'Forgot password?',
              () => setState(() => _step = AuthStep.forgot),
            ),
          ],
        );

      case AuthStep.forgot:
        return Column(
          children: [
            _title('Forgot password?'),
            _input(phoneC, 'Nomor HP'),
            const SizedBox(height: 18),
            _button('Kirim Kode Verifikasi', () {
              setState(() => _step = AuthStep.verify);
            }),
          ],
        );

      case AuthStep.verify:
        return Column(
          children: [
            _title('Verification Code'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                5,
                (_) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _button('Verify', () {
              setState(() => _step = AuthStep.reset);
            }),
          ],
        );

      case AuthStep.reset:
        return Column(
          children: [
            _title('Create New Password'),
            _input(passC, 'New Password', obscure: true),
            _space(),
            _input(confirmC, 'Confirm Password', obscure: true),
            const SizedBox(height: 18),
            _button('Confirm', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignInPage()),
              );
            }),
          ],
        );
    }
  }

  // ===== REUSABLE UI =====
  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w700),
        ),
      );

  Widget _input(TextEditingController c, String label,
      {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _button(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(text,
                style:
                    const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _textButton(String text, VoidCallback onTap) {
    return TextButton(onPressed: onTap, child: Text(text));
  }

  Widget _space() => const SizedBox(height: 12);

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8)
          ],
        ),
        child: child,
      );
}
