enum NotifType {
  updateStatus,
  updatePeringkat,
  rekomendasi,
  permintaanVerifikasi,
  unknown
}

class NotifModel {
  final int id; // notif_id
  final int userId; // pengguna_id
  final NotifType type; // tipe_notif (ENUM)
  final String message; // pesan
  bool isRead; // sudah_dibaca
  final DateTime createdAt; // dibuat_pada

  NotifModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  // Factory untuk parsing JSON dari API Laravel
  factory NotifModel.fromJson(Map<String, dynamic> json) {
    return NotifModel(
      id: json['notif_id'],
      userId: json['pengguna_id'],
      type: _parseType(json['tipe_notif']),
      message: json['pesan'],
      // Laravel mengirim boolean sebagai 1/0 atau true/false
      isRead: json['sudah_dibaca'] == 1 || json['sudah_dibaca'] == true,
      createdAt: DateTime.parse(json['dibuat_pada']),
    );
  }

  // Helper konversi String DB ke Enum Flutter
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
}
