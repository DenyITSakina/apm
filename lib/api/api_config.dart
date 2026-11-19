class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://10.30.0.9/res/public/index.php/api';

  //http://127.0.0.1:8000/api
  //http://10.30.0.9/res/public/index.php/api
  //http://10.30.0.16/api_dev/public/index.php/api

  static const String antrianApm = '$baseUrl/apm-antrian';
  static const String antrianApmLoket = '$baseUrl/apm-antrian-loket';
  static const String antrianApmPoli = '$baseUrl/apm-antrian-poli';
  static const String poliListApm = '$baseUrl/apm-poli';
  static const String dokterJadwalApm = '$baseUrl/apm-jadwal-dokter';
  static const String daftarApmRegPoli = '$baseUrl/apm-reg-poli';
  static const String bpjsCekRujukan = '$baseUrl/bpjs/cek-rujukan';
  static const String getDaftar = '$baseUrl/apm-get-sosial';
  static const String bookingPasien = '$baseUrl/pasien-booking';

  /// Konfigurasi Gemini untuk asisten bantuan check-in APM.
  /// Nilai dapat di-override via --dart-define. Jangan sebarkan kunci API.
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  static const String geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.5-flash',
  );
  static double get geminiTemperature {
    const v = String.fromEnvironment('GEMINI_TEMPERATURE', defaultValue: '0.7');
    return double.tryParse(v) ?? 0.7;
  }

  static double get geminiTopP {
    const v = String.fromEnvironment('GEMINI_TOP_P', defaultValue: '0.95');
    return double.tryParse(v) ?? 0.95;
  }

  static const int geminiTopK = int.fromEnvironment(
    'GEMINI_TOP_K',
    defaultValue: 40,
  );
  static const int geminiMaxOutputTokens = int.fromEnvironment(
    'GEMINI_MAX_OUTPUT_TOKENS',
    defaultValue: 2048,
  );
  static const int geminiMaxRetries = int.fromEnvironment(
    'GEMINI_MAX_RETRIES',
    defaultValue: 2,
  );
  static const int geminiTimeoutSeconds = int.fromEnvironment(
    'GEMINI_TIMEOUT',
    defaultValue: 30,
  );
  static const bool geminiEnableThinking = bool.fromEnvironment(
    'GEMINI_ENABLE_THINKING',
    defaultValue: true,
  );
  static const int geminiThinkingBudget = int.fromEnvironment(
    'GEMINI_THINKING_BUDGET',
    defaultValue: 1024,
  );

  static String get geminiEndpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';
}
