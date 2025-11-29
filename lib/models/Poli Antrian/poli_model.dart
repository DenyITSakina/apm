// models/poli_model.dart
class PoliModel {
  final int id;
  final String poli;

  PoliModel({
    required this.id,
    required this.poli,
  });

  factory PoliModel.fromJson(Map<String, dynamic> json) {
    return PoliModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      poli: json['poli'] ?? '',
    );
  }
}