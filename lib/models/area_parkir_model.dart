class AreaParkirModel {
  final int areaId;
  final String namaArea;

  AreaParkirModel({
    required this.areaId,
    required this.namaArea,
  });

  factory AreaParkirModel.fromJson(Map<String, dynamic> json) {
    return AreaParkirModel(
      areaId: json['area_id'],
      namaArea: json['nama_area'],
    );
  }
}
