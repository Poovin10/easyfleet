import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_view.dart';
import 'error_view.dart';
import 'loading_view.dart';

/// Renders an [AsyncValue] with consistent loading, error and empty states.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.emptyMessage,
    this.isEmpty,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final String? emptyMessage;
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const LoadingView(),
      error: (error, _) =>
          ErrorView(message: friendlyError(error), onRetry: onRetry),
      data: (data) {
        if (isEmpty != null && isEmpty!(data)) {
          return EmptyView(message: emptyMessage);
        }
        return builder(data);
      },
    );
  }
}

/// Converts backend/SDK exceptions into user-readable messages.
String friendlyError(Object error) {
  var text = error.toString();
  const prefixes = [
    'PostgrestException(message: ',
    'AuthException(message: ',
    'Exception: ',
    'StateError: ',
    'UnsupportedError: ',
  ];
  for (final prefix in prefixes) {
    if (text.startsWith(prefix)) {
      text = text.substring(prefix.length);
      final comma = text.indexOf(', code:');
      if (comma > 0) text = text.substring(0, comma);
      break;
    }
  }
  if (text.contains('SUBSCRIPTION_REQUIRED')) {
    return 'An active EasyFleet subscription is required. Open Subscription to renew.';
  }
  if (text.contains('Failed host lookup') || text.contains('SocketException')) {
    return 'No internet connection. Changes are saved and will sync when you are back online.';
  }
  if (text.length > 220) text = '${text.substring(0, 220)}…';
  return text;
}

void showSuccessSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
}

void showErrorSnack(BuildContext context, Object error) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(friendlyError(error)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                )
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
