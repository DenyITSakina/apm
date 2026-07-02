import 'package:flutter/material.dart';

class AntrianCard extends StatelessWidget {
  final Map<String, dynamic> pasien;

  const AntrianCard({super.key, required this.pasien});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150 * 3.78,
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 35, child: _buildLeftSection()),
              const SizedBox(width: 4),
              Expanded(flex: 65, child: _buildRightSection()),
            ],
          ),
          const SizedBox(height: 4),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      child: Row(
        children: [
          SizedBox(width: 35 * 3.78, height: 20 * 3.78, child: _buildLogo()),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RSU SAKINA IDAMAN',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const Text(
                  'Jl. Nyi Tjondro Loekito No.60 | Telp. 0274 501 8021 - 0274 502 9090',
                  style: TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final logoUrl = pasien['logo_url'];
    if (logoUrl != null && logoUrl.toString().isNotEmpty) {
      return Image.network(
        logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.medical_services, size: 20),
          );
        },
      );
    }

    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.medical_services, size: 20),
    );
  }

  Widget _buildLeftSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'RM',
                  '${pasien['rm'] ?? ''} / ${pasien['cara_bayar'] ?? ''}',
                ),
                _buildInfoRow('Nama', pasien['nama'] ?? ''),
                _buildInfoRow('Tgl Lahir', pasien['tgl_lahir'] ?? '-'),
                _buildInfoRow('Telp', pasien['no_telp'] ?? ''),
                _buildInfoRow('Poli', pasien['nama_layanan'] ?? ''),
                _buildInfoRow('Dokter', pasien['nama_dokter'] ?? ''),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black, width: 1.5)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'NO ANTRIAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        pasien['no_antrian']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 75,
                  child:
                      pasien['qr_code'] != null &&
                          pasien['qr_code'].toString().isNotEmpty
                      ? Image.network(
                          pasien['qr_code'],
                          width: 70,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.qr_code, size: 70);
                          },
                        )
                      : const Icon(Icons.qr_code, size: 70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 65,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              ': $value',
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.5),
            color: Colors.grey[300],
          ),
          padding: const EdgeInsets.all(3),
          child: const Center(
            child: Text(
              'FORMULIR KENDALI TINDAKAN RAWAT JALAN',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.black, width: 1.5),
              right: BorderSide(color: Colors.black, width: 1.5),
              bottom: BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
          child: _buildFormTable(),
        ),
      ],
    );
  }

  Widget _buildFormTable() {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(30),
        1: FixedColumnWidth(30),
        2: FlexColumnWidth(),
      },
      border: TableBorder.all(color: Colors.black, width: 1),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: [
            _buildTableCell(
              'Ket.',
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w700,
            ),
            _buildTableCell(
              'No.',
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w700,
            ),
            _buildTableCell(
              'Prosedur',
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell(
              'A',
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w700,
            ),
            _buildTableCell('', textAlign: TextAlign.center),
            _buildTableCell('Konsultasi', fontWeight: FontWeight.w700),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell(''),
            _buildTableCell('1', textAlign: TextAlign.center),
            _buildTableCell(''),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell(''),
            _buildTableCell('2', textAlign: TextAlign.center),
            _buildTableCell(''),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell(
              'B',
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w700,
            ),
            _buildTableCell('', textAlign: TextAlign.center),
            _buildTableCell('Tindakan Medis', fontWeight: FontWeight.w700),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell(''),
            _buildTableCell('1', textAlign: TextAlign.center),
            _buildTableCell(''),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell(''),
            _buildTableCell('2', textAlign: TextAlign.center),
            _buildTableCell(''),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell(
              'C',
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w700,
            ),
            _buildTableCell('', textAlign: TextAlign.center),
            _buildTableCell('Penunjang Medis', fontWeight: FontWeight.w700),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell(''),
            _buildTableCell('1', textAlign: TextAlign.center),
            _buildTableCell(''),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell(''),
            _buildTableCell('2', textAlign: TextAlign.center),
            _buildTableCell(''),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell(
              'D',
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w700,
            ),
            _buildTableCell('', textAlign: TextAlign.center),
            _buildTableCell('Resep', fontWeight: FontWeight.w700),
          ],
        ),
        TableRow(
          children: [
            _buildTableCell(
              'E',
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w700,
            ),
            _buildTableCell('', textAlign: TextAlign.center),
            _buildTableCell('Lain-lain', fontWeight: FontWeight.w700),
          ],
        ),
      ],
    );
  }

  TableCell _buildTableCell(
    String text, {
    TextAlign textAlign = TextAlign.left,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Text(
          text,
          textAlign: textAlign,
          style: TextStyle(fontSize: 9, fontWeight: fontWeight),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 1)),
      ),
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Generated: ${pasien['tgl_masuk'] ?? ''} ${pasien['jam_masuk'] ?? ''}',
            style: const TextStyle(fontSize: 8),
          ),
          if (pasien['nama_operator'] != null && pasien['nama_operator'] != '')
            Text(
              ' | ${pasien['nama_operator']}',
              style: const TextStyle(fontSize: 8),
            ),
        ],
      ),
    );
  }
}

class AntrianPage extends StatelessWidget {
  const AntrianPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> pasien = {
      'logo_url': 'https://example.com/logo.png',
      'rm': '123456',
      'cara_bayar': 'BPJS',
      'nama': 'John Doe',
      'tgl_lahir': '1990-01-01',
      'no_telp': '08123456789',
      'nama_layanan': 'Poli Umum',
      'nama_dokter': 'Dr. Budi',
      'no_antrian': 'A-001',
      'qr_code': 'https://example.com/qr.png',
      'tgl_masuk': '2024-01-15',
      'jam_masuk': '08:00',
      'nama_operator': 'Admin',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Kartu Antrian')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AntrianCard(pasien: pasien),
        ),
      ),
    );
  }
}
