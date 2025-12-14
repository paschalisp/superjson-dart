library;

import 'package:intl/intl.dart';

typedef Json = Map<String, dynamic>;

mixin Jsonizable {
  Json get asJson;
}

extension JsonExtensions on Json {
  MapEntry<String, dynamic> getByKey(String key, {MapEntry<String, dynamic> Function()? orElse}) {
    return entries.firstWhere((element) => element.key == key, orElse: orElse);
  }

  String getString(String key, {required String orElse}) => getStringOrNull(key, orElse: orElse) as String;

  String? getStringOrNull(String key, {String? orElse}) {
    if (!containsKey(key)) return orElse;

    return switch (this[key]) {
      String _ => this[key],
      num _ => this[key].toString(),
      bool _ => this[key].toString(),
      _ => orElse,
    };
  }

  int getInt(String key, {required int orElse, Function(num)? roundFn}) =>
      getIntOrNull(key, orElse: orElse, roundFn: roundFn) as int;

  int? getIntOrNull(String key, {int? orElse, Function(num)? roundFn}) {
    if (!containsKey(key)) return orElse;

    return switch (this[key]) {
      int _ => this[key],
      String _ => int.tryParse(this[key]) ?? orElse,
      num _ => roundFn != null ? roundFn(this[key]) : orElse,
      _ => orElse,
    };
  }

  double getDouble(String key, {required double orElse}) => getDoubleOrNull(key, orElse: orElse) as double;

  double? getDoubleOrNull(String key, {double? orElse}) => containsKey(key)
      ? switch (this[key]) {
          double _ => this[key],
          int _ || num _ => this[key].toDouble(),
          String _ => double.tryParse(this[key]) ?? orElse,
          _ => orElse,
        }
      : orElse;

  bool getBool(String key, {required bool orElse, bool strict = false}) =>
      getBoolOrNull(key, orElse: orElse, strict: strict) as bool;

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

  Duration getDuration(String key, {required Duration orElse}) => getDurationOrNull(key, orElse: orElse) as Duration;
  Duration? getDurationOrNull(String key, {Duration? orElse}) => containsKey(key)
      ? switch (this[key]) {
          int _ => Duration(milliseconds: this[key]),
          String _ => int.tryParse(this[key]) != null ? Duration(milliseconds: int.parse(this[key])) : orElse,
          _ => orElse,
        }
      : orElse;

  Json applyJson(Json json) {
    for (var key in json.keys) {
      this[key] = json[key];
    }

    return this;
  }

  DateTime getDateTime(String key, {required DateTime orElse}) => getDateTimeOrNull(key, orElse: orElse) as DateTime;

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

  List<T> getList<T>(String key, {required List<T> orElse}) => getListOrNull(key, orElse: orElse) as List<T>;

  List<T>? getListOrNull<T>(String key, {List<T>? orElse}) {
    if (containsKey(key) && this[key] is Iterable) {
      return (this[key] as Iterable).whereType<T>().toList();
    }

    return orElse;
  }

  Json getJson(String key, {required Json orElse}) {
    if (containsKey(key) && this[key] is Map) {
      return Map<String, dynamic>.from(this[key]);
    }

    return orElse;
  }

  Map<T, V> getMap<T, V>(String key, {required Map<T, V> orElse}) {
    if (containsKey(key) && this[key] is Map) {
      return this[key];
    }

    return orElse;
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

  /// Returns a subset of the Json structure containing only keys prefixed with the given value followed by a dot (.).
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
  String get asJsonFormat => toUtc().toIso8601String();
}

extension DurationJsonExtensions on Duration {
  int get asJson => inMilliseconds;
}
