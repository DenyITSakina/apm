import 'package:apm/theme/app_tokens.dart';
import 'package:apm/theme/app_typography.dart';
import 'package:apm/widget/app_button.dart';
import 'package:flutter/material.dart';

Future<void> showFailureDialog(
  BuildContext context,
  String message, {
  String title = 'Gagal',
  String actionLabel = 'COBA LAGI',
  VoidCallback? onClose,
  Duration? autoCloseAfter,
}) {
  final dialogFuture = showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: title,
    barrierColor: AppColors.danger.withValues(alpha: 0.55),
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
                        color: AppColors.danger.withValues(alpha: 0.3),
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
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.danger, AppColors.primaryDark],
                            ),
                            boxShadow: AppShadow.glow(AppColors.danger),
                          ),
                          child: const Icon(
                            Icons.error_rounded,
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
                            color: AppColors.dangerSoft,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.danger,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Silahkan ke FO untuk lebih lanjut',
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
                          icon: Icons.refresh_rounded,
                          height: 56,
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (onClose != null) {
                              onClose();
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

  if (autoCloseAfter != null && context.mounted) {
    Future.delayed(autoCloseAfter, () {
      if (context.mounted) {
        Navigator.of(context).pop();
        if (onClose != null) {
          onClose();
        }
      }
    });
  }

  return dialogFuture;
}
