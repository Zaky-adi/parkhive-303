import 'dart:io';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/area_parkir_model.dart';
import 'theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final ApiService _apiService = ApiService();

  List<AreaParkirModel> _areaList = [];
  AreaParkirModel? _selectedArea;
  String? _selectedType;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _loadingArea = true;
  bool _isSubmitting = false;

  final TextEditingController _noteController = TextEditingController();

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _loadAreaParkir();
  }

  Future<void> _loadAreaParkir() async {
    try {
      final data = await _apiService.fetchAreaParkir();
      setState(() {
        _areaList = data;
        _loadingArea = false;
      });
    } catch (e) {
      _loadingArea = false;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: "Error",
        desc: "Gagal memuat lokasi parkir",
      ).show();
    }
  }

  // ================= IMAGE =================
  Future<void> _pickImage() async {
    try {
      XFile? pickedFile;

      // Mobile → kamera
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
      } else {
        // Windows / Web / Desktop → gallery
        pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
      }

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile!.path);
        });
      }
    } catch (e) {
      debugPrint("Error ambil gambar: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengambil foto"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= SUBMIT =================
  void _submitLaporan() async {
    if (_selectedType == null ||
        _selectedArea == null ||
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
        areaId: _selectedArea!.areaId,
        tipeLaporan: _selectedType!,
        detailLaporan: _noteController.text,
        foto: _imageFile,
      );

      setState(() => _isSubmitting = false);

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: "Laporan berhasil",
        desc: "Laporan dikirim dan menunggu verifikasi admin",
        btnOkOnPress: () {
          setState(() {
            _selectedArea = null;
            _selectedType = null;
            _imageFile = null;
            _noteController.clear();
          });
        },
      ).show();
    } catch (e) {
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
      appBar: AppBar(title: const Text("Laporkan Spot Parkir")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Jenis Laporan"),
            _radio("Update_Status", "Update ketersediaan"),
            _radio("Parkir_Ilegal", "Parkir ilegal"),
            _radio("Koreksi_Data", "Koreksi data"),
            const SizedBox(height: 20),
            _sectionTitle("Lokasi Parkir"),
            _loadingArea
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<AreaParkirModel>(
                    value: _selectedArea,
                    decoration: _inputDecoration("Pilih lokasi parkir"),
                    items: _areaList
                        .map((area) => DropdownMenuItem(
                              value: area,
                              child: Text(area.namaArea),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedArea = v),
                  ),
            const SizedBox(height: 20),
            _sectionTitle("Detail Laporan"),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: _inputDecoration("Contoh: parkir penuh jam 10 pagi"),
            ),
            const SizedBox(height: 20),
            _sectionTitle("Foto (Opsional)"),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: _imageFile == null
                    ? const Center(
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
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLaporan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "Kirim Laporan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================
  Widget _radio(String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedType,
      onChanged: (v) => setState(() => _selectedType = v),
      title: Text(label),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );
}
