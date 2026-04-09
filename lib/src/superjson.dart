library;

import 'package:intl/intl.dart';

typedef Json = Map<String, dynamic>;

mixin Jsonable {
  Json toJson();
}

extension JsonExtensions on Json {
  // region Get* methods
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
    final (json, property) = _deepestJson(key);
    if (!json.containsKey(property)) return orElse;

    return switch (json[property]) {
      String _ => json[property],
      num _ => json[property].toString(),
      bool _ => json[property].toString(),
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
    final (json, property) = _deepestJson(key);
    if (!json.containsKey(property)) return orElse;

    return switch (json[property]) {
      int _ => json[property],
      String _ => int.tryParse(json[property]) ?? orElse,
      num _ => roundFn != null ? roundFn(json[property]) : orElse,
      _ => orElse,
    };
  }

  /// Returns the double value for the specified [key], or [orElse] if not found or not convertible.
  double getDouble(String key, {double? orElse}) => getDoubleOrNull(key, orElse: orElse) ?? 0.0;

  /// Returns the double value for the specified [key], or [orElse] if not found or not convertible.
  /// Attempts to parse strings and convert numeric values.
  double? getDoubleOrNull(String key, {double? orElse}) {
    final (json, property) = _deepestJson(key);

    return json.containsKey(property)
        ? switch (json[property]) {
            double _ => json[property],
            int _ || num _ => json[property].toDouble(),
            String _ => double.tryParse(json[property]) ?? orElse,
            _ => orElse,
          }
        : orElse;
  }

  /// Returns the boolean value for the specified [key], or [orElse] if not found or not convertible.
  /// When [strict] is true, only accepts 'true' and 'false' strings; otherwise accepts '1', '0', 'yes', 'no'.
  bool getBool(String key, {bool? orElse, bool strict = false}) =>
      getBoolOrNull(key, orElse: orElse, strict: strict) ?? false;

  /// Returns the boolean value for the specified [key], or [orElse] if not found or not convertible.
  /// When [strict] is true, only accepts 'true' and 'false' strings; otherwise accepts '1', '0', 'yes', 'no'.
  /// Also converts integers 1 and 0 to true and false respectively.
  bool? getBoolOrNull(String key, {bool? orElse, bool strict = true}) {
    final (json, property) = _deepestJson(key);

    return json.containsKey(property)
        ? switch (json[property]) {
            bool _ => json[property],
            String _ =>
              strict
                  ? (['true'].contains((json[property] as String).toLowerCase())
                        ? true
                        : ['false'].contains((json[property] as String).toLowerCase())
                        ? false
                        : orElse)
                  : (['true', '1', 'yes'].contains((json[property] as String).toLowerCase())
                        ? true
                        : ['false', '0', 'no'].contains((json[property] as String).toLowerCase())
                        ? false
                        : orElse),
            int _ =>
              json[property] == 1
                  ? true
                  : json[property] == 0
                  ? false
                  : orElse,
            _ => orElse,
          }
        : orElse;
  }

  /// Returns the duration value for the specified [key], or [orElse] if not found or not convertible.
  Duration getDuration(String key, {Duration? orElse}) => getDurationOrNull(key, orElse: orElse) ?? const Duration();

  /// Returns the duration value for the specified [key], or [orElse] if not found or not convertible.
  /// Interprets integer values as milliseconds.
  Duration? getDurationOrNull(String key, {Duration? orElse}) {
    final (json, property) = _deepestJson(key);

    return json.containsKey(property)
        ? switch (json[property]) {
            Duration _ => json[property],
            int _ => Duration(milliseconds: json[property]),
            String _ =>
              int.tryParse(json[property]) != null ? Duration(milliseconds: int.parse(json[property])) : orElse,
            _ => orElse,
          }
        : orElse;
  }

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
    final (json, property) = _deepestJson(key);

