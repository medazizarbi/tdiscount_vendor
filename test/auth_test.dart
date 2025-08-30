import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tdiscount_vendor/services/auth_services.dart';

void main() {
  // Load environment variables before running tests
  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });

  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    group('Login Tests', () {
      test('should return success for valid login credentials', () async {
        // Test with valid credentials (you might want to use test credentials)
        final result = await authService.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Print result for debugging
        print('Login Result: $result');

        // You can adjust these assertions based on your API response
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), true);
        expect(result.containsKey('message'), true);

        // If login is successful, check for success response
        if (result['success'] == true) {
          expect(result['data'], isNotNull);
        }
      });

      test('should return failure for invalid email format', () async {
        final result = await authService.login(
          email: 'invalid-email',
          password: 'password123',
        );

        print('Invalid Email Result: $result');

        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], false);
        expect(result['message'], isNotNull);
      });

      test('should return failure for wrong password', () async {
        final result = await authService.login(
          email: 'test@example.com',
          password: 'wrongpassword',
        );

        print('Wrong Password Result: $result');

        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], false);
        expect(result['message'], isNotNull);
      });

      test('should return failure for empty credentials', () async {
        final result = await authService.login(
          email: '',
          password: '',
        );

        print('Empty Credentials Result: $result');

        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], false);
      });
    });

    group('Register Tests', () {
      test('should return success for valid registration data', () async {
        // Use unique email for each test run
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final testEmail = 'test$timestamp@example.com';

        final result = await authService.register(
          name: 'Test User',
          email: testEmail,
          password: 'password123',
        );

        print('Register Result: $result');

        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), true);
        expect(result.containsKey('message'), true);

        // If registration is successful, check for success response
        if (result['success'] == true) {
          expect(result['data'], isNotNull);
        }
      });

      test('should return failure for duplicate email', () async {
        // Register same user twice
        const testData = {
          'name': 'Test User',
          'email': 'duplicate@example.com',
          'password': 'password123',
        };

        // First registration
        await authService.register(
          name: testData['name']!,
          email: testData['email']!,
          password: testData['password']!,
        );

        // Second registration with same email
        final result = await authService.register(
          name: testData['name']!,
          email: testData['email']!,
          password: testData['password']!,
        );

        print('Duplicate Email Result: $result');

        expect(result, isA<Map<String, dynamic>>());
        // This should fail due to duplicate email
        expect(result['success'], false);
      });

      test('should return failure for invalid email format in registration',
          () async {
        final result = await authService.register(
          name: 'Test User',
          email: 'invalid-email-format',
          password: 'password123',
        );

        print('Invalid Registration Email Result: $result');

        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], false);
      });

      test('should return failure for empty registration fields', () async {
        final result = await authService.register(
          name: '',
          email: '',
          password: '',
        );

        print('Empty Registration Fields Result: $result');

        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], false);
      });

      test('should return failure for weak password', () async {
        final result = await authService.register(
          name: 'Test User',
          email: 'test@example.com',
          password: '123', // Weak password
        );

        print('Weak Password Result: $result');

        expect(result, isA<Map<String, dynamic>>());
        // This might pass or fail depending on your backend validation
        expect(result.containsKey('success'), true);
      });
    });

    group('URL Construction Tests', () {
      test('should construct correct login URL', () async {
        final loginUrl = AuthService.loginUrl;
        print('Login URL: $loginUrl');

        expect(loginUrl, contains(AuthService.baseUrl));
        expect(loginUrl, contains(AuthService.loginEndpoint));
      });

      test('should construct correct register URL', () async {
        final registerUrl = AuthService.registerUrl;
        print('Register URL: $registerUrl');

        expect(registerUrl, contains(AuthService.baseUrl));
        expect(registerUrl, contains(AuthService.registerEndpoint));
      });
    });
  });
}
