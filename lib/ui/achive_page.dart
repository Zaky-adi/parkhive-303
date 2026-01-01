import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;

// 1. MODEL DATA (Sesuai Response API Laravel)
class LeaderboardUser {
  final int rank;
  final String name;
  final int points;
  final int reports;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.points,
    required this.reports,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      rank: json['rank'],
      name: json['name'],
      points: json['points'],
      reports: json['reports'] ?? 0,
    );
  }
}

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<LeaderboardUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  // 2. FUNGSI FETCH DATA
// Di dalam _LeaderboardPageState

  Future<void> _fetchLeaderboard() async {
    try {
      // Panggil dari Service, kodingan jadi lebih rapi
      final dataList = await ApiService().getLeaderboard();

      if (!mounted) return;

      setState(() {
        _users = dataList.map((e) => LeaderboardUser.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Opsional: Tampilkan Snackbar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Helper untuk mendapatkan warna berdasarkan Rank (agar sesuai desain asli)
  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.blue;
    if (rank == 3) return Colors.grey;
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    // 3. MEMISAHKAN DATA UNTUK PODIUM & LIST
    // Mencari user ranking 1, 2, 3 untuk podium
    LeaderboardUser? rank1;
    LeaderboardUser? rank2;
    LeaderboardUser? rank3;

    try {
      rank1 = _users.firstWhere((u) => u.rank == 1);
    } catch (_) {}
    try {
      rank2 = _users.firstWhere((u) => u.rank == 2);
    } catch (_) {}
    try {
      rank3 = _users.firstWhere((u) => u.rank == 3);
    } catch (_) {}

    // List sisa (Ranking 4 ke bawah)
    final listRankings = _users.where((u) => u.rank > 3).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ✅ Header Top Section (TIDAK BERUBAH)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD54F),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Papan peringkat",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Top kontributor Kampus - Terbaru",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ Podium TOP 3 sesuai desain
                  // Logic: Tampilkan hanya jika datanya ada
                  if (_users.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // #2 (Posisi Kiri)
                        if (rank2 != null)
                          _PodiumCard(
                            rank: "#2",
                            name: rank2.name,
                            points: rank2.points,
                            color: _getRankColor(2), // Colors.blue
                            height: 130,
                          )
                        else
                          // Spacer jika rank 2 belum ada tapi rank 1 ada (menjaga layout)
                          const SizedBox(width: 90),

                        const SizedBox(width: 14),

                        // #1 (Posisi Tengah - Lebih tinggi)
                        if (rank1 != null)
                          _PodiumCard(
                            rank: "#1",
                            name: rank1.name,
                            points: rank1.points,
                            color: _getRankColor(1), // Colors.amber
                            height: 160,
                            isFirst: true,
                          ),

                        const SizedBox(width: 14),

                        // #3 (Posisi Kanan)
                        if (rank3 != null)
                          _PodiumCard(
                            rank: "#3",
                            name: rank3.name,
                            points: rank3.points,
                            color: _getRankColor(3), // Colors.grey
                            height: 130,
                          )
                        else
                          const SizedBox(width: 90),
                      ],
                    ),

                  const SizedBox(height: 25),

                  // ✅ Rank list (Rank 4 ke bawah)
                  Column(
                    children: listRankings.map((item) {
                      return _RankTile(
                        rank: item.rank,
                        name: item.name,
                        reports: item.reports,
                        points: item.points,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

// ===========================================================================
// ✅ PODIUM CARD SESUAI DESAIN (TIDAK BERUBAH SAMA SEKALI)
// ===========================================================================
class _PodiumCard extends StatelessWidget {
  final String rank;
  final String name;
  final int points;
  final Color color;
  final bool isFirst;
  final double height;

  const _PodiumCard({
    required this.rank,
    required this.name,
    required this.points,
    required this.color,
    required this.height,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.emoji_events, color: color, size: 32),
        const SizedBox(height: 8),
        Container(
          width: 90,
          height: height,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color, width: 2),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rank,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines:
                    2, // Tambahan safe guard agar nama panjang tidak overflow
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  Text(
                    " $points",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// ✅ RANK TILE LIST (#4 - #9) (TIDAK BERUBAH SAMA SEKALI)
// ===========================================================================
class _RankTile extends StatelessWidget {
  final int rank;
  final String name;
  final int reports;
  final int points;

  const _RankTile({
    required this.rank,
    required this.name,
    required this.reports,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // Rank Circle
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD54F),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "#$rank",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name + Reports
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  "$reports Laporan",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),

          // Points
          Row(
            children: [
              const Icon(Icons.star, size: 18, color: Colors.amber),
              Text(
                " $points",
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
