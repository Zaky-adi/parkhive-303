import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'theme.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class GiftPage extends StatefulWidget {
  const GiftPage({super.key});

  @override
  State<GiftPage> createState() => _GiftPageState();
}

class _GiftPageState extends State<GiftPage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  int totalPoint = 0;
  bool isLoading = true;
  List<dynamic> hadiahList = [];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool showFirework = false;

  @override
  void initState() {
    super.initState();
    _loadPoint();
    _loadHadiah();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut);

    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
  }

  Future<void> _loadPoint() async {
    try {
      final profile = await _apiService.getProfile();
      if (!mounted) return;
      setState(() {
        totalPoint = profile['total_poin'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _loadHadiah() async {
    try {
      final data = await _apiService.getHadiah();
      if (!mounted) return;

      // Pisahkan hadiah yang sudah dan belum ditukar
      List<dynamic> belumDitukar = [];
      List<dynamic> sudahDitukar = [];

      for (var h in data) {
        final bool sudah =
            (h['jumlah'] ?? 0) > 0; // jumlah pivot > 0 = sudah ditukar
        if (sudah) {
          sudahDitukar.add(h);
        } else {
          belumDitukar.add(h);
        }
      }

      setState(() {
        hadiahList = [
          ...belumDitukar,
          ...sudahDitukar
        ]; // gabungkan: belum di atas
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showSuccess(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Berhasil',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  void _showError(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Gagal',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  void _playFirework() {
    setState(() => showFirework = true);
    _animationController.forward(from: 0);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => showFirework = false);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pointCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'Hadiah',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  hadiahList.isEmpty
                      ? const Text('Belum ada hadiah')
                      : Column(
                          children: hadiahList.map((h) {
                            final bool sudahDitukar = (h['jumlah'] ?? 0) > 0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _giftItem(
                                hadiahId: h['hadiah_id'],
                                title: h['nama_hadiah'],
                                subtitle: h['deskripsi_hadiah'] ?? '-',
                                point: h['biaya_poin'],
                                stok: h['stok_tersedia'] as int?,
                                sudahDitukar: sudahDitukar,
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
          if (showFirework)
            Positioned.fill(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  color: Colors.black26,
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.auto_awesome,
                              size: 120, color: Colors.orange),
                          SizedBox(height: 12),
                          Text(
                            'Tukar Berhasil!',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pointCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [AppColors.yellow, AppColors.deepYellow]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total poin kamu'),
              Text(
                '$totalPoint',
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Icon(Icons.star, size: 36),
        ],
      ),
    );
  }

  Widget _giftItem({
    required int hadiahId,
    required String title,
    required String subtitle,
    required int point,
    int? stok,
    bool sudahDitukar = false,
  }) {
    final bool isVoucher = stok == null;
    final bool stokHabis = !isVoucher && stok <= 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 4),
                Text(
                  isVoucher
                      ? '$point poin • Voucher'
                      : '$point poin • Stok ${stok ?? "-"}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: (stokHabis || sudahDitukar)
                ? null
                : () {
                    // Konfirmasi sebelum tukar
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.question,
                      animType: AnimType.scale,
                      title: 'Konfirmasi',
                      desc: 'Tukar "$title" dengan $point poin?',
                      btnCancelText: 'Batal',
                      btnOkText: 'Tukar',
                      btnCancelOnPress: () {},
                      btnOkOnPress: () async {
                        try {
                          await _apiService.tukarHadiah(hadiahId);
                          if (!mounted) return;
                          await _loadPoint();
                          await _loadHadiah();
                          _playFirework();
                          _showSuccess('Berhasil menukar $title 🎉');
                        } catch (e) {
                          if (!mounted) return;
                          _showError(e.toString());
                        }
                      },
                    ).show();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: sudahDitukar ? Colors.grey : null,
            ),
            child: Text(sudahDitukar ? 'Ditukar' : 'Tukar'),
          ),
        ],
      ),
    );
  }
}
