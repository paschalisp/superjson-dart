library;

import 'package:intl/intl.dart';

typedef Json = Map<String, dynamic>;

mixin Jsonizable {
  Json get asJson;
}

extension JsonExtensions on Json {
  /// Returns the map entry for the specified [key].
  /// If not found, calls [orElse] if provided, otherwise throws.
  MapEntry<String, dynamic> getByKey(String key, {MapEntry<String, dynamic> Function()? orElse}) {
    return entries.firstWhere((element) => element.key == key, orElse: orElse);
  }

  /// Returns the string value for the specified [key], or [orElse] if not found or not convertible.
  String getString(String key, {String? orElse}) => getStringOrNull(key, orElse: orElse) ?? '';

  /// Returns the string value for the specified [key], or [orElse] if not found or not convertible.
  /// Attempts to convert numbers and booleans to strings.
  String? getStringOrNull(String key, {String? orElse}) {
    if (!containsKey(key)) return orElse;

    return switch (this[key]) {
      String _ => this[key],
      num _ => this[key].toString(),
      bool _ => this[key].toString(),
      _ => orElse,
    };
  }

  /// Returns the integer value for the specified [key], or [orElse] if not found or not convertible.
  /// Optionally applies [roundFn] to convert numeric values.
  int getInt(String key, {int? orElse, Function(num)? roundFn}) =>
      getIntOrNull(key, orElse: orElse, roundFn: roundFn) ?? 0;

  /// Returns the integer value for the specified [key], or [orElse] if not found or not convertible.
  /// Attempts to parse strings and optionally applies [roundFn] to convert numeric values.
  int? getIntOrNull(String key, {int? orElse, Function(num)? roundFn}) {
    if (!containsKey(key)) return orElse;

    return switch (this[key]) {
      int _ => this[key],
      String _ => int.tryParse(this[key]) ?? orElse,
      num _ => roundFn != null ? roundFn(this[key]) : orElse,
      _ => orElse,
    };
  }

  /// Returns the double value for the specified [key], or [orElse] if not found or not convertible.
  double getDouble(String key, {double? orElse}) => getDoubleOrNull(key, orElse: orElse) ?? 0.0;

  /// Returns the double value for the specified [key], or [orElse] if not found or not convertible.
  /// Attempts to parse strings and convert numeric values.
  double? getDoubleOrNull(String key, {double? orElse}) => containsKey(key)
      ? switch (this[key]) {
          double _ => this[key],
          int _ || num _ => this[key].toDouble(),
          String _ => double.tryParse(this[key]) ?? orElse,
          _ => orElse,
        }
      : orElse;

  /// Returns the boolean value for the specified [key], or [orElse] if not found or not convertible.
  /// When [strict] is true, only accepts 'true' and 'false' strings; otherwise accepts '1', '0', 'yes', 'no'.
  bool getBool(String key, {bool? orElse, bool strict = false}) =>
      getBoolOrNull(key, orElse: orElse, strict: strict) ?? false;

  /// Returns the boolean value for the specified [key], or [orElse] if not found or not convertible.
  /// When [strict] is true, only accepts 'true' and 'false' strings; otherwise accepts '1', '0', 'yes', 'no'.
  /// Also converts integers 1 and 0 to true and false respectively.
  bool? getBoolOrNull(String key, {bool? orElse, bool strict = true}) => containsKey(key)
      ? switch (this[key]) {
          bool _ => this[key],
          String _ =>
            strict
                ? (['true'].contains((this[key] as String).toLowerCase())
                      ? true
                      : ['false'].contains((this[key] as String).toLowerCase())
                      ? false
                      : orElse)
                : (['true', '1', 'yes'].contains((this[key] as String).toLowerCase())
                      ? true
                      : ['false', '0', 'no'].contains((this[key] as String).toLowerCase())
                      ? false
                      : orElse),
          int _ =>
            this[key] == 1
                ? true
                : this[key] == 0
                ? false
                : orElse,
          _ => orElse,
        }
      : orElse;

  /// Returns the duration value for the specified [key], or [orElse] if not found or not convertible.
  Duration getDuration(String key, {Duration? orElse}) => getDurationOrNull(key, orElse: orElse) ?? const Duration();

  /// Returns the duration value for the specified [key], or [orElse] if not found or not convertible.
  /// Interprets integer values as milliseconds.
  Duration? getDurationOrNull(String key, {Duration? orElse}) => containsKey(key)
      ? switch (this[key]) {
          int _ => Duration(milliseconds: this[key]),
          String _ => int.tryParse(this[key]) != null ? Duration(milliseconds: int.parse(this[key])) : orElse,
          _ => orElse,
        }
      : orElse;

  /// Merges the provided [json] into this Json object, overwriting existing keys.
  /// Returns this Json object for method chaining.
  Json applyJson(Json json) {
    for (var key in json.keys) {
      this[key] = json[key];
    }

    return this;
  }

