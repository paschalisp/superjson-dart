A powerful Dart package that extends `Map<String, dynamic>` with strongly typed
getters and utilities for working with flat and nested JSON data structures.

[![pub package](https://img.shields.io/pub/v/superjson.svg)](https://pub.dev/packages/superjson)
[![package publisher](https://img.shields.io/pub/publisher/superjson.svg)](https://pub.dev/packages/superjson/publisher)

All package's functionality is built around an extension on the below typedef,
making it seamless to be integrated with existing code and allow working with JSON structures with ease.
```dart
typedef Json = Map<String, dynamic>;
```

## Getting started

Add `superjson` to your `pubspec.yaml`:

```yaml
dependencies:
  superjson: ^1.0.6
```

Then import it in your Dart code:

```dart
import 'package:superjson/superjson.dart';
```

## Usage

### Basic type-safe getters

```dart
final data = {
  'name': 'John Doe',
  'age': '25',  // String that can be parsed as int
  'metrics': {
    'score': 95.7
  },
  'settings': {
    'active': 'true',
    'flag': false
  }
};

// Get values with automatic type conversion and defaults
String name = data.getString('name', orElse: 'Unknown');  // 'John Doe'
int age = data.getInt('age');                             // 25 (parsed from string)
double score = data.getDouble('metrics.score');           // 95.7
double scoreInt = data.getInt('metrics.score',
        roundFn: (v) => v.round());                       // 96
bool active = data.getBool('settings.active');            // true
bool flag = data.getBool('settings.flag', orElse: true);  // false

// Get values via the generic getter
String name = data.getValue<String>('name');              // 'John Doe'
Json metrics = data.getValue<Json>('metrics');            // {'score': 95.7}
double score = data.getValue<double>('metrics.score');    // 95.7
```

### Nullable getters

```dart
final data = {'email': 'user@example.com'};
// Equivalent to:
// Json data = {'email': 'user@example.com'};
// and:
// Map<String, dynamic> data = {'email': 'user@example.com'};

String? email = data.getStringOrNull('email');     // 'user@example.com'
String? phone = data.getStringOrNull('phone');     // null
int? missing = data.getIntOrNull('missing', orElse: 100);  // 100 (custom default)
```

### DateTime parsing

```dart
final data = {
  'created': '2024-01-15T10:30:00Z',
  'updated': 'Mon, 15 Jan 2024 10:30:00 GMT',
};

DateTime created = data.getDateTime('created', orElse: DateTime.now());
DateTime? updated = data.getDateTimeOrNull('updated');

// Treat parsed date as UTC and optionally convert to local
// isUTC: true - treats the components as UTC
// convertToLocal: false - keeps it as UTC (otherwise converts to local)
DateTime utc = data.getDateTime('created', isUTC: true, convertToLocal: false);
```

### Collections

```dart
final data = {
  'tags': ['dart', 'json', 'parser'],
  'metadata': {'version': '1.0', 'author': 'Example'},
};

List<String> tags = data.getList<String>('tags', []);
Json metadata = data.getJson('metadata', {});
```

### Flattening and unflattening

```dart
final nested = {
  'user': {
    'name': 'John',
    'address': {
      'city': 'New York',
    }
  }
};

// Flatten nested structure
final flat = nested.flattened;
// {'user.name': 'John', 'user.address.city': 'New York'}

// Unflatten back to nested structure
final original = flat.unflattened;
// {'user': {'name': 'John', 'address': {'city': 'New York'}}}
```

### Custom JSON serialization with Jsonable

```dart
class User with Jsonable {
  final String name;
  final int age;

  User(this.name, this.age);

  @override
  Json toJson() => {'name': name, 'age': age};
}

User user = User('Alice', 30);
Json json = user.toJson();  // {'name': 'Alice', 'age': 30}
```

### Filtering JSON

```dart
final data = {
  'name': 'John',
  'age': 25,
  'city': 'New York',
};

// Filter based on key or value
final filtered = data.filter((key, value) => key != 'age');
// {'name': 'John', 'city': 'New York'}
```

For more detailed examples, see the `/example` folder.

## Features

### Extracting values from JSON
The package supports fetching the following types from JSON structures (see below for examples):

#### Generic type extraction

- **T (Generic)**
  - Methods: `getValue<T>()`, `getValueOrNull<T>()`
  - Extracts values of any type `T` directly from the JSON structure
  - Works with all supported types (String, int, double, bool, Duration, DateTime, List<T>, Json, Jsonable, Map<T, V>)
  - Supports nested field access via dot notation (e.g., `"user.profile.name"`)

#### Specific type extraction

All methods support nested field access via dot notation, e.g. `myjson.getString('user.profile.name')`, `myjson.getJson('user.profile')`, `myjson.getInt('metrics.performance.score')` etc.

- **String** 
  - Methods: `getString()`, `getStringOrNull()`
  - Can also convert from: 
    - `num`: `15` ➡ `"15"`
    - `bool`: `true` ➡ `"true"` 

- **int**
  - Methods: `getInt()`, `getIntOrNull()`
  - Can also convert from: 
    - `String` (with parsing): `"15"` ➡ `15`,
    - `num` (with optional rounding): `15.0` ➡ `15`

- **double**
  - Methods: `getDouble()`, `getDoubleOrNull()`
  - Can also convert from:
    - `int` / `num`: `100` ➡ `100.0`
    - `String` (with parsing): `"100.5"` ➡ `100.5`

- **bool**
  - Methods: `getBool()`, `getBoolOrNull()`
  - Can also convert from: 
    - `String` (`"true"` or `"false"`, or additionally '1'/'0'/'yes'/'no' if strict mode is disabled),
    - `int` (1 = true, 0 = false)
  - Supports strict and non-strict parsing modes (pass `strict: true/false` to the getter method)

- **Duration**
  - Methods: `getDuration()`, `getDurationOrNull()`
  - Converts from:
    - `int` (milliseconds)
    - `String` (parsed as milliseconds)

- **DateTime**
  - Methods: `getDateTime()`, `getDateTimeOrNull()`
  - Converts from:
    - `String` (ISO 8601, RFC 2822, RFC 1123 and custom formats)
    - `Map` (Google's protobuf Timestamp format: `{seconds: x, nanos: y}`)
  - Supports `isUTC` (treats parsed date as UTC) and `convertToLocal` (converts back to local if `isUTC` is true) arguments

- **List<T>**
  - Methods: `getList<T>()`, `getListOrNull<T>()`
  - Converts from: `Iterable` (filters by type `T`)

- **Json** (Map<String, dynamic>):
  - Methods: `getJson()`
  - Converts from:
    - `Map`

- **Map<T, V>**
  - Methods: `getMap<T, V>()`
  - Converts from:
    - `Map`

### Flattening and unflattening JSON

The package provides useful methods to flatten nested JSON structures into dot-notation keys and unflatten them back:

- **flattened** getter
  - Converts nested JSON structures into a flat map with dot-separated keys
  - Example: `{'user': {'name': 'John'}}` ➡ `{'user.name': 'John'}`
  - Recursively processes all nested `Json` objects and `Jsonizable` mixins

- **unflattened** getter
  - Reconstructs the original nested structure from a flattened JSON
  - Example: `{'user.name': 'John'}` ➡ `{'user': {'name': 'John'}}`
  - Automatically groups keys by their prefixes

- **unflatten(prefix)** method
  - Extracts a subset of keys matching a specific prefix
  - Returns a new `Json` object with the prefix removed from keys
  - Useful for isolating specific sections of a flattened structure

### Filtering JSON

- **filter(predicate)** method
  - Filters the JSON object returning a subset with keys that match custom criteria
  - Example: `json.filter((key, value) => key.startsWith('user_'))`

### Jsonable mixin

The `Jsonable` mixin provides a standard interface for converting custom Dart objects to JSON structures. Any class that
uses this mixin must implement the `toJson()` method, which returns a `Json` (Map<String, dynamic>) representation of
the object.

## Additional information

### Default values for the non-nullable getters:
When the specified key is missing from the JSON structure,
the non-nullable get methods return a default value, according to the table below.

| Method | Default Value |
   |--------|---------------|
| `getString()` | `''` |
| `getInt()` | `0` |
| `getDouble()` | `0.0` |
| `getBool()` | `false` |
| `getDateTime()` | `DateTime.fromMillisecondsSinceEpoch(0)` |
| `getTimestamp()` | `DateTime.fromMillisecondsSinceEpoch(0)` |
| `getDuration()` | `Duration()` |
| `getList<T>()` | `[]` |
| `getJson()` | `{}` |
| `getMap<T, V>()` | `{}` |

### Contributing

Please file feature requests and bugs at the [issue tracker][tracker].

### License

Licensed under the BSD-3-Clause License.

[tracker]: https://github.com/paschalisp/superjson-dart/issues/new