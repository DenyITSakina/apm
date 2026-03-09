import 'dart:io';
import 'package:apm/blog/blog_booking_pasien_baru.dart';
import 'package:apm/blog/booking_pasien_lama_bloc.dart';
import 'package:apm/home/dashboard_apm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'Blog/antrian_apm_bloc.dart';
import 'Blog/blog_pendaftran.dart';
import 'theme/Style/http_overrides.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AntrianApmBloc()),
        BlocProvider(create: (_) => CekinBloc()),
        BlocProvider(create: (_) => BookingPasienBaruBloc()),
        BlocProvider(create: (_) => BookingPasienLamaBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RSU Sakina Idaman',
        theme: AppTheme.lightTheme,
        home: DashboardApm(),
      ),
    );
  }
}
