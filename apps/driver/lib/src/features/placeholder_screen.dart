import 'package:easyfleet_ui/easyfleet_ui.dart';
import 'package:flutter/material.dart';

/// Phase 0 placeholder; replaced by the feature screens in Phase 1.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: EmptyView(
        icon: icon,
        message: '$title\n(implementation follows the adoption matrix)',
      ),
    );
  }
}
