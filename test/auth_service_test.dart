import 'package:flutter_test/flutter_test.dart';
import 'package:smart_waste/models/user_model.dart';

void main() {
  test('User model toMap works correctly', () {
    final user = AppUser(
      uid: '123',
      role: 'user',
      email: 'test@gmail.com',
      username: 'TestUser',
    );

    final map = user.toMap();

    expect(map['role'], 'user');
    expect(map['username'], 'TestUser');
  });
}