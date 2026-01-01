import 'package:flutter/material.dart';
import 'theme.dart';

class GiftPage extends StatefulWidget {
  const GiftPage({super.key});

  @override
  State<GiftPage> createState() => _GiftPageState();
}

class _GiftPageState extends State<GiftPage>
    with SingleTickerProviderStateMixin {
  int totalPoint = 850;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool showFirework = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut);

    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _playFirework() {
    setState(() => showFirework = true);
    _animationController.forward(from: 0);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => showFirework = false);
    });
  }

  void _tukarHadiah(String title, int point) {
    if (totalPoint < point) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Poin kamu tidak mencukupi 😥'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Tukar'),
        content: Text('Tukar "$title" dengan $point poin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                totalPoint -= point;
              });

              Navigator.pop(context);
              _playFirework();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Berhasil menukar $title 🎉'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Tukar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'Hadiah populer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _giftItem(
                    title: 'Voucher kantin 20k',
                    subtitle: 'Makan siang gratis di kantin kampus',
                    point: 500,
                    icon: Icons.restaurant_menu,
                  ),
                  const SizedBox(height: 12),
                  _giftItem(
                    title: 'Diskon fotokopi 50%',
                    subtitle: 'Potongan 50% untuk fotokopi',
                    point: 200,
                    icon: Icons.print,
                  ),
                  const SizedBox(height: 12),
                  _giftItem(
                    title: 'Merchandise kampus',
                    subtitle: 'T-shirt atau tote bag kampus',
                    point: 800,
                    icon: Icons.shopping_bag,
                  ),
                  const SizedBox(height: 20),
                  _infoNote(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          /// 🎆 FIREWORK OVERLAY
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
                          Icon(
                            Icons.auto_awesome,
                            size: 120,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Tukar Berhasil!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.yellow, AppColors.deepYellow],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total poin kamu',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                '$totalPoint',
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const Icon(Icons.star, size: 36),
        ],
      ),
    );
  }

  Widget _giftItem({
    required String title,
    required String subtitle,
    required int point,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text('$point poin',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _tukarHadiah(title, point),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tukar'),
          ),
        ],
      ),
    );
  }

  Widget _infoNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Poin akan hangus dalam 6 bulan jika tidak ada aktivitas',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