  /// Returns the DateTime value for the specified [key], or [orElse] if not found or not parseable.
  DateTime getDateTime(String key, {DateTime? orElse}) =>
      getDateTimeOrNull(key, orElse: orElse) ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// Returns the DateTime value for the specified [key], or [orElse] if not found or not parseable.
  /// Attempts multiple date formats including ISO 8601 and common JSON date formats.
  DateTime? getDateTimeOrNull(String key, {DateTime? orElse}) {
    if (containsKey(key)) {
      if (this[key] is DateTime) return this[key];
      if (this[key] is String) {
        // 1st try: Parse directly
        var date = DateTime.tryParse(this[key]);
        if (date is DateTime) return date;

        // 2nd try: Parse by common JSON date format
        var dateFormat = DateFormat(r'''EEE, d MMM yyyy hh:mm:ss Z''');
        date = dateFormat.tryParse(this[key]);
        if (date is DateTime) return date;

        // 3nd try: Parse by common JSON date format without timezone
        dateFormat = DateFormat(r'''EEE, d MMM yyyy hh:mm:ss''');
        date = dateFormat.tryParse(this[key]);
        if (date is DateTime) return date;

        // 4th try: Parse by common JSON date format with milliseconds without timezone
        dateFormat = DateFormat(r'''EEE, d MMM yyyy hh:mm:ss.SSS''');
        date = dateFormat.tryParse(this[key]);
        if (date is DateTime) return date;
      }
    }

    return orElse;
  }

  /// Returns the DateTime value from a Google protobuf Timestamp format for the specified [key], or [orElse] if not found or invalid.
  DateTime getTimestamp(String key, {DateTime? orElse}) =>
      getTimestampOrNull(key, orElse: orElse) ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// Returns the DateTime value from a Google protobuf Timestamp format for the specified [key], or [orElse] if not found or invalid.
  /// Expects a Json object with 'seconds' and 'nanos' fields.
  DateTime? getTimestampOrNull(String key, {DateTime? orElse}) {
    if (containsKey(key)) {
      if (this[key] is Json) {
        try {
          return DateTime.fromMillisecondsSinceEpoch(
            this[key]['seconds'].toInt() * 1000 + (this[key]['nanos'] ~/ 1000000),
            isUtc: true,
          ).toLocal();
        } catch (_) {}
      }
    }

    return orElse;
  }

  /// Returns a typed list for the specified [key], or [orElse] if not found or not a list.
  List<T> getList<T>(String key, {List<T>? orElse}) => getListOrNull(key, orElse: orElse) ?? <T>[];

  /// Returns a typed list for the specified [key], or [orElse] if not found or not a list.
  /// Filters elements to only include those matching type [T].
  List<T>? getListOrNull<T>(String key, {List<T>? orElse}) {
    if (containsKey(key) && this[key] is Iterable) {
      return (this[key] as Iterable).whereType<T>().toList();
    }

    return orElse;
  }

  /// Returns a Json object for the specified [key], or [orElse] if not found or not a map.
  Json getJson(String key, {Json? orElse}) {
    if (containsKey(key) && this[key] is Map) {
      return Map<String, dynamic>.from(this[key]);
    }

    return orElse ?? {};
  }

  /// Returns a typed map for the specified [key], or [orElse] if not found or not a map.
  Map<T, V> getMap<T, V>(String key, {Map<T, V>? orElse}) {
    if (containsKey(key) && this[key] is Map) {
      return this[key];
    }

    return orElse ?? <T, V>{};
  }

  /// Returns a flattened version of the Json structure with any sub-keys separated with a dot (.) from their parent keys.
  Json get flattened {
    Json j = {};

    for (final key in keys) {
      if (this[key] is Json) {
        Json map = (this[key] as Json).flattened;
        for (final sub in map.keys) {
          j['$key.$sub'] = map[sub];
        }
      } else if (this[key] is Jsonizable) {
        Json map = (this[key] as Jsonizable).asJson.flattened;
        for (final sub in map.keys) {
          j['$key.$sub'] = map[sub];
        }
      } else {
        j[key] = this[key];
      }
    }

    return j;
  }

  /// Returns the original version of a previously flattened Json structure.
  Json get unflattened {
    Json j = {};

    /// Holds all prefixes that have been already unflattened
    List<String> processed = [];

    for (final key in keys) {
      if (key.contains('.') && !key.startsWith('.')) {
        final prefix = key.substring(0, key.indexOf('.'));
        if (processed.contains(prefix)) continue;

        var json = unflatten(prefix).unflattened;
        j[prefix] = json;

        processed.add(prefix);
      } else {
        // Add plain key/value
        j[key] = this[key];
      }
    }

    return j;
  }

  /// Returns a subset of the Json structure containing only keys prefixed with the given [prefix] followed by a dot (.).
  /// The prefix is removed from the resulting keys.
  Json unflatten(String prefix) {
    Json j = {};

    for (final key in keys) {
      if (key.startsWith('$prefix.')) {
        final sub = key.substring(prefix.length + 1);

        j[sub] = this[key];
      }
    }

    return j;
  }
}

extension DateJsonExtensions on DateTime {
  /// Returns the DateTime as an ISO 8601 string in UTC format.
  String get asJsonFormat => toUtc().toIso8601String();

  /// Returns the DateTime as a date-only string in ISO 8601 format (YYYY-MM-DD).
  String get asJsonDateOnlyFormat => toIso8601String().substring(0, 10);

  /// Converts the date/time in Google's protobuf Timestamp compatible format.
  Json get asJsonTimestamp => {
    'seconds': millisecondsSinceEpoch ~/ 1000,
    'nanos': (millisecondsSinceEpoch % 1000) * 1000000,
  };
}

extension DurationJsonExtensions on Duration {
  /// Returns the duration as an integer representing milliseconds.
  int get asJson => inMilliseconds;
}
