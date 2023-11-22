import 'dart:math';

import 'package:option_result/option_result.dart';

Random random = Random();

void main() async {
  // Get a user object from the database
  Result<User, String> user = await getUser(id: 12345);

  // If it's an Err type value, display the unwrapped error value and return
  if (user case Err(e: String error)) {
    print('Error retrieving user: $error');
    return;
  }

  // Try getting the user's email address
  Option<String> email = user.unwrap().email;

  // If the user has an email address, print it
  if (email case Some(v: String address)) {
    print('User email: $address');
  } else {
    print('User has no email set');
  }

  // Alternative to the above using a switch expression for pattern matching
  String message = switch (email) {
    Some(v: String address) => 'User email: $address',
    None() => 'User has no email set'
  };

  print(message);
}

/// Represents a user in a database
class User {
  int id;
  Option<String> email;
  User(this.id, this.email);
}

/// Simulate pulling a user from a database
Future<Result<User, String>> getUser({required int id}) async {
  await Future.delayed(Duration(milliseconds: 100));

  int randInt = random.nextInt(3);

  return switch (randInt) {
    0 => Ok(User(id, Some('foo$id@bar.com'))),
    1 => Ok(User(id, None())),
    2 => Err('User $id not found'),
    _ => Err('Something went wrong')
  };
}
