import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Top 3 data
    final List<Map<String, dynamic>> top3 = [
      {'rank': 2, 'name': 'Boyu', 'points': 1240, 'color': Colors.blue},
      {'rank': 1, 'name': 'Ahmad', 'points': 1300, 'color': Colors.amber},
      {'rank': 3, 'name': 'Gilang', 'points': 1200, 'color': Colors.grey},
    ];

    // ✅ Other ranks
    final List<Map<String, dynamic>> list = [
      {'rank': 4, 'name': 'Nada', 'reports': 12, 'points': 1150},
      {'rank': 5, 'name': 'Luna', 'reports': 11, 'points': 1110},
      {'rank': 6, 'name': 'Tio', 'reports': 10, 'points': 1000},
      {'rank': 7, 'name': 'Siska', 'reports': 9, 'points': 950},
      {'rank': 8, 'name': 'Lusi', 'reports': 8, 'points': 900},
      {'rank': 9, 'name': 'Rafi Pratama', 'reports': 7, 'points': 750},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ Header Top Section
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
                    "Top kontributor Kampus - Oktober 2025",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // #2
                _PodiumCard(
                  rank: "#2",
                  name: top3[0]['name'],
                  points: top3[0]['points'],
                  color: top3[0]['color'],
                  height: 130,
                ),
                const SizedBox(width: 14),

                // #1 (lebih tinggi)
                _PodiumCard(
                  rank: "#1",
                  name: top3[1]['name'],
                  points: top3[1]['points'],
                  color: top3[1]['color'],
                  height: 160,
                  isFirst: true,
                ),
                const SizedBox(width: 14),

                // #3
                _PodiumCard(
                  rank: "#3",
                  name: top3[2]['name'],
                  points: top3[2]['points'],
                  color: top3[2]['color'],
                  height: 130,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ✅ Rank list
            Column(
              children: list.map((item) {
                return _RankTile(
                  rank: item['rank'],
                  name: item['name'],
                  reports: item['reports'],
                  points: item['points'],
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
// ✅ PODIUM CARD SESUAI DESAIN
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
// ✅ RANK TILE LIST (#4 - #9)
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
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F),
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
                  style:
                      const TextStyle(color: Colors.black54, fontSize: 13),
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
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
