enum NotifType {
  updateStatus,
  updatePeringkat,
  rekomendasi,
  permintaanVerifikasi,
  unknown
}

class NotifModel {
  final int id;
  final int userId;
  final NotifType type;
  final String message;
  bool isRead;
  final DateTime createdAt;

  NotifModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  // ===== DARI API (Laravel → Flutter) =====
  factory NotifModel.fromJson(Map<String, dynamic> json) {
    return NotifModel(
      id: json['notif_id'],
      userId: json['pengguna_id'],
      type: _parseType(json['tipe_notif']),
      message: json['pesan'],
      isRead: json['sudah_dibaca'] == 1 || json['sudah_dibaca'] == true,
      createdAt: DateTime.parse(json['dibuat_pada']),
    );
  }

  // ===== KE API / LOCAL / PAYLOAD =====
  Map<String, dynamic> toJson() {
    return {
      'notif_id': id,
      'pengguna_id': userId,
      'tipe_notif': _typeToString(type),
      'pesan': message,
      'sudah_dibaca': isRead ? 1 : 0,
      'dibuat_pada': createdAt.toIso8601String(),
    };
  }

  // ===== HELPER =====
  static NotifType _parseType(String type) {
    switch (type) {
      case 'Update_Status':
        return NotifType.updateStatus;
      case 'Update_Peringkat':
        return NotifType.updatePeringkat;
      case 'Rekomendasi':
        return NotifType.rekomendasi;
      case 'Permintaan_Verifikasi':
        return NotifType.permintaanVerifikasi;
      default:
        return NotifType.unknown;
    }
  }

  static String _typeToString(NotifType type) {
    switch (type) {
      case NotifType.updateStatus:
        return 'Update_Status';
      case NotifType.updatePeringkat:
        return 'Update_Peringkat';
      case NotifType.rekomendasi:
        return 'Rekomendasi';
      case NotifType.permintaanVerifikasi:
        return 'Permintaan_Verifikasi';
      default:
        return 'Unknown';
    }
  }
}
