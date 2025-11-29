import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Tampilan/JKN/antrian_jkn.dart';
import 'Blog Antrian APM/antrian_apm_bloc.dart';
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RSU Sakina Idaman',
        theme: AppTheme.lightTheme,
        home: AntrianJknPage(),
      ),
    );
  }
}
