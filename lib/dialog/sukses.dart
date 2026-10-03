import 'package:apm/func/navigation_helpers.dart';
import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/app_typography.dart';
import 'package:apm/widget/app_button.dart';
import 'package:flutter/material.dart';

Future<void> showSuccessDialog(
  BuildContext context,
  String message, {
  String title = 'Berhasil',
  String actionLabel = 'SELESAI',
  VoidCallback? onClose,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: title,
    barrierColor: AppColors.primaryDark.withValues(alpha: 0.55),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, _) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.88, end: 1.0).animate(curved),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.3),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppGradients.brand,
                            boxShadow: AppShadow.glow(AppColors.primary),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppText.family,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppText.family,
                            fontSize: 15,
                            height: 1.55,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_rounded,
                                color: AppColors.accentDark,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Silakan lanjutkan ke poli atau loket sesuai '
                                  'petunjuk petugas.',
                                  style: TextStyle(
                                    fontFamily: AppText.family,
                                    fontSize: 13,
                                    height: 1.45,
                                    color: AppColors.textSecondary,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppGradientButton(
                          label: actionLabel,
                          icon: Icons.home_rounded,
                          height: 56,
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (onClose != null) {
                              onClose();
                            } else {
                              popToRoot(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 420),
  );
}
