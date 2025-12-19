## 1.0.3
 * All non-nullable getXXX() methods now return a default value (see the list) instead of requiring the `orElse` argument.
   * getString() -> ''
   * getInt() -> 0
   * getDouble() -> 0.0
   * getBool() -> false
   * getDateTime() -> DateTime.fromMillisecondsSinceEpoch(0)
   * getTimestamp() -> DateTime.fromMillisecondsSinceEpoch(0)
   * getDuration() -> Duration()
   * getList<T>() -> []
   * getJson() -> {}
   * getMap<T, V>() -> {}

## 1.0.2
 * Updated the `intl` dependency to the latest version (0.20.2).

## 1.0.1
 * Added timestamp parsing, compatible to Google's protobuf Timestamp format (`{seconds: x, nanos: y}`).

## 1.0.0
 * Initial public version (already matured in production applications).