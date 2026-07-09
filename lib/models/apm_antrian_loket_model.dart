class ApmAntrianLoketModel {
  final int noAntrian;
  final String waktu;

  const ApmAntrianLoketModel({required this.noAntrian, required this.waktu});

  factory ApmAntrianLoketModel.fromJson(Map<String, dynamic> json) {
    final noRaw = json['no_antrian'] ?? json['noAntrian'] ?? 0;
    final waktuRaw = json['waktu'] ?? '';

    return ApmAntrianLoketModel(
      noAntrian: int.tryParse(noRaw.toString()) ?? 0,
      waktu: waktuRaw.toString(),
    );
  }
}
