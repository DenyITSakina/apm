import 'package:equatable/equatable.dart';
import '../../models/booking_model.dart';
import '../../models/pasien_model.dart';
import '../../models/dokter_model.dart';
import '../../models/poli_model.dart';

enum BookingStatus { initial, loading, loaded, loadingDokter, success, error }

class BookingState extends Equatable {
  final BookingStatus status;
  final String? errorMessage;
  final List<PoliModel> poliList;
  final List<DokterModel> dokterList;
  final PasienBpjsData? pasienBpjs;
  final BookingData? bookingResult;
  final int selectedPoliId;
  final String selectedDokterId;

  const BookingState({
    this.status = BookingStatus.initial,
    this.errorMessage,
    this.poliList = const [],
    this.dokterList = const [],
    this.pasienBpjs,
    this.bookingResult,
    this.selectedPoliId = 0,
    this.selectedDokterId = '',
  });

  BookingState copyWith({
    BookingStatus? status,
    String? errorMessage,
    List<PoliModel>? poliList,
    List<DokterModel>? dokterList,
    PasienBpjsData? pasienBpjs,
    BookingData? bookingResult,
    int? selectedPoliId,
    String? selectedDokterId,
  }) {
    return BookingState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      poliList: poliList ?? this.poliList,
      dokterList: dokterList ?? this.dokterList,
      pasienBpjs: pasienBpjs ?? this.pasienBpjs,
      bookingResult: bookingResult ?? this.bookingResult,
      selectedPoliId: selectedPoliId ?? this.selectedPoliId,
      selectedDokterId: selectedDokterId ?? this.selectedDokterId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    poliList,
    dokterList,
    pasienBpjs,
    bookingResult,
    selectedPoliId,
    selectedDokterId,
  ];
}
