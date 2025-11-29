import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

void _cekPrinter() async {
  final printers = await Printing.listPrinters();
  for (final printer in printers) {
    print('Printer ditemukan: ${printer.name}');
  }
}

class TesPrinting extends StatelessWidget {
  const TesPrinting({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
