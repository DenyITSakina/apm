import 'package:apm/blog/booking_bloc.dart';
import 'package:apm/blog/booking_event.dart';
import 'package:apm/blog/booking_state.dart';
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
        title: Text(widget.jenis == '1' ? 'Booking Umum' : 'Booking BPJS'),
        backgroundColor: Colors.orange,
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
