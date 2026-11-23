import 'package:flutter/material.dart';

/// Colored status pill used across both apps.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.dense = false});

  final String status;
  final bool dense;

  static const _colors = <String, Color>{
    // Verification / approval
    'VERIFIED': Color(0xFF2E7D32),
    'APPROVED': Color(0xFF2E7D32),
    'ACTIVE': Color(0xFF2E7D32),
    'COMPLETED': Color(0xFF2E7D32),
    'AVAILABLE': Color(0xFF2E7D32),
    'PENDING': Color(0xFFF9A825),
    'SUBMITTED': Color(0xFFF9A825),
    'APPLIED': Color(0xFFF9A825),
    'TRIAL': Color(0xFFF9A825),
    'ASSIGNED': Color(0xFF1565C0),
    'IN_TRANSIT': Color(0xFF1565C0),
    'SHORTLISTED': Color(0xFF1565C0),
    'ON_TRIP': Color(0xFF1565C0),
    'OPEN': Color(0xFF1565C0),
    'PLANNED': Color(0xFF616161),
    'NOT_SUBMITTED': Color(0xFF616161),
    'UNBOUND': Color(0xFF616161),
    'FAILED': Color(0xFFC62828),
    'REJECTED': Color(0xFFC62828),
    'EXPIRED': Color(0xFFC62828),
    'CANCELLED': Color(0xFFC62828),
    'FAULTY': Color(0xFFC62828),
    'REVIEW_REQUIRED': Color(0xFFEF6C00),
    'CLOSURE_PENDING': Color(0xFFEF6C00),
    'IN_MAINTENANCE': Color(0xFFEF6C00),
    'OFFLINE': Color(0xFF757575),
    'WITHDRAWN': Color(0xFF757575),
    'ENDED': Color(0xFF757575),
    'FILLED': Color(0xFF6A1B9A),
    'APPOINTED': Color(0xFF6A1B9A),
  };

  static String label(String status) => status
      .replaceAll('_', ' ')
      .toLowerCase()
      .replaceRange(0, 1, status.isEmpty ? '' : status[0]);

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 10,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label(status),
        style: TextStyle(
          color: color,
          fontSize: dense ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
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
