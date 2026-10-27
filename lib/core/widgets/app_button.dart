import 'package:flutter/material.dart';

import 'app_loader.dart';

enum AppButtonVariant { filled, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.filled,
  });

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : variant = AppButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final callback = isLoading ? () {} : onPressed;
    final Widget child = isLoading
        ? AppLoader(
            size: 22,
            color: variant == AppButtonVariant.filled
                ? Theme.of(context).colorScheme.onPrimary
                : null,
          )
        : Text(label);
    final iconWidget = icon == null || isLoading ? null : Icon(icon, size: 20);

    final button = switch (variant) {
      AppButtonVariant.filled =>
        iconWidget == null
            ? FilledButton(onPressed: callback, child: child)
            : FilledButton.icon(
                onPressed: callback,
                icon: iconWidget,
                label: child,
              ),
      AppButtonVariant.outlined =>
        iconWidget == null
            ? OutlinedButton(onPressed: callback, child: child)
            : OutlinedButton.icon(
                onPressed: callback,
                icon: iconWidget,
                label: child,
              ),
      AppButtonVariant.text =>
        iconWidget == null
            ? TextButton(onPressed: callback, child: child)
            : TextButton.icon(
                onPressed: callback,
                icon: iconWidget,
                label: child,
              ),
    };
    return IgnorePointer(ignoring: isLoading, child: button);
  }
}
