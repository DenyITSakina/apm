class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://127.0.0.1:8000/api';

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
}
