import 'dart:convert';

import 'package:superjson/json.dart';
import 'package:test/test.dart';

void main() {
  group('getString tests', () {
    test('returns string value when key exists', () {
      final json = {'name': 'John Doe'};
      expect(json.getString('name', orElse: ''), 'John Doe');
    });

    test('returns default when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getString('missing', orElse: 'default'), 'default');
    });

    test('converts non-string types to string', () {
      final json = {'number': 42, 'bool': true};
      expect(json.getString('number', orElse: ''), '42');
      expect(json.getString('bool', orElse: ''), 'true');
    });

    test('handles null values with default', () {
      final json = {'key': null};
      expect(json.getString('key', orElse: 'default'), 'default');
    });

    test('handles empty string', () {
      final json = {'empty': ''};
      expect(json.getString('empty', orElse: 'default'), '');
    });
  });

  group('getStringOrNull tests', () {
    test('returns string value when key exists', () {
      final json = {'name': 'Jane'};
      expect(json.getStringOrNull('name'), 'Jane');
    });

    test('returns null when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getStringOrNull('missing'), null);
    });

    test('returns custom default when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getStringOrNull('missing', orElse: 'custom'), 'custom');
    });

    test('handles null values', () {
      final json = {'key': null};
      expect(json.getStringOrNull('key'), null);
    });

    test('converts non-string types to string', () {
      final json = {'number': 123};
      expect(json.getStringOrNull('number'), '123');
    });
  });

  group('getInt tests', () {
    test('returns int value when key exists', () {
      final json = {'age': 25};
      expect(json.getInt('age', orElse: 0), 25);
    });

    test('returns default when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getInt('missing', orElse: 100), 100);
    });

    test('parses string to int', () {
      final json = {'count': '42'};
      expect(json.getInt('count', orElse: 0), 42);
    });

    test('parses negative string to int', () {
      final json = {'value': '-15'};
      expect(json.getInt('value', orElse: 0), -15);
    });

    test('converts double to int', () {
      final json = {'score': 95.7};
      expect(json.getInt('score', orElse: 0, roundFn: (v) => v.ceil()), 96);
      expect(json.getInt('score', orElse: 0, roundFn: (v) => v.floor()), 95);
    });

    test('returns default for invalid string', () {
      final json = {'invalid': 'abc'};
      expect(json.getInt('invalid', orElse: 0), 0);
    });

    test('returns default for null value', () {
      final json = {'key': null};
      expect(json.getInt('key', orElse: -1), -1);
    });

    test('handles zero', () {
      final json = {'zero': 0};
      expect(json.getInt('zero', orElse: 10), 0);
    });
  });

  group('getIntOrNull tests', () {
    test('returns int value when key exists', () {
      final json = {'age': 30};
      expect(json.getIntOrNull('age'), 30);
    });

    test('returns null when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getIntOrNull('missing'), null);
    });

    test('returns custom default when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getIntOrNull('missing', orElse: 50), 50);
    });

    test('parses string to int', () {
      final json = {'count': '100'};
      expect(json.getIntOrNull('count'), 100);
    });

    test('returns null for invalid string', () {
      final json = {'invalid': 'xyz'};
      expect(json.getIntOrNull('invalid'), null);
    });

    test('handles null values', () {
      final json = {'key': null};
      expect(json.getIntOrNull('key'), null);
    });
  });

  group('getDouble tests', () {
    test('returns double value when key exists', () {
      final json = {'price': 19.99};
      expect(json.getDouble('price', orElse: 0.0), 19.99);
    });

    test('returns default when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getDouble('missing', orElse: 5.5), 5.5);
    });

    test('parses string to double', () {
      final json = {'value': '3.14'};
      expect(json.getDouble('value', orElse: 0.0), 3.14);
    });

    test('parses negative string to double', () {
      final json = {'value': '-2.5'};
      expect(json.getDouble('value', orElse: 0.0), -2.5);
    });

    test('converts int to double', () {
      final json = {'count': 42};
      expect(json.getDouble('count', orElse: 0.0), 42.0);
    });

    test('returns default for invalid string', () {
      final json = {'invalid': 'not a number'};
      expect(json.getDouble('invalid', orElse: 1.0), 1.0);
    });

    test('returns default for null value', () {
      final json = {'key': null};
      expect(json.getDouble('key', orElse: 0.0), 0.0);
    });

    test('handles zero', () {
      final json = {'zero': 0.0};
      expect(json.getDouble('zero', orElse: 10.0), 0.0);
    });
  });

  group('getDoubleOrNull tests', () {
    test('returns double value when key exists', () {
      final json = {'rate': 7.25};
      expect(json.getDoubleOrNull('rate'), 7.25);
    });

    test('returns null when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getDoubleOrNull('missing'), null);
    });

    test('returns custom default when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getDoubleOrNull('missing', orElse: 2.5), 2.5);
    });

    test('parses string to double', () {
      final json = {'value': '9.81'};
      expect(json.getDoubleOrNull('value'), 9.81);
    });

    test('returns null for invalid string', () {
      final json = {'invalid': 'abc'};
      expect(json.getDoubleOrNull('invalid'), null);
    });

    test('handles null values', () {
      final json = {'key': null};
      expect(json.getDoubleOrNull('key'), null);
    });
  });

  group('getBool tests', () {
    test('returns bool value when key exists', () {
      final json = {'active': true};
      expect(json.getBool('active', orElse: false), true);
    });

    test('returns default when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getBool('missing', orElse: false), false);
    });

    test('parses string "true" to true', () {
      final json = {'flag': 'true'};
      expect(json.getBool('flag', orElse: false), true);
    });

    test('parses string "false" to false', () {
      final json = {'flag': 'false'};
      expect(json.getBool('flag', orElse: true), false);
    });

    test('parses string "TRUE" to true (case insensitive) in non-strict mode', () {
      final json = {'flag': 'TRUE'};
      expect(json.getBool('flag', orElse: false, strict: false), true);
    });

    test('parses string "NO" to false (case insensitive) in non-strict mode', () {
      final json = {'valid': 'No'};
      expect(json.getBool('valid', orElse: true, strict: false), false);
    });

    test('parses string "1" to true', () {
      final json = {'number': 1};
      expect(json.getBool('number', orElse: false), true);
    });
  });

  test('returns default for null value', () {
    final json = {'key': null};
    expect(json.getBool('key', orElse: true), true);
    expect(json.getBool('key', orElse: false), false);
  });

  group('getBoolOrNull tests', () {
    test('returns bool value when key exists', () {
      final json = {'enabled': false};
      expect(json.getBoolOrNull('enabled'), false);
    });

    test('returns null when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getBoolOrNull('missing'), null);
    });

    test('returns custom default when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getBoolOrNull('missing', orElse: true), true);
    });

    test('parses string "true" to true', () {
      final json = {'flag': 'true'};
      expect(json.getBoolOrNull('flag'), true);
    });

    test('parses strings "1" and "yes" to true in non-strict mode', () {
      expect({'flag': '1'}.getBoolOrNull('flag', strict: false), true);
      expect({'flag': 'Yes'}.getBoolOrNull('flag', strict: false), true);
    });

    test('parses strings "0" and "no" to false in non-strict mode', () {
      expect({'flag': '0'}.getBoolOrNull('flag', strict: false), false);
      expect({'flag': 'no'}.getBoolOrNull('flag', strict: false), false);
    });

    test('returns null for non-strict values ("0", "1", "yes" and "no")', () {
      expect({'flag': '0'}.getBoolOrNull('flag'), null);
      expect({'flag': '1'}.getBoolOrNull('flag'), null);
      expect({'flag': 'yes'}.getBoolOrNull('flag'), null);
      expect({'flag': 'no'}.getBoolOrNull('flag'), null);
    });

    test('parses string "false" to false', () {
      final json = {'flag': 'false'};
      expect(json.getBoolOrNull('flag'), false);
    });

    test('returns false for invalid string', () {
      final json = {'invalid': 'maybe'};
      expect(json.getBoolOrNull('invalid'), null);
    });

    test('returns null for invalid int values', () {
      final json = {'number': -1};
      expect(json.getBoolOrNull('number'), null);
    });

    test('handles null values', () {
      final json = {'key': null};
      expect(json.getBoolOrNull('key'), null);
    });
  });

  group('getDateTime tests', () {
    final defaultDate = DateTime(2000, 1, 1);

    test('parses ISO 8601 format', () {
      final json = {'created': '2024-01-15T10:30:00Z'};
      final result = json.getDateTime('created', orElse: defaultDate);
      expect(result.year, 2024);
      expect(result.month, 1);
      expect(result.day, 15);
    });

    test('parses RFC 1123 format', () {
      final json = {'updated': 'Mon, 15 Jan 2024 10:30:00 GMT'};
      final result = json.getDateTime('updated', orElse: defaultDate);
      expect(result.year, 2024);
      expect(result.month, 1);
      expect(result.day, 15);
    });

    test('returns default when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getDateTime('missing', orElse: defaultDate), defaultDate);
    });

    test('returns default for invalid date string', () {
      final json = {'invalid': 'not a date'};
      expect(json.getDateTime('invalid', orElse: defaultDate), defaultDate);
    });

    test('returns default for null value', () {
      final json = {'key': null};
      expect(json.getDateTime('key', orElse: defaultDate), defaultDate);
    });

    test('handles DateTime object directly', () {
      final date = DateTime(2023, 6, 15);
      final json = {'date': date};
      expect(json.getDateTime('date', orElse: defaultDate), date);
    });
  });

  group('getDateTimeOrNull tests', () {
    test('parses ISO 8601 format', () {
      final json = {'timestamp': '2024-03-20T14:45:00Z'};
      final result = json.getDateTimeOrNull('timestamp');
      expect(result, isNotNull);
      expect(result!.year, 2024);
      expect(result.month, 3);
    });

    test('returns null when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getDateTimeOrNull('missing'), null);
    });

    test('returns custom default when key does not exist', () {
      final defaultDate = DateTime(2020, 5, 10);
      final json = <String, dynamic>{};
      expect(json.getDateTimeOrNull('missing', orElse: defaultDate), defaultDate);
    });

    test('returns null for invalid date string', () {
      final json = {'invalid': 'invalid date'};
      expect(json.getDateTimeOrNull('invalid'), null);
    });

    test('handles null values', () {
      final json = {'key': null};
      expect(json.getDateTimeOrNull('key'), null);
    });
  });

  group('getDuration tests', () {
    test('creates duration from milliseconds', () {
      final json = {'timeout': 5000};
      final result = json.getDuration('timeout', orElse: Duration.zero);
      expect(result.inMilliseconds, 5000);
    });

    test('returns default when key does not exist', () {
      final json = <String, dynamic>{};
      final defaultDuration = Duration(seconds: 30);
      expect(json.getDuration('missing', orElse: defaultDuration), defaultDuration);
    });

    test('parses string to int and creates duration', () {
      final json = {'delay': '1000'};
      final result = json.getDuration('delay', orElse: Duration.zero);
      expect(result.inMilliseconds, 1000);
    });

    test('returns default for invalid value', () {
      final json = {'invalid': 'abc'};
      final defaultDuration = Duration(seconds: 10);
      expect(json.getDuration('invalid', orElse: defaultDuration), defaultDuration);
    });

    test('returns default for null value', () {
      final json = {'key': null};
      final defaultDuration = Duration(minutes: 1);
      expect(json.getDuration('key', orElse: defaultDuration), defaultDuration);
    });

    test('handles zero duration', () {
      final json = {'zero': 0};
      expect(json.getDuration('zero', orElse: Duration(seconds: 1)), Duration.zero);
    });
  });

  group('getDurationOrNull tests', () {
    test('creates duration from milliseconds', () {
      final json = {'interval': 3600000};
      final result = json.getDurationOrNull('interval');
      expect(result, isNotNull);
      expect(result!.inHours, 1);
    });

    test('returns null when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getDurationOrNull('missing'), null);
    });

    test('returns custom default when key does not exist', () {
      final json = <String, dynamic>{};
      final defaultDuration = Duration(seconds: 45);
      expect(json.getDurationOrNull('missing', orElse: defaultDuration), defaultDuration);
    });

    test('returns null for invalid value', () {
      final json = {'invalid': 'not a number'};
      expect(json.getDurationOrNull('invalid'), null);
    });

    test('handles null values', () {
      final json = {'key': null};
      expect(json.getDurationOrNull('key'), null);
    });
  });

  group('getList tests', () {
    test('returns typed list when key exists', () {
      final json = {
        'tags': ['dart', 'json', 'parser'],
      };
      final result = json.getList<String>('tags', orElse: []);
      expect(result, ['dart', 'json', 'parser']);
    });

    test('returns default when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getList<String>('missing', orElse: ['default']), ['default']);
    });

    test('filters list by type', () {
      final json = {
        'mixed': [1, 'two', 3, 'four', 5],
      };
      final strings = json.getList<String>('mixed', orElse: []);
      expect(strings, ['two', 'four']);
      final ints = json.getList<int>('mixed', orElse: []);
      expect(ints, [1, 3, 5]);
    });

    test('returns empty list for non-list value', () {
      final json = {'notList': 'string'};
      expect(json.getList<String>('notList', orElse: []), []);
    });

    test('returns default for null value', () {
      final json = {'key': null};
      expect(json.getList<int>('key', orElse: [1, 2, 3]), [1, 2, 3]);
    });

    test('handles empty list', () {
      final json = {'empty': []};
      expect(json.getList<String>('empty', orElse: ['default']), []);
    });

    test('filters complex types', () {
      final json = {
        'items': [
          {'a': 1},
          'string',
          {'b': 2},
          123,
        ],
      };
      final maps = json.getList<Map>('items', orElse: []);
      expect(maps.length, 2);
    });
  });

  group('getListOrNull tests', () {
    test('returns typed list when key exists', () {
      final json = {
        'numbers': [1, 2, 3],
      };
      final result = json.getListOrNull<int>('numbers');
      expect(result, [1, 2, 3]);
    });

    test('returns null when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getListOrNull<String>('missing'), null);
    });

    test('returns custom default when key does not exist', () {
      final json = <String, dynamic>{};
      expect(json.getListOrNull<String>('missing', orElse: ['a', 'b']), ['a', 'b']);
    });

    test('filters list by type', () {
      final json = {
        'data': [true, 1, false, 2, true],
      };
      final bools = json.getListOrNull<bool>('data');
      expect(bools, [true, false, true]);
    });

    test('returns null for non-list value', () {
      final json = {'notList': 42};
      expect(json.getListOrNull<int>('notList'), null);
    });

    test('handles null values', () {
      final json = {'key': null};
      expect(json.getListOrNull<String>('key'), null);
    });
  });

  group('getJson tests', () {
    test('returns nested JSON when key exists', () {
      final json = {
        'user': {'name': 'John', 'age': 30},
      };
      final result = json.getJson('user', orElse: {});
      expect(result['name'], 'John');
      expect(result['age'], 30);
    });

    test('returns default when key does not exist', () {
      final json = <String, dynamic>{};
      final defaultJson = {'default': true};
      expect(json.getJson('missing', orElse: defaultJson), defaultJson);
    });

    test('returns empty map for non-map value', () {
      final json = {'notMap': 'string'};
      expect(json.getJson('notMap', orElse: {}), {});
    });

    test('returns default for null value', () {
      final json = {'key': null};
      final defaultJson = {'fallback': 'value'};
      expect(json.getJson('key', orElse: defaultJson), defaultJson);
    });

    test('handles deeply nested JSON', () {
      final json = {
        'level1': {
          'level2': {'level3': 'deep'},
        },
      };
      final result = json.getJson('level1', orElse: {});
      expect(result['level2'], isA<Map>());
    });

    test('handles empty JSON object', () {
      final json = {'empty': <String, dynamic>{}};
      expect(json.getJson('empty', orElse: {'default': true}), {});
    });
  });

  group('Flatten/unflatten tests', () {
    final json = {
      'a': 'a',
      'b': {
        'b1': 'b1',
        'b2': 'b2',
        'b3': {'b3a': 'b3a', 'b3b': 'b3b'},
      },
      '1': 1,
      'true': true,
    };

    test('Flatten/unflatten roundtrip preserves structure', () {
      expect(jsonEncode(json.flattened.unflattened), jsonEncode(json));
    });

    test('flattened produces correct dot notation keys', () {
      final flat = json.flattened;
      expect(flat['a'], 'a');
      expect(flat['b.b1'], 'b1');
      expect(flat['b.b2'], 'b2');
      expect(flat['b.b3.b3a'], 'b3a');
      expect(flat['b.b3.b3b'], 'b3b');
      expect(flat['1'], 1);
      expect(flat['true'], true);
    });

    test('unflattened reconstructs nested structure', () {
      final flat = {'user.name': 'Alice', 'user.address.city': 'NYC', 'user.address.zip': '10001'};
      final unflat = flat.unflattened;
      expect(unflat['user'], isA<Map>());
      expect(unflat['user']['name'], 'Alice');
      expect(unflat['user']['address'], isA<Map>());
      expect(unflat['user']['address']['city'], 'NYC');
    });

    test('handles empty map', () {
      final empty = <String, dynamic>{};
      expect(empty.flattened, {});
      expect(empty.unflattened, {});
    });

    test('handles single level map', () {
      final simple = {'a': 1, 'b': 2};
      expect(simple.flattened, simple);
      expect(simple.unflattened, simple);
    });

    test('handles deeply nested structure', () {
      final deep = {
        'l1': {
          'l2': {
            'l3': {'l4': 'deep'},
          },
        },
      };
      final flat = deep.flattened;
      expect(flat['l1.l2.l3.l4'], 'deep');
      expect(flat.unflattened, deep);
    });

    test('preserves non-map values during flatten', () {
      final mixed = {
        'string': 'value',
        'number': 42,
        'bool': true,
        'list': [1, 2, 3],
        'nested': {'key': 'value'},
      };
      final flat = mixed.flattened;
      expect(flat['string'], 'value');
      expect(flat['number'], 42);
      expect(flat['bool'], true);
      expect(flat['list'], [1, 2, 3]);
      expect(flat['nested.key'], 'value');
    });
  });

  group('Edge cases and boundary tests', () {
    test('handles very large integers', () {
      final json = {'bigInt': 9223372036854775807};
      expect(json.getInt('bigInt', orElse: 0), 9223372036854775807);
    });

    test('handles very small doubles', () {
      final json = {'tiny': 0.0000001};
      expect(json.getDouble('tiny', orElse: 0.0), closeTo(0.0000001, 0.00000001));
    });

    test('handles special double values', () {
      final json = {'inf': double.infinity, 'negInf': double.negativeInfinity};
      expect(json.getDouble('inf', orElse: 0.0), double.infinity);
      expect(json.getDouble('negInf', orElse: 0.0), double.negativeInfinity);
    });

    test('handles empty strings in parsing', () {
      final json = {'empty': ''};
      expect(json.getInt('empty', orElse: -1), -1);
      expect(json.getDouble('empty', orElse: -1.0), -1.0);
      expect(json.getBool('empty', orElse: true), true);
    });

    test('handles whitespace in string parsing', () {
      final json = {'spaces': '  42  ', 'tabs': '\t3.14\t'};
      expect(json.getInt('spaces', orElse: 0), 42);
      expect(json.getDouble('tabs', orElse: 0.0), 3.14);
    });

    test('handles mixed case boolean strings', () {
      final json = {'t1': 'True', 't2': 'TRUE', 'f1': 'False', 'f2': 'FALSE'};
      expect(json.getBool('t1', orElse: false), true);
      expect(json.getBool('t2', orElse: false), true);
      expect(json.getBool('f1', orElse: true), false);
      expect(json.getBool('f2', orElse: true), false);
    });

    test('handles list with all null elements', () {
      final json = {
        'nulls': [null, null, null],
      };
      expect(json.getList<String>('nulls', orElse: ['default']), []);
    });

    test('handles deeply nested null values', () {
      final json = {
        'a': {
          'b': {'c': null},
        },
      };
      final nested = json.getJson('a', orElse: {});
      final deepNested = nested.getJson('b', orElse: {});
      expect(deepNested.getStringOrNull('c'), null);
    });
  });
}
