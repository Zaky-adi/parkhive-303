import 'package:flutter/material.dart';
import 'theme.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Notifikasi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              color: AppColors.dark,
                            ),
                      ),
                      const SizedBox(width: 6),

                      // Badge notif baru
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '2',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 26, color: AppColors.dark),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ===== LIST NOTIFIKASI =====
              Expanded(
                child: ListView(
                  children: const [
                    _NotifItem(
                      icon: Icons.error_outline,
                      iconColor: Colors.red,
                      customIconType: NotifIconType.warning,
                      title: 'Parkir hampir penuh',
                      desc:
                          'Parkir TA tinggal 3 slot. Pertimbangkan parkir alternatif.',
                      time: '3 menit lalu',
                      location: 'TA',
                    ),
                    _NotifItem(
                      icon: Icons.location_on_outlined,
                      iconColor: Colors.orange,
                      customIconType: NotifIconType.location,
                      title: 'Update Ketersediaan',
                      desc: 'Parkir GU sekarang tersedia 15 slot.',
                      time: '5 menit lalu',
                      location: 'TA',
                    ),
                    _NotifItem(
                      icon: Icons.show_chart,
                      iconColor: Colors.green,
                      customIconType: NotifIconType.chart,
                      title: 'Poin baru!',
                      desc: 'Kamu mendapat +10 poin dari laporan terbaru.',
                      time: '7 menit lalu',
                      location: '',
                    ),
                    _NotifItem(
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.blue,
                      customIconType: NotifIconType.check,
                      title: 'Spot baru ditemukan',
                      desc:
                          'User lain menemukan spot parkir baru di gedung TA samping.',
                      time: '4 menit lalu',
                      location: 'TA',
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

// ENUM UNTUK TIPE ICON
enum NotifIconType { warning, location, chart, check }

class _NotifItem extends StatelessWidget {
  final IconData icon;
  final NotifIconType customIconType;
  final Color iconColor;
  final String title;
  final String desc;
  final String time;
  final String location;

  const _NotifItem({
    required this.icon,
    required this.customIconType,
    required this.iconColor,
    required this.title,
    required this.desc,
    required this.time,
    required this.location,
  });

  // Custom icon sesuai desain UI
  Widget buildCustomIcon() {
    switch (customIconType) {
      case NotifIconType.warning:
        return Icon(Icons.error_outline, size: 26, color: Colors.red);
      case NotifIconType.location:
        return Icon(Icons.location_on_outlined, size: 26, color: Colors.orange);
      case NotifIconType.chart:
        return Icon(Icons.show_chart, size: 26, color: Colors.green);
      case NotifIconType.check:
        return Icon(Icons.check_circle_outline, size: 26, color: Colors.blue);
      default:
        return Icon(icon, size: 26, color: iconColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== TITLE, ICON, CLOSE =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  buildCustomIcon(),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.dark),
                  ),
                ],
              ),
              const Icon(Icons.close_rounded, size: 18, color: Colors.black54),
            ],
          ),

          const SizedBox(height: 6),

          // ===== DESCRIPTION =====
          Text(
            desc,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

          // ===== TIME & LOCATION =====
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.black45),
              const SizedBox(width: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              if (location.isNotEmpty) ...[
                const SizedBox(width: 14),
                const Icon(Icons.location_pin, size: 14, color: Colors.black45),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
