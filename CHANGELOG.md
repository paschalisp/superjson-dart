## 1.0.5
* Added generic filtering method `filter()`.

## 1.0.4
 * Added generic `getValue<T>()` and `getValueOrNull<T>()` methods.
 * All get methods now accept fetching nested fields via dot notation (e.g. `json.getString("account.contact.name")`).

## 1.0.3
 * All non-nullable get methods now return a default value, depending on their type, instead of requiring the `orElse` argument.

## 1.0.2
 * Updated the `intl` dependency to the latest version (0.20.2).

## 1.0.1
 * Added timestamp parsing, compatible to Google's protobuf Timestamp format (`{seconds: x, nanos: y}`).

## 1.0.0
 * Initial public version (already matured in production applications).