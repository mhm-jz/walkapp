import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';
import 'app_button.dart';
import 'app_card.dart';

abstract final class AppDialog {
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) =>
          AlertDialog(title: Text(title), content: content, actions: actions),
    );
  }
}

abstract final class AppBottomSheet {
  static Future<T?> show<T>(BuildContext context, {required Widget child}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            top: AppSpacing.sm,
            right: AppSpacing.xl,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
          ),
          child: child,
        ),
      ),
    );
  }
}

abstract final class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? scheme.error : null,
      ),
    );
  }
}

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({this.label, super.key});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label ?? 'Loading',
      child: const CircularProgressIndicator(),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _StateView(icon: icon, title: title, message: message);
  }
}

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.message,
    this.onRetry,
    this.compact = false,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final content = _StateView(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      message: message,
      color: scheme.error,
      action: onRetry == null
          ? null
          : AppButton(
              label: 'Try again',
              variant: AppButtonVariant.outlined,
              onPressed: onRetry,
            ),
    );
    return compact
        ? AppCard(color: scheme.errorContainer, child: content)
        : content;
  }
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.title,
    required this.message,
    this.color,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color? color;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 40, color: color),
        const SizedBox(height: AppSpacing.sm),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (action != null) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          action!,
        ],
      ],
    );
  }
}
