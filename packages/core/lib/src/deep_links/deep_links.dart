/// Deep-link parsing for the native EasyFleet intent filter
/// `https://app.easyfleet.in/trip/{tripId}`.
abstract final class DeepLinks {
  static final RegExp _tripPath = RegExp(r'^/trip/([^/]+)/?$');

  /// Returns the trip id when [uri] is an EasyFleet trip deep link.
  static String? tripIdFromUri(Uri uri) {
    final match = _tripPath.firstMatch(uri.path);
    if (match == null) return null;
    final host = uri.host.toLowerCase();
    if (host != 'app.easyfleet.in' && host != 'localhost') return null;
    return Uri.decodeComponent(match.group(1)!);
  }
}
