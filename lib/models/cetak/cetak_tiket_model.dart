class CetakTiketResponse {
  final int code;
  final int data; // nomor antrian dari API
  final String message;

  CetakTiketResponse({
    required this.code,
    required this.data,
    required this.message,
  });

  factory CetakTiketResponse.fromJson(Map<String, dynamic> json) {
    return CetakTiketResponse(
      code: json['code'] as int? ?? 0,
      data: json['data'] as int? ?? 0,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'data': data,
      'message': message,
    };
  }
}