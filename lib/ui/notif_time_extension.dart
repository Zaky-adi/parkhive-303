import 'package:flutter/material.dart';
import 'notification_model.dart';

extension NotifTypeUI on NotifType {
  IconData get icon {
    switch (this) {
      case NotifType.updateStatus:
        return Icons.warning_amber_rounded;
      case NotifType.updatePeringkat:
        return Icons.bar_chart_rounded;
      case NotifType.rekomendasi:
        return Icons.location_on_rounded;
      case NotifType.permintaanVerifikasi:
        return Icons.check_circle_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotifType.updateStatus:
        return Colors.orange;
      case NotifType.updatePeringkat:
        return Colors.blue;
      case NotifType.rekomendasi:
        return Colors.green;
      case NotifType.permintaanVerifikasi:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
