import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'theme.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? _selectedType;

  // ✅ tambah dropdown lokasi
  String? _selectedLocation;
  final List<String> _locations = [
    "Tower A",
    "Gedung Utama",
    "Depan Tekno",
  ];

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _slotController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  void _showConfirmDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: "Konfirmasi Laporan",
      desc:
          "Apakah informasi yang kamu berikan sudah benar?\nKamu akan mendapatkan +5 poin.",
      btnOkText: "Ya, kirim",
      btnCancelText: "Cek lagi",
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        _showSuccessDialog();
      },
      btnOkColor: AppColors.yellow,
      btnCancelColor: Colors.grey.shade300,
    ).show();
  }

  void _showSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: "Laporan Berhasil!",
      desc: "Terima kasih atas kontribusimu 🙌\nKamu mendapat +5 poin.",
      btnOkText: "Tutup",
      btnOkColor: AppColors.yellow,
      btnOkOnPress: () {
        setState(() {
          _selectedType = null;
          _selectedLocation = null;
          _locationController.clear();
          _slotController.clear();
          _noteController.clear();
        });
      },
    ).show();
  }

  void _validateAndConfirm() {
    if (_selectedType == null ||
        _selectedLocation == null || // ✅ validasi dropdown
        _slotController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: "Data belum lengkap",
        desc: "Lengkapi semua data wajib sebelum mengirim laporan!",
        btnOkOnPress: () {},
        btnOkColor: Colors.orange,
      ).show();
      return;
    }
    _showConfirmDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporkan spot parkir"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bantu pengguna lain dan dapatkan poin!",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // --- Jenis laporan ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Jenis laporan",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  _radioTile("baru", "Spot parkir baru +10 poin"),
                  _radioTile("update", "Update ketersediaan +5 poin"),
                  _radioTile("penuh", "Laporkan spot penuh +5 poin"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Lokasi parkir ---
            _label("Lokasi parkir*"),

            // ✅ Dropdown pengganti TextField
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: _inputDecoration("Pilih lokasi parkir"),
              items: _locations
                  .map((loc) => DropdownMenuItem(
                        value: loc,
                        child: Text(loc),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value;
                  _locationController.text = value!; // tetap simpan untuk logic lama
                });
              },
            ),

            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.my_location_outlined),
              label: const Text("Gunakan lokasi saat ini"),
            ),
            const SizedBox(height: 20),

            // --- Slot tersedia ---
            _label("Slot tersedia*"),
            TextField(
              controller: _slotController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("Masukkan jumlah slot tersedia"),
            ),
            const SizedBox(height: 20),

            // --- Catatan tambahan ---
            _label("Catatan tambahan"),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: _inputDecoration(
                "Contoh: Parkir ilegal di dekat trotoar parkiran TA...",
              ),
            ),
            const SizedBox(height: 20),

            // --- Foto opsional ---
            _label("Foto (opsional)"),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          size: 32, color: Colors.black45),
                      SizedBox(height: 6),
                      Text("Tambahkan foto",
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Tombol Kirim Laporan ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _validateAndConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Kirim Laporan",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Tips poin ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.yellow.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tips mendapat poin lebih banyak:',
                    style: TextStyle(
                      color: Color(0xFFEF9A00),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  _TipItem("Laporan akurat (+ bonus 5 poin)"),
                  _TipItem("Tambahkan foto (+3 poin)"),
                  _TipItem("Update berkala (+2 poin / update)"),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // helper radio
  Widget _radioTile(String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedType,
      onChanged: (v) => setState(() => _selectedType = v),
      title: Text(label),
      dense: true,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.yellow,
    );
  }

  // helper text label
  Widget _label(String text) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15));

  // helper input decoration
  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      );
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFFEF9A00))),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
