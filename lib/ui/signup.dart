import 'package:flutter/material.dart';
import 'signin.dart';
import '../services/api_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final ApiService _apiService = ApiService();

  // 1. Tambahkan Controllers untuk semua input (termasuk No HP)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isValidName(String name) {
    return RegExp(r'^[a-zA-Z\s]{3,}$').hasMatch(name.trim());
  }

  bool _isValidEmail(String email) {
    if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return false;
    }

    // blokir email sementara
    final blockedDomains = [
      'mailinator.com',
      'tempmail.com',
      '10minutemail.com'
    ];

    return !blockedDomains.any(email.endsWith);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^(8)[0-9]{8,11}$').hasMatch(phone);
  }

  bool _isStrongPassword(String password) {
    return RegExp(
      r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
    ).hasMatch(password);
  }

  void _showError(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Data Tidak Valid',
      desc: message,
      btnOkText: 'Perbaiki',
      btnOkOnPress: () {},
    ).show();
  }

  Future<bool> _showDataWarning() async {
    bool proceed = false;

    await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Gunakan Data Asli',
      desc: 'Gunakan email dan nomor HP aktif.\n'
          'Akun dengan data palsu dapat diblokir permanen.',
      btnCancelText: 'Batal',
      btnOkText: 'Saya Mengerti',
      btnOkOnPress: () => proceed = true,
      btnCancelOnPress: () => proceed = false,
    ).show();

    return proceed;
  }

  // State untuk Loading dan Error
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Fungsi Logika Registrasi ---
  void _handleRegister() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _noHpController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    // ================= VALIDASI =================
    if (!_isValidName(name)) {
      _showError("Nama harus minimal 3 huruf dan tanpa angka.");
      return;
    }

    if (!_isValidEmail(email)) {
      _showError("Gunakan email aktif & valid (bukan email sementara).");
      return;
    }

    if (!_isValidPhone(phone)) {
      _showError("Nomor HP harus aktif dan berformat Indonesia.");
      return;
    }

    if (!_isStrongPassword(password)) {
      _showError(
        "Password minimal 8 karakter dan harus mengandung:\n"
        "• Huruf besar\n"
        "• Angka\n"
        "• Simbol (@#! dll)",
      );
      return;
    }

    if (password != confirm) {
      _showError("Password dan konfirmasi tidak sama.");
      return;
    }

    // ================= WARNING PSIKOLOGIS =================
    final agree = await _showDataWarning();
    if (!agree) return;

    // ================= SUBMIT =================
    try {
      setState(() => _isLoading = true);

      await _apiService.registerUser(
        name,
        email,
        phone,
        password,
        confirm,
      );

      setState(() => _isLoading = false);

      // ✅ SUKSES
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Registrasi Berhasil',
        desc:
            'Akun berhasil dibuat.\nGunakan email & nomor HP asli untuk keamanan akun.',
        btnOkText: 'Login',
        btnOkOnPress: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SignInPage()),
          );
        },
      ).show();
    } catch (e) {
      setState(() => _isLoading = false);

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Registrasi Gagal',
        desc: e.toString().replaceFirst('Exception: ', ''),
        btnOkOnPress: () {},
      ).show();
    }
  }

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
        child: SingleChildScrollView(
          // Tambahkan SingleChildScrollView untuk menghindari overflow
          child: Column(
            children: [
              const SizedBox(height: 80),
              // Logo
              Container(
                height: 92,
                width: 92,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12)),
                child: const Center(
                    child: Text('P',
                        style: TextStyle(color: Colors.white, fontSize: 44))),
              ),
              const SizedBox(height: 14),
              const Text('ParkHive',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              const Text('Sign Up',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),

              // --- Kotak Form ---
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    // Input Nama
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          hintText: 'Contoh:Zaky Adi'),
                    ),
                    const SizedBox(height: 12),
                    // Input Email
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Contoh:test@gmail.com'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    // Input Nomor HP
                    TextField(
                      controller: _noHpController,
                      decoration: const InputDecoration(
                          labelText: 'Nomor HP', hintText: 'Contoh:8123456...'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    // Input Password
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Min 8 karakter, huruf besar, angka & simbol',
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Input Confirm Password
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Konfirmasi Sandi'),
                    ),
                    const SizedBox(height: 16),

                    // Pesan Error
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          _errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Tombol Sign Up
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // Hubungkan ke _handleRegister
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Sign Up',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),

              // Memberikan ruang di bawah form
              const SizedBox(height: 50),

              // Tombol Sign In
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SignInPage()));
                },
                child: const Text.rich(TextSpan(
                    text: 'Already have an account? ',
                    children: [
                      TextSpan(
                          text: 'Sign In',
                          style: TextStyle(fontWeight: FontWeight.w700))
                    ])),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
