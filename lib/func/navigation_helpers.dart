import 'package:flutter/material.dart';
import 'package:full_swipe_back_gesture/full_swipe_back_gesture.dart';

/// Helper untuk membuat route yang mendukung full swipe back.
/// Digunakan supaya semua page yang dipush akan punya gesture back.
void pushBackSwipePage<T>({
  required BuildContext context,
  required Widget page,
}) {
  Navigator.of(context).push(BackSwipePageRoute<T>(builder: (_) => page));
}
