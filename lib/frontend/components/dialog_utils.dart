import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mat_finance/frontend/components/dialog_overlay_controller.dart';

/// Shows a dialog with a blurred background that fades in/out in sync with the dialog.
Future<T?> showBlurredDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Duration duration = const Duration(milliseconds: 200),
  double maxSigma = 10,
}) {
  // Mark overlay shown for full-app cover (titlebar included)
  DialogOverlayController.instance.push();
  final future = showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    // Build only the dialog content here; we'll compose the blur in transitionBuilder to ensure sync.
    pageBuilder: (ctx, animation, secondaryAnimation) => Center(child: Builder(builder: builder)),
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      final double t = Curves.easeOutCubic.transform(animation.value);
      final double sigma = maxSigma * t;
      return Stack(
        children: [
          // Animated blur + fade synced with dialog animation
          Positioned.fill(
            child: Opacity(
              opacity: t,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: Container(color: Colors.black.withValues(alpha: 0.1)),
              ),
            ),
          ),
          // Tap outside to dismiss
          if (barrierDismissible)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => Navigator.of(ctx).maybePop(),
                child: const SizedBox.shrink(),
              ),
            ),
          // Dialog content with a subtle scale/opacity animation
          Opacity(
            opacity: animation.value,
            child: Transform.scale(
              scale: 0.98 + 0.02 * t,
              child: child,
            ),
          ),
        ],
      );
    },
    transitionDuration: duration,
  );
  // Hide overlay when dialog completes (dismissed by any means)
  return future.whenComplete(() {
    DialogOverlayController.instance.pop();
  });
}


