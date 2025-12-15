import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../ui/signin.dart'; // sesuaikan path SignInPage kamu

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(20),
      title: const Text(
        'Keluar dari akun?',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
      ),
      content: const Text(
        'Apakah kamu yakin ingin keluar?\n'
        'Kamu perlu login kembali untuk mengakses aplikasi.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black87, fontSize: 14),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // 1️⃣ Hapus token
                  await apiService.logout();

                  // 2️⃣ Tutup dialog
                  Navigator.of(context).pop();

                  // 3️⃣ Arahkan ke SignIn & hapus semua halaman sebelumnya
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Ya, keluar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
