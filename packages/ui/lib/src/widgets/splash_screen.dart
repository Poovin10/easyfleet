import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.appName});

  final String appName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_shipping,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(appName, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
