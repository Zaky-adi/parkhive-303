import 'package:flutter/material.dart';
import 'theme.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<NotifData> _notifList = [
    NotifData(
      type: NotifIconType.warning,
      title: 'Parkir hampir penuh',
      desc: 'Parkir TA tinggal 3 slot. Pertimbangkan parkir alternatif.',
      time: '3 menit lalu',
      location: 'TA',
    ),
    NotifData(
      type: NotifIconType.location,
      title: 'Update Ketersediaan',
      desc: 'Parkir GU sekarang tersedia 15 slot.',
      time: '5 menit lalu',
      location: 'GU',
    ),
    NotifData(
      type: NotifIconType.chart,
      title: 'Poin baru!',
      desc: 'Kamu mendapat +10 poin dari laporan terbaru.',
      time: '7 menit lalu',
      location: '',
    ),
    NotifData(
      type: NotifIconType.check,
      title: 'Spot baru ditemukan',
      desc: 'User lain menemukan spot parkir baru di gedung TA samping.',
      time: '10 menit lalu',
      location: 'TA',
    ),
  ];

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
              // ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Notifikasi',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  color: AppColors.dark,
                                ),
                      ),
                      const SizedBox(width: 6),

                      if (_notifList.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _notifList.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
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

              // ================= LIST =================
              Expanded(
                child: _notifList.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada notifikasi',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notifList.length,
                        itemBuilder: (context, index) {
                          final notif = _notifList[index];
                          return _NotifItem(
                            data: notif,
                            onClose: () {
                              setState(() {
                                _notifList.removeAt(index);
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================
// MODEL DATA
// =======================================================
class NotifData {
  final NotifIconType type;
  final String title;
  final String desc;
  final String time;
  final String location;

  NotifData({
    required this.type,
    required this.title,
    required this.desc,
    required this.time,
    required this.location,
  });
}

// ENUM UNTUK ICON
enum NotifIconType { warning, location, chart, check }

// =======================================================
// ITEM WIDGET
// =======================================================
class _NotifItem extends StatelessWidget {
  final NotifData data;
  final VoidCallback onClose;

  const _NotifItem({
    required this.data,
    required this.onClose,
  });

  Widget _buildIcon() {
    switch (data.type) {
      case NotifIconType.warning:
        return const Icon(Icons.error_outline,
            size: 26, color: Colors.red);
      case NotifIconType.location:
        return const Icon(Icons.location_on_outlined,
            size: 26, color: Colors.orange);
      case NotifIconType.chart:
        return const Icon(Icons.show_chart,
            size: 26, color: Colors.green);
      case NotifIconType.check:
        return const Icon(Icons.check_circle_outline,
            size: 26, color: Colors.blue);
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
          // ===== TITLE =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildIcon(),
                  const SizedBox(width: 10),
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close_rounded,
                    size: 18, color: Colors.black54),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ===== DESC =====
          Text(
            data.desc,
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
              const Icon(Icons.access_time,
                  size: 14, color: Colors.black45),
              const SizedBox(width: 4),
              Text(
                data.time,
                style:
                    const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              if (data.location.isNotEmpty) ...[
                const SizedBox(width: 14),
                const Icon(Icons.location_pin,
                    size: 14, color: Colors.black45),
                const SizedBox(width: 4),
                Text(
                  data.location,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
