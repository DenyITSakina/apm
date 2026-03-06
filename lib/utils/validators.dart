class Validators {
  static String? validateNIK(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIK wajib diisi';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'NIK hanya boleh berisi angka';
    }

    if (value.length != 16) {
      return 'NIK harus 16 digit';
    }

    return null;
  }

  static String? validateNoHP(String? value) {
    if (value == null || value.isEmpty) {
      return 'No. HP wajib diisi';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'No. HP hanya boleh berisi angka';
    }

    if (!value.startsWith('08')) {
      return 'No. HP harus diawali 08';
    }

    if (value.length < 10 || value.length > 13) {
      return 'No. HP harus 10-13 digit';
    }

    return null;
  }

  static String? validateNomorKartuBPJS(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor kartu BPJS wajib diisi';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Nomor kartu hanya boleh berisi angka';
    }

    if (value.length != 13) {
      return 'Nomor kartu BPJS harus 13 digit';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }
}
