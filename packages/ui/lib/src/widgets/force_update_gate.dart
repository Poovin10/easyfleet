import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

/// Wraps the app and blocks usage when the minimum supported version is not met.
class ForceUpdateGate extends StatefulWidget {
  const ForceUpdateGate({
    super.key,
    required this.currentVersion,
    required this.minimumVersion,
    required this.child,
  });

  final String currentVersion;
  final String minimumVersion;
  final Widget child;

  @override
  State<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends State<ForceUpdateGate> {
  bool? _updateRequired;

  @override
  void initState() {
    super.initState();
    _updateRequired = _isOutdated(widget.currentVersion, widget.minimumVersion);
  }

  static bool _isOutdated(String current, String minimum) {
    final a = current.split('.').map(int.tryParse).whereType<int>().toList();
    final b = minimum.split('.').map(int.tryParse).whereType<int>().toList();
    for (var i = 0; i < 3; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av != bv) return av < bv;
    }
    return false;
  }

  Future<void> _requestUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } on Object catch (_) {
      // Play Store unavailable (e.g. debug build) — fall back to store URL.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_updateRequired == false) return widget.child;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.system_update, size: 56),
              const SizedBox(height: 16),
              Text(
                'A new version is required',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Install version ${widget.minimumVersion} or newer to continue.',
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _requestUpdate,
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
