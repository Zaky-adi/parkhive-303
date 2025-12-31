class AreaParkirModel {
  final int areaId;
  final String namaArea;
  final double lintang;
  final double bujur;
  final int totalSlot;
  final String? deskripsi;
  final bool terverifikasi;

  AreaParkirModel({
    required this.areaId,
    required this.namaArea,
    required this.lintang,
    required this.bujur,
    required this.totalSlot,
    this.deskripsi,
    required this.terverifikasi,
  });

  factory AreaParkirModel.fromJson(Map<String, dynamic> json) {
    return AreaParkirModel(
      areaId: json['area_id'],
      namaArea: json['nama_area'],
      lintang: double.parse(json['lintang'].toString()),
      bujur: double.parse(json['bujur'].toString()),
      totalSlot: json['total_slot'],
      deskripsi: json['deskripsi'],
      terverifikasi: json['terverifikasi'] == 1,
    );
  }
}
