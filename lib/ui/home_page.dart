import 'package:flutter/material.dart';
import 'map_page.dart';
import 'profile_page.dart';
import 'gift_page.dart';
import 'achive_page.dart';
import 'theme.dart';
import 'notification_page.dart';
import 'report_page.dart';
import '../ui/parking_card_model.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    MapPage(),
    const GiftPage(),
    const LeaderboardPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: _pages[_tabIndex],

      // ================= BOTTOM NAV =================
      bottomNavigationBar: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 'Beranda', 0),
            _navItem(Icons.location_on_outlined, 'Peta', 1),
            _navItem(Icons.card_giftcard_outlined, 'Hadiah', 2),
            _navItem(Icons.emoji_events_outlined, 'Peringkat', 3),
            _navItem(Icons.person_outline, 'Profil', 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = _tabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? AppColors.yellow : Colors.black38),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.yellow : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// HOME CONTENT
/// =======================================================
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int challengeProgress = 0;
  final int challengeTarget = 2;
  bool rewardClaimed = false;

  late Future<List<ParkingCardModel>> _parkingFuture;

  @override
  void initState() {
    super.initState();
    _parkingFuture = ApiService().fetchParkingCards();
  }

  void _onReport(BuildContext context) {
    if (challengeProgress < challengeTarget) {
      setState(() {
        challengeProgress++;
      });

      if (challengeProgress == challengeTarget && !rewardClaimed) {
        rewardClaimed = true;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Tantangan selesai! +50 poin'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressRatio = challengeProgress / challengeTarget;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 16),
            _challengeCard(progressRatio),
            const SizedBox(height: 24),
            const Text(
              'Spot parkir kampus',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<ParkingCardModel>>(
              future: _parkingFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }

                final parkings = snapshot.data!;

                return Column(
                  children: parkings.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _parkingCard(
                        context,
                        title: p.namaArea,
                        used: p.used,
                        total: p.totalSlot,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Selamat datang!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationPage(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // ================= TANTANGAN =================
  Widget _challengeCard(double ratio) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tantangan hari ini',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    const Text('Laporkan 2 spot parkir kampus'),
                  ],
                ),
              ),
              Column(
                children: const [
                  Icon(Icons.lightbulb_outline, size: 32),
                  SizedBox(height: 4),
                  Text('+50 poin',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: Colors.white54,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$challengeProgress / $challengeTarget',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ================= PARKING CARD =================
  Widget _parkingCard(
    BuildContext context, {
    required String title,
    required int used,
    required int total,
  }) {
    final ratio = used / total;
    final available = used < total * 0.8;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text('Slot parkir\n$used / $total'),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    color: AppColors.yellow,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _onReport(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Laporkan kondisi'),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: available ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              available ? 'Tersedia' : 'Terbatas',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
    );
  }
}
