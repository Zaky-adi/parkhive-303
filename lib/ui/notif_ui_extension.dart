import 'package:flutter/material.dart';
import '../ui/notification_model.dart';
import 'package:intl/intl.dart';

extension NotifUI on NotifModel {
  IconData get icon {
    switch (type) {
      case NotifType.updateStatus:
        return Icons.error_outline;
      case NotifType.rekomendasi:
        return Icons.location_on_outlined;
      case NotifType.updatePeringkat:
        return Icons.show_chart;
      case NotifType.permintaanVerifikasi:
        return Icons.check_circle_outline;
      default:
        return Icons.notifications;
    }
  }

  Color get iconColor {
    switch (type) {
      case NotifType.updateStatus:
        return Colors.red;
      case NotifType.rekomendasi:
        return Colors.orange;
      case NotifType.updatePeringkat:
        return Colors.green;
      case NotifType.permintaanVerifikasi:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String get title {
    switch (type) {
      case NotifType.updateStatus:
        return 'Parkir hampir penuh';
      case NotifType.rekomendasi:
        return 'Update Ketersediaan';
      case NotifType.updatePeringkat:
        return 'Poin Baru';
      case NotifType.permintaanVerifikasi:
        return 'Permintaan Verifikasi';
      default:
        return 'Notifikasi';
    }
  }

  String get desc => message;

  String get time {
    final diff = DateTime.now().difference(createdAt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else {
      return DateFormat('dd MMM').format(createdAt);
    }
  }
}
