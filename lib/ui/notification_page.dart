import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../services/api_service.dart';
import '../ui/notification_service.dart';
import '../ui/notif_data.dart';
import '../ui/notif_ui_extension.dart';
import '../ui/notif_time_extension.dart';
import 'theme.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ApiService _apiService = ApiService();

  List<NotifData> _notifList = [];
  bool _isLoading = true;

  final String _userToken = "TOKEN_DUMMY_DARI_LOGIN";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().init();
    });

    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final models = await _apiService.getNotifications(_userToken);

      final data = models.map(NotifData.fromModel).toList();

      if (data.any((n) => !n.isRead)) {
        NotificationService().showNotification(
          id: 100,
          title: 'Notifikasi Baru',
          body: 'Ada notifikasi baru untuk Anda',
        );
      }

      if (!mounted) return;
      setState(() {
        _notifList = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markRead(int index) async {
    final notif = _notifList[index];
    if (notif.isRead) return;

    setState(() {
      _notifList[index] = notif.copyWith(isRead: true);
    });

    try {
      await _apiService.markAsRead(notif.id, _userToken);
    } catch (_) {
      setState(() {
        _notifList[index] = notif;
      });
    }
  }

  Future<void> _deleteNotif(int index) async {
    final notif = _notifList[index];
    setState(() => _notifList.removeAt(index));

    try {
      await _apiService.deleteNotification(notif.id, _userToken);
    } catch (_) {
      setState(() => _notifList.insert(index, notif));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final unread = _notifList.where((n) => !n.isRead).length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Notifikasi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Text(
                  unread.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            ],
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notifList.isEmpty) {
      return const Center(child: Text('Tidak ada notifikasi'));
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        itemCount: _notifList.length,
        itemBuilder: (_, index) {
          final notif = _notifList[index];
          return _NotifItem(
            data: notif,
            onTap: () => _markRead(index),
            onClose: () => _deleteNotif(index),
          );
        },
      ),
    );
  }
}

// =======================================================
// MODEL DATA (DATA ONLY — TANPA UI)
// =======================================================

// =======================================================
// NOTIFICATION SERVICE (SUDAH BENAR)
// =======================================================

// =======================================================
// ITEM UI (PAKAI EXTENSION)
// =======================================================

class _NotifItem extends StatelessWidget {
  final NotifData data;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _NotifItem({
    required this.data,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: data.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: data.isRead
                ? AppColors.cardBorder
                : Colors.blue.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(data.icon, color: data.iconColor, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    data.title,
                    style: TextStyle(
                      fontWeight:
                          data.isRead ? FontWeight.w700 : FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onClose,
                  child: const Icon(Icons.close_rounded, size: 18),
                )
              ],
            ),
            const SizedBox(height: 6),
            Text(data.desc),
            const SizedBox(height: 10),
            Text(
              data.time,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
