class ChallengeModel {
  final String judul;
  final String deskripsi;
  final int progress;
  final int target;
  final bool rewardClaimed;

  ChallengeModel({
    required this.judul,
    required this.deskripsi,
    required this.progress,
    required this.target,
    required this.rewardClaimed,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      judul: json['judul'] ?? 'Tantangan harian',
      deskripsi: json['deskripsi'] ??
          'Selesaikan tantangan harian untuk mendapatkan hadiah!',
      progress: json['progress'] ?? 0,
      target: json['target'] ?? 1,
      rewardClaimed: json['reward_claimed'] ?? false,
    );
  }
}
