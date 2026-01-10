import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';
import 'theme.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'dart:io'; // Untuk cek Platform (Android/Windows)

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ApiService _apiService = ApiService();

  List<NotifData> _notifList = [];
  bool _isLoading = true; // Status loading

  // TODO: Ganti ini dengan Token asli dari Login (SharedPreferences/SecureStorage)

  @override
  void initState() {
    super.initState();
    _fetchData(); // Ambil data dari API saat halaman dibuka
  }

  // Fungsi Ambil Data dari API
  Future<void> _fetchData() async {
    try {
      final data = await _apiService.getNotifications();
      setState(() {
        _notifList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi Tandai Baca
  Future<void> _markRead(int index) async {
    final notif = _notifList[index];
    if (notif.isRead) return;

    setState(() {
      notif.isRead = true;
    });

    try {
      if (notif.id != null) {
        await _apiService.markAsRead(notif.id!);
      }
    } catch (e) {
      print("Gagal mark as read: $e");
    }
  }

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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              color: AppColors.dark,
                            ),
                      ),
                      const SizedBox(width: 6),

                      // Badge hanya muncul jika ada yang belum dibaca
                      if (_notifList.any((n) => !n.isRead))
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            // Hitung jumlah yang isRead == false
                            _notifList
                                .where((n) => !n.isRead)
                                .length
                                .toString(),
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
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator()) // Loading Indicator
                    : _notifList.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada notifikasi',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : RefreshIndicator(
                            // Tarik ke bawah untuk refresh
                            onRefresh: _fetchData,
                            child: ListView.builder(
                              itemCount: _notifList.length,
                              itemBuilder: (context, index) {
                                final notif = _notifList[index];
                                return _NotifItem(
                                  data: notif,
                                  onTap: () => _markRead(index),
                                );
                              },
                            ),
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
// MODEL DATA (Disesuaikan agar menyimpan ID dan Status Baca)
// =======================================================
class NotifData {
  final int? id; // Tambahkan ID agar bisa delete/update ke API
  final NotifIconType type;
  final String title;
  final String desc;
  final String time;
  final String location;
  bool isRead; // Tambahkan status baca (mutable)

  NotifData({
    this.id,
    required this.type,
    required this.title,
    required this.desc,
    required this.time,
    required this.location,
    this.isRead = false,
  });

  factory NotifData.fromLaravel(Map<String, dynamic> json) {
    NotifIconType iconType;
    String generatedTitle;

    switch (json['tipe_notif']) {
      case 'Update_Status':
        iconType = NotifIconType.check;
        generatedTitle = 'Laporan Disetujui';
        break;

      case 'Permintaan_Verifikasi':
        iconType = NotifIconType.warning;
        generatedTitle = 'Laporan Ditolak';
        break;

      case 'Login_Streak':
        iconType = NotifIconType.fire;
        generatedTitle = 'Login Harian';
        break;

      default:
        iconType = NotifIconType.check;
        generatedTitle = 'Informasi Laporan';
    }

    String timeAgoString = '';
    try {
      final createdDate = DateTime.parse(json['dibuat_pada']);
      final diff = DateTime.now().difference(createdDate);
      if (diff.inMinutes < 60) {
        timeAgoString = '${diff.inMinutes} menit lalu';
      } else if (diff.inHours < 24) {
        timeAgoString = '${diff.inHours} jam lalu';
      } else {
        timeAgoString = DateFormat('dd MMM').format(createdDate);
      }
    } catch (e) {
      timeAgoString = 'Baru saja';
    }

    return NotifData(
      id: json['notif_id'], // Simpan ID
      type: iconType,
      title: generatedTitle,
      desc: json['pesan'],
      time: timeAgoString,
      // Karena DB tidak punya lokasi, kita kosongkan atau ambil dari pesan jika ada logika khusus
      location: '',
      // Handle boolean dari Laravel (bisa 1/0 atau true/false)
      isRead: json['sudah_dibaca'] == 1 || json['sudah_dibaca'] == true,
    );
  }
}

enum NotifIconType { warning, location, chart, check, fire }

// =======================================================
// ITEM WIDGET (Update Sedikit untuk Visual Status Baca)
// =======================================================
class _NotifItem extends StatelessWidget {
  final NotifData data;
  final VoidCallback onTap; // Tambahkan aksi tap

  const _NotifItem({
    required this.data,
    required this.onTap,
  });

  Widget _buildIcon() {
    switch (data.type) {
      case NotifIconType.warning:
        return const Icon(Icons.error_outline, size: 26, color: Colors.red);
      case NotifIconType.location:
        return const Icon(Icons.location_on_outlined,
            size: 26, color: Colors.orange);
      case NotifIconType.chart:
        return const Icon(Icons.show_chart, size: 26, color: Colors.green);
      case NotifIconType.check:
        return const Icon(Icons.check_circle_outline,
            size: 26, color: Colors.blue);
      case NotifIconType.fire:
        return const Icon(
          Icons.local_fire_department,
          size: 26,
          color: Colors.deepOrange,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Agar bisa diklik untuk mark as read
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Jika belum dibaca, background sedikit abu-abu, jika sudah putih
          color: data.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: data.isRead
                ? AppColors.cardBorder
                : Colors.blue.withOpacity(0.3),
            width: data.isRead ? 1 : 1.5, // Border lebih tebal jika belum baca
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildIcon(),
                    const SizedBox(width: 10),
                    Text(
                      data.title,
                      style: TextStyle(
                        // Font lebih tebal jika belum baca
                        fontWeight:
                            data.isRead ? FontWeight.w700 : FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.dark,
                      ),
                    ),
                    if (!data.isRead) ...[
                      // Titik merah penanda belum dibaca
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      )
                    ]
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              data.desc,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.black45),
                const SizedBox(width: 4),
                Text(
                  data.time,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                if (data.location.isNotEmpty) ...[
                  const SizedBox(width: 14),
                  const Icon(Icons.location_pin,
                      size: 14, color: Colors.black45),
                  const SizedBox(width: 4),
                  Text(
                    data.location,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
