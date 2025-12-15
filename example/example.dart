// ignore_for_file: avoid_print

import 'package:superjson/superjson.dart';

void main() {
  // Sample JSON structure representing a user with various data types
  Json userData = {
    'id': 12345,
    'username': 'john_doe',
    'email': 'john@example.com',
    'age': '30', // String that can be parsed as int
    'score': 95.7,
    'rating': '4.8', // String that can be parsed as double
    'isActive': 'true', // String that can be parsed as bool
    'isPremium': 1, // int that can be converted to bool
    'isVerified': false,
    'accountCreated': '2024-01-15T10:30:00Z', // ISO 8601
    'lastLogin': 'Mon, 15 Jan 2024 10:30:00 GMT', // RFC 1123
    'sessionDuration': 3600000, // Duration in milliseconds
    'timeout': '5000', // String duration in milliseconds
    'tags': ['dart', 'json', 'developer'],
    'permissions': [1, 'admin', true, 3.14], // Mixed types
    'settings': {'theme': 'dark', 'notifications': true, 'language': 'en'},
    'metadata': {'version': 1.0, 'build': 42},
  };

  print('User Info:\n');

  // Direct string value
  String username = userData.getString('username', orElse: 'unknown');
  print('Username: $username'); // john_doe

  // Non-existent key with default
  String middleName = userData.getString('middleName', orElse: 'N/A');
  print('Middle name: $middleName'); // N/A

  // Nullable string
  String? phone = userData.getStringOrNull('phone');
  print('Phone: $phone'); // null

  // Conversion from bool to string
  String verifiedAsString = userData.getString('isVerified', orElse: 'unknown');
  print('Verified as string: $verifiedAsString'); // false

  // Direct int value
  int id = userData.getInt('id', orElse: 0);
  print('ID: $id'); // 12345

  // Parsing string to int
  int age = userData.getInt('age', orElse: 0);
  print('Age: $age'); // 30

  // Non-existent key with default
  int followers = userData.getInt('followers', orElse: 0);
  print('Followers: $followers'); // 0

  // Converting double to int with rounding
  int scoreRounded = userData.getInt('score', orElse: 0, roundFn: (v) => v.round());
  print('Score rounded: $scoreRounded'); // 96

  int scoreFloor = userData.getInt('score', orElse: 0, roundFn: (v) => v.floor());
  print('Score floor: $scoreFloor'); // 95

  // Direct bool value
  bool isVerified = userData.getBool('isVerified', orElse: false);
  print('Is verified: $isVerified'); // false

  // Parsing string to bool (strict mode)
  bool isActive = userData.getBool('isActive', orElse: false, strict: true);
  print('Is active (strict): $isActive'); // true

  // Converting int to bool (1 = true, 0 = false)
  bool isPremium = userData.getBool('isPremium', orElse: false);
  print('Is premium: $isPremium'); // true

  // Non-existent key with default
  bool isAdmin = userData.getBool('isAdmin', orElse: false);
  print('Is admin: $isAdmin'); // false

  // Non-strict mode (allows 'yes', 'no', '1', '0')
  Json extraData = {'acceptTerms': 'yes', 'subscribe': '1'};
  bool acceptTerms = extraData.getBool('acceptTerms', orElse: false);
  print('Accept terms (non-strict): $acceptTerms'); // true

  bool subscribe = extraData.getBool('subscribe', orElse: false);
  print('Subscribe (non-strict): $subscribe'); // true

  // From int (milliseconds)
  Duration sessionDuration = userData.getDuration('sessionDuration', orElse: Duration.zero);
  print('Session duration: ${sessionDuration.inMinutes} minutes'); // 60 minutes

  // From string (parsed as milliseconds)
  Duration timeout = userData.getDuration('timeout', orElse: Duration.zero);
  print('Timeout: ${timeout.inSeconds} seconds'); // 5 seconds

  final now = DateTime.now();

  // ISO 8601 format
  DateTime accountCreated = userData.getDateTime('accountCreated', orElse: now);
  print('Account created: $accountCreated'); // 2024-01-15 10:30:00.000Z

  // RFC 1123 format
  DateTime lastLogin = userData.getDateTime('lastLogin', orElse: now);
  print('Last login: $lastLogin'); // 2024-01-15 10:30:00.000Z

  // List of strings
  List<String> tags = userData.getList<String>('tags', orElse: []);
  print('Tags: $tags'); // [dart, json, developer]

  // List with mixed types (filters by String)
  List<String> permissionStrings = userData.getList<String>('permissions', orElse: []);
  print('Permission strings: $permissionStrings'); // [admin]

  // List with mixed types (filters by int)
  List<int> permissionInts = userData.getList<int>('permissions', orElse: []);
  print('Permission ints: $permissionInts'); // [1, 3]

  // Get nested JSON object
  Json settings = userData.getJson('settings', orElse: {});
  print('Settings: $settings'); // {theme: dark, notifications: true, ...}

  String theme = settings.getString('theme', orElse: 'light');
  print('Theme: $theme'); // dark

  // Get typed Map
  Map<String, dynamic> metadata = userData.getMap<String, dynamic>('metadata', orElse: {});
  print('Metadata: $metadata'); // {version: 1.0, build: 42}

  // Get Map with specific types
  Map<String, String> stringSettings = {'theme': 'dark', 'language': 'en'};
  Json wrappedSettings = {'config': stringSettings};
  Map<String, String> config = wrappedSettings.getMap<String, String>('config', orElse: {});
  print('Config: $config'); // {theme: dark, language: en}

  Json nestedData = {
    'user': {
      'name': 'John',
      'address': {'city': 'New York', 'zip': '10001'},
      'contacts': {'email': 'john@example.com'},
    },
    'active': true,
  };

  // Flatten nested structure
  Json flattened = nestedData.flattened;
  print('Flattened: $flattened');
  // {user.name: John, user.address.city: New York, user.address.zip: 10001, ...}

  // Access flattened keys
  String city = flattened.getString('user.address.city', orElse: '');
  print('City from flattened: $city'); // New York

  // Unflatten back to nested structure
  Json unflattened = flattened.unflattened;
  print('Unflattened: $unflattened');
  // {user: {name: John, address: {city: New York, zip: 10001}, ...}, ...}

  User user = User(name: 'Alice', age: 28, email: 'alice@example.com', isActive: true);

  Json userJson = user.asJson;
  print('User as JSON: $userJson');
  // {name: Alice, age: 28, email: alice@example.com, isActive: true}
}

// Example class using Jsonizable mixin
class User with Jsonizable {
  final String name;
  final int age;
  final String email;
  final bool isActive;

  User({required this.name, required this.age, required this.email, required this.isActive});

  @override
  Json get asJson => {'name': name, 'age': age, 'email': email, 'isActive': isActive};
}
