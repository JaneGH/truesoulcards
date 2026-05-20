import 'package:flutter/material.dart';

/// Centered loading or error UI for async data screens.
class AsyncStatusView extends StatelessWidget {
  const AsyncStatusView.loading({
    super.key,
    required this.message,
  })  : errorMessage = null,
        onRetry = null,
        retryLabel = null;

  const AsyncStatusView.error({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.retryLabel,
  })  : message = null;

  final String? message;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (message != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.45,
                color: theme.colorScheme.error,
              ),
            ),
            if (onRetry != null && retryLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
