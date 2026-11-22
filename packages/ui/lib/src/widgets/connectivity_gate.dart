import 'package:flutter/material.dart';

/// Shows a banner when offline; the wrapped content remains visible so cached
/// data can still be read (matching WonderMove's connectivity-gate behaviour).
class ConnectivityGate extends StatelessWidget {
  const ConnectivityGate({
    super.key,
    required this.connectivityStream,
    required this.offlineMessage,
    required this.child,
  });

  final Stream<bool> connectivityStream;
  final String offlineMessage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: connectivityStream,
      initialData: true,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        return Column(
          children: [
            if (!isOnline)
              Material(
                color: Theme.of(context).colorScheme.errorContainer,
                child: ListTile(
                  leading: Icon(
                    Icons.cloud_off_outlined,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  title: Text(
                    offlineMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
