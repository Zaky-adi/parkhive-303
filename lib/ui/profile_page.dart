import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'logout_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _apiService.getProfile();

    // 🔥 kalau API kamu bungkus pakai "data"
    if (response.containsKey('data')) {
      return response['data'];
    }

    return response;
  }

  void showLaporanDialog(BuildContext context, List aktivitas) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detail Laporan'),
        content: aktivitas.isEmpty
            ? const Text('Belum ada laporan')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: aktivitas.length,
                  itemBuilder: (context, index) {
                    final item = aktivitas[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(item['deskripsi'] ?? '-'),
                      subtitle: Text(item['waktu'] ?? '-'),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void showBadgeDialog(BuildContext context, List badges) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Badge Kamu'),
        content: badges.isEmpty
            ? const Text('Belum memiliki badge')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return ListTile(
                      leading: const Icon(Icons.workspace_premium),
                      title: Text(badge['nama'] ?? '-'),
                      subtitle: Text(badge['deskripsi'] ?? '-'),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchProfile(),
          builder: (context, snapshot) {
            // ===== LOADING =====
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ===== ERROR =====
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Terjadi kesalahan:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            // ===== DATA KOSONG =====
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Data tidak tersedia'));
            }

            final data = snapshot.data!;

            final String nama = data['nama'] ?? '-';
            final String email = data['email'] ?? '-';
            final int totalPoin = data['total_poin'] ?? 0;
            final int totalLaporan = data['jumlah_laporan'] ?? 0;
            final int totalBadge = data['jumlah_badge'] ?? 0;

            final List aktivitas = (data['aktivitas'] is List)
                ? (data['aktivitas'] as List).take(3).toList()
                : [];

            return SingleChildScrollView(
              child: Column(
                children: [
                  // ===============================
                  // HEADER PROFIL
                  // ===============================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6C709),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Profil',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const CircleAvatar(
                          radius: 45,
                          backgroundImage:
                              AssetImage("assets/images/profil.jpeg"),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          nama,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        Text(email),
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              statItem(Icons.star, '$totalPoin', 'Poin'),
                              statItem(
                                Icons.location_on,
                                '$totalLaporan',
                                'Laporan',
                                onTap: () {
                                  showLaporanDialog(context, aktivitas);
                                },
                              ),
                              statItem(
                                Icons.workspace_premium,
                                '$totalBadge',
                                'Badge',
                                onTap: () {
                                  showBadgeDialog(
                                      context, data['badges'] ?? []);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===============================
                  // AKTIVITAS TERAKHIR
                  // ===============================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Aktivitas terakhir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (aktivitas.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Belum ada aktivitas',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ] else ...[
                    ...aktivitas.map((item) {
                      return activityCard(
                        icon: Icons.history,
                        title: item['judul'] ?? 'Aktivitas',
                        subtitle:
                            '${item['deskripsi'] ?? '-'} • ${item['waktu'] ?? '-'}',
                      );
                    }).toList(),
                  ],

                  const SizedBox(height: 24),

                  // ===============================
                  // LOGOUT
                  // ===============================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const LogoutDialog(),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Keluar',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                              color: Colors.redAccent, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===============================
  // WIDGET STAT
  // ===============================
  static Widget statItem(
    IconData icon,
    String value,
    String label, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ===============================
  // WIDGET AKTIVITAS
  // ===============================
  static Widget activityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFFF3CC),
                child: Icon(icon, color: const Color(0xFFF6C709)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
