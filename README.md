A powerful Dart package that extends `Map<String, dynamic>` with strongly typed
getters and utilities for working with flat and nested JSON data structures.

[![pub package](https://img.shields.io/pub/v/superjson.svg)](https://pub.dev/packages/superjson)
[![package publisher](https://img.shields.io/pub/publisher/superjson.svg)](https://pub.dev/packages/superjson/publisher)

All package's functionality is built around an extension on the below typedef,
making it seamless to be integrated with existing code and allow working with JSON structures with ease.
```dart
typedef Json = Map<String, dynamic>;
```

## Features

### Extracting values from JSON
The package supports fetching the following types from JSON structures (see below for examples):

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

## Getting started

Add `superjson` to your `pubspec.yaml`:

```yaml
dependencies:
  superjson: ^1.0.0
```

Then import it in your Dart code:

```dart
import 'package:superjson/superjson.dart';
```

## Usage

### Basic type-safe getters

```dart
// or: Map<String, dynamic> data = {...}
Json data = {
  'name': 'John Doe',
  'age': '25',  // String that can be parsed as int
  'score': 95.7,
  'active': 'true',
  'flag': false,
};

// Get values with automatic type conversion and defaults
String name = data.getString('name', orElse: 'Unknown');  // 'John Doe'
int age = data.getInt('age', orElse: 0);                  // 25 (parsed from string)
double score = data.getDouble('score', orElse: 0.0);      // 95.7
double scoreInt = data.getInt('score', orElse: 0,
        roundFn: (v) => v.round());                       // 96
bool active = data.getBool('active', orElse: false);      // true
bool flag = data.getBool('flag', orElse: true);           // false
```

### Nullable getters

```dart
Json data = {'email': 'user@example.com'};

String? email = data.getStringOrNull('email');     // 'user@example.com'
String? phone = data.getStringOrNull('phone');     // null
int? missing = data.getIntOrNull('missing', orElse: 100);  // 100 (custom default)
```

### DateTime parsing

```dart
Json data = {
  'created': '2024-01-15T10:30:00Z',
  'updated': 'Mon, 15 Jan 2024 10:30:00 GMT',
};

DateTime created = data.getDateTime('created', DateTime.now());
DateTime? updated = data.getDateTimeOrNull('updated');
```

### Collections

```dart
Json data = {
  'tags': ['dart', 'json', 'parser'],
  'metadata': {'version': '1.0', 'author': 'Example'},
};

List<String> tags = data.getList<String>('tags', []);
Json metadata = data.getJson('metadata', {});
```

### Flattening and unflattening

```dart
Json nested = {
  'user': {
    'name': 'John',
    'address': {
      'city': 'New York',
    }
  }
};

// Flatten nested structure
Json flat = nested.flattened;
// {'user.name': 'John', 'user.address.city': 'New York'}

// Unflatten back to nested structure
Json original = flat.unflattened;
// {'user': {'name': 'John', 'address': {'city': 'New York'}}}
```

### Custom JSON serialization with Jsonizable

```dart
class User with Jsonizable {
  final String name;
  final int age;

  User(this.name, this.age);

  @override
  Json get asJson => {'name': name, 'age': age};
}

User user = User('Alice', 30);
Json json = user.asJson;  // {'name': 'Alice', 'age': 30}
```

For more detailed examples, see the `/example` folder.

## Additional information

### Contributing

Please file feature requests and bugs at the [issue tracker][tracker].

### License

Licensed under the BSD-3-Clause License. See the LICENSE.txt file for details.

[tracker]: https://github.com/paschalisp/superjson-dart/issues/new