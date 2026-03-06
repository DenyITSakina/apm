String formatTglBlnTahun(String inputDate) {
  DateTime date = DateTime.parse(inputDate);

  List<String> bulan = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agu",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ];

  return "${date.day} ${bulan[date.month - 1]} ${date.year}";
}
