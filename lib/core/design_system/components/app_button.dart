import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';

enum AppButtonVariant { primary, secondary, outlined, text, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final callback = isLoading ? null : onPressed;
    final foreground = switch (variant) {
      AppButtonVariant.secondary => Theme.of(
        context,
      ).colorScheme.onSecondaryContainer,
      AppButtonVariant.destructive => Theme.of(context).colorScheme.onError,
      _ => null,
    };
    final background = switch (variant) {
      AppButtonVariant.secondary => Theme.of(
        context,
      ).colorScheme.secondaryContainer,
      AppButtonVariant.destructive => Theme.of(context).colorScheme.error,
      _ => null,
    };
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isLoading)
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (icon != null)
          Icon(icon),
        if (isLoading || icon != null) const SizedBox(width: AppSpacing.sm),
        Flexible(child: Text(label)),
      ],
    );
    final style = ButtonStyle(
      backgroundColor: background == null
          ? null
          : WidgetStatePropertyAll(background),
      foregroundColor: foreground == null
          ? null
          : WidgetStatePropertyAll(foreground),
    );
    final animatedChild = AnimatedSwitcher(
      duration: AppDurations.fast,
      child: KeyedSubtree(
        key: ValueKey<String>(
          '$label-${icon?.codePoint}-${isLoading ? 'loading' : 'ready'}',
        ),
        child: child,
      ),
    );
    final button = switch (variant) {
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: callback,
        style: style,
        child: animatedChild,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: callback,
        style: style,
        child: animatedChild,
      ),
      _ => FilledButton(
        onPressed: callback,
        style: style,
        child: animatedChild,
      ),
    };
    return Semantics(
      liveRegion: isLoading,
      label: isLoading ? '$label, loading' : null,
      child: SizedBox(width: expanded ? double.infinity : null, child: button),
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: Icon(icon), tooltip: tooltip);
  }
}
