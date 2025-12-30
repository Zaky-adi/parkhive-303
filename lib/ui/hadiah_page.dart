import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HadiahPage extends StatefulWidget {
  const HadiahPage({Key? key}) : super(key: key);

  @override
  State<HadiahPage> createState() => _HadiahPageState();
}

class _HadiahPageState extends State<HadiahPage> {
  final ApiService _apiService = ApiService();

  /// 0 = daftar hadiah
  /// 1 = hadiah saya
  int selectedTab = 0;

  List<int> claimedHadiahIds = [];

  // ================= EXPIRED CHECK =================
  bool isExpired(String? date) {
    if (date == null) return false;
    try {
      return DateTime.now().isAfter(DateTime.parse(date));
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadiah'),
        backgroundColor: const Color(0xFFF6C709),
      ),
      body: Column(
        children: [
          // ================= TAB =================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                tabItem('Daftar Hadiah', 0),
                const SizedBox(width: 24),
                tabItem('Hadiah Saya', 1),
              ],
            ),
          ),

          const Divider(height: 1),

          // ================= CONTENT =================
          Expanded(
            child: FutureBuilder(
              future: Future.wait([
                _apiService.getHadiah(),
                _apiService.getHadiahSaya(),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final allHadiah = snapshot.data![0] as List<dynamic>;
                final hadiahSaya = snapshot.data![1] as List<dynamic>;

                // simpan hadiah yang sudah diklaim
                claimedHadiahIds =
                    hadiahSaya.map<int>((h) => h['hadiah_id'] as int).toList();

                final data = selectedTab == 0 ? allHadiah : hadiahSaya;

                if (data.isEmpty) {
                  return Center(
                    child: Text(
                      selectedTab == 0
                          ? 'Belum ada hadiah tersedia'
                          : 'Kamu belum memiliki hadiah',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final h = data[index];
                    final expired = isExpired(h['tanggal_kadaluarsa']);
                    final isClaimed = claimedHadiahIds.contains(h['hadiah_id']);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.card_giftcard,
                          color: Colors.amber,
                          size: 32,
                        ),
                        title: Text(
                          h['nama_hadiah'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(h['deskripsi_hadiah'] ?? '-'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 16, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text('${h['biaya_poin']} poin'),
                                const SizedBox(width: 12),
                                Text(
                                  selectedTab == 0
                                      ? 'Stok: ${h['stok_tersedia']}'
                                      : 'Jumlah: ${h['jumlah']}',
                                ),
                              ],
                            ),
                            if (h['tanggal_kadaluarsa'] != null) ...[
                              const SizedBox(height: 6),

                              // ===== KHUSUS HADIAH SAYA (TENGAH) =====
                              if (selectedTab == 1)
                                Center(
                                  child: Row(
                                    children: [
                                      Icon(
                                        isExpired(h['tanggal_kadaluarsa'])
                                            ? Icons.cancel
                                            : Icons.schedule,
                                        size: 16,
                                        color:
                                            isExpired(h['tanggal_kadaluarsa'])
                                                ? Colors.red
                                                : Colors.green,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isExpired(h['tanggal_kadaluarsa'])
                                            ? 'Kadaluarsa (${h['tanggal_kadaluarsa']})'
                                            : 'Berlaku sampai ${h['tanggal_kadaluarsa']}',
                                      ),
                                    ],
                                  ),
                                )

                              // ===== DAFTAR HADIAH (KIRI) =====
                              else
                                Row(
                                  children: [
                                    Icon(
                                      expired ? Icons.cancel : Icons.schedule,
                                      size: 16,
                                      color:
                                          expired ? Colors.red : Colors.green,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      expired
                                          ? 'Kadaluarsa (${h['tanggal_kadaluarsa']})'
                                          : 'Berlaku sampai ${h['tanggal_kadaluarsa']}',
                                      style: TextStyle(
                                        color:
                                            expired ? Colors.red : Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                            ]
                          ],
                        ),

                        // ================= TOMBOL TUKAR =================
                        trailing: selectedTab == 0
                            ? ElevatedButton(
                                onPressed: (!isClaimed &&
                                        (h['stok_tersedia'] ?? 0) > 0 &&
                                        !expired)
                                    ? () async {
                                        await _apiService.tukarHadiah(
                                          hadiahId: h['hadiah_id'],
                                          jumlah: 1,
                                        );

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                '🎉 Hadiah berhasil diklaim'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );

                                        setState(() {});
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isClaimed
                                      ? Colors.grey[300]
                                      : const Color(0xFFF6C709),
                                ),
                                child: Text(
                                  isClaimed
                                      ? 'Diklaim'
                                      : expired
                                          ? 'Kadaluarsa'
                                          : 'Tukar',
                                  style: TextStyle(
                                    color: isClaimed
                                        ? Colors.black54
                                        : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAB WIDGET =================
  Widget tabItem(String title, int index) {
    final isActive = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          if (isActive)
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFF6C709),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}
