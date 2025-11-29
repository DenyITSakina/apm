import 'dart:ffi';
import 'dart:io' show Process, ProcessStartMode;
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:win32/win32.dart';

import '../../Blog Antrian APM/antrian_apm_bloc.dart';
import '../../Services/api_service_config.dart';
import '../../models/apm/apm_antrian_model.dart';
import 'dialog/confirmation_dialog.dart';
import 'dialog/error_dialog.dart';
import 'dialog/success_dialog.dart';
import 'form_pendaftaran.dart';
import 'responsive/responsive.dart';
import 'widget/antrian_header.dart';
import 'widget/input_section.dart';
import 'widget/keypad_section.dart';

class AntrianJknPage extends StatefulWidget {
  const AntrianJknPage({super.key});

  @override
  State<AntrianJknPage> createState() => _AntrianJknPageState();
}

class _AntrianJknPageState extends State<AntrianJknPage> {
  final TextEditingController _textController = TextEditingController();
  String _selectedType = '';
  bool _isJknEnabled = true;
  bool _isUmumEnabled = true;
  bool _isPendaftaranEnabled = true;
  ApmAntrianModel? _validatedData;
  bool _isBatalBooking = false;

  // Tambahan untuk form pendaftaran
  String? _selectedJaminan;
  PoliModel? _selectedPoli;
  DokterModel? _selectedDokter;
  List<PoliModel> _poliList = [];
  List<DokterModel> _dokterList = [];
  bool _isDialogVisible = false;
  bool _isFormPendaftaranActive = false;
  bool _isLanjutButtonsDisabled = false;
  bool _isInputSectionVisible = true;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_validatedData != null) {
      setState(() {
        _validatedData = null;
      });
    }
  }

  void _onNumberPressed(String number) {
    if (_selectedType.isEmpty) {
      return;
    }

    setState(() {
      _textController.text += number;
    });
  }

  void showTopRightMessage(BuildContext context, String message) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.only(top: 16, right: 16),
      borderRadius: BorderRadius.circular(8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: Colors.orange.shade700,
      animationDuration: const Duration(milliseconds: 300),
      duration: const Duration(seconds: 2),
      messageText: SizedBox(
        width: 150,
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, mobile: 14),
              color: Colors.white,
            ),
          ),
        ),
      ),
    ).show(context);
  }

  void _onBackspacePressed() {
    final text = _textController.text;
    if (text.isNotEmpty) {
      setState(() {
        _textController.text = text.substring(0, text.length - 1);
      });
    }
  }

  void _onClearPressed() {
    setState(() {
      _textController.clear();
      _validatedData = null;
    });
  }

  void _onBackToSelection() {
    setState(() {
      _isInputSectionVisible = true;
      _selectedType = '';
      _isJknEnabled = true;
      _isUmumEnabled = true;
      _isPendaftaranEnabled = true;
      _isBatalBooking = false;
      _validatedData = null;
      _isFormPendaftaranActive = false;
      _isLanjutButtonsDisabled = false;
      _selectedJaminan = null;
      _selectedPoli = null;
      _selectedDokter = null;
      _poliList = [];
      _dokterList = [];
      _textController.clear();
    });

    FocusScope.of(context).requestFocus(FocusNode()); 
  }



  Future<void> _onJknPressed() async {
    setState(() {
      _selectedType = 'jkn';
      _isJknEnabled = true;
      _isUmumEnabled = false;
      _isPendaftaranEnabled = false;
      _validatedData = null;
      _isFormPendaftaranActive = false;
      _isLanjutButtonsDisabled = true;
    });
    
    if (_textController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(message: 'Mohon isi No. Peserta JKN terlebih dahulu sebelum melanjutkan.');
        },
      );
      return;
    }
      await openFristaOrAfter(
      context: context,
      noPeserta: _textController.text,
);
    
    //await openExe(context, _textController.text);
  }

  void _onUmumPressed() {
    setState(() {
      _selectedType = 'umum';
      _isJknEnabled = false;
      _isUmumEnabled = true;
      _isPendaftaranEnabled = false;
      _validatedData = null;
      _isFormPendaftaranActive = false;
      _isLanjutButtonsDisabled = false;
    });
  }

  void _onPendaftaranPressed() {
    setState(() {
      _selectedType = 'pendaftaran';
      _isJknEnabled = false;
      _isUmumEnabled = false;
      _isPendaftaranEnabled = true;
      _validatedData = null;
    });
  }

  void _onValidateAntrian(BuildContext context) {
    if (_textController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(message: 'Nomor tidak boleh kosong');
        },
      );
      return;
    }

    context.read<AntrianApmBloc>().add(
      ValidateAntrianEvent(_textController.text, _selectedType, noIdentitas: ''),
    );
  }

  Future<void> _fetchPoliAndDokter() async {
  try {
    // Contoh menggunakan API service
    final fetchedPoliList = await ApiService.getPoliList();
    // final fetchedDokterList = await ApiService.getDokterList();

    setState(() {
      _poliList = fetchedPoliList;
      // _dokterList = fetchedDokterList;
    });
    } catch (e) {
      debugPrint("Gagal fetch poli/dokter: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengambil data poli/dokter.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onLanjutPoli() async {
  if (_validatedData == null) return;

  if (_isBatalBooking) {
    await showDialog(
      context: context,
      builder: (_) => ErrorDialog(
        message: 'Tidak dapat lanjut ke Poli karena booking telah dibatalkan.\nSilakan lanjut ke Loket saja.',
      ),
    );
    return;
  }

  if (_selectedType == 'pendaftaran') {
    try {
      await _fetchPoliAndDokter(); 
      if (_poliList.isEmpty) {
        await showDialog(
          context: context,
          builder: (_) => ErrorDialog(message: 'Data POLI belum tersedia. Silakan coba lagi.'),
        );
        return;
      }

      // Tampilkan form pendaftaran
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => PendaftaranDialog(
          pasienData: _validatedData!,
          listPoli: _poliList,
          onDialogClose: _onBackToSelection,
        ),
      );
    } catch (e) {
      await showDialog(
        context: context,
        builder: (_) => ErrorDialog(message: 'Gagal memuat data POLI/Dokter.\nError: $e'),
      );
    }
  } else {
    await showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Lanjut ke POLI',
        message: 'Apakah Anda yakin ingin melanjutkan ke POLI untuk:\n\nNama: ${_validatedData!.pasien}\nID: ${_validatedData!.id}',
        onConfirm: () {
          context.read<AntrianApmBloc>().add(
            LanjutKePoliEvent(
              noBoking: _validatedData?.id,        
              noRm: _validatedData?.rm,           
              noKtp: _validatedData?.noIdentitas, 
              jenisAntrian: _selectedType,       
            ),
          );
        },
      ),
    );
  }
}

  void _onLanjutLoket() {
    if (_validatedData != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmationDialog(
            title: 'Lanjut ke Loket',
            message: 'Apakah Anda yakin ingin melanjutkan ke Front Office untuk:\n\n'
                'Nama: ${_validatedData!.pasien}\n'
                'ID: ${_validatedData!.id}',
            onConfirm: () {
              context.read<AntrianApmBloc>().add(
                LanjutKeLoketEvent(_validatedData!, _selectedType,  _validatedData!.noBooking),
              );
            },
          );
        },
      );
    }
  }

  // Fungsi-fungsi untuk Windows API
  Future<bool> isSidikJariRunning() async {
    final result = await Process.run(
      'tasklist',
      [],
      runInShell: true,
    );
    return result.stdout.toString().contains("After.exe");
  }

  Future<void> closeSidikJariExe() async {
    await Process.run(
      'taskkill',
      ['/IM', 'After.exe', '/F'],
      runInShell: true,
    );
  }

  bool isWindowOpen(String windowTitle) {
    final titlePtr = windowTitle.toNativeUtf16();
    final hWnd = FindWindow(nullptr, titlePtr);
    calloc.free(titlePtr);
    return hWnd != 0;
  }

  void focusWindow(String windowTitle) {
    final titlePtr = windowTitle.toNativeUtf16();
    final hWnd = FindWindow(nullptr, titlePtr);

    if (hWnd != 0) {
      SetForegroundWindow(hWnd);
      debugPrint("Window ditemukan & difokuskan");
    } else {
      debugPrint("Window tidak ditemukan: $windowTitle");
    }

    calloc.free(titlePtr);
  }

  void sendVirtualKey(int keyCode) {
    final input = calloc<INPUT>();
    input.ref.type = INPUT_KEYBOARD;
    input.ref.ki.wVk = keyCode;
    SendInput(1, input, sizeOf<INPUT>());

    input.ref.ki.dwFlags = KEYEVENTF_KEYUP;
    SendInput(1, input, sizeOf<INPUT>());

    calloc.free(input);
  }

  void sendKeys(String text) {
    for (final rune in text.runes) {
      final input = calloc<INPUT>();
      input.ref.type = INPUT_KEYBOARD;
      input.ref.ki.wScan = rune;
      input.ref.ki.dwFlags = KEYEVENTF_UNICODE;
      SendInput(1, input, sizeOf<INPUT>());

      input.ref.ki.dwFlags = KEYEVENTF_UNICODE | KEYEVENTF_KEYUP; 
      SendInput(1, input, sizeOf<INPUT>());

      calloc.free(input);
    }
  }

  void pressEnter() => sendVirtualKey(VK_RETURN);
  void pressTab()   => sendVirtualKey(VK_TAB);

  Future<void> sendAutoLogin({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    sendKeys(username);
    pressTab();
    sendKeys(password);
    pressEnter();
  }

  Future<void> openFristaOrAfter({
    required BuildContext context,
    required String noPeserta,
  }) async {
    const pythonScript = r"D:\git\apm\python_scripts\frista_automation.py";

    try {
      final result = await Process.run(
        'python',
        [pythonScript, noPeserta],
        runInShell: true,
      );

      debugPrint(result.stdout.toString());
      debugPrint(result.stderr.toString());

      switch (result.exitCode) {
        case 0:
          break;
        case 1:
          await openExe(context, noPeserta);
          break;
        default:
          await openExe(context, noPeserta);
          break; 
      }
    } catch (e) {
      debugPrint("Error menjalankan Python: $e → buka After.exe");
      await openExe(context, noPeserta);
    }
  }

  Future<void> openExe(BuildContext context, String noPeserta) async {
    const exePath = r"C:\Program Files (x86)\BPJS Kesehatan\Aplikasi Sidik Jari BPJS Kesehatan\After.exe";

    try {
      Process? process;

      if (!await isSidikJariRunning()) {
        process = await Process.start(
          exePath,
          [],
          runInShell: true,
          mode: ProcessStartMode.normal,
        );
      }

      await Future.delayed(const Duration(seconds: 2));
      focusWindow("Aplikasi Sidik Jari BPJS Kesehatan");

      await sendAutoLogin(
        username: "cicifitria",
        password: "Idaman99!",
      );

      await Future.delayed(const Duration(seconds: 2));
      await sendNoPeserta(context, noPeserta);

      if (process != null) {
        await process.exitCode;
        debugPrint("EXE menutup sendiri.");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  String detectNomorType(String nomor) {
    if (isBpjs(nomor)) return "BPJS";
    if (isNik(nomor)) return "NIK";
    return "UNKNOWN";
  }

  bool isBpjs(String nomor) {
    String cleanNomor = nomor.replaceAll(RegExp(r'[^\d]'), '');
    return cleanNomor.length == 13;
  }

  bool isNik(String nomor) {
    String cleanNomor = nomor.replaceAll(RegExp(r'[^\d]'), '');
    return cleanNomor.length == 16;
  }

  String normalizeNomor(String nomor) {
    return nomor.replaceAll(RegExp(r'[^\d]'), '');
  }

  Future<void> sendNoPeserta(BuildContext context, String nomor) async {
    String normalizedNomor = normalizeNomor(nomor);
    String tipe = detectNomorType(normalizedNomor);

    print('Auto-detection: $nomor -> $tipe');

    if (tipe == "UNKNOWN") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nomor harus 13 digit (BPJS) atau 16 digit (NIK)',
            style: TextStyle(fontSize: 14),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      if (await isSidikJariRunning()) {
        print("Nomor salah → EXE akan ditutup otomatis");
        await closeSidikJariExe();
      }
      return;
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    print('Reset fokus ke awal form...');
    for (int i = 0; i < 3; i++) {
      sendKeys("+{TAB}");
      await Future.delayed(const Duration(milliseconds: 200));
    }

    print('Memilih radio button $tipe...');
    if (tipe == "BPJS") {
      await Future.delayed(const Duration(milliseconds: 400));
      sendKeys(" ");
      print('Radio BPJS dipilih');
    } else if (tipe == "NIK") {
      sendKeys("{TAB}");
      await Future.delayed(const Duration(milliseconds: 300));
      sendKeys("{TAB}");
      await Future.delayed(const Duration(milliseconds: 400));
      sendKeys(" ");
      print('Radio NIK dipilih');
    }

    await Future.delayed(const Duration(milliseconds: 400));

    print('Pindah ke field input nomor...');
    sendKeys("{TAB}");
    await Future.delayed(const Duration(milliseconds: 300));

    print('Mengisi nomor: $normalizedNomor');
    sendKeys(normalizedNomor);
    await Future.delayed(const Duration(milliseconds: 800));

    print('Submit form...');
    pressEnter();

    await Future.delayed(const Duration(milliseconds: 500));
    print("Form $tipe selesai diisi");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AntrianApmBloc, AntrianApmState>(
          listener: (context, state) {
            if (state is AntrianApmValidated) {
              setState(() {
                _validatedData = state.apmData;
                _isBatalBooking = state.isBatalBooking;
                _isJknEnabled = false;
                _isUmumEnabled = false;
                _isPendaftaranEnabled = false;
                _isLanjutButtonsDisabled = false;
              });

              if (_selectedType == 'pendaftaran') {
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    // _showPendaftaranForm(context);
                  }
                });
                return;
              }

              if (state.isBatalBooking) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Booking telah dibatalkan. Hanya dapat lanjut ke Loket.',
                      style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, mobile: 14)),
                    ),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            } else if (state is AntrianApmPrinted) {
               showDialog(
              context: context,
              builder: (BuildContext context) {
                return SuccessDialog(
                  title: 'Berhasil!',
                  message: '${state.message}\n\n'
                      'Nama: ${_validatedData?.pasien ?? ""}\n'
                      'Jenis: ${_selectedType.toUpperCase()}',
                  noAntrian: state.noAntrian,
                  onAntrianBerikutnya: () {
                    //Navigator.of(context).pop();
                    _onBackToSelection();   
                  },
                );
              },
            );

            } else if (state is AntrianApmError) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(message: state.pesan);
                },
              );
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final bool isMobile = constraints.maxWidth < 768;
                
                if (isMobile) {
                  return _buildMobileLayout(context, state);
                } else {
                  return _buildDesktopLayout(context, state);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AntrianApmState state) {
    return Column(
      children: [
        const AntrianHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                InputSection(
                  isVisible: _isInputSectionVisible,
                  textController: _textController,
                  selectedType: _selectedType,
                  validatedData: _validatedData,
                  state: state,
                  isLanjutButtonsDisabled: _isLanjutButtonsDisabled,
                  isFormPendaftaranActive: _isFormPendaftaranActive,
                  isBatalBooking: _isBatalBooking,
                  onBackToSelection: _onBackToSelection,
                  onValidateAntrian: () => _onValidateAntrian(context),
                  onLanjutPoli: _onLanjutPoli,
                  onLanjutLoket: _onLanjutLoket,
                  onJknPressed: _onJknPressed,
                  onUmumPressed: _onUmumPressed,
                  onPendaftaranPressed: _onPendaftaranPressed,
                ),
                const SizedBox(height: 16),
                KeypadSection(
                  onNumberPressed: _onNumberPressed,
                  onBackspacePressed: _onBackspacePressed,
                  onClearPressed: _onClearPressed,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AntrianApmState state) {
    return Column(
      children: [
        const AntrianHeader(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: KeypadSection(
                    onNumberPressed: _onNumberPressed,
                    onBackspacePressed: _onBackspacePressed,
                    onClearPressed: _onClearPressed,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 3,
                  child: InputSection(
                    isVisible: _isInputSectionVisible,
                    textController: _textController,
                    selectedType: _selectedType,
                    validatedData: _validatedData,
                    state: state,
                    isLanjutButtonsDisabled: _isLanjutButtonsDisabled,
                    isFormPendaftaranActive: _isFormPendaftaranActive,
                    isBatalBooking: _isBatalBooking,
                    onBackToSelection: _onBackToSelection,
                    onValidateAntrian: () => _onValidateAntrian(context),
                    onLanjutPoli: _onLanjutPoli,
                    onLanjutLoket: _onLanjutLoket,
                    onJknPressed: _onJknPressed,
                    onUmumPressed: _onUmumPressed,
                    onPendaftaranPressed: _onPendaftaranPressed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}