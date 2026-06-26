# TODO - full_swipe_back_gesture 0.1.1 di semua halaman

- [x] Implement dependency `full_swipe_back_gesture: 0.1.1` di `pubspec.yaml`
- [ ] Buat wrapper widget (mis. `FullSwipeBackGestureWrapper`) yang membungkus `child`
- [ ] Terapkan wrapper secara global di `MaterialApp` (di `home` + semua navigated routes) atau lewat custom `onGenerateRoute`/route wrapper
- [ ] Pastikan dialog/route non-page tetap aman (hanya yang memerlukan swipe-back)
- [ ] Jalankan `flutter pub get` dan `flutter analyze`
- [ ] Smoke test: buka tiap halaman dan swipe-back dari edge untuk memastikan `Navigator.pop` bekerja
