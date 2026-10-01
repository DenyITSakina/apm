import 'package:flutter/material.dart';

/// Helper untuk push halaman tanpa gesture full swipe back.
void pushPage<T>({
  required BuildContext context,
  required Widget page,
}) {
  Navigator.of(context).push(MaterialPageRoute<T>(builder: (_) => page));
}

/// Kembali ke halaman paling atas (dashboard) dan membersihkan seluruh stack
/// di bawahnya, sehingga kiosk siap digunakan pasien berikutnya.
void popToRoot(BuildContext context) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.popUntil((route) => route.isFirst);
  }
}
