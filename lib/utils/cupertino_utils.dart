import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CupertinoUtils {
  // iOS-style Toast Message with Animations
  static void showToast(BuildContext context, String message, {
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    late AnimationController animationController;
    late Animation<double> slideAnimation;
    late Animation<double> fadeAnimation;
    late Animation<double> scaleAnimation;

    // Create animation controller
    animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: Navigator.of(context),
    );

    // Create animations
    slideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.elasticOut,
    ));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    ));

    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.elasticOut,
    ));

    overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Positioned(
            top: MediaQuery.of(context).padding.top + 60 + slideAnimation.value,
            left: 20,
            right: 20,
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Opacity(
                opacity: fadeAnimation.value,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? CupertinoColors.systemBackground.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CupertinoColors.separator.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 600),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.rotate(
                                angle: value * 0.5,
                                child: Transform.scale(
                                  scale: 0.8 + (0.2 * value),
                                  child: Icon(
                                    icon,
                                    color: textColor ?? CupertinoColors.label,
                                    size: 20,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 500),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(20 * (1 - value), 0),
                                  child: Text(
                                    message,
                                    style: TextStyle(
                                      color: textColor ?? CupertinoColors.label,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    overlay.insert(overlayEntry);

    // Start appearing animation
    animationController.forward();

    // Start disappearing animation after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        // Reverse animation for disappearing
        animationController.reverse().then((_) {
          overlayEntry.remove();
          animationController.dispose();
        });
      }
    });
  }

  // iOS-style Success Toast
  static void showSuccessToast(BuildContext context, String message) {
    showToast(
      context,
      message,
      icon: CupertinoIcons.checkmark_circle_fill,
      backgroundColor: CupertinoColors.systemGreen.withValues(alpha: 0.95),
      textColor: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // iOS-style Error Toast
  static void showErrorToast(BuildContext context, String message) {
    showToast(
      context,
      message,
      icon: CupertinoIcons.exclamationmark_triangle_fill,
      backgroundColor: CupertinoColors.systemRed.withValues(alpha: 0.95),
      textColor: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // iOS-style Warning Toast
  static void showWarningToast(BuildContext context, String message) {
    showToast(
      context,
      message,
      icon: CupertinoIcons.exclamationmark_circle_fill,
      backgroundColor: CupertinoColors.systemOrange.withValues(alpha: 0.95),
      textColor: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // iOS-style Info Toast
  static void showInfoToast(BuildContext context, String message) {
    showToast(
      context,
      message,
      icon: CupertinoIcons.info_circle_fill,
      backgroundColor: CupertinoColors.systemBlue.withValues(alpha: 0.95),
      textColor: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // iOS-style Alert Dialog
  static void showAlert(BuildContext context, {
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        actions: [
          if (secondaryButtonText != null)
            CupertinoDialogAction(
              onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
              child: Text(
                secondaryButtonText,
                style: const TextStyle(
                  color: CupertinoColors.systemBlue,
                ),
              ),
            ),
          CupertinoDialogAction(
            onPressed: onPrimaryPressed ?? () => Navigator.of(context).pop(),
            isDefaultAction: true,
            child: Text(
              primaryButtonText ?? 'OK',
              style: const TextStyle(
                color: CupertinoColors.systemBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // iOS-style Action Sheet
  static void showActionSheet(BuildContext context, {
    required String title,
    String? message,
    required List<CupertinoActionSheetAction> actions,
    bool showCancelButton = true,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        message: message != null
            ? Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                ),
              )
            : null,
        actions: actions,
        cancelButton: showCancelButton
            ? CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: CupertinoColors.systemBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  // iOS-style Loading Dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(radius: 15),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Dismiss Loading Dialog
  static void dismissLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}