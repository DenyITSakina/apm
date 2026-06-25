import 'package:apm/blog/booking_bloc.dart';
import 'package:apm/blog/booking_event.dart';
import 'package:apm/blog/booking_state.dart';
import 'package:apm/home/booking_bpjs_page.dart';
import 'package:apm/home/booking_umum_page.dart';
import 'package:apm/models/booking_model.dart';
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
    context.read<BookingBloc>().add(LoadPoliEvent());
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
          if (state.status == BookingStatus.success) {
            _showSuccessDialog(context, state.bookingResult);
          }
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

  void _showSuccessDialog(BuildContext context, BookingData? data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Booking Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('No. Antrian', data?.noAntrian ?? '-'),
            _buildInfoRow('Kode Booking', data?.kodeBooking ?? '-'),
            _buildInfoRow('Nama Pasien', data?.namaPasien ?? '-'),
            _buildInfoRow('Tanggal Periksa', data?.tanggalPeriksa ?? '-'),
            _buildInfoRow('Unit', data?.unit ?? '-'),
            _buildInfoRow('Dokter', data?.dokter ?? '-'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              context.read<BookingBloc>().add(ResetBookingEvent());
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(': $value')),
        ],
      ),
    );
  }
}
