import 'package:apm/constants/app_constants.dart';
import 'package:apm/models/dokter_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool enabled;
  final VoidCallback? onTap;
  final void Function(bool)? onFocusChange;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
    this.obscureText = false,
    this.suffixIcon,
    this.enabled = true,
    this.onTap,
    this.onFocusChange,
    this.maxLength, // Tambahkan ini
    this.inputFormatters, // Tambahkan ini
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Focus(
          onFocusChange: onFocusChange,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            focusNode: focusNode,
            textInputAction: textInputAction,
            onEditingComplete: onEditingComplete,
            obscureText: obscureText,
            enabled: enabled,
            onTap: onTap,
            maxLength: maxLength, // Tambahkan maxLength
            inputFormatters: inputFormatters, // Tambahkan inputFormatters
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.teal600, size: 20),
              suffixIcon: suffixIcon,
              hintText: 'Masukkan $label',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusMedium,
                ),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusMedium,
                ),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusMedium,
                ),
                borderSide: BorderSide(color: AppColors.teal600, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusMedium,
                ),
                borderSide: BorderSide(color: AppColors.error, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusMedium,
                ),
                borderSide: BorderSide(color: AppColors.error, width: 2),
              ),
              filled: true,
              fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              // Hilangkan counter text karena kita tidak perlu menampilkan jumlah karakter
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final void Function(bool)? onFocusChange;

  const CustomDatePickerField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onTap,
    this.validator,
    this.focusNode,
    this.onFocusChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Focus(
          onFocusChange: onFocusChange,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            validator: validator,
            focusNode: focusNode,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.teal600, size: 20),
              suffixIcon: Icon(
                Icons.calendar_today,
                color: AppColors.teal600,
                size: 20,
              ),
              hintText: 'Pilih $label',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusMedium,
                ),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusMedium,
                ),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDimens.borderRadiusMedium,
                ),
                borderSide: BorderSide(color: AppColors.teal600, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomGenderChip extends StatelessWidget {
  final String value;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomGenderChip({
    Key? key,
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal600 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.teal600 : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.teal600,
          ),
        ),
      ),
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T) display;
  final bool enabled;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.display,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.local_hospital,
              color: AppColors.teal600,
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
              borderSide: BorderSide(color: AppColors.teal600, width: 2),
            ),
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          icon: Icon(Icons.arrow_drop_down, color: AppColors.teal600),
          dropdownColor: Colors.white,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                display(item),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}

class CustomSectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;
  final EdgeInsets? padding;

  const CustomSectionCard({
    Key? key,
    required this.title,
    this.icon,
    required this.children,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.teal600, size: 24),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal800,
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          ...children,
        ],
      ),
    );
  }
}

class CustomSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;

  const CustomSubmitButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusXLarge),
          ),
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.teal700, AppColors.teal600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusXLarge),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class DokterListItem extends StatelessWidget {
  final DokterModel dokter;
  final bool isSelected;
  final VoidCallback onTap;

  const DokterListItem({
    Key? key,
    required this.dokter,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.teal600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.teal600 : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medical_services,
                color: isSelected ? Colors.white : AppColors.teal600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dokter.namaDokter,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.teal800
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (dokter.jadwal != null && dokter.jadwal!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isSelected
                              ? AppColors.teal600
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dokter.jadwal!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isSelected
                                ? AppColors.teal600
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      "Tidak ada jadwal spesifik",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.teal600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
