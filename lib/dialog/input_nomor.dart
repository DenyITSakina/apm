import 'package:flutter/material.dart';

Future<String?> showNomorDialog(BuildContext context) {
  final controller = TextEditingController();
  final ValueNotifier<String> errorText = ValueNotifier("");
  final ValueNotifier<bool> isValid = ValueNotifier(false);

  return showGeneralDialog<String>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.6),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 550, // ⬅️ diperbesar
            padding: const EdgeInsets.fromLTRB(40, 45, 40, 35),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // === HEADER ===
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.teal.withOpacity(0.15),
                      ),
                      child: const Icon(
                        Icons.credit_card,
                        size: 50,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Validasi Nomor BPJS",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // === INPUT NOMOR ===
                StatefulBuilder(
                  builder: (_, setState) {
                    return TextField(
                      controller: controller,
                      readOnly: true,
                      maxLength: 13,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "Masukkan No BPJS..",
                        hintStyle: const TextStyle(
                          fontSize: 28,
                          color: Colors.black26,
                        ),
                        errorText: errorText.value.isEmpty
                            ? null
                            : errorText.value,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(
                            color: isValid.value ? Colors.green : Colors.red,
                            width: 3,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 10,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // === KEYPAD ===
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: 12,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.6,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (_, i) {
                    final keys = [
                      "1",
                      "2",
                      "3",
                      "4",
                      "5",
                      "6",
                      "7",
                      "8",
                      "9",
                      "",
                      "0",
                      "←",
                    ];

                    final key = keys[i];
                    if (key.isEmpty) return const SizedBox.shrink();

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        // tombol hapus
                        if (key == "←") {
                          if (controller.text.isNotEmpty) {
                            controller.text = controller.text.substring(
                              0,
                              controller.text.length - 1,
                            );
                          }
                        } else {
                          if (controller.text.length < 13) {
                            controller.text += key;
                          }
                        }

                        // VALIDASI
                        if (controller.text.length == 13) {
                          errorText.value = "";
                          isValid.value = true;
                        } else {
                          errorText.value =
                              "Harus 13 digit (Sekarang: ${controller.text.length})";
                          isValid.value = false;
                        }

                        (context as Element).markNeedsBuild(); // refresh UI
                      },
                      child: Text(
                        key,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // === TOMBOL AKSI ===
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, null),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          side: const BorderSide(color: Colors.red, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "BATAL",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: isValid,
                        builder: (_, valid, __) {
                          return ElevatedButton(
                            onPressed: valid
                                ? () => Navigator.pop(
                                    context,
                                    controller.text.trim(),
                                  )
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: valid
                                  ? Colors.teal
                                  : Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              "LANJUT",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Transform.scale(
        scale: curved.value,
        child: Opacity(opacity: anim.value, child: child),
      );
    },
  );
}
