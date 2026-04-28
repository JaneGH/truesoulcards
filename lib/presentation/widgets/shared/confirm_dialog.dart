import 'package:flutter/material.dart';

Future<bool?> showDeleteConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmText,
  required String cancelText,
}) {
  return showAdaptiveDialog<bool>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final cs = theme.colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              confirmText,
              style: theme.textTheme.labelLarge?.copyWith(color: cs.error),
            ),
          ),
        ],
      );
    },
  );
}
