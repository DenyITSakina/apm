import 'package:apm/blog/booking/booking_bloc.dart';
import 'package:apm/blog/booking/booking_event.dart';
import 'package:apm/blog/booking/booking_state.dart';
import 'package:apm/home/booking_bpjs_page.dart';
import 'package:apm/home/booking_umum_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingPage extends StatefulWidget {
  final String jenis; // '1' for umum, '2' for bpjs

  const BookingPage({Key? key, required this.jenis}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BookingBloc>().add(LoadPoliEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),

        title: Column(
          children: [
            const Text(
              "Booking Pasien",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),

            Text(
              widget.jenis == '1' ? 'Booking Umum' : 'Booking BPJS',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        foregroundColor: Colors.white,

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.jenis == '1'
                  ? [const Color(0xFFFF9800), const Color(0xFFFF6F00)]
                  : [const Color(0xFF2196F3), const Color(0xFF1565C0)],
            ),
          ),
        ),

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(26),
            bottomRight: Radius.circular(26),
          ),
        ),

        toolbarHeight: 90,
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state.status == BookingStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                backgroundColor: Colors.red,
              ),
            );
          }
          // Dialog sukses sekarang ditangani di masing-masing halaman
        },
        builder: (context, state) {
          if (state.status == BookingStatus.loading && state.poliList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BookingStatus.error && state.poliList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Terjadi kesalahan'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BookingBloc>().add(LoadPoliEvent());
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (widget.jenis == '1') {
            return const BookingUmumPage();
          } else {
            return const BookingBpjsPage();
          }
        },
      ),
    );
  }
}
