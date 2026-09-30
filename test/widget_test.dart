import 'package:apm/home/check_in_bpjs/cekin_bpjs_page.dart';
import 'package:apm/home/check_in_umum/cekin_umum_page.dart';
import 'package:apm/home/dashboard_apm.dart';
import 'package:apm/main.dart';
import 'package:apm/widget/number_entry_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    // Test tidak melakukan fetch font dari jaringan.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpKiosk(
    WidgetTester tester, {
    Size size = const Size(1280, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
  }

  /// Dipanggil di akhir setiap test: majukan waktu sehingga seluruh
  /// Future.delayed (auto focus scanner, dsb) selesai dan tidak ada timer
  /// tertinggal saat widget tree dibuang.
  Future<void> closeKiosk(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> bukaCekinUmum(WidgetTester tester) async {
    await tester.tap(find.text('Cek-in Umum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LANJUT'));
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard menampilkan tiga layanan', (tester) async {
    await pumpKiosk(tester);

    expect(find.byType(DashboardApm), findsOneWidget);
    expect(find.text('RSU SAKINA IDAMAN'), findsOneWidget);
    expect(find.text('Cek-in BPJS'), findsOneWidget);
    expect(find.text('Cek-in Umum'), findsOneWidget);
    expect(find.text('Booking Online'), findsOneWidget);

    await closeKiosk(tester);
  });

  testWidgets('dashboard -> konfirmasi -> halaman cek-in BPJS', (tester) async {
    await pumpKiosk(tester);

    await tester.tap(find.text('Cek-in BPJS'));
    await tester.pumpAndSettle();
    expect(find.text('LANJUT'), findsOneWidget);

    await tester.tap(find.text('LANJUT'));
    await tester.pumpAndSettle();

    expect(find.byType(CekinBpjs), findsOneWidget);
    expect(find.byType(NumberEntryBoard), findsOneWidget);
    expect(find.text('CEK BPJS'), findsOneWidget);

    await closeKiosk(tester);
  });

  testWidgets('dashboard -> konfirmasi -> halaman cek-in Umum', (tester) async {
    await pumpKiosk(tester);
    await bukaCekinUmum(tester);

    expect(find.byType(CekinUmumPage), findsOneWidget);
    expect(find.text('CARI DATA'), findsOneWidget);

    await closeKiosk(tester);
  });

  testWidgets('keypad mengisi nomor yang tampil di layar scanner', (
    tester,
  ) async {
    await pumpKiosk(tester);
    await bukaCekinUmum(tester);

    await tester.tap(find.byKey(const ValueKey('keypad-1')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('keypad-2')));
    await tester.pump();

    final display = tester.widget<Text>(
      find.byKey(NumberEntryBoard.displayKey),
    );
    expect(display.data, '12');

    await closeKiosk(tester);
  });

  testWidgets('tombol backspace menghapus digit terakhir', (tester) async {
    await pumpKiosk(tester);
    await bukaCekinUmum(tester);

    await tester.tap(find.byKey(const ValueKey('keypad-7')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('keypad-backspace')));
    await tester.pump();

    expect(find.byKey(NumberEntryBoard.displayKey), findsNothing);
    expect(find.text('Masukkan nomor / pindai barcode'), findsOneWidget);

    await closeKiosk(tester);
  });

  testWidgets('tombol C mengosongkan input', (tester) async {
    await pumpKiosk(tester);
    await bukaCekinUmum(tester);

    await tester.tap(find.byKey(const ValueKey('keypad-5')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('keypad-clear')));
    await tester.pump();

    expect(find.byKey(NumberEntryBoard.displayKey), findsNothing);

    await closeKiosk(tester);
  });
}
