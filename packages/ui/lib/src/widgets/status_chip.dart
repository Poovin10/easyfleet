import 'package:easyfleet_core/easyfleet_core.dart';
import 'package:flutter/material.dart';

/// Colored status pill used across both apps.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.dense = false});

  final String status;
  final bool dense;

  static const _verified = AppColors.verified;
  static const _signal = AppColors.signal;
  static const _ink = AppColors.inkSoft;
  static const _danger = AppColors.danger;

  static const _colors = <String, Color>{
    // Verification / approval
    'VERIFIED': _verified,
    'APPROVED': _verified,
    'ACTIVE': _verified,
    'COMPLETED': _verified,
    'AVAILABLE': _verified,
    'PENDING': _signal,
    'SUBMITTED': _signal,
    'APPLIED': _signal,
    'TRIAL': _signal,
    'ASSIGNED': AppColors.slate,
    'IN_TRANSIT': AppColors.slate,
    'SHORTLISTED': AppColors.slate,
    'ON_TRIP': AppColors.slate,
    'OPEN': AppColors.slate,
    'PLANNED': _ink,
    'NOT_SUBMITTED': _ink,
    'UNBOUND': _ink,
    'FAILED': _danger,
    'REJECTED': _danger,
    'EXPIRED': _danger,
    'CANCELLED': _danger,
    'FAULTY': _danger,
    'REVIEW_REQUIRED': _signal,
    'CLOSURE_PENDING': _signal,
    'IN_MAINTENANCE': _signal,
    'OFFLINE': AppColors.slate,
    'WITHDRAWN': AppColors.slate,
    'ENDED': AppColors.slate,
    'FILLED': _ink,
    'APPOINTED': _ink,
  };

  static String label(String status) => status
      .replaceAll('_', ' ')
      .toLowerCase()
      .replaceRange(0, 1, status.isEmpty ? '' : status[0]);

  /// Semantic colors are tuned for the surface they sit on: amber darkens on
  /// paper, while slate and teal lift on the petrol-dark surface.
  static Color _readableColor(Color semantic, Brightness brightness) {
    final light = brightness == Brightness.light;
    if (semantic == AppColors.signal) {
      return light ? const Color(0xFF8A5A10) : AppColors.signal;
    }
    if (semantic == AppColors.slate) {
      return light ? AppColors.slate : const Color(0xFFB8C7C9);
    }
    if (semantic == AppColors.inkSoft) {
      return light ? AppColors.inkSoft : const Color(0xFFD6E2E4);
    }
    if (semantic == AppColors.verified) {
      return light ? AppColors.verified : const Color(0xFF63C2B4);
    }
    if (semantic == AppColors.danger && !light) {
      return const Color(0xFFF08A7B);
    }
    return semantic;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = _colors[status] ?? theme.colorScheme.primary;
    final color = _readableColor(semantic, theme.brightness);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 7 : 11,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: semantic.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: semantic.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: dense ? 4 : 6),
          Text(
            label(status),
            style: TextStyle(
              color: color,
              fontFamily: 'IBMPlexSans',
              fontSize: dense ? 10.5 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Verified form text field with optional numeric keyboard.
class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.numeric = false,
    this.decimal = false,
    this.maxLines = 1,
    this.enabled = true,
    this.prefixText,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool numeric;
  final bool decimal;
  final int maxLines;
  final bool enabled;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : numeric
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
      ),
      validator:
          validator ??
          (value) => value == null || value.trim().isEmpty
              ? '$label is required'
              : null,
    );
  }
}

String? positiveNumberValidator(String? value, {bool allowZero = false}) {
  if (value == null || value.trim().isEmpty) return 'Required';
  final parsed = double.tryParse(value.trim());
  if (parsed == null) return 'Enter a valid number';
  if (allowZero ? parsed < 0 : parsed <= 0) {
    return allowZero ? 'Cannot be negative' : 'Must be greater than zero';
  }
  return null;
}

String? optionalNumberValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = double.tryParse(value.trim());
  if (parsed == null) return 'Enter a valid number';
  if (parsed < 0) return 'Cannot be negative';
  return null;
}
