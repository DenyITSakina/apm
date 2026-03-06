String formatNama(String nama) {
  nama = nama.trim();
  if (nama.isEmpty) return nama;

  final formatted = nama
      .toLowerCase()
      .split(' ')
      .map((e) => e.isNotEmpty ? '${e[0].toUpperCase()}${e.substring(1)}' : e)
      .join(' ');

  return formatted.replaceAll("Sp.", "Sp.").replaceAll("Dr", "Dr.");
}
