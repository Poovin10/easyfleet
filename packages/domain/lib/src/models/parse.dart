/// Tolerant row parsers for PostgREST snake_case responses.
library;

String? str(Object? v) => v?.toString();

String strReq(Object? v, [String fallback = '']) => v?.toString() ?? fallback;

double? dbl(Object? v) => v == null ? null : double.tryParse(v.toString());

int? integer(Object? v) => v == null ? null : int.tryParse(v.toString());

bool boolean(Object? v) =>
    v == true || v == 'true' || v == 1 || v == 't' || v == 'TRUE';

DateTime? dt(Object? v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

DateTime dtReq(Object? v) => dt(v) ?? DateTime.fromMillisecondsSinceEpoch(0);

DateTime? dateOnly(Object? v) {
  if (v == null) return null;
  final parsed = DateTime.tryParse(v.toString());
  return parsed == null
      ? null
      : DateTime(parsed.year, parsed.month, parsed.day);
}

List<String> strList(Object? v) {
  if (v is List) return v.map((e) => e.toString()).toList();
  return const [];
}

Map<String, dynamic> jsonMap(Object? v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return const {};
}
