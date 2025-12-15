import 'package:flutter/material.dart';
import 'signup.dart';
import 'home_page.dart';
import '../services/api_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

// Ubah dari StatelessWidget menjadi StatefulWidget
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // 1. Tambahkan Controllers dan ApiService
  final ApiService _apiService = ApiService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Tambahkan State untuk Loading dan Error
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false; // State untuk toggle visibility

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 3. Fungsi Logika Login
  void _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: 'Data belum lengkap',
        desc: 'Email dan password wajib diisi.',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    try {
      setState(() => _isLoading = true);

      await _apiService.loginUser(
        _emailController.text,
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      // ✅ LOGIN BERHASIL
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Login Berhasil',
        desc: 'Selamat datang kembali 👋',
        btnOkText: 'Masuk',
        btnOkOnPress: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        },
      ).show();
    } catch (e) {
      setState(() => _isLoading = false);

      // ❌ LOGIN GAGAL
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Login Gagal',
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
      // resizeToAvoidBottomInset: false, // Hapus atau atur ke true jika ingin scroll saat keyboard muncul
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          // Ganti Column dengan SingleChildScrollView
          child: SizedBox(
            height: MediaQuery.of(context)
                .size
                .height, // Pastikan konten mengisi layar
            child: Column(
              children: [
                const SizedBox(height: 80),
                // --- Logo (Sama) ---
                Container(
                  height: 92,
                  width: 92,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('P',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'ParkHive',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Sign in',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
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
                      // Input Email
                      TextField(
                        controller: _emailController, // Hubungkan controller
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Input Password
                      TextField(
                        controller: _passwordController, // Hubungkan controller
                        obscureText:
                            !_isPasswordVisible, // Gunakan state visibility
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible =
                                    !_isPasswordVisible; // Toggle visibility
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pesan Error (Tampil jika ada)
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Tombol Sign In
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          // Panggil _handleLogin, nonaktifkan jika loading
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Sign In',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(), // Spacer agar elemen di bawah berada di bawah

                // --- Tombol Sign Up (Sama) ---
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignUpPage()));
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      children: [
                        TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(fontWeight: FontWeight.w700))
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
