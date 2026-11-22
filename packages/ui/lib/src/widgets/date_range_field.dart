import 'package:flutter/material.dart';

class DateRangeField extends StatelessWidget {
  const DateRangeField({
    super.key,
    required this.label,
    required this.range,
    required this.onChanged,
  });

  final String label;
  final DateTimeRange? range;
  final ValueChanged<DateTimeRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = range == null
        ? 'Select range'
        : '${MaterialLocalizations.of(context).formatShortDate(range!.start)} – '
              '${MaterialLocalizations.of(context).formatShortDate(range!.end)}';

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.date_range),
      ),
      child: InkWell(
        onTap: () async {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            initialDateRange: range,
          );
          if (picked != null && context.mounted) onChanged(picked);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(text),
        ),
      ),
    );
  }
}
