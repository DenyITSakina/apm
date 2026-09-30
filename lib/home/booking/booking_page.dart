import 'package:apm/blog/booking/booking_bloc.dart';
import 'package:apm/blog/booking/booking_event.dart';
import 'package:apm/blog/booking/booking_state.dart';
import 'package:apm/dialog/top_toast.dart';
import 'package:apm/home/booking/booking_bpjs_page.dart';
import 'package:apm/home/booking/booking_umum_page.dart';
import 'package:apm/theme/app_tokens.dart';
import 'package:apm/widget/app_button.dart';
import 'package:apm/widget/app_page_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingPage extends StatefulWidget {
  /// '1' untuk umum, '2' untuk BPJS.
  final String jenis;

  const BookingPage({super.key, required this.jenis});

  bool get isUmum => jenis == '1';

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BookingBloc>().add(LoadPoliEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: widget.isUmum ? 'BOOKING UMUM' : 'BOOKING BPJS',
              subtitle: widget.isUmum
                  ? 'Pilih poli, dokter, dan tanggal pemeriksaan'
                  : 'Verifikasi data BPJS lalu pilih poli dan dokter',
              badge: widget.isUmum ? 'Pasien Umum' : 'Peserta BPJS',
              badgeIcon: widget.isUmum
                  ? Icons.people_alt_rounded
                  : Icons.health_and_safety_rounded,
            ),
            Expanded(
              child: BlocConsumer<BookingBloc, BookingState>(
                listener: (context, state) {
                  if (state.status == BookingStatus.error) {
                    TopToast.error(
                      context,
                      state.errorMessage ?? 'Terjadi kesalahan',
                    );
                  }
                },
                builder: (context, state) {
                  if (state.status == BookingStatus.loading &&
                      state.poliList.isEmpty) {
                    return const _BookingLoading();
                  }

                  if (state.status == BookingStatus.error &&
                      state.poliList.isEmpty) {
                    return _BookingError(
                      message: state.errorMessage ?? 'Terjadi kesalahan',
                      onRetry: () =>
                          context.read<BookingBloc>().add(LoadPoliEvent()),
                    );
                  }

                  return widget.isUmum
                      ? const BookingUmumPage()
                      : const BookingBpjsPage();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingLoading extends StatelessWidget {
  const _BookingLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Memuat data poli...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingError extends StatelessWidget {
  const _BookingError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 220,
              child: AppGradientButton(
                label: 'COBA LAGI',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                height: 52,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
