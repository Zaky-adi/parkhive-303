import 'package:flutter/material.dart';
import 'map_page.dart';
import 'profile_page.dart';
import 'report_page.dart';
import 'achive_page.dart';
import 'theme.dart';
import 'notification_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;

  final _pages = [
    const HomeContent(),
    MapPage(),
    const ReportPage(),
    const LeaderboardPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_tabIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _tabIndex = 2),
        backgroundColor: AppColors.yellow,
        child: const Icon(Icons.add, color: Colors.black, size: 32),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              navButton(Icons.home_outlined, 0),
              navButton(Icons.location_on_outlined, 1),
              const SizedBox(width: 56),
              navButton(Icons.emoji_events_outlined, 3),
              navButton(Icons.person_outline, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget navButton(IconData icon, int index) {
    final active = index == _tabIndex;
    return IconButton(
      onPressed: () => setState(() => _tabIndex = index),
      icon: Icon(icon, color: active ? AppColors.yellow : Colors.black54),
    );
  }
}

// ================== HOME CONTENT ==================
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerCard(context),
            const SizedBox(height: 18),

            sectionTitle('Parkir terdekat'),
            const SizedBox(height: 10),
            areaCard(context, 'Parkiran GU', '50 m', '13/20 Tersedia', 'Mobil', true),
            const SizedBox(height: 10),
            areaCard(context, 'Parkiran TA', '100 m', '3/20 Penuh', 'Motor', false),
            const SizedBox(height: 10),
            areaCard(context, 'Parkiran PPU', '20 m', '19/20 Tersedia', 'Mobil', true),
            const SizedBox(height: 20),

            sectionTitle('Aktivitas terbaru'),
            const SizedBox(height: 10),
            activityCard('Novia', 'melaporkan spot baru di parkiran TA', '5 menit lalu', '+10 poin'),
            const SizedBox(height: 8),
            activityCard('Putri', 'melaporkan spot penuh di parkiran GU', '3 menit lalu', '+5 poin'),
            const SizedBox(height: 8),
            activityCard('Ridho', 'mengonfirmasi ketersediaan di parkiran Belakang', '4 menit lalu', '+5 poin'),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ===== HEADER CARD =====
  static Widget headerCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hai!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  SizedBox(height: 4),
                  Text('Cari parkir terdekat yuk!', style: TextStyle(fontSize: 16)),
                ],
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationPage()),
                        );
                      },
                      icon: const Icon(Icons.notifications_none_rounded, color: Colors.black),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
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
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              statBox(Icons.local_parking, '12', 'Spot dilaporkan'),
              statBox(Icons.star_border, '500', 'Poin'),
              statBox(Icons.trending_up, '#15', 'Peringkat'),
            ],
          ),
        ],
      ),
    );
  }

  static Widget statBox(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black, size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ===== PARKIR CARD =====
  static Widget areaCard(
    BuildContext context,
    String title,
    String distance,
    String availability,
    String type,
    bool available,
  ) {
    Color statusColor = available ? AppColors.yellow : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
              const SizedBox(width: 4),
              Text(distance, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  availability,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(type, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => const RecommendationSheet(),
                  );
                },
                child: const Text(
                  'Lihat parkir alternatif →',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget activityCard(String name, String message, String time, String point) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: '$name ',
                      style: const TextStyle(color: Color(0xFFEF9A00), fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: message),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.black45),
                  const SizedBox(width: 4),
                  Text(time, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ]),
          ),
          Text(point,
              style: const TextStyle(color: AppColors.deepYellow, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  static Widget sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700));
  }
}

// ======= BOTTOM SHEET REKOMENDASI =======
class RecommendationSheet extends StatelessWidget {
  const RecommendationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.45,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              const Center(
                child: Text('Rekomendasi terbaik',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              ),
              const SizedBox(height: 18),
              parkirItem('Parkir samping TA', '50 m', '13/20 Tersedia', 'Motor'),
              const SizedBox(height: 12),
              parkirItem('Parkir belakang GU', '70 m', '17/20 Tersedia', 'Mobil'),
            ],
          ),
        );
      },
    );
  }

  static Widget parkirItem(String name, String distance, String available, String type) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
              const SizedBox(width: 4),
              Text(distance, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.yellow),
                ),
                child: Text(available,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.yellow)),
              ),
              const SizedBox(width: 10),
              Text(type, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
