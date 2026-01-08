int hitungPoinLaporan(Map<String, dynamic> laporan) {
  if (laporan['status'] != 'Terverifikasi') {
    return 0;
  }

  switch (laporan['tipe_laporan']) {
    case 'Parkir_Ilegal':
      return 15;
    case 'Koreksi_Data':
      return 5;
    case 'Update_Status':
      return 5;
    default:
      return 0;
  }
}
