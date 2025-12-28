import 'dart:io';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

import '../services/api_service.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  // ================= DROPDOWN DATA =================
  final Map<int, String> _lokasiParkirMap = {
    1: "Parkir Gedung Utama",
    2: "Parkir Tower A",
    3: "Parkir Technopreneur",
  };

  int? _selectedLokasiId;
  String? _selectedType;
  File? _imageFile;

  bool _isSubmitting = false;

  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _slotController = TextEditingController();

  // ================= IMAGE =================
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = (!kIsWeb &&
              (Platform.isAndroid || Platform.isIOS))
          ? await _picker.pickImage(
              source: ImageSource.camera,
              imageQuality: 80,
            )
          : await _picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
            );

      if (pickedFile == null) return;

      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengambil foto"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= SUBMIT =================
  Future<void> _submitLaporan() async {
    if (_selectedType == null ||
        _selectedLokasiId == null ||
        _noteController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: "Data belum lengkap",
        desc: "Lengkapi semua data wajib!",
      ).show();
      return;
    }

    try {
      setState(() => _isSubmitting = true);

      await _apiService.kirimLaporan(
        areaId: _selectedLokasiId!, // ✅ INT
        tipeLaporan: _selectedType!,
        detailLaporan: _noteController.text,
        foto: _imageFile,
      );

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: "Berhasil",
        desc: "Laporan berhasil dikirim",
        btnOkOnPress: () {
          setState(() {
            _selectedType = null;
            _selectedLokasiId = null;
            _imageFile = null;
            _noteController.clear();
            _slotController.clear();
          });
        },
      ).show();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: "Gagal",
        desc: e.toString(),
      ).show();
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Laporkan spot parkir",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _jenisLaporanCard(),
            const SizedBox(height: 20),

            _label("Lokasi parkir*"),
            DropdownButtonFormField<int>(
              value: _selectedLokasiId,
              decoration: _inputDecoration(
                "Pilih lokasi parkir",
                icon: Icons.location_on_outlined,
              ),
              items: _lokasiParkirMap.entries
                  .map(
                    (e) => DropdownMenuItem<int>(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedLokasiId = v),
            ),

            if (_selectedType == "UPDATE") ...[
              const SizedBox(height: 16),
              _label("Slot tersedia*"),
              TextField(
                controller: _slotController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Jumlah slot tersedia"),
              ),
            ],

            const SizedBox(height: 16),
            _label("Catatan tambahan"),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: _inputDecoration(
                "Contoh: Parkir ilegal di dekat trotoar parkiran TA pada pagi hari.",
              ),
            ),

            const SizedBox(height: 20),
            _label("Foto (opsional)"),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black26),
                ),
                child: _imageFile == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 36, color: Colors.black45),
                          SizedBox(height: 8),
                          Text("Tambah foto",
                              style: TextStyle(color: Colors.black54)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
            _tipsCard(),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLaporan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Kirim Laporan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI PART =================

  Widget _jenisLaporanCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Laporkan spot parkir",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              "Bantu pengguna lain dan dapatkan poin!",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            const Text(
              "Jenis laporan",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            _radio("BARU", "Spot parkir baru", "+10 poin"),
            _radio("UPDATE", "Update ketersediaan", "+5 poin"),
            _radio("PENUH", "Laporkan spot penuh", "+5 poin"),
          ],
        ),
      ),
    );
  }

  Widget _radio(String value, String title, String point) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedType,
      onChanged: (v) => setState(() => _selectedType = v),
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Expanded(child: Text(title)),
          Text(point,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tips mendapat poin lebih banyak:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 6),
          Text("• Laporan akurat (+ bonus 5 poin)"),
          Text("• Tambahkan foto (+3 poin)"),
          Text("• Update berkala (+2 poin / update)"),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  InputDecoration _inputDecoration(String hint, {IconData? icon}) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      );
}
