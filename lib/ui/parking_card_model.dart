class ParkingCardModel {
  final int areaId;
  final String namaArea;
  final int totalSlot;
  final int slotTersedia;
  final int used;
  final String status;
  final String sumber;

  ParkingCardModel({
    required this.areaId,
    required this.namaArea,
    required this.totalSlot,
    required this.slotTersedia,
    required this.used,
    required this.status,
    required this.sumber,
  });

  factory ParkingCardModel.fromJson(Map<String, dynamic> json) {
    return ParkingCardModel(
      areaId: json['area_id'],
      namaArea: json['nama_area'],
      totalSlot: json['total_slot'],
      slotTersedia: json['slot_tersedia'],
      used: json['used'],
      status: json['status'],
      sumber: json['sumber'],
    );
  }
}