    if (json.containsKey(property)) {
      if (json[property] is DateTime) return json[property];
      if (json[property] is String) {
        // 1st try: Parse directly
        var date = DateTime.tryParse(json[property]);
        if (date is DateTime) return date;

        // 2nd try: Parse by common JSON date format
        var dateFormat = DateFormat(r'''EEE, d MMM yyyy hh:mm:ss Z''');
        date = dateFormat.tryParse(json[property]);
        if (date is DateTime) return date;

        // 3nd try: Parse by common JSON date format without timezone
        dateFormat = DateFormat(r'''EEE, d MMM yyyy hh:mm:ss''');
        date = dateFormat.tryParse(json[property]);
        if (date is DateTime) return date;

        // 4th try: Parse by common JSON date format with milliseconds without timezone
        dateFormat = DateFormat(r'''EEE, d MMM yyyy hh:mm:ss.SSS''');
        date = dateFormat.tryParse(json[property]);
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
    final (json, property) = _deepestJson(key);

    if (json.containsKey(property)) {
      if (json[property] is Json) {
        try {
          return DateTime.fromMillisecondsSinceEpoch(
            json[property]['seconds'].toInt() * 1000 + (json[property]['nanos'] ~/ 1000000),
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
  List<T>? getListOrNull<T>(String key, {List<T>? orElse}) => getIterableOrNull(key, orElse: orElse)?.toList();

  /// Returns a typed Iterable for the specified [key], or [orElse] if not found or not a list.
  Iterable<T> getIterable<T>(String key, {Iterable<T>? orElse}) => getIterableOrNull(key, orElse: orElse) ?? <T>[];

  /// Returns a typed Iterable for the specified [key], or [orElse] if not found or not an iterable.
  /// Filters elements to only include those matching type [T].
  Iterable<T>? getIterableOrNull<T>(String key, {Iterable<T>? orElse}) {
    final (json, property) = _deepestJson(key);

    if (json.containsKey(property) && json[property] is Iterable) {
      return (json[property] as Iterable).whereType<T>();
    }

    return orElse;
  }

  /// Returns a Json object for the specified [key], or [orElse] if not found or not a Json value.
  Json getJson(String key, {Json? orElse}) => getJsonOrNull(key, orElse: orElse) ?? {};

  /// Returns a Json object for the specified [key], or [orElse] if not found or not a Json value.
  Json? getJsonOrNull(String key, {Json? orElse}) {
    final (json, property) = _deepestJson(key);

    if (json.containsKey(property) && json[property] is Json) {
      return Json.from(this[property]);
    }

    return orElse;
  }

  /// Returns a typed map for the specified [key], or [orElse] if not found or not a map.
  Map<T, V> getMap<T, V>(String key, {Map<T, V>? orElse}) => getMapOrNull<T, V>(key, orElse: orElse) ?? <T, V>{};

  /// Returns a typed map for the specified [key], or [orElse] if not found or not a map.
  Map<T, V>? getMapOrNull<T, V>(String key, {Map<T, V>? orElse}) {
    final (json, property) = _deepestJson(key);

    if (json.containsKey(property) && json[property] is Map) {
      return json[key];
    }

    return orElse;
  }

  /// Returns a typed value for the specified [key], optionally providing a non-null default value if not found or not convertible.
  /// If [orElse] is provided, it will be used as the fallback value; otherwise, the default value for the type is returned.
  /// Built-in supported T types are: [String], [int], [double], [bool], [DateTime], [Duration], [List], [Iterable], [Json], [Map].
  /// Throws an exception if type [T] is not one of the above supported types, no value is found, and no [orElse] fallback is provided.
  T getValue<T>(String key, {T? orElse}) {
    final value = getValueOrNull<T>(key, orElse: orElse);
    if (value == null) {
      if (T == String) {
        return '' as T;
      } else if (T == int) {
        return 0 as T;
      } else if (T == double) {
        return 0.0 as T;
      } else if (T == bool) {
        return false as T;
      } else if (T == DateTime) {
        return DateTime.fromMillisecondsSinceEpoch(0) as T;
      } else if (T == Duration) {
        return const Duration() as T;
      } else if (T == List || T == Iterable) {
        return [] as T;
      } else if (T == Json) {
        return {} as T;
      } else {
        throw Exception('Cannot return the default value of an unknown type.');
      }
    }
    return value;
  }

  /// Returns a typed value for the specified [key], or [orElse] if not found or not convertible.
  /// Automatically determines the appropriate typed get method based on type [T].
  /// Built-in supported T types are: [String], [int], [double], [bool], [DateTime], [List], [Json], [Map<T,V>].
  T? getValueOrNull<T>(String key, {T? orElse}) {
    if (T == String) {
      return getStringOrNull(key, orElse: orElse as String?) as T?;
    } else if (T == int) {
      return getIntOrNull(key, orElse: orElse as int?) as T?;
    } else if (T == double) {
      return getDoubleOrNull(key, orElse: orElse as double?) as T?;
    } else if (T == bool) {
      return getBoolOrNull(key, orElse: orElse as bool?) as T?;
    } else if (T == DateTime) {
      return getDateTimeOrNull(key, orElse: orElse as DateTime?) as T?;
    } else if (T == Duration) {
      return getDurationOrNull(key, orElse: orElse as Duration?) as T?;
    } else if (T == List) {
      return getListOrNull(key, orElse: orElse as List?) as T?;
    } else if (T == Iterable) {
      return getIterableOrNull(key, orElse: orElse as Iterable?) as T?;
    } else if (T == Json) {
      return getJson(key, orElse: orElse as Json?) as T?;
    } else if (T == Map) {
      return getMap(key, orElse: orElse as Map?) as T?;
    } else {
      if (containsKey(key) && this[key] is T) {
        return this[key];
      }

      return orElse;
    }
  }

  /// Filters the provided [json] returning a subset with keys that match custom criteria.
  Json filter(bool Function(String key, dynamic value) fn) {
    Json ret = {};

    for (var key in keys) {
      if (!fn(key, this[key])) continue;

      ret[key] = this[key];
    }

    return ret;
  }

  // endregion

  // region Flattening getters
  /// Returns a flattened version of the Json structure with any sub-keys separated with a dot (.) from their parent keys.
  Json get flattened {
    Json j = {};

    for (final key in keys) {
      if (this[key] is Json) {
        Json map = (this[key] as Json).flattened;
        for (final sub in map.keys) {
          j['$key.$sub'] = map[sub];
        }
      } else if (this[key] is Jsonable) {
        Json map = (this[key] as Jsonable).toJson().flattened;
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

  // endregion

  // region Internal methods
  /// Returns the deepest accessible Json object by navigating through a dot-separated key path.
  ///
  /// Takes a [key] with dot notation (e.g., 'user.address.city') and returns the Json object
  /// at the deepest level that can be reached. If the key exists directly in this Json, returns
  /// this Json object. If any intermediate node in the path doesn't exist or is not a Json object,
  /// returns an empty Json.
  (Json, String) _deepestJson(String key) {
    if (containsKey(key)) return (this, key);

    List<String> nodes = key.split('.');
    if (nodes.length < 2) return (this, key);

    // The last key on the dot-notation path is the actual property name to query, so remove it before starting.
    final property = nodes.removeLast();

    Json json = this;
    for (final node in nodes) {
      if (!json.containsKey(node) || json[node] is! Json) return ({}, property);

      json = json[node];
    }

    return (json, property);
  }

  // endregion
}

extension DateJsonExtensions on DateTime {
  /// Returns the DateTime as an ISO 8601 string.
  /// When [dateOnly] is true, returns only the date portion (YYYY-MM-DD).
  /// When [dateOnly] is false, returns the full date and time in UTC format.
  String toJsonFormat({bool dateOnly = false}) =>
      dateOnly ? toIso8601String().substring(0, 10) : toUtc().toIso8601String();

  /// Returns the DateTime as an ISO 8601 string in UTC format.
  @Deprecated('Use toJsonFormat() instead')
  String get asJsonFormat => toUtc().toIso8601String();

  /// Returns the DateTime as a date-only string in ISO 8601 format (YYYY-MM-DD).
  @Deprecated('Use toJsonFormat() instead')
  String get asJsonDateOnlyFormat => toIso8601String().substring(0, 10);

  /// Converts and returns the date/time in Google's protobuf Timestamp compatible format.
  ///
  /// The returned JSON structure contains:
  /// * `seconds`: the number of seconds since Unix epoch
  /// * `nanos`: the fractional seconds in nanoseconds
  Json toProtobufJson() => {
    'seconds': millisecondsSinceEpoch ~/ 1000,
    'nanos': (millisecondsSinceEpoch % 1000) * 1000000,
  };

  /// Converts the date/time in Google's protobuf Timestamp compatible format.
  @Deprecated('Use toProtobufJson() instead')
  Json get asJsonTimestamp => {
    'seconds': millisecondsSinceEpoch ~/ 1000,
    'nanos': (millisecondsSinceEpoch % 1000) * 1000000,
  };
}

extension DurationJsonExtensions on Duration {
  /// Returns the duration as an integer representing milliseconds.
  int get asJson => inMilliseconds;
}
