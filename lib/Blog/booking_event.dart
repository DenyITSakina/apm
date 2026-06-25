// booking_event.dart
import 'package:equatable/equatable.dart';
import '../../models/booking_model.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

// Load Poli
class LoadPoliEvent extends BookingEvent {}

// Load Dokter Umum dengan tanggal
class LoadDokterUmumEvent extends BookingEvent {
  final int idLayanan;
  final String tanggal;

  const LoadDokterUmumEvent({required this.idLayanan, required this.tanggal});

  @override
  List<Object?> get props => [idLayanan, tanggal];
}

// Load Dokter JKN dengan tanggal
class LoadDokterJknEvent extends BookingEvent {
  final int idLayanan;
  final String tanggal;

  const LoadDokterJknEvent({required this.idLayanan, required this.tanggal});

  @override
  List<Object?> get props => [idLayanan, tanggal];
}

// Cek Pasien BPJS
class CekPasienBpjsEvent extends BookingEvent {
  final String noBpjs;

  const CekPasienBpjsEvent(this.noBpjs);

  @override
  List<Object?> get props => [noBpjs];
}

// Submit Booking Umum
class SubmitBookingUmumEvent extends BookingEvent {
  final BookingRequest request;

  const SubmitBookingUmumEvent(this.request);

  @override
  List<Object?> get props => [request];
}

// Submit Booking BPJS
class SubmitBookingBpjsEvent extends BookingEvent {
  final BookingRequest request;

  const SubmitBookingBpjsEvent(this.request);

  @override
  List<Object?> get props => [request];
}

// Reset State
class ResetBookingEvent extends BookingEvent {}
