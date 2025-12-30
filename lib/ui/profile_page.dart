import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'logout_dialog.dart';
import 'hadiah_page.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

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
  // HELPER FORMAT
  // ===============================
  String formatTipeLaporan(String? tipe) {
    if (tipe == null) return '-';
    return tipe.replaceAll('_', ' ');
  }

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
  // DIALOG LAPORAN
  // ===============================
  void showLaporanDialog(BuildContext context, List laporans) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Laporan Parkir Saya'),
        content: laporans.isEmpty
            ? const Text('Belum ada laporan parkir')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: laporans.length,
                  itemBuilder: (context, index) {
                    final l = laporans[index];
                    return ListTile(
                      leading: const Icon(Icons.local_parking),
                      title: Text(formatTipeLaporan(l['tipe_laporan'])),
                      subtitle: Row(
                        children: [
                          Text(
                            l['status'] ?? '-',
                            style: TextStyle(
                              color: statusColor(l['status']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(' • '),
                          Text(l['tanggal_laporan'] ?? '-'),
                        ],
                      ),
                      trailing: l['status'] == 'Terverifikasi' &&
                              l['poin_claimed'] == 0
                          ? ElevatedButton(
                              onPressed: () async {
                                await _apiService.claimLaporanPoin(l['id']);

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('⭐ Poin berhasil diklaim'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              child: const Text('Klaim Poin'),
                            )
                          : l['poin_claimed'] == 1
                              ? const Text(
                                  'Poin diklaim',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : null,
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

  void showPoinDialog(BuildContext context, int poin) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Total Poin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 48),
            const SizedBox(height: 12),
            Text(
              '$poin Poin',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Poin didapat dari aktivitas, laporan, dan verifikasi.',
              textAlign: TextAlign.center,
            ),
          ],
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

  void showBadgeDetail(BuildContext context, Map badge) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(badge['nama'] ?? 'Badge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspace_premium,
              size: 48,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            Text(
              badge['deskripsi'] ?? '-',
              textAlign: TextAlign.center,
            ),
          ],
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
        title: const Text('Badge Saya'),
        content: badges.isEmpty
            ? const Text('Kamu belum memiliki badge')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: badges.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.workspace_premium,
                        color: Color(0xFFF6C709),
                      ),
                      title: Text(
                        badge['nama_badge'] ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Syarat poin: ${badge['syarat_poin'] ?? 0}',
                      ),
                      trailing: badge['is_claimed'] == 0
                          ? ElevatedButton(
                              onPressed: () {
                                showConfirmClaimBadge(context, badge);
                              },
                              child: const Text('Klaim'),
                            )
                          : const Text(
                              'Diklaim',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

  void showHadiahDialog(BuildContext context) {
    int selectedTab = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Hadiah'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    // ===== TAB TEXT =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        hadiahTab('Daftar Hadiah', 0, selectedTab, setState),
                        const SizedBox(width: 24),
                        hadiahTab('Hadiah Saya', 1, selectedTab, setState),
                      ],
                    ),

                    const Divider(),

                    // ===== CONTENT =====
                    Expanded(
                      child: FutureBuilder<List<dynamic>>(
                        future: selectedTab == 0
                            ? _apiService.getHadiah()
                            : _apiService.getHadiahSaya(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text(snapshot.error.toString()));
                          }

                          final data = snapshot.data ?? [];

                          if (data.isEmpty) {
                            return Center(
                              child: Text(
                                selectedTab == 0
                                    ? 'Belum ada hadiah'
                                    : 'Belum punya hadiah',
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final h = data[index];

                              return ListTile(
                                leading: const Icon(Icons.card_giftcard,
                                    color: Colors.amber),
                                title: Text(h['nama_hadiah'] ?? '-'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(h['deskripsi_hadiah'] ?? '-'),
                                    const SizedBox(height: 4),
                                    Text('${h['biaya_poin']} poin'),
                                    if (h['tanggal_kadaluarsa'] != null)
                                      Text(
                                        '⏰ ${h['tanggal_kadaluarsa']}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.green),
                                      ),
                                  ],
                                ),

                                // Tombol hanya di daftar hadiah
                                trailing: selectedTab == 0
                                    ? ElevatedButton(
                                        onPressed: (h['stok_tersedia'] ?? 0) > 0
                                            ? () async {
                                                await _apiService.tukarHadiah(
                                                  hadiahId: h['hadiah_id'],
                                                  jumlah: 1,
                                                );
                                                Navigator.pop(context);
                                              }
                                            : null,
                                        child: const Text('Tukar'),
                                      )
                                    : null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showConfirmClaimBadge(
    BuildContext context,
    Map badge,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Klaim Badge'),
        content: Text(
          'Klaim badge "${badge['nama_badge']}"?\n'
          'Poin akan ditambahkan setelah badge diklaim.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // tutup dialog konfirmasi

              await _apiService.claimBadge(badge['badge_id']);

              Navigator.pop(context); // tutup dialog badge

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🏆 Badge berhasil diklaim, poin bertambah'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Klaim'),
          ),
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
              return Center(
                child: Text(
                  'Terjadi kesalahan:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('Data tidak tersedia'));
            }

            final data = snapshot.data!;

            final String nama = data['nama'] ?? '-';
            final String email = data['email'] ?? '-';
            final int totalPoin = data['total_poin'] ?? 0;
            final int totalLaporan = data['jumlah_laporan'] ?? 0;
            final int totalBadge = data['jumlah_badge'] ?? 0;

            final List aktivitas = data['aktivitas'] ?? [];
            final List laporans = data['laporan'] ?? [];
            final List badges = (data['badges'] is List) ? data['badges'] : [];
            final List hadiah = (data['hadiah'] is List) ? data['hadiah'] : [];

            return SingleChildScrollView(
              child: Column(
                children: [
                  // ===============================
                  // HEADER PROFIL
                  // ===============================
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6C709),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(24),
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
                              fontSize: 18, fontWeight: FontWeight.w700),
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
                              statItem(
                                Icons.star,
                                '$totalPoin',
                                'Poin',
                                onTap: () {
                                  showPoinDialog(context, totalPoin);
                                },
                              ),
                              statItem(
                                Icons.location_on,
                                '$totalLaporan',
                                'Laporan',
                                onTap: () =>
                                    showLaporanDialog(context, laporans),
                              ),
                              statItem(
                                Icons.workspace_premium,
                                '$totalBadge',
                                'Badge',
                                onTap: () {
                                  showBadgeDialog(context, badges);
                                },
                              ),
                              statItem(
                                Icons.card_giftcard,
                                'Hadiah',
                                'Reward',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => HadiahPage()),
                                  );
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
                  sectionTitle('Aktivitas terakhir'),

                  if (aktivitas.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Belum ada aktivitas'),
                    )
                  else
                    ...aktivitas.map((item) {
                      return activityCard(
                        icon: Icons.history,
                        title: item['judul'] ?? 'Aktivitas',
                        subtitle:
                            '${item['deskripsi'] ?? '-'} • ${item['waktu'] ?? '-'}',
                      );
                    }).toList(),

                  const SizedBox(height: 24),

                  // ===============================
                  // LOGOUT
                  // ===============================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        style: TextStyle(color: Colors.red),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.redAccent),
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
  // WIDGETS
  // ===============================
  static Widget statItem(
    IconData icon,
    String value,
    String label, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  static Widget activityCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget hadiahTab(
    String title,
    int index,
    int selectedTab,
    Function setState,
  ) {
    final isActive = selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 40,
              color: const Color(0xFFF6C709),
            ),
        ],
      ),
    );
  }
}
