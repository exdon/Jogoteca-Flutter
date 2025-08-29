import 'dart:convert';

class GameHelperCT {
  static bool getHasOptions(Map<String, dynamic> question) {
    final raw = question['hasOptions'];
    final options = question['options'];

    final fromFlag = raw == true || raw == 'true' || raw == 1;
    final fromOptions = (options is List && options.isNotEmpty) ||
        (options is String &&
            options.trim().startsWith('[') &&
            options.trim().endsWith(']') &&
            (jsonDecode(options) as List).isNotEmpty);

    return fromFlag || fromOptions;
  }

}