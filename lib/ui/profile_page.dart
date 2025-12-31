import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'logout_dialog.dart';
import 'hadiah_page.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ApiService _apiService = ApiService();

  // ===============================
  // API PROFILE
  // ===============================
  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _apiService.getProfile();
    if (response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  // ===============================
  // HELPER
  // ===============================
  Color statusColor(String? status) {
    switch (status) {
      case 'Terverifikasi':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      case 'Menunggu':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // ===============================
  // DIALOG
  // ===============================
  void showPoinDialog(BuildContext context, int poin) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Total Poin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 48, color: Colors.amber),
            const SizedBox(height: 12),
            Text(
              '$poin Poin',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          )
        ],
      ),
    );
  }

  void showLaporanDialog(BuildContext context, List laporans) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Laporan Saya'),
        content: laporans.isEmpty
            ? const Text('Belum ada laporan')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: laporans.length,
                  itemBuilder: (_, i) {
                    final l = laporans[i];
                    return ListTile(
                      leading: const Icon(Icons.local_parking),
                      title: Text(l['tipe_laporan'] ?? '-'),
                      subtitle: Text(
                        l['status'] ?? '-',
                        style: TextStyle(color: statusColor(l['status'])),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          )
        ],
      ),
    );
  }

  void showBadgeDialog(BuildContext context, List badges) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Badge Saya'),
        content: badges.isEmpty
            ? const Text('Belum ada badge')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: badges.length,
                  itemBuilder: (_, i) {
                    final b = badges[i];
                    return ListTile(
                      leading: const Icon(Icons.workspace_premium,
                          color: Colors.amber),
                      title: Text(b['nama_badge'] ?? '-'),
                      subtitle: Text('Syarat poin: ${b['syarat_poin'] ?? 0}'),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          )
        ],
      ),
    );
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('Data tidak tersedia'));
            }

            final data = snapshot.data!;
            final String nama = data['nama'] ?? '-';
            final String email = data['email'] ?? '-';
            final int poin = data['total_poin'] ?? 0;
            final int laporan = data['jumlah_laporan'] ?? 0;
            final int badge = data['jumlah_badge'] ?? 0;

            final List aktivitas = data['aktivitas'] ?? [];
            final List laporans = data['laporan'] ?? [];
            final List badges = data['badges'] ?? [];

            return SingleChildScrollView(
              child: Column(
                children: [
                  // HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6C709),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Profil',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 20),
                        const CircleAvatar(
                          radius: 45,
                          backgroundImage:
                              AssetImage('assets/images/profil.jpeg'),
                        ),
                        const SizedBox(height: 12),
                        Text(nama,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
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
                              statItem(Icons.star, '$poin', 'Poin',
                                  () => showPoinDialog(context, poin)),
                              statItem(Icons.location_on, '$laporan', 'Laporan',
                                  () => showLaporanDialog(context, laporans)),
                              statItem(
                                  Icons.workspace_premium,
                                  '$badge',
                                  'Badge',
                                  () => showBadgeDialog(context, badges)),
                              statItem(Icons.card_giftcard, 'Hadiah', 'Reward',
                                  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => HadiahPage()),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // AKTIVITAS
                  sectionTitle('Aktivitas terakhir'),
                  if (aktivitas.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Belum ada aktivitas'),
                    )
                  else
                    ...aktivitas.map((a) {
                      return activityCard(
                        title: a['judul'] ?? '-',
                        subtitle:
                            '${a['deskripsi'] ?? '-'} • ${a['waktu'] ?? '-'}',
                      );
                    }),

                  const SizedBox(height: 24),

                  // LOGOUT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const LogoutDialog(),
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text('Keluar',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===============================
  // WIDGET KECIL
  // ===============================
  static Widget statItem(
      IconData icon, String value, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  static Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
    );
  }

  static Widget activityCard(
      {required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFFFF3CC),
              child: Icon(Icons.history, color: Color(0xFFF6C709)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
